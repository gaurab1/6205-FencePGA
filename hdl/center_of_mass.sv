`timescale 1ns / 1ps
`default_nettype none

module center_of_mass (
                         input wire clk_in,
                         input wire rst_in,
                         input wire [10:0] x_in,
                         input wire [9:0]  y_in,
                         input wire valid_in,
                         input wire tabulate_in,
                         output logic [10:0] x_out,
                         output logic [9:0] y_out,
                         output logic valid_out);

  //your design here!
  logic [31:0] x_sum, y_sum, count, x_remainder, y_remainder, x_sum_copy, y_sum_copy, count_copy;
  logic data_valid_in, x_data_valid_out, y_data_valid_out, x_busy, y_busy, x_error, y_error, prev, x_done, y_done;


  divider x_division(.clk_in(clk_in),
           .rst_in(rst_in),
           .dividend_in(x_sum_copy),
           .divisor_in(count_copy),
           .data_valid_in(data_valid_in),
           .quotient_out(x_out),
           .remainder_out(x_remainder),
           .data_valid_out(x_data_valid_out),
           .error_out(x_error),
           .busy_out(x_busy));

  divider y_division(.clk_in(clk_in),
           .rst_in(rst_in),
           .dividend_in(y_sum_copy),
           .divisor_in(count_copy),
           .data_valid_in(data_valid_in),
           .quotient_out(y_out),
           .remainder_out(y_remainder),
           .data_valid_out(y_data_valid_out),
           .error_out(y_error),
           .busy_out(y_busy));
  
  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      x_sum <= 0;
      y_sum <= 0;
      count <= 0;
      data_valid_in <= 0;
      valid_out <= 0;
    end else begin
      if (valid_in) begin
        x_sum <= x_sum + x_in;
        y_sum <= y_sum + y_in;
        count <= count + 1;
      end
      if (tabulate_in && (prev == 0) && (count > 0)) begin
        x_sum_copy <= x_sum;
        y_sum_copy <= y_sum;
        count_copy <= count;
        data_valid_in <= 1;

        x_sum <= 0;
        y_sum <= 0;
        count <= 0;
        x_done <= 0;
        y_done <= 0;
      end else begin
        data_valid_in <= 0;
      end

      if ((x_data_valid_out && ~x_error)) begin
        x_done <= 1;
      end

      if ((y_data_valid_out && ~y_error)) begin
        y_done <= 1;
      end

      if ((x_done && y_done)) begin
        valid_out <= 1;
        x_done <= 0;
        y_done <= 0;
      end else begin
        valid_out <= 0;
      end

      prev <= tabulate_in;
    end

  end

endmodule


`default_nettype wire
