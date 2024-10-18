////////////////////////////////////////////////////////////////////////////////////////////////////

`include "encoder.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////

function logic [EGF_DIM - 1 : 0] egf_mul (
    input [EGF_DIM - 1 : 0] data_0,
    input [EGF_DIM - 1 : 0] data_1
);

    logic redundant_bit;
    logic [EGF_DIM - 1 : 0] returned_data;
    redundant_bit = '0;
    returned_data = '0;

    for (int i = 0; i < EGF_DIM; i ++) begin
        redundant_bit = returned_data[EGF_DIM - 1];
        for (int j = EGF_DIM - 1; j > 0; j --) begin
            returned_data[j] = returned_data[j - 1] ^ (redundant_bit & EGF_PRI_POL[j]) ^ (data_0[j] & data_1[EGF_DIM - i - 1]);
        end
        returned_data[0] = (redundant_bit & EGF_PRI_POL[0]) ^ (data_0[0] & data_1[EGF_DIM - i - 1]);
    end
    
    return returned_data;

endfunction


////////////////////////////////////////////////////////////////////////////////////////////////////

module enc_pro_partly (
    input [RSC_MES_LEN % ENC_SYM - 1 : 0][EGF_DIM - 1 : 0] pro_for_data,
    output logic [RSC_PAR_LEN - 1 : 0][EGF_DIM - 1 : 0] pro_par_data
);

    always_comb begin
        logic [RSC_PAR_LEN - 1 : 0][EGF_DIM - 1 : 0] data_temp;
        data_temp = '0;
        for (int i = RSC_MES_LEN % ENC_SYM - 1; i >= 0; i --) begin
            for (int j = RSC_PAR_LEN - 1; j > 0; j --) begin
                pro_par_data[j] = data_temp[j - 1] ^ egf_mul(pro_for_data[i] ^ data_temp[RSC_PAR_LEN - 1], RSC_GEN_POL[j]);
            end
            pro_par_data[0] = egf_mul(pro_for_data[i] ^ data_temp[RSC_PAR_LEN - 1], RSC_GEN_POL[0]);
            data_temp = pro_par_data;
        end
    end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////

module enc_pro_fully (
    input [ENC_SYM - 1 : 0][EGF_DIM - 1 : 0] pro_for_data,
    input [RSC_PAR_LEN - 1 : 0][EGF_DIM - 1 : 0] pro_data_reg,
    output logic [RSC_PAR_LEN - 1 : 0][EGF_DIM - 1 : 0] pro_ful_data
);

    always_comb begin
        logic [RSC_PAR_LEN - 1 : 0][EGF_DIM - 1 : 0] data_temp;
        data_temp = pro_data_reg;
        for (int i = ENC_SYM - 1; i >= 0; i --) begin
            for (int j = RSC_PAR_LEN - 1; j > 0; j --) begin
                pro_ful_data[j] = data_temp[j - 1] ^ egf_mul(pro_for_data[i] ^ data_temp[RSC_PAR_LEN - 1], RSC_GEN_POL[j]);
            end
            pro_ful_data[0] = egf_mul(pro_for_data[i] ^ data_temp[RSC_PAR_LEN - 1], RSC_GEN_POL[0]);
            data_temp = pro_ful_data;
        end
    end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////

module enc_processor (
    input clk,
    input rst_n,
    input PRO_PHASE pro_phase,
    input [$clog2(ENC_SYM + 1) - 1 : 0] pro_request,
    input [$clog2(ENC_MES_BUF_DEP + 1) - 1 : 0] pro_offset,
    input [ENC_MES_BUF_DEP - 1 : 0][EGF_DIM - 1 : 0] mes_buf_data,
    output logic [RSC_PAR_LEN - 1 : 0][EGF_DIM - 1 : 0] pro_data
);

    logic [ENC_SYM - 1 : 0][EGF_DIM - 1 : 0] pro_for_data;
    logic [RSC_PAR_LEN - 1 : 0][EGF_DIM - 1 : 0] pro_par_data;
    logic [RSC_PAR_LEN - 1 : 0][EGF_DIM - 1 : 0] pro_ful_data;
    logic [RSC_PAR_LEN - 1 : 0][EGF_DIM - 1 : 0] pro_data_reg;
    
    assign pro_for_data = mes_buf_data[pro_offset +: ENC_SYM];

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pro_data_reg <= '0;
        end else begin
            pro_data_reg <= pro_data;
        end
    end

////////////////////////////////////////////////////////////////////////////////////////////////////

    enc_pro_partly pro_partly (
        .pro_for_data(pro_for_data[RSC_MES_LEN % ENC_SYM - 1 : 0]),
        .pro_par_data(pro_par_data)
    );

    enc_pro_fully pro_fully (
        .pro_for_data(pro_for_data),
        .pro_data_reg(pro_data_reg),
        .pro_ful_data(pro_ful_data)
    );

////////////////////////////////////////////////////////////////////////////////////////////////////

//    always_comb begin
//        if (pro_phase == PRO_PAR) begin
//            pro_data = pro_par_data;
//        end else if (pro_phase == PRO_FUL) begin
//            pro_data = pro_ful_data;
//        end else begin
//            pro_data = 'x;
//        end
//    end

    always_comb begin
        if (pro_phase == PRO_PAR) begin
            pro_data = pro_par_data;
        end else begin
            pro_data = pro_ful_data;
        end
    end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////