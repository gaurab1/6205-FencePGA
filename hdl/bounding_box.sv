`timescale 1ns / 1ps
`default_nettype none

module bounding_box (
                         input wire clk_in,
                         input wire rst_in,
                         input wire [10:0] hcount_in,
                         input wire [9:0]  vcount_in,
                         input wire valid_in,
                         input wire tabulate_in,
                         output logic [10:0] x_out,
                         output logic [9:0] y_out,
                         output logic [10:0] w_out,
                         output logic [9:0] h_out,
                         output logic valid_out);

  parameter H_PIXELS = 960;
  parameter V_PIXELS = 640;
  //your design here!
  logic [10:0] x_com_calc, x_threshold;
  logic [9:0] y_com_calc, y_threshold;
  logic new_com, find_dims, data_x_out, data_y_out;

  center_of_mass com(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .x_in(hcount_in),  // (PS3)
    .y_in(vcount_in), // (PS3)
    .valid_in(valid_in), //aka threshold
    .tabulate_in(tabulate_in),
    .x_out(x_com_calc),
    .y_out(y_com_calc),
    .valid_out(new_com)
  );

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
        find_dims <= 0;
        x_threshold <= 10;
        y_threshold <= 5;
    end else begin
        if (new_com && (find_dims == 0)) begin
            find_dims <= 1;
            data_x_out <= 0;
            data_y_out <= 0;
            x_out <= x_com_calc;
            y_out <= y_com_calc;
            valid_out <= 0;
        end else if (find_dims) begin
            if (hcount_in == x_out && vcount_in > y_out && vcount_in < 720 && (data_y_out == 0)) begin
                y_threshold <= (y_threshold > 0 && (valid_in == 0)) ? y_threshold - 1: y_threshold;
                if (y_threshold == 0 || vcount_in >= V_PIXELS) begin
                    h_out <= vcount_in;
                    data_y_out <= 1;
                end
            end else if (vcount_in == y_out && hcount_in > x_out && (data_x_out == 0)) begin
                x_threshold <= (x_threshold > 0 && (valid_in == 0)) ? x_threshold - 1: x_threshold;
                if (x_threshold == 0 || hcount_in >= H_PIXELS) begin
                    w_out <= hcount_in;
                    data_x_out <= 1;
                end
            end else if ((data_y_out && data_x_out)) begin
                x_threshold <= 10;
                y_threshold <= 5;
                find_dims <= 0;
                valid_out <= 1;
            end
        end else begin
            valid_out <= 0;
        end
    end

  end

endmodule


`default_nettype wire
