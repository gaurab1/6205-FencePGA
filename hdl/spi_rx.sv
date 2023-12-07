`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
module spi_rx
       #(  parameter DATA_WIDTH = 8
        )
        ( input wire clk_in,
          input wire rst_in,
          input wire data_in,
          input wire data_clk_in,
          input wire sel_in,
          output logic [DATA_WIDTH-1:0] data_out,
          output logic new_data_out
        );
  logic [$clog2(DATA_WIDTH)-1:0] ch = DATA_WIDTH-1;
  logic prev;

  always_ff @(posedge clk_in) begin
	if (rst_in) begin
		ch <= DATA_WIDTH-1;
		new_data_out <= 0;
    end else begin
		if (sel_in == 0) begin
			if (prev == 0 && data_clk_in == 1) begin
				data_out[ch] <= data_in;
			  	if (ch == 0) begin
	                new_data_out <= 1;
        	        ch <= DATA_WIDTH-1;
            	end else begin
                    ch <= ch - 1;
                    new_data_out <= 0;
		        end
            end
		end else begin
			  new_data_out <= 0;
		end
		prev <= data_clk_in;
	end
  end
endmodule

`default_nettype wire // prevents system from inferring an undeclared logic (good practice)

