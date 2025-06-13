module PontosFlutuantes(
    input logic clock_100kHz, 
    input logic reset,
    input logic [0:31] op_A_in,
    input logic [0:31] op_B_in,
    output logic [0:31] data_out,
    output logic [0:3] status_out // 0: exact, 1: overflow, 2: underflow, 3: Inexact
);


typedef enum logic [1:0] { 
    READ, // vai ler os dados de entrada a e b
    OPERATION, // vai realizar a operação de adição
    EQUALIZING, // vai igualar os expoentes de A e B
    CHECK, // vai verificar se a operação foi exact, overflow, underflow ou inexact
} state_t;


state_t EA, EP;
logic signed [0:5] deslocamento;


// para ficar mais fácil de manipular os bits, vamos separar os campos do ponto flutuante
logic [0:24] mantissa_A, mantissa_B;
logic [0:5] expoente_A, expoente_B;
logic sinal_A, sinal_B;


always_ff @(posedge clock_100kHz, negedge reset) begin
    if(!reset) begin
        deslocamento <= 0;
        guarda_A <= 0;
        guarda_B <= 0;
        data_out <= 0;
        status_out <= 0;
        mantissa_A <= 0;
        mantissa_B <= 0;
        expoente_A <= 0;
        expoente_B <= 0;
        sinal_A <= 0;
        sinal_B <= 0;
    end else
    begin
        case(EA)

            READ:begin
                    //separando os campos do ponto flutuante do A
                    sinal_A <= op_A_in[0];
                    expoente_A <= op_A_in[1:6];
                    mantissa_A <= op_A_in[7:31];

                    //separando os campos do ponto flutuante do B
                    sinal_B <= op_B_in[0];
                    expoente_B <= op_B_in[1:6];
                    mantissa_B <= op_B_in[7:31];

                    //definindo o deslocamento
                    deslocamento <= op_A_in[1:6] - op_B_in[1:6];
            end
                  EQUALIZING:begin
                    if(deslocamento > 0) begin
                        mantissa_B <= mantissa_B >> deslocamento; // shiftando a mantissa B para a direita
                    end else if(deslocamento < 0) begin
                        mantissa_A <= mantissa_A << deslocamento; // shiftando a mantissa A para a direita
                    end
            end

            OPERATION:begin
                         if (sinal_A == sinal_B) begin
                        data_out[7:31]<= mantissa_A + mantissa_B;
                        end else begin
                        data_out[7:31] <= mantissa_A - mantissa_B;
                        end
                        //depois da operação, alinhar os expoentes e os sinais
                        if (expoente_A > expoente_B) begin
                            data_out[1:6] <= expoente_A;
                            data_out[0] <= sinal_A;
                        end else begin
                            data_out[1:6] <= expoente_B;
                            data_out[0] <= sinal_B;                            

                        end
            end
            CHECK:begin
                if ((mantissa_A + mantissa_B) > 24'hFFFFFF) status_out <= 1; // overflow
                if((mantissa_A + mantissa_B) < 24'h000001) status_out <= 2; // underflow

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
              
                    EA <= EQUALIZING;
            end
            EQUALIZING: begin
                if (deslocamento != 0) begin
                    EA <= OPERATION;
                end else begin
                    EA <= OPERATION;
                end
            end
            OPERATION: begin
                EA <= CHECK;
            end
            CHECK:
                EA <= READ; 

        endcase
    end
end

endmodule