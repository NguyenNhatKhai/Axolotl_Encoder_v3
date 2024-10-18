////////////////////////////////////////////////////////////////////////////////////////////////////

`include "encoder.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
localparam CLOCK_TICK = 5;
localparam CLOCK_MARGIN = 2;

////////////////////////////////////////////////////////////////////////////////////////////////////

module test();

    logic clk;
    logic rst_n;
    logic gen_valid;
    logic [ENC_SYM * EGF_DIM - 1 : 0] gen_data;
    logic [ENC_SYM * EGF_DIM - 1 : 0] enc_data;
    
    encoder test (
        .clk(clk),
        .rst_n(rst_n),
        .gen_valid(gen_valid),
        .gen_data(gen_data),
        .enc_data(enc_data)
    );
    
    initial begin
        clk = 0;
        forever #CLOCK_TICK clk = ~clk;
    end
    
    initial begin
        rst_n <= #(0 * CLOCK_TICK) 1;
        rst_n <= #(22 * CLOCK_TICK + CLOCK_MARGIN) 0;
        rst_n <= #(27 * CLOCK_TICK + CLOCK_MARGIN) 1;
    end
    
    initial begin
        gen_valid <= #(0 * CLOCK_TICK) 0;
        gen_valid <= #(35 * CLOCK_TICK + CLOCK_MARGIN) 1;
        gen_valid <= #(59 * CLOCK_TICK + CLOCK_MARGIN) 0;
    end

    initial begin
        gen_data = 'x;
        #(33 * CLOCK_TICK + CLOCK_MARGIN);
        for (int i = 0; i < 3; i ++) begin
            #(2 * CLOCK_TICK) gen_data = 16'h0123;
            #(2 * CLOCK_TICK) gen_data = 16'h4567;
            #(2 * CLOCK_TICK) gen_data = 16'h89ab;
            #(2 * CLOCK_TICK) gen_data = 16'hcdef;
        end
        #(2 * CLOCK_TICK) gen_data = 'x;
        #(100 * CLOCK_TICK) $finish;
    end

//    initial begin
//        #(33 * CLOCK_TICK + CLOCK_MARGIN);
//        for (int i = 0; i < 7; i ++) begin
//            #(2 * CLOCK_TICK) gen_data = 32'h00010203;
//            #(2 * CLOCK_TICK) gen_data = 32'h04050607;
//            #(2 * CLOCK_TICK) gen_data = 32'h08090a0b;
//            #(2 * CLOCK_TICK) gen_data = 32'h0c0d0e0f;
//        end
//        #(100 * CLOCK_TICK) $finish;
//    end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////