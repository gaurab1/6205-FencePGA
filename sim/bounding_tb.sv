`timescale 1ns / 1ps
`default_nettype none

module bounding_tb;

    //make logics for inputs and outputs!
    logic clk_in;
    logic rst_in;
    logic [10:0] x_in;
    logic [9:0] y_in;
    logic valid_in;
    logic tabulate_in;
    logic [10:0] x_out, w_out;
    logic [9:0] y_out, h_out;
    logic valid_out;

    bounding_box bb(.clk_in(clk_in), .rst_in(rst_in),
                         .hcount_in(x_in),
                         .vcount_in(y_in),
                         .valid_in(valid_in),
                         .tabulate_in(tabulate_in),
                         .x_out(x_out),
                         .y_out(y_out),
                         .w_out(w_out),
                         .h_out(h_out),
                         .valid_out(valid_out));
    always begin
        #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk_in = !clk_in;
    end

    //initial block...this is our test simulation
    initial begin
        $dumpfile("bounding.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,bounding_tb); //store everything at the current level and below
        $display("Starting Sim"); //print nice message
        clk_in = 0; //initialize clk (super important)
        rst_in = 0; //initialize rst (super important)
        #10;
        rst_in = 1;
        #10;
        rst_in = 0;
        tabulate_in = 0;
        valid_in = 0;
        for (int i = 0; i < 3; i++) begin
            for (int x = 0; x < 1020; x++) begin
                for (int y = 0; y < 960; y++) begin
                    x_in = x;
                    y_in = y;
                    valid_in = (x > 50 && x < 200 && y > 50 && y < 200) ? 1 : 0;
                    #10;
                end
                #50;
            end
            tabulate_in = 1;
            #500;
            tabulate_in = 0;
        end

        $display("Finishing Sim"); //print nice message
        $finish;

    end
endmodule //counter_tb

`default_nettype wire