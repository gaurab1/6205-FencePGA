`timescale 1ns / 1ps
`default_nettype none
`include "hdl/types.svh"

module syncer_tb();
  localparam DATA_WIDTH = $bits(data_t);

  logic clk_in;
  logic rst_in;

  logic [88:0] data_to_send;

  // inputs from outside
  logic data_in, data_clk_in, sel_in;

  // inputs from same fpga
  location_t player_location;
  logic player_location_valid;

  // outputs to print
  location_t syncer_player_location;
  data_t opponent_data;
  logic syncer_data_valid;

  // SPI_RX.
  syncer syncer_inst(
    .clk_pixel_in(clk_in),
    .rst_in(rst_in),
    .location_in(player_location),
    .location_in_valid(player_location_valid),
    .data_in(data_in),
    .data_clk_in(data_clk_in),
    .sel_in(sel_in),
    .player_location_out(syncer_player_location),
    .opponent_data_out(opponent_data),
    .data_out_valid(syncer_data_valid)
  );

  always begin
      #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
      clk_in = !clk_in;
  end
  //initial block...this is our test simulation
  initial begin
    $dumpfile("syncer.vcd"); //file to store value change dump (vcd)
    $dumpvars(0, syncer_tb);
    $display("Starting Sim"); //print nice message at start
    clk_in = 0;
    rst_in = 0;
    sel_in = 1;
    #10;
    rst_in = 1;
    #10;
    rst_in = 0;
    #10;
    sel_in = 0;
    player_location_valid = 0;
    data_to_send = 89'b101_00000100001_1010101010_11111011111_0101010101_10101010101_0101010101_00_10101010101_0101010101;
    for (int i = 0; i < $bits(data_t); i=i+1) begin
      data_clk_in = 0;
      data_in = data_to_send[$bits(data_t)-1-i];
      #500;
      if (i == 15) begin
        data_clk_in = 1;
        #230;
        player_location_valid = 1'b1;
        player_location = 63'b11100100001_1111111010_11100011111_0101011101_10101010101_0101010101;
        #10;
        player_location_valid = 0;
        #260;
      end else begin
        data_clk_in = 1;
        #500;
      end
    end
    sel_in = 1;

    #100;

    #10;
    rst_in = 1;
    #10;
    rst_in = 0;
    #10;
    player_location_valid = 1'b1;
    player_location = 63'b00000100001_1111111010_11100011111_0101011101_10101010101_0101010101;
    #10;
    sel_in = 0;
    player_location_valid = 0;
    data_to_send = 89'b101_00011101101_1010101010_11111011111_0101010101_10101010101_0101010101_00_10101010101_0101010101;
    for (int i = 0; i < $bits(data_t); i=i+1) begin
      data_clk_in = 0;
      data_in = data_to_send[$bits(data_t)-1-i];
      #500;
      data_clk_in = 1;
      #500;
    end
    sel_in = 1;

    #100;

    #10;
    rst_in = 1;
    #10;
    rst_in = 0;
    #10;
    sel_in = 0;
    player_location_valid = 0;
    data_to_send = 89'b101_00000100001_1010101010_11111011011_0111011101_10101010101_0101010101_00_10101010101_0101010101;
    for (int i = 0; i < $bits(data_t); i=i+1) begin
      data_clk_in = 0;
      data_in = data_to_send[$bits(data_t)-1-i];
      #500;
      data_clk_in = 1;
      #500;
    end
    sel_in = 1;
    #10;
    player_location_valid = 1'b1;
    player_location = 63'b01010101011_1111111010_11100011111_0101011101_10101010101_0101010101;

    #100;

    $display("Finishing Sim"); //print nice message at end
    $finish;
  end
endmodule
`default_nettype wire
