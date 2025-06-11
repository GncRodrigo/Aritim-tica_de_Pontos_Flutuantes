module PontosFlutuantes(
    input logic clock_100kHz, 
    input logic reset,
    input logic [0:31] op_A_in,
    input logic [0:31] op_B_in,
    output logic [0:31] data_out,
    output logic [0:3] status_out, // 0: exact, 1: overflow, 2: underflow, 3: Inexact
);
endmodule

typedef enum logic [2:0] { 
    READ, // vai ler os dados de entrada a e b
    OPERATION, // vai realizar a operação de adição
    EQUALIZING, // vai igualar os expoentes de A e B
    CHECK, // vai verificar se a operação foi exact, overflow, underflow ou inexact
    WRITE// quando terminar a operação, vai escrever o resultado na saída

} state_t;


state_t EA, EP;
assing EA_queue = EA;
logic [0:5] deslocamento;
logic [0:31] guarda_A, guarda_B;
logic [0:1] count_read;


always_ff @(posedge clock_100kHz, negedge reset) begin
    if(!reset) begin
        op_A_in <= 0;
        count_read <= 0;
        op_B_in <= 0;
        data_out <= 0;
        status_out <= 0;
    end else
    begin
        case(EA)

            READ:begin
                deslocamento <= op_A_in[1:6] - op_B_in[1:6]; 
                count_read <= count_read + 1;
                if(count_read == 1) begin
                    if(deslocamento < 0) begin
                        // Se o deslocamento for negativo, significa que op_B é maior que op_A
                        guarda_A <= op_A_in[7:31] << -deslocamento;
                        op_A_in[7:31] <= op_A_in[7:31] << -deslocamento;
                    end
                    if(deslocamento > 0) begin
                        // Se o deslocamento for positivo, significa que op_A é maior que op_B
                        guarda_B <= op_B_in[7:31] << deslocamento;
                        op_B_in[7:31] <= op_B_in[7:31] << deslocamento;
                    end
                end


            end

            OPERATION:begin
                    if(op_A_in[0] == op_B_in[0]) begin
                        data_out <= op_A_in[7:31] + op_B_in[7:31];
                    end else begin
                        data_out <= op_A_in[7:31] - op_B_in[7:31];
                    end

            end
            EQUALIZING:begin
            // Aqui vamos igualar os expoentes de A e B
                if(deslocamento < 0) begin
                    status_out[1:6] <= op_B_in[1:6];
                    status_out[0] <= op_B_in[0];
                    status_out[7:31] <= status_out[7:31] >> -deslocamento;

                end else begin
                    status_out[1:6] <= op_A_in[1:6];
                    status_out[0] <= op_A_in[0];
                    status_out[7:31] <= status_out[7:31] >> deslocamento;
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
                if(count_read == 1)begin
                    EA <= OPERATION;
                end
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