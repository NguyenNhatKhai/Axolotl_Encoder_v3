////////////////////////////////////////////////////////////////////////////////////////////////////

`include "encoder.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////

module enc_mes_buffer (
    input clk,
    input rst_n,
    input con_stall,
    input [ENC_SYM - 1 : 0][EGF_DIM - 1 : 0] gen_data,
    output logic [ENC_MES_BUF_DEP - 1 : 0][EGF_DIM - 1 : 0] mes_buf_data
);

////////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        for (genvar i = ENC_MES_BUF_DEP - 1; i >= 0; i--) begin
            if (i < ENC_SYM) begin
                always_ff @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        mes_buf_data[i] <= '0;
                    end else if (!con_stall) begin
                        mes_buf_data[i] <= gen_data[i];
                    end
                end
            end else begin
                always_ff @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        mes_buf_data[i] <= '0;
                    end else if (!con_stall) begin
                        mes_buf_data[i] <= mes_buf_data[i - ENC_SYM];
                    end
                end
            end
        end
    endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////

module enc_par_buffer (
    input clk,
    input rst_n,
    input pro_finished,
    input [RSC_PAR_LEN - 1 : 0][EGF_DIM - 1 : 0] pro_data,
    output logic [ENC_PAR_BUF_DEP - 1 : 0][EGF_DIM - 1 : 0] par_buf_data
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            par_buf_data <= '0;
        end else if (pro_finished) begin
            par_buf_data <= pro_data;
        end
    end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////