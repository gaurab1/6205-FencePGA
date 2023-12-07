`timescale 1ns / 1ps
`default_nettype none

module top_level(
  input wire clk_100mhz,
  input wire [15:0] sw, //all 16 input slide switches
  input wire [3:0] btn, //all four momentary button switches
  output logic [15:0] led, //16 green output LEDs (located right above switches)
  output logic [2:0] rgb0, //rgb led
  output logic [2:0] rgb1, //rgb led
  output logic [2:0] hdmi_tx_p, //hdmi output signals (blue, green, red)
  output logic [2:0] hdmi_tx_n, //hdmi output signals (negatives)
  output logic hdmi_clk_p, hdmi_clk_n, //differential hdmi clock
  output logic [6:0] ss0_c,
  output logic [6:0] ss1_c,
  output logic [3:0] ss0_an,
  output logic [3:0] ss1_an,
  input wire [7:0] pmoda,
  input wire [7:0] pmodb,
  input wire [5:0] gpio,
  output logic pmodbclk,
  output logic pmodblock
  );
  assign led = sw; //for debugging
  //shut up those rgb LEDs (active high):
  assign rgb1= 0;
  assign rgb0 = 0;

  //have btnd control system reset
  logic sys_rst;
  assign sys_rst = btn[0];

  //variable for seven-segment module
  logic [6:0] ss_c;

  //Clocking Variables:
  logic clk_pixel, clk_5x; //clock lines (pixel clock and 1/2 tmds clock)
  logic locked; //locked signal (we'll leave unused but still hook it up)

  //Signals related to driving the video pipeline
  logic [10:0] hcount; //horizontal count
  logic [9:0] vcount; //vertical count
  logic vert_sync; //vertical sync signal
  logic hor_sync; //horizontal sync signal
  logic active_draw; //active draw signal
  logic new_frame; //new frame (use this to trigger center of mass calculations)
  logic [5:0] frame_count; //current frame


  //camera module: (see datasheet)
  logic cam_clk_buff, cam_clk_in; //returning camera clock
  logic vsync_buff, vsync_in; //vsync signals from camera
  logic href_buff, href_in; //href signals from camera
  logic [7:0] pixel_buff, pixel_in; //pixel lines from camera
  logic [15:0] cam_pixel; //16 bit 565 RGB image from camera
  logic valid_pixel; //indicates valid pixel from camera
  logic frame_done; //indicates completion of frame from camera

  //outputs of the recover module
  logic [15:0] pixel_data_rec; // pixel data from recovery module
  logic [10:0] hcount_rec; //hcount from recovery module
  logic [9:0] vcount_rec; //vcount from recovery module
  logic  data_valid_rec; //single-cycle (74.25 MHz) valid data from recovery module

  //output of the scaled modules
  logic [10:0] hcount_scaled; //scaled hcount for looking up camera frame pixel
  logic [9:0] vcount_scaled; //scaled vcount for looking up camera frame pixel
  logic valid_addr_scaled; //whether or not two values above are valid (or out of frame)

  //outputs of the rotation module
  logic [16:0] img_addr_rot; //result of image transformation rotation
  logic valid_addr_rot; //forward propagated valid_addr_scaled
  logic [1:0] valid_addr_rot_pipe; //pipelining variables in || with frame_buffer

  //values from the frame buffer:
  logic [15:0] frame_buff_raw; //output of frame buffer (direct)
  logic [15:0] frame_buff; //output of frame buffer OR black (based on pipeline valid)

  //remapped frame_buffer outputs with 8 bits for r, g, b
  logic [7:0] fb_red, fb_green, fb_blue;

  //output of rgb to ycrcb conversion (10 bits due to module):
  logic [9:0] y_full, cr_full, cb_full; //ycrcb conversion of full pixel
  //bottom 8 of y, cr, cb conversions:
  logic [7:0] y, cr, cb; //ycrcb conversion of full pixel

  //channel select module (select which of six color channels to mask):
  logic [2:0] channel_sel;
  logic [7:0] selected_channel; //selected channels
  //selected_channel could contain any of the six color channels depend on selection

  //threshold module (apply masking threshold):
  logic [7:0] lower_threshold;
  logic [7:0] upper_threshold;
  logic mask_shirt; //Whether or not thresholded pixel is 1 or 0
  logic mask_saber;

  // ir output
  logic [31:0] ir_out;
  logic [2:0] error_out;
  logic [3:0] state_out;

  //Center of Mass variables (tally all mask=1 pixels for a frame and calculate their center of mass)
  logic [11:0] x_com, x_com_calc, w_com, w_com_calc, x_com_calc_saber, x_com_saber; //long term x_com and output from module, resp
  logic [10:0] y_com, y_com_calc, h_com, h_com_calc, y_com_calc_saber, y_com_saber; //long term y_com and output from module, resp
  logic new_com, new_com_saber; //used to know when to update x_com and y_com ...

  //crosshair output:
  logic [7:0] ch_red, ch_green, ch_blue;


  //used with switches for display selections
  logic [1:0] display_choice;
  logic [1:0] target_choice;

  //final processed red, gren, blue for consumption in tmds module
  logic [7:0] red, green, blue;

  logic [9:0] tmds_10b [0:2]; //output of each TMDS encoder!
  logic tmds_signal [2:0]; //output of each TMDS serializer!

  //Clock domain crossing to synchronize the camera's clock
  //to be back on the 65MHz system clock, delayed by a clock cycle.
  always_ff @(posedge clk_pixel) begin
    cam_clk_buff <= pmodb[0]; //sync camera
    cam_clk_in <= cam_clk_buff;
    vsync_buff <= pmodb[1]; //sync vsync signal
    vsync_in <= vsync_buff;
    href_buff <= pmodb[2]; //sync href signal
    href_in <= href_buff;
    pixel_buff <= pmoda; //sync pixels
    pixel_in <= pixel_buff;
  end

  //clock manager...creates 74.25 MHz and 5 times 74.25 MHz for pixel and TMDS,respectively
  hdmi_clk_wiz_720p mhdmicw (
      .clk_pixel(clk_pixel),
      .clk_tmds(clk_5x),
      .reset(0),
      .locked(locked),
      .clk_ref(clk_100mhz)
  );

  //from week 04! (make sure you include in your hdl) (same as before)
  video_sig_gen mvg(
      .clk_pixel_in(clk_pixel),
      .rst_in(sys_rst),
      .hcount_out(hcount),
      .vcount_out(vcount),
      .vs_out(vert_sync),
      .hs_out(hor_sync),
      .ad_out(active_draw),
      .nf_out(new_frame),
      .fc_out(frame_count)
  );

  //Controls and Processes Camera information
  camera camera_m(
    .clk_pixel_in(clk_pixel),
    .pmodbclk(pmodbclk), //data lines in from camera
    .pmodblock(pmodblock), //
    //returned information from camera (raw):
    .cam_clk_in(cam_clk_in),
    .vsync_in(vsync_in),
    .href_in(href_in),
    .pixel_in(pixel_in),
    //output framed info from camera for processing:
    .pixel_out(cam_pixel), //16 bit 565 RGB pixel
    .pixel_valid_out(valid_pixel), //pixel valid signal
    .frame_done_out(frame_done) //single-cycle indicator of finished frame
  );

  //camera and recover module are kept separate since some users may eventually
  //want to add pre-processing on signal prior to framing into hcount/vcount-based
  //values.

  //The recover module takes in information from the camera
  // and sends out:
  // * 5-6-5 pixels of camera information
  // * corresponding hcount and vcount for that pixel
  // * single-cycle valid indicator
  recover recover_m (
    .valid_pixel_in(valid_pixel),
    .pixel_in(cam_pixel),
    .frame_done_in(frame_done),
    .system_clk_in(clk_pixel),
    .rst_in(sys_rst),
    .pixel_out(pixel_data_rec), //processed pixel data out
    .data_valid_out(data_valid_rec), //single-cycle valid indicator
    .hcount_out(hcount_rec), //corresponding hcount of camera pixel
    .vcount_out(vcount_rec) //corresponding vcount of camera pixel
  );

  //two-port BRAM used to hold image from camera.
  //because camera is producing video for 320 by 240 pixels at ~30 fps
  //but our display is running at 720p at 60 fps, there's no hope to have the
  //production and consumption of information be synchronized in this system
  //instead we use a frame buffer as a go-between. The camera places pixels in at
  //its own rate, and we pull them out for display at the 720p rate/requirement
  //this avoids the whole sync issue. It will however result in artifacts when you
  //introduce fast motion in front of the camera. These lines/tears in the image
  //are the result of unsynced frame-rewriting happening while displaying. It won't
  //matter for slow movement
  //also note the camera produces a 320*240 image, but we display it 240 by 320
  //(taken care of by the rotate module below).
  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(16), //each entry in this memory is 16 bits
    .RAM_DEPTH(320*240)) //there are 240*320 or 76800 entries for full frame
    frame_buffer (
    .addra(hcount_rec + 320*(240 - vcount_rec)), //pixels are stored using this math
    .clka(clk_pixel),
    .wea(data_valid_rec),
    .dina(pixel_data_rec),
    .ena(1'b1),
    .regcea(1'b1),
    .rsta(sys_rst),
    .douta(), //never read from this side
    .addrb(img_addr_rot),//transformed lookup pixel
    .dinb(16'b0),
    .clkb(clk_pixel),
    .web(1'b0),
    .enb(valid_addr_rot),
    .rstb(sys_rst),
    .regceb(1'b1),
    .doutb(frame_buff_raw)
  );

  //start of the full video pipeline is here...
  //hcount, vcount, etc... are used for coming up with what to draw.

  //first question, given an hcount,vcount, should we draw/not draw something from
  //the camera. Assume the camera image is normally a 240-by-320 (width, height)
  //image in the top left of the screen. Depending on inputs you may want to scale up
  // to either 480*640 or a horizontally stretched 960*640
  // valid_addr_out indicates if hcount/vcount within range of this scaling
  //scale_in specifies how much to scale up image:
  // * 'b00: factor of 1
  // * 'b01: undefined
  // * 'b10: factor of 4 in h and 2 in v
  // * 'b11: factor of 2
  scale(
    .scale_in({sw[0],btn[1]}),
    .hcount_in(hcount),
    .vcount_in(vcount),
    .scaled_hcount_out(hcount_scaled),
    .scaled_vcount_out(vcount_scaled),
    .valid_addr_out(valid_addr_scaled)
  );


  //Rotates and mirror-images Image to render correctly (pi/2 CCW rotate):
  // The output address should be fed right into the frame buffer for lookup
  rotate rotate_m (
    .clk_in(clk_pixel),
    .rst_in(sys_rst),
    .hcount_in(hcount_scaled),
    .vcount_in(vcount_scaled),
    .valid_addr_in(valid_addr_scaled),
    .pixel_addr_out(img_addr_rot),
    .valid_addr_out(valid_addr_rot)
    );

  //the Port B of the frame buffer would exist here.
  // The output of rotate is used to grab a pixel from it
  // however the output of the memory is always *something* even when we are
  // reading at address 0...so we need to know whether or not what we're getting
  // is legit data (within the bounds of the frame buffer's render)
  // we utilize valid_addr_rot for this, but have to pipeline it by two cycles
  // in order to make sure the valid signal is lined up in time with the signal
  // it is being used to validate:

  always_ff @(posedge clk_pixel)begin
    valid_addr_rot_pipe[0] <= valid_addr_rot;
    valid_addr_rot_pipe[1] <= valid_addr_rot_pipe[0];
  end
  assign frame_buff = valid_addr_rot_pipe[1]?frame_buff_raw:16'b0;

  //split fame_buff into 3 8 bit color channels (5:6:5 adjusted accordingly)
  assign fb_red = {frame_buff[15:11],3'b0};
  assign fb_green = {frame_buff[10:5], 2'b0};
  assign fb_blue = {frame_buff[4:0],3'b0};

  //Convert RGB of full pixel to YCrCb
  //See lecture 07 for YCrCb discussion.
  //Module has a 3 cycle latency
  rgb_to_ycrcb rgbtoycrcb_m(
    .clk_in(clk_pixel),
    .r_in(fb_red),
    .g_in(fb_green),
    .b_in(fb_blue),
    .y_out(y_full),
    .cr_out(cr_full),
    .cb_out(cb_full)
  );

  //take lower 8 of full outputs
  assign y = y_full[7:0];
  assign cr = cr_full[7:0];
  assign cb = cb_full[7:0];

  logic [7:0] r_in_pipe [2:0]; //PS1
  logic [7:0] g_in_pipe [2:0];
  logic [7:0] b_in_pipe [2:0];

  always_ff @(posedge clk_pixel)begin
    r_in_pipe[0] <= fb_red;
    g_in_pipe[0] <= fb_green;
    b_in_pipe[0] <= fb_blue;
    for (int i=1; i<3; i = i+1)begin
      r_in_pipe[i] <= r_in_pipe[i-1];
      g_in_pipe[i] <= g_in_pipe[i-1];
      b_in_pipe[i] <= b_in_pipe[i-1];
    end
  end
  assign channel_sel = sw[3:1];
  // * 3'b000: green
  // * 3'b001: red
  // * 3'b010: blue
  // * 3'b011: not valid
  // * 3'b100: y (luminance)
  // * 3'b101: Cr (Chroma Red)
  // * 3'b110: Cb (Chroma Blue)
  // * 3'b111: not valid
  //Channel Select: Takes in the full RGB and YCrCb information and
  // chooses one of them to output as an 8 bit value
  channel_select(
     .sel_in(channel_sel),
     .r_in(r_in_pipe[2]),   //PS1
     .g_in(g_in_pipe[2]),  
     .b_in(b_in_pipe[2]),   
     .y_in(y),
     .cr_in(cr),
     .cb_in(cb),
     .channel_out(selected_channel)
  );

  //threshold values used to determine what value  passes:
  assign lower_threshold = {sw[11:8],4'b0};
  assign upper_threshold = {sw[15:12],4'b0};

  //Thresholder: Takes in the full selected channedl and
  //based on upper and lower bounds provides a binary mask bit
  // * 1 if selected channel is within the bounds (inclusive)
  // * 0 if selected channel is not within the bounds
  threshold(
     .clk_in(clk_pixel),
     .rst_in(sys_rst),
     .pixel_in(selected_channel),
     .lower_bound_in(lower_threshold),             // 8'b00010000
     .upper_bound_in(upper_threshold),             // 8'b01111000
     .mask_out(mask_shirt) //single bit if pixel within mask.
  );

  threshold(
     .clk_in(clk_pixel),
     .rst_in(sys_rst),
     .pixel_in(cb),
     .lower_bound_in(8'b00001110),
     .upper_bound_in(8'b00100000),
     .mask_out(mask_saber) //single bit if pixel within mask.
  );

  //modified version of seven segment display for showing
  // thresholds and selected channel
  // lab05_ssc mssc(.clk_in(clk_pixel),
  //                .rst_in(sys_rst),
  //                .lt_in(lower_threshold),
  //                .ut_in(upper_threshold),
  //                .channel_sel_in(channel_sel),
  //                .cat_out(ss_c),
  //                .an_out({ss0_an, ss1_an})
  // );
  seven_segment_controller(.clk_in(clk_pixel),
                           .rst_in(sys_rst),
                           .val_in(ir_out),
                           .cat_out(ss_c),
                           .an_out({ss0_an, ss1_an}));
  assign ss0_c = ss_c; //control upper four digit's cathodes!
  assign ss1_c = ss_c; //same as above but for lower four digits!

  logic [10:0] h_count_pipe [6:0];
  logic [9:0] v_count_pipe [6:0];
  logic hor_sync_pipe [6:0];
  logic vert_sync_pipe [6:0];
  logic active_draw_pipe [6:0];
  logic new_frame_pipe [6:0];
  logic [7:0] ch_blue_pipe[6:0];
  logic [7:0] ch_green_pipe[6:0];
  logic [7:0] ch_red_pipe[6:0];
  always_ff @(posedge clk_pixel)begin
    h_count_pipe[0] <= hcount;
    v_count_pipe[0] <= vcount;
    hor_sync_pipe[0] <= hor_sync;
    vert_sync_pipe[0] <= vert_sync;
    active_draw_pipe[0] <= active_draw;
    new_frame_pipe[0] <= new_frame;
    ch_blue_pipe[0] <= ch_blue;
    ch_green_pipe[0] <= ch_green;
    ch_red_pipe[0] <= ch_red;
    for (int i=1; i<7; i = i+1)begin
      h_count_pipe[i] <= h_count_pipe[i-1];
      v_count_pipe[i] <= v_count_pipe[i-1];
      hor_sync_pipe[i] <= hor_sync_pipe[i-1];
      vert_sync_pipe[i] <= vert_sync_pipe[i-1];
      active_draw_pipe[i] <= active_draw_pipe[i-1];
      new_frame_pipe[i] <= new_frame_pipe[i-1];
      ch_blue_pipe[i] <= ch_blue_pipe[i-1];
      ch_green_pipe[i] <= ch_green_pipe[i-1];
      ch_red_pipe[i] <= ch_red_pipe[i-1];
    end
  end
  //Center of Mass Calculation:
  //using x_com_calc and y_com_calc values
  //Center of Mass:

  center_of_mass com_m(
    .clk_in(clk_pixel),
    .rst_in(sys_rst),
    .x_in(h_count_pipe[6]),  // (PS3)
    .y_in(v_count_pipe[6]), // (PS3)
    .valid_in(mask_saber), //aka threshold
    .tabulate_in((new_frame_pipe[6])),
    .x_out(x_com_calc_saber),
    .y_out(y_com_calc_saber),
    .valid_out(new_com_saber)
  );

  bounding_box bb(
    .clk_in(clk_pixel),
    .rst_in(sys_rst),
    .hcount_in(h_count_pipe[6]),  // (PS3)
    .vcount_in(v_count_pipe[6]), // (PS3)
    .valid_in(mask_shirt), //aka threshold
    .tabulate_in((new_frame_pipe[6])),
    .x_out(x_com_calc),
    .y_out(y_com_calc),
    .w_out(w_com_calc),
    .h_out(h_com_calc),
    .valid_out(new_com)
  );


  //grab logic for above
  //update center of mass x_com, y_com based on new_com signal
  always_ff @(posedge clk_pixel)begin
    if (sys_rst)begin
      x_com_saber <= 0;
      y_com_saber <= 0;
      x_com <= 50;
      y_com <= 50;
      w_com <= 0;
      h_com <= 0;
    end else begin
      if (new_com) begin
        x_com <= x_com_calc;
        y_com <= y_com_calc;
        w_com <= w_com_calc;
        h_com <= h_com_calc;
      end
      if (new_com_saber) begin
        x_com_saber <= x_com_calc_saber;
        y_com_saber <= y_com_calc_saber;
      end
    end
  end

  //Create Crosshair patter on center of mass:
  //0 cycle latency
  //TODO: Should be using output of (PS3)
  always_comb begin
    if (hcount == x_com_saber || vcount == y_com_saber) begin
      ch_red = 8'hF2;
      ch_green = 8'hF2;
      ch_blue = 8'hF2;
    end else begin
      ch_red   = ((((hcount + w_com) >= (x_com << 1)) && hcount < (w_com)) &&
                        (((vcount + h_com) >= (y_com << 1)) && vcount < (h_com)))?8'hFF:8'h00;
      ch_green = ((((hcount + w_com) >= (x_com << 1)) && hcount < (w_com)) &&
                        (((vcount + h_com) >= (y_com << 1)) && vcount < (h_com)))?8'hFF:8'h00;
      ch_blue  = ((((hcount + w_com) >= (x_com << 1)) && hcount < (w_com)) &&
                        (((vcount + h_com) >= (y_com << 1)) && vcount < (h_com)))?8'hFF:8'h00;
    end
  end

  ir_fsm irlol(.clk_in(clk_pixel), //clock in (74.25MHz)
          .rst_in(sys_rst), //reset in
          .ir_signal(pmodb[7]), //signal in
          .code_out(ir_out),
          .error_out(error_out), //output error codes for debugging
          .state_out(state_out)
        );

  assign display_choice = sw[5:4];
  assign target_choice =  sw[7:6];

  //choose what to display from the camera:
  // * 'b00:  normal camera out
  // * 'b01:  selected channel image in grayscale
  // * 'b10:  masked pixel (all on if 1, all off if 0)
  // * 'b11:  chroma channel with mask overtop as magenta
  //
  //then choose what to use with center of mass:
  // * 'b00: nothing
  // * 'b01: crosshair
  // * 'b10: sprite on top
  // * 'b11: nothing
  logic [7:0] r_in_pipe_1 [3:0];
  logic [7:0] g_in_pipe_1 [3:0];
  logic [7:0] b_in_pipe_1 [3:0];
  logic [7:0] selected_channel_pipe;
  logic [7:0] y_pipe;
  always_ff @(posedge clk_pixel)begin
    r_in_pipe_1[0] <= fb_red;
    g_in_pipe_1[0] <= fb_green;
    b_in_pipe_1[0] <= fb_blue;
    y_pipe <= y;
    selected_channel_pipe <= selected_channel;
    for (int i=1; i<4; i = i+1)begin
      r_in_pipe_1[i] <= r_in_pipe_1[i-1];
      g_in_pipe_1[i] <= g_in_pipe_1[i-1];
      b_in_pipe_1[i] <= b_in_pipe_1[i-1];
    end
  end

  

  // video_mux (
  //   .bg_in(display_choice), //choose background
  //   .target_in(target_choice), //choose target
  //   .camera_pixel_in({r_in_pipe_1[3], g_in_pipe_1[3], b_in_pipe_1[3]}), //PS2
  //   .camera_y_in(y_pipe), //needs (PS6)
  //   .channel_in(selected_channel_pipe), //needs (PS5)
  //   .thresholded_pixel_in(mask_shirt), //(PS4)
  //   .crosshair_in({ch_red_pipe[6], ch_green_pipe[6], ch_blue_pipe[6]}), // needs (PS8)
  //   .com_sprite_pixel_in(0), // needs (PS9) maybe?
  //   .pixel_out({red,green,blue}) //output to tmds
  // );

  display_module plswork (
    .hcount_in(h_count_pipe[6]),
    .vcount_in(v_count_pipe[6]),
    .nf_in(new_frame_pipe[6]),
    .player_box_x_in(x_com),
    .player_box_y_in(y_com),
    .player_box_xmax_in(w_com),
    .player_box_ymax_in(h_com),
    .player_saber_x_in(x_com_saber),
    .player_saber_y_in(y_com_saber),
    .opponent_box_x_in(20),
    .opponent_box_y_in(20),
    .opponent_box_xmax_in(30),
    .opponent_box_ymax_in(30),
    .opponent_saber_x_in(0),
    .opponent_saber_y_in(0),
    .pixel_out({red, green, blue})
  );

  //TODO: Appropriate signals below need to use outputs from PS7

  //three tmds_encoders (blue, green, red)
  tmds_encoder tmds_red(
	.clk_in(clk_pixel),
  .rst_in(sys_rst),
	.data_in(red),
  .control_in(2'b0),
	.ve_in(active_draw_pipe[6]),
	.tmds_out(tmds_10b[2]));

  tmds_encoder tmds_green(
	.clk_in(clk_pixel),
  .rst_in(sys_rst),
	.data_in(green),
  .control_in(2'b0),
	.ve_in(active_draw_pipe[6]),
	.tmds_out(tmds_10b[1]));

  tmds_encoder tmds_blue(
	.clk_in(clk_pixel),
  .rst_in(sys_rst),
	.data_in(blue),
  .control_in({vert_sync_pipe[6],hor_sync_pipe[6]}),
	.ve_in(active_draw_pipe[6]),
	.tmds_out(tmds_10b[0]));

  //four tmds_serializers (blue, green, red, and clock)
  tmds_serializer red_ser(
    .clk_pixel_in(clk_pixel),
    .clk_5x_in(clk_5x),
    .rst_in(sys_rst),
    .tmds_in(tmds_10b[2]),
    .tmds_out(tmds_signal[2]));

  tmds_serializer green_ser(
    .clk_pixel_in(clk_pixel),
    .clk_5x_in(clk_5x),
    .rst_in(sys_rst),
    .tmds_in(tmds_10b[1]),
    .tmds_out(tmds_signal[1]));

  tmds_serializer blue_ser(
    .clk_pixel_in(clk_pixel),
    .clk_5x_in(clk_5x),
    .rst_in(sys_rst),
    .tmds_in(tmds_10b[0]),
    .tmds_out(tmds_signal[0]));

  //output buffers generating differential signal:
  OBUFDS OBUFDS_blue (.I(tmds_signal[0]), .O(hdmi_tx_p[0]), .OB(hdmi_tx_n[0]));
  OBUFDS OBUFDS_green(.I(tmds_signal[1]), .O(hdmi_tx_p[1]), .OB(hdmi_tx_n[1]));
  OBUFDS OBUFDS_red  (.I(tmds_signal[2]), .O(hdmi_tx_p[2]), .OB(hdmi_tx_n[2]));
  OBUFDS OBUFDS_clock(.I(clk_pixel), .O(hdmi_clk_p), .OB(hdmi_clk_n));

endmodule // top_level


`default_nettype wire
