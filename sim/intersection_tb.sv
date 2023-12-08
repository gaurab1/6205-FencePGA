`timescale 1ns / 1ps
`timescale 1ns / 1ps
`default_nettype none
`include "hdl/types.svh"

module intersection_tb();
  logic [10:0] saber_start_x;
  logic [9:0] saber_start_y;
  logic [10:0] saber_current_x;
  logic [9:0] saber_current_y;
  location_t opponent;
  logic is_intersecting;
  logic expected_is_intersecting;
  logic [6:0] test_case;

  intersection_detector intersection_inst(
    .saber_start_x(saber_start_x),
    .saber_start_y(saber_start_y),
    .saber_current_x(saber_current_x),
    .saber_current_y(saber_current_y),
    .opponent(opponent),
    .is_intersecting(is_intersecting)
  );

  //initial block...this is our test simulation
  initial begin
    $dumpfile("intersection.vcd"); //file to store value change dump (vcd)
    $dumpvars(0, intersection_tb);
    $display("Starting Sim"); //print nice message at start
    #10;
    opponent = 63'b00100000000_0100000000_01000000000_1000000000_10101010101_0101010101;
    saber_start_x = 11'b00010000000;
    saber_start_y =  10'b0010000000;
    test_case = 1;

    #10;
    saber_current_x = 11'b00010000000;
    saber_current_y =  10'b0010000000;
    expected_is_intersecting = 1'b0;
    test_case = 2;

    #10;
    saber_current_x = 11'b00110000000;
    saber_current_y =  10'b0010000000;
    expected_is_intersecting = 1'b0;
    test_case = 3;
    
    #10;
    saber_current_x = 11'b01100000000;
    saber_current_y =  10'b0010000000;
    expected_is_intersecting = 1'b0;
    test_case = 4;

    #10;
    saber_current_x = 11'b00110000000;
    saber_current_y =  10'b0111000000;
    expected_is_intersecting = 1'b0;
    test_case = 5;

    #10;
    saber_current_x = 11'b01100000000;
    saber_current_y =  10'b0110000000;
    expected_is_intersecting = 1'b1;
    test_case = 6;

    #100;

    $display("Finishing Sim"); //print nice message at end
    $finish;
  end
endmodule
`default_nettype wire
