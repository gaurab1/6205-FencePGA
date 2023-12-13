`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module display_module (
  input wire clk_in,
  input wire rst_in,
  input wire [23:0] img_sprite_in,
  input wire [31:0] ir_in,
  input wire start_screen,
  input wire camera_sw,
  input wire [23:0] camera_pixel_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire nf_in,
  input wire [11:0] player_box_x_in,
  input wire [10:0] player_box_y_in,
  input wire [11:0] player_box_xmax_in,
  input wire [10:0] player_box_ymax_in,
  input wire [11:0] player_saber_x_in,
  input wire [10:0] player_saber_y_in,
  input wire [11:0] pre_saber_x_in,
  input wire [10:0] pre_saber_y_in,
  input wire [2:0] player_health_in,
  input wire [1:0] player_saber_state_in,
  input wire [11:0] player_attack_x_in,
  input wire [10:0] player_attack_y_in,
  input wire [11:0] opponent_box_x_in,
  input wire [10:0] opponent_box_y_in,
  input wire [11:0] opponent_box_xmax_in,
  input wire [10:0] opponent_box_ymax_in,
  input wire [11:0] opponent_saber_x_in,
  input wire [10:0] opponent_saber_y_in,
  input wire [2:0] opponent_health_in,
  input wire [1:0] opponent_saber_state_in,
  input wire [11:0] opponent_attack_x_in,
  input wire [10:0] opponent_attack_y_in,
  output logic [23:0] pixel_out
);
  
  logic border, display_start;
  logic [23:0] player_box, player_saber, opponent_box, opponent_saber, show_start, player_health, opponent_health, player_line, opponent_line;
  logic start;
  logic [11:0] player_saber_x;
  logic [10:0] player_saber_y;
  logic [23:0] player_saber_color, opponent_saber_color;
  logic player_active;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
        display_start <= 1;
        player_active <= 0;
    end else begin
      if (ir_in == 32'h20DF_5BA4 || ir_in == 32'h20DF_5AA5) begin
        display_start <= 0;
      end
      if (display_start == 1) begin
        player_saber_x <= pre_saber_x_in;
        player_saber_y <= pre_saber_y_in;
      end else begin
        player_saber_x <= player_saber_x_in;
        player_saber_y <= player_saber_y_in;
      end

      if (player_saber_state_in == 0) begin
        player_saber_color <= 24'hFF_FF_FF;
        player_active <= 0;
      end else if (player_saber_state_in == 1 || player_saber_state_in == 3) begin
        player_saber_color <= 24'h00_FF_00;
        player_active <= 1;
      end else begin
        player_saber_color <= 24'h00_00_FF;
      end

      if (opponent_saber_state_in == 0) begin
        opponent_saber_color <= 24'hFF_FF_FF;
        opponent_active <= 0;
      end else if (opponent_saber_state_in == 1 || opponent_saber_state_in == 3) begin
        opponent_saber_color <= 24'h00_FF_00;
        opponent_active <= 1;
      end else begin
        opponent_saber_color <= 24'h00_00_FF;
      end
    end
  end


  transparent_block_sprite player(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(player_box_x_in),
    .y_in(player_box_y_in),
    .xmax_in(player_box_xmax_in),
    .ymax_in(player_box_ymax_in),
    .red_out(player_box[23:16]),
    .green_out(player_box[15:8]),
    .blue_out(player_box[7:0]));

  display_health #(.COLOR(24'h00_00_FF)) playerhealth(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(200),
    .y_in(20),
    .health(player_health_in),
    .color_out(player_health)
  );

  display_health #(.COLOR(24'hFF_00_00)) opponenthealth(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(560),
    .y_in(20),
    .health(opponent_health_in),
    .color_out(opponent_health)
  );

  // low_line_sprite playerline (
  //   .clk_in(clk_in),
  //   .rst_in(rst_in),
  //   .hcount_in(hcount_in),
  //   .vcount_in(vcount_in),
  //   .x1_in(player_saber_x < player_attack_x_in : player_saber_x : player_attack_x_in),
  //   .x2_in(player_saber_x < player_attack_x_in : player_attack_x_in : player_saber_x),
  //   .y1_in(player_saber_x < player_attack_x_in : player_saber_y : player_attack_y_in),
  //   .y2_in(player_saber_x < player_attack_x_in : player_attack_y_in : player_saber_y),   
  //   .line_active(player_active),
  //   .red_out(player_line[23:16]),
  //   .green_out(player_line[15:8]),
  //   .blue_out(player_line[7:0])
  // );
  line_sprite playerline (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x1_in(player_attack_x_in),
    .x2_in(player_saber_x),
    .y1_in(player_attack_y_in),
    .y2_in(player_saber_y),   
    .line_active(player_active),
    .color_out(player_line)
  );

  line_sprite opponentline (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x1_in(opponent_attack_x_in),
    .x2_in(opponent_saber_x_in),
    .y1_in(opponent_attack_y_in),
    .y2_in(opponent_saber_y_in),   
    .line_active(opponent_active),
    .color_out(opponent_line)
  );

  trace_display playersaber(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .nf_in(nf_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(player_saber_x),
    .y_in(player_saber_y),
    .color_in(player_saber_color),
    .color_out(player_saber)
  );

  fixed_block_sprite opponentsaber(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(opponent_saber_x_in),
    .y_in(opponent_saber_y_in),
    .red_out(opponent_saber[23:16]),
    .green_out(opponent_saber[15:8]),
    .blue_out(opponent_saber[7:0])
  );

  block_sprite opp(
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in(opponent_box_x_in),
    .y_in(opponent_box_y_in),
    .xmax_in(opponent_box_xmax_in),
    .ymax_in(opponent_box_ymax_in),
    .red_out(opponent_box[23:16]),
    .green_out(opponent_box[15:8]),
    .blue_out(opponent_box[7:0]));

  start_display menu (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .img_sprite_in(img_sprite_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .display_out(show_start)
  );

  display_module_mux lol (
    .clk_in(clk_in),
    .game_border_in(border),
    .camera_pixel_in(camera_sw ? camera_pixel_in : 0),
    .start_display(display_start),
    .start_in(show_start),
    .player_box_in(player_box),
    .opponent_box_in(opponent_box),
    .player_saber_in(player_saber),
    .opponent_saber_in(opponent_saber),
    .player_health_in(player_health),
    .opponent_health_in(opponent_health),
    .player_line_in(player_line),
    .opponent_line_in(opponent_line),
    .pixel_out(pixel_out)
  );

  assign border = (hcount_in == 960 && vcount_in <= 640) || (vcount_in == 640 && hcount_in <= 960);

endmodule

`default_nettype wire
