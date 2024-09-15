module generador_lfsr (
  input wire clk                        , // clock
  input wire i_valid                    , // señal que habilita la generacion de la secuencia
  input wire i_rst                      , // reset asincrono
  input wire i_soft_reset               , // reset sincrono
  input wire [7:0] i_seed               , // seed
  output wire [7:0] o_LFSR
);

reg [7:0] LFSR = 8'h00                           ;  // Registro para la secuencia
reg [7:0] seed = 8'h00                           ;  // Seed inicial
wire feedback = LFSR[7] ^ (LFSR[6:0]==7'b0000000);  // Retroalimentación tomada del MSB y si son todas 0

always @(posedge clk or posedge i_rst)  // implemento reset asincrono
begin
    if (i_rst) begin
        LFSR <= seed;                   // El seed será el valor de hard reset
    end else if (i_soft_reset) begin 
        LFSR <= i_seed;                 // Valor que contenga la entrada
    end else if (i_valid) begin
        LFSR[0] <= feedback;            // Genero la secuencia
        LFSR[1] <= LFSR[0];
        LFSR[2] <= LFSR[1] ^ feedback;
        LFSR[3] <= LFSR[2] ^ feedback;
        LFSR[4] <= LFSR[3];
        LFSR[5] <= LFSR[4];
        LFSR[6] <= LFSR[5] ^ feedback;
        LFSR[7] <= LFSR[6];
     end 
end

assign o_LFSR = LFSR; // salida de la secuencia, copio lo que haya actualizado LFSR

endmodule
