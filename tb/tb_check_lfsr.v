`timescale 1ns / 1ps

module tb_check_lfsr;

    reg clk;
    reg i_valid;
    reg i_rst;
    reg i_soft_reset;
    reg [7:0] i_lfsr_tocheck;
    wire o_lock;
    
    reg [7:0] LFSR_test;   // Valores comparables del lfsr
    wire feedback = LFSR_test[7] ^ (LFSR_test[6:0]==7'b0000000);

    
    
    checker_lfsr uut (
        .clk(clk),
        .i_valid(i_valid),
        .i_rst(i_rst),
        .i_soft_reset(i_soft_reset),
        .i_lfsr_tocheck(i_lfsr_tocheck),
        .o_lock(o_lock)
    );
    
// Alterno el clock cada 50 unidades de tiempo
always #5 clk = ~clk;  // Genero el clock con periodo de 100ns // REVISAR OTROS CLOCK

integer valids;
integer invalids;

initial
begin
    clk = 0;
    i_valid = 0;
    i_rst = 1;
    i_soft_reset = 0;
    i_lfsr_tocheck = 8'h00;
    LFSR_test = 8'h00;
    valids = 0;
    invalids = 0;

    @(posedge clk);
    i_rst = 0;
    i_valid = 1;
    @(posedge clk);   
    
    
    
    // 4 válidos 1 inválido
    valids = 12;
    invalids = 15;
    @(posedge clk);
    generate_valid(valids);
    @(posedge clk);
    generate_invalid(invalids);
    @(posedge clk);
    
    
    
    i_rst = 1;
    @(posedge clk);
    i_rst = 0;
    @(posedge clk);
    
    
    
    // 2 inválidos, 1 válido
    valids = 15;
    invalids = 8;
    @(posedge clk);
    generate_valid(valids);
    @(posedge clk);
    generate_invalid(invalids);
    @(posedge clk);
    
    
    
    
    i_rst = 1;
    @(posedge clk);
    i_rst = 0;
    @(posedge clk);
    
    
    
    
    // 5 válidos, 3 inválidos
    valids = 5;
    invalids = 3;
    @(posedge clk);
    generate_valid(valids);
    @(posedge clk);
    generate_invalid(invalids);
    @(posedge clk);
    
    //#500;
    repeat(5) @(posedge clk);
    
    $finish;
end

task generate_valid(input [4:0] v);
    repeat(v)
    begin
        begin
            LFSR_test[0] <= feedback                ;
            LFSR_test[1] <= LFSR_test[0]            ;
            LFSR_test[2] <= LFSR_test[1] ^ feedback ;
            LFSR_test[3] <= LFSR_test[2] ^ feedback ;
            LFSR_test[4] <= LFSR_test[3]            ;
            LFSR_test[5] <= LFSR_test[4]            ;
            LFSR_test[6] <= LFSR_test[5] ^ feedback ;
            LFSR_test[7] <= LFSR_test[6]            ;
        
            i_lfsr_tocheck <= LFSR_test             ; // Cargo el generado
            @(posedge clk);
        end
    end
endtask

task generate_invalid(input [4:0] i);  // Secuencia inversa
    repeat(i)
    begin
        begin
            LFSR_test[0] <= ~feedback               ;
            LFSR_test[1] <= ~LFSR_test[0]           ;
            LFSR_test[2] <= ~LFSR_test[1] ^ feedback;
            LFSR_test[3] <= ~LFSR_test[2] ^ feedback;
            LFSR_test[4] <= ~LFSR_test[3]           ;
            LFSR_test[5] <= ~LFSR_test[4]           ;
            LFSR_test[6] <= ~LFSR_test[5] ^ feedback;
            LFSR_test[7] <= ~LFSR_test[6]           ;
        
            i_lfsr_tocheck <= LFSR_test             ; // Cargo el generado
            @(posedge clk);
        end
    end
endtask

endmodule
