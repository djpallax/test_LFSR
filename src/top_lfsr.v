module top_lfsr
    (

        input wire clk
        //input wire i_rst,
        //input wire i_soft_reset,
        //input wire i_valid,
        //input wire [7 : 0] i_seed,    // input wire [NB_LSFR - 1 : 0] i_seed,
        //input wire i_corrupt,
        //output wire o_lock
    );
    
    wire i_rst;
    wire i_soft_reset;
    wire i_valid;
    wire [7 : 0] i_seed;    // input wire [NB_LSFR - 1 : 0] i_seed,
    wire i_corrupt;
    wire o_lock;
    wire [7:0]                 connect_lfsr;    // bus de datos de la secuencia
    wire [7:0]                 corrupt_lfsr;    // Secuencia corrupta

    generador_lfsr
        u_generador_lfsr
        (
            .clk                 (clk),
            .i_soft_reset (i_soft_reset),
            .i_rst               (i_rst),
            .i_valid           (i_valid),
            .i_seed             (i_seed),
            .o_LFSR       (connect_lfsr)
        );
        
    checker_lfsr
        u_checker_lfsr
        (
            .clk                     (clk),
            .i_soft_reset   (i_soft_reset),
            .i_rst                 (i_rst),
            .i_valid             (i_valid),
            .o_lock               (o_lock),
            .i_lfsr_tocheck (corrupt_lfsr)      // Conecto la secuencia que puede estar corrompida
        );
    
    // Si corrupt está en 1, corrompo la secuencia y falla el checker
    assign corrupt_lfsr = i_corrupt ? {connect_lfsr [7:1], ~connect_lfsr[0]} : connect_lfsr;
    
    vio
    u_vio
   (.clk_0      (clk),
    .probe_in0_0(o_lock),
    .probe_out0_0(i_seed),
    .probe_out1_0(i_soft_reset),
    .probe_out2_0(i_valid),
    .probe_out3_0(i_corrupt),
    .probe_out4_0(i_rst)
    );
    
    ila
    u_ila
   (.clk_0    (clk),
    .probe0_0(o_lock)
    );

endmodule
