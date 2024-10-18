////////////////////////////////////////////////////////////////////////////////////////////////////

`include "encoder.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////

module enc_controller (
    input clk,
    input rst_n,
    input gen_valid,
    output logic [$clog2(RSC_COD_LEN) - 1 : 0] con_counter,
    output logic con_stall,
    output PRO_PHASE pro_phase,
    output logic pro_finished,
    output logic [$clog2(ENC_SYM + 1) - 1 : 0] pro_request,
    output logic [$clog2(ENC_MES_BUF_DEP + 1) - 1 : 0] pro_offset,
    output SEL_PHASE sel_phase,
    output logic [$clog2(ENC_SYM + 1) - 1 : 0] mes_request,
    output logic [$clog2(ENC_SYM + 1) - 1 : 0] par_request,
    output logic [$clog2(ENC_MES_BUF_DEP + 1) - 1 : 0] mes_offset,
    output logic [$clog2(ENC_PAR_BUF_DEP + 1) - 1 : 0] par_offset
);

    logic [$clog2(RSC_COD_LEN) - 1 : 0] con_counter_new;
    logic con_stall_new;
    
    PRO_PHASE pro_phase_new;
    logic pro_finished_new;
    logic [$clog2(ENC_SYM + 1) - 1 : 0] pro_request_new;
    logic [$clog2(ENC_MES_BUF_DEP + 1) - 1 : 0] pro_offset_new;
    
    SEL_PHASE sel_phase_new;
    logic [$clog2(ENC_SYM + 1) - 1 : 0] mes_request_new;
    logic [$clog2(ENC_SYM + 1) - 1 : 0] par_request_new;
    logic [$clog2(ENC_MES_BUF_DEP + 1) - 1 : 0] mes_offset_new;
    logic [$clog2(ENC_PAR_BUF_DEP + 1) - 1 : 0] par_offset_new;
    
    assign pro_finished_new = (con_counter_new >= RSC_MES_LEN && con_counter_new < RSC_MES_LEN + ENC_SYM);
    assign par_request_new = ENC_SYM - mes_request_new;

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            con_counter <= '0;
            con_stall <= '0;
            pro_phase <= PRO_IDL;
            pro_finished <= '0;
            pro_request <= '0;
            pro_offset <= '0;
            sel_phase <= SEL_IDL;
            mes_request <= '0;
            par_request <= '0;
            mes_offset <= '0;
            par_offset <= '0;
        end else if (gen_valid) begin
            con_counter <= con_counter_new;
            con_stall <= con_stall_new;
            pro_phase <= pro_phase_new;
            pro_finished <= pro_finished_new;
            pro_request <= pro_request_new;
            pro_offset <= pro_offset_new;
            sel_phase <= sel_phase_new;
            mes_request <= mes_request_new;
            par_request <= par_request_new;
            mes_offset <= mes_offset_new;
            par_offset <= par_offset_new;
        end
    end
    
////////////////////////////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if (con_counter > RSC_COD_LEN - ENC_SYM) begin
            con_counter_new = con_counter + ENC_SYM - RSC_COD_LEN;
        end else begin
            con_counter_new = con_counter + ENC_SYM;
        end
    end

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_comb begin
        logic [RSC_PAR_LEN - 1 : 0] con_stall_temp;
        for (int i = RSC_PAR_LEN - 1; i >= 0; i --) begin
            con_stall_temp[i] = (con_counter_new == ENC_CON_STA[i]);
        end
        con_stall_new = |con_stall_temp;
    end

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if (con_counter_new < RSC_MES_LEN % ENC_SYM) begin
            pro_phase_new = PRO_IDL;
        end else if (con_counter_new < ENC_SYM + RSC_MES_LEN % ENC_SYM) begin
            pro_phase_new = PRO_PAR;
        end else if (con_counter_new < RSC_MES_LEN + ENC_SYM) begin
            pro_phase_new = PRO_FUL;
        end else begin
            pro_phase_new = PRO_IDL;
        end
    end
    
////////////////////////////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if (pro_phase_new == PRO_PAR) begin
            pro_request_new = RSC_MES_LEN % ENC_SYM;
        end else if (pro_phase_new == PRO_FUL) begin
            pro_request_new = ENC_SYM;
        end else begin
            pro_request_new = '0;
        end
    end
    
////////////////////////////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if (con_counter_new == ENC_SYM) begin
            pro_offset_new = ENC_SYM - RSC_MES_LEN % ENC_SYM;
        end else if (con_stall) begin
            pro_offset_new = pro_offset - pro_request_new;
        end else begin
            pro_offset_new = pro_offset + ENC_SYM - pro_request_new;
        end
    end

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if (con_counter_new == '0) begin
            sel_phase_new = SEL_IDL;
        end else if (con_counter_new < ENC_SYM) begin
            sel_phase_new = SEL_PTM;
        end else if (con_counter_new <= RSC_MES_LEN) begin
            sel_phase_new = SEL_MES;
        end else if (con_counter_new < RSC_MES_LEN + ENC_SYM) begin
            sel_phase_new = SEL_MTP;
        end else if (con_counter_new <= RSC_COD_LEN) begin
            sel_phase_new = SEL_PAR;
        end else begin
            sel_phase_new = SEL_IDL;
        end
    end

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if (sel_phase_new == SEL_MES) begin
            mes_request_new = ENC_SYM;
        end else if (sel_phase_new == SEL_MTP) begin
            mes_request_new = RSC_MES_LEN + ENC_SYM - con_counter_new;
        end else if (sel_phase_new == SEL_PTM) begin
            mes_request_new = con_counter_new;
        end else begin
            mes_request_new = '0;
        end
    end

////////////////////////////////////////////////////////////////////////////////////////////////////
    
    always_comb begin
        if (con_counter_new == ENC_SYM) begin
            mes_offset_new = '0;
        end else if (con_stall) begin
            mes_offset_new = mes_offset - mes_request_new;
        end else begin
            mes_offset_new = mes_offset + ENC_SYM - mes_request_new;
        end
    end

////////////////////////////////////////////////////////////////////////////////////////////////////
    
    always_comb begin
        if (con_counter_new == ENC_SYM) begin
            par_offset_new = '0;
        end else if (pro_finished_new) begin
            par_offset_new = RSC_PAR_LEN - par_request_new;
        end else begin
            par_offset_new = par_offset - par_request_new;
        end
    end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////