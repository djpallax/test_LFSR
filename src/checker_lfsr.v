module checker_lfsr (
    input wire clk                        , // clock
    input wire i_valid                    , // señal que habilita la generacion de la secuencia
    input wire i_rst                      , // reset asincrono
    input wire i_soft_reset               , // reset sincrono
    input wire [7:0] i_lfsr_tocheck       , // combinación a verificar
    output wire o_lock                      // bandera de bloqueo del checker
);

reg [2:0] valid                                     ;  // Acumulador de valores válidos, lleva la cuenta
reg [2:0] invalid                                   ;  // Acumulador de inválidos
reg [7:0] LFSR                                      ;  // Registro para la secuencia de verificación
wire feedback = LFSR[7] ^ (LFSR[6:0]==7'b0000000)   ;  // Retroalimentación tomada del MSB y si son todas 0
reg [7:0] buf_LFSR                                  ;  // Buffer de la secuencia para comparar
reg lock                                            ;  // Flag de bloqueo

always @(posedge clk or posedge i_rst) 
begin
    if (i_rst) begin        // No debería tomar la combinaciín de salida del generador? igual que soft
        LFSR        <= 8'h00            ;         // Combinación a la salida del generador
        valid       <= 0                ;
        invalid     <= 0                ;
        lock        <= 0                ;
        buf_LFSR    <= 0                ;
        
    end else if (i_soft_reset) begin 
        LFSR        <= i_lfsr_tocheck   ;         // Combinación a la salida del generador
        valid       <= 0                ;
        invalid     <= 0                ;
        lock        <= 0                ;
        
    end else if(i_valid) begin
        
        buf_LFSR <= i_lfsr_tocheck;
        
        //Por lo general, se genera una secuencia y al ciclo siguiente la puede comparar a la entrada, entonces buffer
        if((lock == 0) && (buf_LFSR != LFSR)) begin     // Si el buffer es distinto a la secuencia que debería venir, y hay inválidos suficientes, actualizo
            LFSR <= i_lfsr_tocheck;	         	// Actualizo secuencia con la entrada
            
        end else begin                          	// Si viene bien, calculo la siguiente a verificar
            LFSR[0] <= feedback;            		// Genero la secuencia a comparar
            LFSR[1] <= LFSR[0];
            LFSR[2] <= LFSR[1] ^ feedback;
            LFSR[3] <= LFSR[2] ^ feedback;
            LFSR[4] <= LFSR[3];
            LFSR[5] <= LFSR[4];
            LFSR[6] <= LFSR[5] ^ feedback;
            LFSR[7] <= LFSR[6];
        end
        
        if (buf_LFSR == LFSR)     // Si el buffer coincide con el calculado
        begin
            valid <= valid + 1; // Acumulo
            invalid <= 0;
            if (valid >= 5)         // Si 5 ok, lock pasa a 1
            begin
                lock <= 1;
                valid <= 0;
            end
        end else if (buf_LFSR != LFSR)
        begin                       // Si son distintos
            //LFSR <= i_lfsr_tocheck;         // Toma una seed nueva
            valid <= 0;
            invalid <= invalid + 1;
            if (invalid >= 3)
            begin
                lock <= 0;
                invalid <= 0;
            end
        end
    end
end

assign o_lock = lock;

endmodule
