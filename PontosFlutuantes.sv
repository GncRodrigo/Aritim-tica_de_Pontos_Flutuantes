module PontosFlutuantes(
    input logic clock_100kHz, 
    input logic reset,
    input logic [31:0] op_A_in,
    input logic [31:0] op_B_in,
    output logic [2:0] qual_lugar,
    output logic [31:0] data_out,
    output logic [3:0] status_out // 0: exact, 1: overflow, 2: underflow, 3: Inexact
);


typedef enum logic [2:0] { 
    READ, // vai ler os dados de entrada a e b
    OPERATION, // vai realizar a operação de adição
    EQUALIZING, // vai igualar os expoentes de A e B
    POS_OPERATION, // vai o ajuste da mantissa de data_out caso necessário
    FINALIZE, // vai montar o data_out com os valores finais já estabilizados
    CHECK // vai verificar se a operação foi exact, overflow, underflow ou inexact
} state_t;


state_t EA;
logic  [5:0] deslocamento;


// para ficar mais fácil de manipular os bits, vamos separar os campos do ponto flutuante
logic [24:0] mantissa_A, mantissa_B;
logic [26:0] mantissa_out;
logic [5:0] expoente_A, expoente_B;
logic sinal_A, sinal_B;
logic comparar;
logic [1:0] start;
logic helper;


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
        helper <= 0;
    end else
    begin
        case(EA)

            READ:begin // para facilitar, separar as mantissas, expoentes e sinais de A e B, além disso deixar sempre o maior expoente em A
                    if(start == 0 )begin
                        helper <= 0; // reset helper
                        qual_lugar <= 0;
                        comparar <=  (op_A_in[30:25] >= op_B_in[30:25])? 1'b1 : 1'b0; 
                        start <= 1; 
                    end
                    // A sempre será o maior expoente
                    if(start == 1) begin
                        sinal_A <= comparar ? op_A_in[31] : op_B_in[31];   
                        expoente_A  <= comparar ? op_A_in[30:25] : op_B_in[30:25];   
                        mantissa_A <= comparar ? {1'b1,op_A_in[24:0]} : {1'b1,op_B_in[24:0]}; 
                                
                        // B sempre será o menor expoente
                        sinal_B <= comparar ? op_B_in[31] : op_A_in[31]; 
                        expoente_B  <= comparar ? op_B_in[30:25] : op_A_in[30:25];   
                        mantissa_B <= comparar ? {1'b1,op_B_in[24:0]} : {1'b1,op_A_in[24:0]};     

                        start <= 2; 
                    end
                    if(start == 2) begin
                        deslocamento <= expoente_A - expoente_B;        
                        start <= 3; // reset start para a próxima leitura       
                    end
            end

                  EQUALIZING:begin
                    qual_lugar <= 1; // indica que estamos no processo de equalização
                  mantissa_B <= mantissa_B >> deslocamento; // desloca a mantissa de B para alinhar com A
                  start <= 0; // reset start para a próxima leitura
                
            end

            OPERATION:begin
                qual_lugar <= 2; // indica que estamos na operação de adição ou subtração
                // agora iremos fazer a operação de adição ou subtração das mantissas
                if(sinal_A == sinal_B) begin
                    
                  
                    mantissa_out <= mantissa_A + mantissa_B; // se os sinais forem iguais, soma as mantissas
                    
            end else begin
                  
                    mantissa_out <= mantissa_A - mantissa_B; // se os sinais forem diferentes, subtrai as mantissas
                    
            end
                        
            end
            POS_OPERATION: begin
                qual_lugar <= 3;

                if (mantissa_out == 0) begin
                    helper <= 1;
                end else if (mantissa_out[26]) begin
                    mantissa_out <= mantissa_out >> 1;
                    expoente_A <= expoente_A + 1;
                    helper <= 0;
                end else if (!mantissa_out[25]) begin
                    mantissa_out <= mantissa_out << 1;
                    expoente_A <= expoente_A - 1;
                    helper <= 0;
                end else begin
                    helper <= 1;
                end
            end

            // Novo estado para montar data_out com os valores finais já estabilizados
            FINALIZE: begin
                qual_lugar <= 5;
                data_out[31]    <= sinal_A;
                data_out[30:25] <= expoente_A;
                data_out[24:2]  <= mantissa_out[25:1]; // pega os bits da mantissa já ajustados
              
            end

            CHECK: begin
                qual_lugar <= 4; // indica que estamos no processo de verificação do status
                if (expoente_A >= 6'd63) begin
                    status_out <= 4'd1; // overflow
                end else if (expoente_A <= 6'd0) begin
                    status_out <= 4'd2; // underflow
                end else if (mantissa_out[25:2] == 24'd0) begin
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
                EA <= OPERATION;
            end
            OPERATION: begin
                EA <= POS_OPERATION;
            end
            POS_OPERATION: begin
                if(helper == 1) begin
                    EA <= FINALIZE; // se a mantissa já estiver estabilizada, vai para o estado de finalização
                end else begin
                    EA <= POS_OPERATION; // continua ajustando a mantissa
                end
            end
            FINALIZE: begin
                EA <= CHECK; // vai para o estado de verificação do status
            end

            CHECK:begin
                EA <= READ; 
            end

        endcase
    end
end

endmodule