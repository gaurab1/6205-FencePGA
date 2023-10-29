module tm_choice (
  input wire [7:0] data_in,
  output logic [8:0] qm_out
  );
  logic [3:0] sumi;
    always_comb begin
      sumi = data_in[0] + data_in[1] + data_in[2] + data_in[3] + data_in[4] + data_in[5] + data_in[6] + data_in[7];
      if (sumi > 4 | (sumi == 4 & data_in[0] == 0)) begin
        qm_out[8] = 0;
        qm_out[0] = data_in[0];
        for (int i = 1; i < 8; i++) begin
          qm_out[i] = ~(qm_out[i-1] ^data_in[i]);
        end
      end else begin
        qm_out[8] = 1;
        qm_out[0] = data_in[0];
        for (int i = 1; i < 8; i++) begin
          qm_out[i] = (qm_out[i-1] ^data_in[i]);
        end
      end
    end

endmodule //end tm_choice

