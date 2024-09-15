// iverilog -o tb_gen_lfsr tb_gen_lfsr.v
// vvp tb_gen_lfsr
// gtkwave generador.vcd

`timescale 1ns/1ps
//`include "generador_lfsr.v"
//`include "top_lfsr.v"

module tb_gen_lfsr;

reg clk          ;  // Señales
reg i_valid      ;
reg i_rst        ;
reg i_soft_reset ;
reg [7:0] i_seed ;
wire [7:0] o_LFSR;

//top_lfsr dut (
generador_lfsr uut (
    .clk(clk),
    .i_valid(i_valid),
    .i_rst(i_rst),
    .i_soft_reset(i_soft_reset),
    .i_seed(i_seed),
    .o_LFSR(o_LFSR)    
);

// Alterno el clock cada 50 unidades de tiempo
always #50 clk = ~clk;  // Genero el clock con periodo de 100ns

integer i; // Variable para el bucle
integer j; // Variable para la periodicidad

initial begin
    $dumpfile("generador.vcd");     // Waveform generado
    $dumpvars(0, tb_gen_lfsr);      // Variables a incluir

    // Inicializo las señales
    clk = 0;
    i_valid = 1;    // Que empiece haciendo algo
    i_rst = 1;
    i_soft_reset = 0;
    i_seed = 8'h00;
    i = 0;
    j = 0;
    
    @(posedge clk);
    i_rst = 0;
    @(posedge clk);

    // Genero un reset entre 1us y 250us
    async_reset;
    //i_rst = 0;

    repeat(50) @(posedge clk);

    // Cambio el seed
    change_seed(8'h7F);

    repeat(2) @(posedge clk);

    // Genero un soft reset entre 1us y 250us
    soft_reset;

    repeat(50) @(posedge clk);

    // Random valid al final por el bucle limitado
    random_valid;

    repeat(50) @(posedge clk);

    // Verificar periodicidad:
    i_valid = 1;
    i = 0;
    i_seed = 8'h1A;
    change_seed(i_seed);
    soft_reset;

    check_periodicity;

    $finish;    // Fin de la simulación

end

// REVISAR RANDOM NO FUNCIONA
task async_reset;
    reg [31:0] random_delay; // Acá almaceno el valor entre 1us y 250us
    begin
        random_delay = $urandom_range(1000, 250000); // 1000*1ns = 1us
        i_rst = 1;
        $display("Delay establecido en %d ns", random_delay);
        #random_delay;  // Delay random
        @(posedge clk);
        i_rst = 0;  // Suelto el reset cuando venga el clk
    end
endtask

task change_seed (input [7:0] new_seed);    // Valor nuevo que recibe
    begin
        i_seed <= new_seed;     // Cambio al nuevo
        $display("Seed cambiado a %h", new_seed);
        @(posedge clk);     // Delay de clk
    end
endtask

task soft_reset;    // Similar a async_reset
    reg [31:0] soft_delay;
    begin
        soft_delay = $urandom_range(1000, 250000);
        i_soft_reset = 1;
        $display("Delay establecido en %d ns", soft_delay);
        #soft_delay;
        @(posedge clk);
        i_soft_reset = 0;
    end
endtask

task random_valid;
    begin
        //integer i;
        for (i = 0; i < 1000; i = i + 1) begin  // 1000 veces
            @(posedge clk);         // Delay de clk
            i_valid = $random % 2;  // Random entre 0 y 1
        end
    end
endtask

task check_periodicity;
    begin
        for (i = 0; i < 1000; i = i + 1) begin  // 1000 veces
            @(posedge clk);         // Delay de clk
            if (o_LFSR == i_seed) begin
                $display("o_LFSR es igual a i_seed, i = %d", i);
                j = 0;
            end else begin
                //$display("o_LFSR es diferente a i_seed");
                j = j + 1;
            end
        end
    end
endtask

endmodule