`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
module spi_tx
       #(   parameter DATA_WIDTH = 8,
            parameter DATA_PERIOD = 100
        )
        ( input wire clk_in,
          input wire rst_in,
          input wire [DATA_WIDTH-1:0] data_in,
          input wire trigger_in,
          output logic data_out,
          output logic data_clk_out,
          output logic sel_out
        );

	localparam DATA_PERIOD_HALF = int'(DATA_PERIOD/2);
	localparam ACTUAL_PERIOD = int'(2*DATA_PERIOD_HALF);
  	localparam COUNTER_MAX = int'(2*DATA_PERIOD_HALF*DATA_WIDTH);
	localparam COUNTER_SIZE = $clog2(COUNTER_MAX);
	logic [COUNTER_SIZE-1:0] counter;
	logic [DATA_WIDTH-1:0] buffer;
	
	logic [COUNTER_SIZE-1:0] ans = ACTUAL_PERIOD;	
	always_ff @(posedge clk_in) begin
		if (rst_in == 1) begin
			sel_out = 1;
		end else begin
			if (trigger_in == 1 && sel_out == 1) begin
				sel_out <= 0;
				buffer <= data_in;
				counter <= 0;
				data_clk_out <= 0;
				data_out <= data_in[DATA_WIDTH - 1];
			end
			if (sel_out == 0) begin
				if ((counter+1) % DATA_PERIOD_HALF == 0) begin
					data_clk_out <= ~data_clk_out;
				end
				if (counter == COUNTER_MAX-1) begin
					sel_out <= 1;
				end
				data_out <= buffer[DATA_WIDTH - 1 - (counter/ans)]; 
				counter <= counter + 1;
			end
		end
	end


endmodule
`default_nettype wire // prevents system from inferring an undeclared logic (good practice)

