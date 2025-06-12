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
    CHECK, // vai verificar se a operação foi exact, overflow, underflow ou inexact
    WRITE// quando terminar a operação, vai escrever o resultado na saída

} state_t;


state_t EA, EP;
logic signed [0:5] deslocamento;
//variavel para armazenar a mantissa que sera shiftada
logic [0:24] guarda_A, guarda_B;

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
        data_out <= 0;
    end else
    begin
        case(EA)

            READ:begin
                    //separando os campos do ponto flutuante do A
                    signal_A <= op_A_in[0];
                    expoente_A <= op_A_in[1:6];
                    mantissa_A <= op_A_in[7:31];

                    //separando os campos do ponto flutuante do B
                    signal_B <= op_B_in[0];
                    expoente_B <= op_B_in[1:6];
                    mantissa_B <= op_B_in[7:31];

                    //defininco o deslocamento
                    deslocamento <= op_A_in[1:6] - op_B_in[1:6];
            end

            OPERATION:begin
                    if(op_A_in[0] == op_B_in[0]) begin
                        data_out <= op_A_in[7:31] + op_B_in[7:31];
                    end else begin
                        data_out <= op_A_in[7:31] - op_B_in[7:31];
                    end

            end
            EQUALIZING:begin
                //igualando os expoentes de A e B
                if(deslocamento > 0) begin
                    //A é maior que B, então vamos deslocar a mantissa de B
                    mantissa_B <= mantissa_B << deslocamento;
                    expoente_B <= expoente_A; // iguala o expoente de B ao de A
                end else if(deslocamento < 0) begin
                    //B é maior que A, então vamos deslocar a mantissa de A
                    mantissa_A <= mantissa_A << (-deslocamento);
                    expoente_A <= expoente_B; // iguala o expoente de A ao de B

                end
            end

            CHECK:begin
              
         
            end

            WRITE:begin

            end

        endcase
    end

end

always_ff @(posedge clock_100kHz, negedge reset) begin
    if(reset) begin
        EA <= READ;
    end else begin
        case(EA)
            READ: begin
              
                    EA <= EQUALIZING;
            end
            OPERATION: begin
                EA <= CHECK;
            end
            CHECK: begin
                EA <= WRITE;
            end
            WRITE: begin
                EA <= READ;
            end

        endcase
    end
end

endmodule