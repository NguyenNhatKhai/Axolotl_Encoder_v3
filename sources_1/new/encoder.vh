////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _ENCODER_VH_
`define _ENCODER_VH_

////////////////////////////////////////////////////////////////////////////////////////////////////

//localparam EGF_DIM = 4;
//localparam logic [EGF_DIM : 0] EGF_PRI_POL = '{1, 0, 0, 1, 1};

//localparam RSC_COR_CAP = 2;
//localparam RSC_PAR_LEN = 2 * RSC_COR_CAP;
//localparam RSC_COD_LEN = 2 ** EGF_DIM - 1;
//localparam RSC_MES_LEN = RSC_COD_LEN - RSC_PAR_LEN;
//localparam logic [RSC_PAR_LEN : 0][EGF_DIM - 1 : 0] RSC_GEN_POL = '{'b0001, 'b1101, 'b1100, 'b1000, 'b0111};

//localparam ENC_SYM = 4;
//localparam logic [RSC_PAR_LEN - 1 : 0][$clog2(RSC_COD_LEN) - 1 : 0] ENC_CON_STA = '{'d11, 'd12, 'd13, 'd14};
//localparam ENC_MES_BUF_DEP = 7;
//localparam ENC_PAR_BUF_DEP = RSC_PAR_LEN;

////////////////////////////////////////////////////////////////////////////////////////////////////

//localparam EGF_DIM = 4;
//localparam logic [EGF_DIM : 0] EGF_PRI_POL = '{1, 0, 0, 1, 1};

//localparam RSC_COR_CAP = 3;
//localparam RSC_PAR_LEN = 2 * RSC_COR_CAP;
//localparam RSC_COD_LEN = 2 ** EGF_DIM - 1;
//localparam RSC_MES_LEN = RSC_COD_LEN - RSC_PAR_LEN;
//localparam logic [RSC_PAR_LEN : 0][EGF_DIM - 1 : 0] RSC_GEN_POL = '{'b0001, 'b0111, 'b1001, 'b0011, 'b1100, 'b1010, 'b1100};

//localparam ENC_SYM = 4;
//localparam logic [RSC_PAR_LEN - 1 : 0][$clog2(RSC_COD_LEN) - 1 : 0] ENC_CON_STA = '{'d7, 'd9, 'd10, 'd11, 'd12, 'd13};
//localparam ENC_MES_BUF_DEP = 8;
//localparam ENC_PAR_BUF_DEP = RSC_PAR_LEN;

////////////////////////////////////////////////////////////////////////////////////////////////////

localparam EGF_DIM = 8;
localparam logic EGF_PRI_POL[EGF_DIM : 0] = '{1, 0, 1, 1, 1, 0, 0, 0, 1};

localparam RSC_COR_CAP = 8;
localparam RSC_PAR_LEN = 2 * RSC_COR_CAP;
localparam RSC_COD_LEN = 2 ** EGF_DIM - 1;
localparam RSC_MES_LEN = RSC_COD_LEN - RSC_PAR_LEN;
localparam logic [RSC_PAR_LEN : 0][EGF_DIM - 1 : 0] RSC_GEN_POL = '{'b00000001, 'b01110110, 'b00110100, 'b01100111, 'b00011111, 'b01101000, 'b01111110, 'b10111011, 'b11101000, 'b00010001, 'b00111000, 'b10110111, 'b00110001, 'b01100100, 'b01010001, 'b00101100, 'b01001111};

localparam ENC_SYM = 4;
localparam logic [RSC_PAR_LEN - 1 : 0][$clog2(RSC_COD_LEN) - 1 : 0] ENC_CON_STA = '{'d239, 'd240, 'd241, 'd242, 'd243, 'd244, 'd245, 'd246, 'd247, 'd248, 'd249, 'd250, 'd251, 'd252, 'd253, 'd254};
localparam ENC_MES_BUF_DEP = 7;
localparam ENC_PAR_BUF_DEP = RSC_PAR_LEN;

////////////////////////////////////////////////////////////////////////////////////////////////////

localparam SEL_PHA_NUM = 5;
localparam PRO_PHA_NUM = 3;

typedef enum logic [$clog2(SEL_PHA_NUM) - 1 : 0] {
    SEL_IDL,
    SEL_MES,
    SEL_PAR,
    SEL_MTP,
    SEL_PTM
} SEL_PHASE;

typedef enum logic [$clog2(PRO_PHA_NUM) - 1 : 0] {
    PRO_IDL,
    PRO_PAR,
    PRO_FUL
} PRO_PHASE;

////////////////////////////////////////////////////////////////////////////////////////////////////

`endif

////////////////////////////////////////////////////////////////////////////////////////////////////