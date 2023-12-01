// `timescale 1ns / 1ps
// `default_nettype none // prevents system from inferring an undeclared logic (good practice)
// module spi_rx
//        #(  parameter DATA_WIDTH = 8
//         )
//         ( input wire clk_in,
//           input wire rst_in,
//           input wire data_in,
//           input wire data_clk_in,
//           input wire sel_in,
//           output logic [DATA_WIDTH-1:0] data_out,
//           output logic new_data_out
//         );
//   logic [$clog2(DATA_WIDTH)-1:0] ch = DATA_WIDTH-1;
//   logic prev;

//   always_ff @(posedge clk_in) begin
// 	  if (rst_in) begin
// 		  ch <= DATA_WIDTH-1;
// 		  new_data_out <= 0;
//     end else begin
// 		  if (sel_in == 0) begin
// 			  if (prev == 0 && data_clk_in == 1) begin
// 				  data_out[ch] <= data_in;
			  
//           if (ch == 0) begin
//             new_data_out <= 1;
//             ch <= DATA_WIDTH-1;
//           end else begin
//             ch <= ch - 1;
//             new_data_out <= 0;
// 		      end
//         end
// 		  end else begin
// 			  new_data_out <= 0;
// 		  end
// 		  prev <= data_clk_in;
// 	  end
//   end
// endmodule

// `default_nettype wire // prevents system from inferring an undeclared logic (good practice)

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

    logic prev_data_clk_in;
    logic [DATA_WIDTH-1:0] accumulated_data;
    logic [$clog2(DATA_WIDTH):0] received_count;
    logic receiving;

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            accumulated_data <= 0;
            data_out <= 0;
            new_data_out <= 0;
        end else if (receiving) begin
            if (sel_in == 1) begin
                receiving <= 0;
                received_count <= 0;
                accumulated_data <= 0;
            end else if (received_count == DATA_WIDTH) begin 
                receiving <= 0;
                received_count <= 0;
                new_data_out <= 1;
                data_out <= accumulated_data;
                accumulated_data <= 0;
            end else if (prev_data_clk_in == 0 && data_clk_in == 1) begin
                accumulated_data <= (accumulated_data<<1) | data_in;
                received_count <= received_count + 1;
            end
        end else if (sel_in == 0) begin
            receiving <= 1;
            received_count <= 0;
            accumulated_data <= 0;
            new_data_out <= 0;
        end else begin
            new_data_out <= 0;
            accumulated_data <= 0;
        end
        prev_data_clk_in <= data_clk_in;
    end 

endmodule
`default_nettype wire // prevents system from inferring an undeclared logic (good practice)
