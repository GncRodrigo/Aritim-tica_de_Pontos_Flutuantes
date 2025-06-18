module PontosFlutuantes(
    input logic clock_100kHz, 
    input logic reset,
    input logic [31:0] op_A_in, // entrada A do ponto flutuante
    input logic [31:0] op_B_in, // entrada B do ponto flutuante
    output logic [31:0] data_out, // saída do ponto flutuante
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
logic [25:0] mantissa_A, mantissa_B, mantissa_A_c, mantissa_B_c; // mantissas auxiliares para A e B
logic [26:0] mantissa_out; // mantissa auxiliar para a saida
logic [5:0] expoente_A, expoente_B, expoente_A_c, expoente_B_c; // expoentes auxiliares para A e B
logic sinal_A, sinal_B, sinal_A_c, sinal_B_c; // sinais auxiliares para A e B
logic comp_reg; // variável para armazenar o resultado do comparador
logic [1:0] start; //para ajudar o controle de READ
logic helper; // ajuda no controle do estado POS_OPERATION
    always_comb begin
        // Calcular o comparador combinatoriamente
        comp_reg = (op_A_in[30:25] >= op_B_in[30:25]);

        // Escolher os sinais de acordo com o comparador
        sinal_A_c = comp_reg ? op_A_in[31] : op_B_in[31];
        sinal_B_c = comp_reg ? op_B_in[31] : op_A_in[31];

        expoente_A_c = comp_reg ? op_A_in[30:25] : op_B_in[30:25];
        expoente_B_c = comp_reg ? op_B_in[30:25] : op_A_in[30:25];

        mantissa_A_c = comp_reg ? {1'b1, op_A_in[24:0]} : {1'b1, op_B_in[24:0]};
        mantissa_B_c = comp_reg ? {1'b1, op_B_in[24:0]} : {1'b1, op_A_in[24:0]};
    end


always_ff @(posedge clock_100kHz, negedge reset) begin
    if(!reset) begin// resetar os valores internos e outputs
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

                start <= start + 1; // incrementa o contador de start para indicar que estamos lendo os dados

                if(start == 1) begin
                sinal_A <= sinal_A_c; // pega o sinal de A
                expoente_A <= expoente_A_c; // pega o expoente de A
                mantissa_A <= mantissa_A_c; // pega a mantissa de A

                sinal_B <= sinal_B_c; // pega o sinal de B
                expoente_B <= expoente_B_c; // pega o expoente de B
                mantissa_B <= mantissa_B_c; // pega a mantissa de B

                deslocamento <= expoente_A_c - expoente_B_c; // calcula o deslocamento necessário para alinhar as mantissas
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

                if (mantissa_out == 0) begin // se a mantissa for zero, não há necessidade de ajuste

                    helper <= 1;

                end else if (mantissa_out[26]) begin // se o bit mais significativo da mantissa for 1, a mantissa será normalizada

                    mantissa_out <= mantissa_out >> 1;
                    expoente_A <= expoente_A + 1;
                    helper <= 0;

                end else if (!mantissa_out[25]) begin // se o segundo bit mais significativo for 0, a mantissa precisa ser ajustada

                    mantissa_out <= mantissa_out << 1;
                    expoente_A <= expoente_A - 1;
                    helper <= 0;

                end else begin
                    // se a mantissa já estiver estabilizada, não há necessidade de ajuste
                    helper <= 1;

                end
            end

            FINALIZE: begin
                // montar o data_out com os valores finais já estabilizados
                data_out[31]    <= sinal_A;
                data_out[30:25] <= expoente_A;
                data_out[24:0]  <= mantissa_out[25:1]; // pega os bits da mantissa já ajustados
              
            end

            CHECK: begin
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

always_ff @(posedge clock_100kHz, negedge reset) begin // controle do estado EA
    if(!reset) begin// se resetar começar por READ
        EA <= READ;
    end else begin
        case(EA)
            READ: begin// quando ser o 3 clock(start == 2) vai para o estado de equalização
                    if(start == 2)begin
                    EA <= EQUALIZING;
                    end
            
            end
            EQUALIZING: begin // faz apenas o deslocamento da mantissa de B para igualar os expoentes
                EA <= OPERATION;
            end
            OPERATION: begin // operação de adição ou subtração das mantissas
                EA <= POS_OPERATION;
            end
            POS_OPERATION: begin// ajuste da mantissa de data_out caso necessário e enquanto nõo estabilizar ficar nesse estado
                if(helper == 1) begin
                    EA <= FINALIZE; // se a mantissa já estiver estabilizada, vai para o estado de finalização
                end else begin
                    EA <= POS_OPERATION; // continua ajustando a mantissa
                end
            end
            FINALIZE: begin// monta o data_out
                EA <= CHECK; // vai para o estado de verificação do status
            end

            CHECK:begin// vau checar qual foi o status da operação
                EA <= READ; 
            end
        endcase
    end
end

endmodule