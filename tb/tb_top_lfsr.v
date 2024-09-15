`timescale 1ns / 1ps

module tb_top_lfsr;

    reg clk;
    reg i_valid;
    reg i_rst;
    reg i_soft_reset;
    reg i_corrupt;
    reg [7:0] i_seed;
    wire o_lock;
    
    top_lfsr uut
    (
        .clk(clk),
        .i_valid(i_valid),
        .i_rst(i_rst),
        .i_soft_reset(i_soft_reset),
        .i_corrupt(i_corrupt),
        .i_seed(i_seed),
        .o_lock(o_lock)
    );
    
    // Alterno el clock cada 50 unidades de tiempo
    always #5 clk = ~clk;  // Genero el clock con periodo de 100ns
    
    initial begin
        // Inicialización de señales
        clk = 0;
        i_valid = 0;
        i_soft_reset = 0;
        i_seed = 8'h01;
        i_corrupt = 0;
        i_rst = 1;
        
        @(posedge clk);

        i_rst = 0;
        //i_soft_reset = 1;

        @(posedge clk);
        
        i_soft_reset = 0;
        i_valid = 1;

        repeat(20) @(posedge clk);

        i_rst = 1;
        i_soft_reset = 1;
        i_seed = 8'h0F;
        
        @(posedge clk);
        
        i_soft_reset = 0;
        i_rst = 0;
        
        repeat(20) @(posedge clk);
        
        i_corrupt = 1;
        
        repeat(20) @(posedge clk);
        
        i_corrupt = 0;

        repeat(20) @(posedge clk);
        $finish;
    end
    
endmodule
