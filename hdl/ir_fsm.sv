`timescale 1ns / 1ps
`default_nettype none
module ir_fsm(
    input wire clk_in,
    input wire rst_in,
    input wire ir_signal,
    output logic [31:0] code_out,
    output logic [2:0] error_out
);

  logic ir_signal_clean; //synchronize incoming infrared to avoid bugs from setup/hold violations

  synchronizer s1
        ( .clk_in(clk_in),
          .rst_in(rst_in),
          .us_in(ir_signal),
          .s_out(ir_signal_clean));

  //infrared decoder
  logic [31:0] code;
  logic [2:0] error;
  logic [3:0] ir_state;
  logic [2:0] locked_error;
  logic new_code;

  ir_decoder mid (  .clk_in(clk_in),
                    .rst_in(rst_in),
                    .signal_in(ir_signal_clean),
                    .code_out(code),
                    .state_out(ir_state),
                    .error_out(error),
                    .new_code_out(new_code));

  always_ff @(posedge clk_in)begin
    code_out <= rst_in?0:new_code?code:code_out;
    locked_error <= rst_in?0:error?error:locked_error;
  end

endmodule

