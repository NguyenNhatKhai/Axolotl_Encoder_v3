////////////////////////////////////////////////////////////////////////////////////////////////////

`include "encoder.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////

module enc_selector (
    input clk,
    input rst_n,
    input gen_valid,
    input SEL_PHASE sel_phase,
    input [$clog2(ENC_SYM + 1) - 1 : 0] mes_request,
    input [$clog2(ENC_SYM + 1) - 1 : 0] par_request,
    input [$clog2(ENC_MES_BUF_DEP + 1) - 1 : 0] mes_offset,
    input [$clog2(ENC_PAR_BUF_DEP + 1) - 1 : 0] par_offset,
    input [ENC_MES_BUF_DEP - 1 : 0][EGF_DIM - 1 : 0] mes_buf_data,
    input [ENC_PAR_BUF_DEP - 1 : 0][EGF_DIM - 1 : 0] par_buf_data,
    input [RSC_PAR_LEN - 1 : 0][EGF_DIM - 1 : 0] pro_data,
    output logic [ENC_SYM - 1 : 0][EGF_DIM - 1 : 0] sel_data
);

    logic [ENC_SYM - 1 : 0][EGF_DIM - 1 : 0] sel_data_new;

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sel_data <= '0;
        end else if (gen_valid) begin
            sel_data <= sel_data_new;
        end
    end

    always_comb begin
        if (sel_phase == SEL_MES) begin
            sel_data_new = mes_buf_data[mes_offset +: ENC_SYM];
        end else if (sel_phase == SEL_PAR) begin
            sel_data_new = par_buf_data[par_offset +: ENC_SYM];
        end else if (sel_phase == SEL_MTP) begin
            for (int i = ENC_SYM - 1; i >= 0; i --) begin
                if (i >= par_request) begin
                    sel_data_new[i] = mes_buf_data[i + mes_offset - par_request];
                end else begin
                    sel_data_new[i] = pro_data[i + par_offset];
                end
            end
        end else if (sel_phase == SEL_PTM) begin
            for (int i = ENC_SYM - 1; i >= 0; i --) begin
                if (i >= mes_request) begin
                    sel_data_new[i] = par_buf_data[i + par_offset - mes_request];
                end else begin
                    sel_data_new[i] = mes_buf_data[i + mes_offset];
                end
            end
        end else begin
            sel_data_new = 'x;
        end
    end

endmodule
    
////////////////////////////////////////////////////////////////////////////////////////////////////