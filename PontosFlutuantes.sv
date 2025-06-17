module PontosFlutuantes(
    input logic clock_100kHz, 
    input logic reset,
    input logic [0:31] op_A_in,
    input logic [0:31] op_B_in,
    output logic [0:31] data_out,
    output logic [0:3] status_out // 0: exact, 1: overflow, 2: underflow, 3: Inexact
);


typedef enum logic [2:0] { 
    READ, // vai ler os dados de entrada a e b
    OPERATION, // vai realizar a operação de adição
    EQUALIZING, // vai igualar os expoentes de A e B
    POS_OPERATION, // vai o ajuste da mantissa de data_out caso necessário
    CHECK // vai verificar se a operação foi exact, overflow, underflow ou inexact
} state_t;


state_t EA;
logic  [0:5] deslocamento;


// para ficar mais fácil de manipular os bits, vamos separar os campos do ponto flutuante
logic [0:24] mantissa_A, mantissa_B;
logic [0:25] mantissa_out;
logic [0:5] expoente_A, expoente_B;
logic sinal_A, sinal_B;
logic comparar;
logic [1:0] start;


always_ff @(posedge clock_100kHz, negedge reset) begin
    if(!reset) begin
        deslocamento <= 0;
        data_out <= 0;
        status_out <= 0;
        mantissa_A <= 0;
        mantissa_B <= 0;
        expoente_A <= 0;
        expoente_B <= 0;
        sinal_A <= 0;
        sinal_B <= 0;
        start <= 0;
    end else
    begin
        case(EA)

            READ:begin // para facilitar, separar as mantissas, expoentes e sinais de A e B, além disso deixar sempre o maior expoente em A
                    if(start == 0 )begin
                        comparar <=  (op_A_in[1:6] >= op_B_in[1:6])? 1'b1 : 1'b0; 
                        start <= 1; 
                    end
                    // A sempre será o maior expoente
                    if(start == 1) begin
                        sinal_A <= comparar ? op_A_in[0] : op_B_in[0];   
                        expoente_A  <= comparar ? op_A_in[1:6] : op_B_in[1:6];   
                        mantissa_A <= comparar ? {1'b1,op_A_in[7:31]} : {1'b1,op_B_in[7:31]}; 
                                
                        // B sempre será o menor expoente
                        sinal_B <= comparar ? op_B_in[0] : op_A_in[0]; 
                        expoente_B  <= comparar ? op_B_in[1:6] : op_A_in[1:6];   
                        mantissa_B <= comparar ? {1'b1,op_B_in[7:31]} : {1'b1,op_A_in[7:31]};     

                        start <= 2; 
                    end
                    if(start == 2) begin
                        deslocamento <= expoente_A - expoente_B;        
                        start <= 3; // reset start para a próxima leitura       
                    end
            end

                  EQUALIZING:begin
                  mantissa_B <= mantissa_B >> deslocamento; // desloca a mantissa de B para alinhar com A
                  start <= 0; // reset start para a próxima leitura
                
            end

            OPERATION:begin

                // agora iremos fazer a operação de adição ou subtração das mantissas
                if(sinal_A == sinal_B) begin
                    
                  
                    mantissa_out <= mantissa_A + mantissa_B; // se os sinais forem iguais, soma as mantissas
                    
            end else begin
                  
                    mantissa_out <= mantissa_A - mantissa_B; // se os sinais forem diferentes, subtrai as mantissas
                    
            end
                        
            end
            POS_OPERATION: begin
                 // antes de fazer a operação iremos completar o expoente e o sinal de data_out
                data_out[0] <= sinal_A; // sinal de A
                data_out[1:6] <= expoente_A; // expoente de A

                            if (mantissa_out[0] == 1) begin // houve carry, precisa normalizar
                    mantissa_out <= mantissa_out >> 1;
                    data_out[1:6] <= data_out[1:6] + 1;
                end else if (mantissa_out[1] == 0 && mantissa_out[2:25] != 0) begin
                    mantissa_out <= mantissa_out << 1;
                    data_out[1:6] <= data_out[1:6] - 1;
                end else begin
                    data_out[7:31] <= mantissa_out[1:25]; // descarta bit oculto
                end
            end

            CHECK: begin
                if (data_out[1:6] >= 6'd63) begin
                    status_out <= 4'd1; // overflow
                end else if (data_out[1:6] <= 6'd0) begin
                    status_out <= 4'd2; // underflow
                end else if (data_out[8:31] == 24'd0) begin
                    status_out <= 4'd3; // inexact (mantissa essencialmente zero)
                end else begin
                    status_out <= 4'd0; // exact
                end
            end


        endcase
    end

end

always_ff @(posedge clock_100kHz, negedge reset) begin
    if(!reset) begin
        EA <= READ;
    end else begin
        case(EA)
            READ: begin
                if (start == 3) begin
                    EA <= EQUALIZING;
                end
            end
            EQUALIZING: begin
                if (deslocamento != 0) begin
                    EA <= OPERATION;
                end else begin
                    EA <= OPERATION;
                end
            end
            OPERATION: begin
                EA <= POS_OPERATION;
            end
            POS_OPERATION: begin
                if(data_out[7] != 0 || data_out[7:31] == 0) begin
                    EA <= CHECK;
                end else begin
                    EA <= POS_OPERATION; // continua ajustando a mantissa
                end
            end
            CHECK:
                EA <= READ; 

        endcase
    end
end

endmodule