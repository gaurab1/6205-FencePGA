`timescale 1ns / 1ps
`default_nettype none
module ir_decoder
       #( parameter SBD  = 1_212_121, //sync burst duration
          parameter SSD  = 606_060, //sync silence duration
          parameter BBD = 80_808, //bit burst duration
          parameter BSD0 = 80_808, //bit silence duration (for 0)
          parameter BSD1 = 215_488, //bit silence duration (for 1)
          parameter MARGIN = 20_000 //The +/- of your signals
        )
        ( input wire clk_in, //clock in (100MHz)
          input wire rst_in, //reset in
          input wire signal_in, //signal in
          output logic [31:0] code_out, //where to place 32 bit code once captured
          output logic new_code_out, //single-cycle indicator that new code is present!
          output logic [2:0] error_out, //output error codes for debugging
          output logic [3:0] state_out //current state out (helpful for debugging)
        );
  logic [31:0] signal_counter;
  typedef enum {IDLE=0, SL=1, SH=2, DL=3, DH=4, F0=5, F1=6, CHECK=7,DATA=8} ir_state;
 
  current_counter mcc( .clk_in(clk_in),
                        .rst_in(rst_in),
                        .signal_in(signal_in),
                        .tally_out(signal_counter));
 
  ir_state state; //state of system!
  logic [$clog2(32):0] bits_received_count;

  logic [31:0] data_buffer;

  assign state_out = state;
 
  always_ff @(posedge clk_in)begin
    if (rst_in)begin
      state <= IDLE;
      code_out <= 0;
      new_code_out <= 0;
      error_out <= 0;
      bits_received_count <= 0;
      data_buffer <= 0;
    end else begin
      case (state)
        IDLE: begin 
          if (signal_in == 0) begin
            error_out <= 0;
            state <= SL;
          end
          data_buffer <= 0;
          bits_received_count <= 0;
          new_code_out <= 0;
        end
        SL: begin
          if (signal_counter > SBD+MARGIN || 
              signal_in == 1 && signal_counter < SBD-MARGIN) begin
            error_out <= 1;
            state <= IDLE;
          end else if (signal_in == 1 && signal_counter >= SBD-MARGIN && signal_counter <= SBD+MARGIN) begin
            state <= SH;
          end
        end
        SH: begin
          if (signal_in == 0 && signal_counter < SSD-MARGIN || 
              signal_counter > SSD+MARGIN) begin
            error_out <= 1;
            state <= IDLE;
          end else if (signal_in == 0 && signal_counter >= SSD-MARGIN && signal_counter <= SSD+MARGIN) begin
            state <= DL;
          end
        end
        DL: begin
          if (signal_in == 1 && signal_counter < BBD-MARGIN || 
              signal_counter > BBD+MARGIN) begin
            error_out <= 1;
            state <= IDLE;
          end else if (signal_in == 1 && signal_counter >= BBD-MARGIN && signal_counter <= BBD+MARGIN) begin
            state <= DH;
          end
        end
        DH: begin
          if (signal_in == 0 && signal_counter < BSD0-MARGIN || 
              signal_counter > BSD1+MARGIN) begin
            error_out <= 1;
            state <= IDLE;
          end else if (signal_in == 0 && signal_counter >= BSD0-MARGIN && signal_counter <= BSD0+MARGIN) begin
            state <= F0;
          end else if (signal_in == 0 && signal_counter >= BSD1-MARGIN && signal_counter <= BSD1+MARGIN) begin
            state <= F1;
          end
        end
        F0: begin
          bits_received_count <= bits_received_count + 1;
          data_buffer <= (data_buffer<<1) | 0;
          state <= CHECK;
        end
        F1: begin
          bits_received_count <= bits_received_count + 1;
          data_buffer <= (data_buffer<<1) | 1;
          state <= CHECK;
        end
        CHECK: begin
          if (bits_received_count < 32) state <= DL;
          else state <= DATA;
        end
        DATA: begin
          bits_received_count <= 0;
          code_out <= data_buffer;
          new_code_out <= 1;
          data_buffer <= 0;
          state <= IDLE;
        end
      endcase
    end
  end
 
endmodule
`default_nettype none