`timescale 1us/1ns
module tb;

    // Declaração dos sinais
    logic clock_100kHz = 0;
    logic reset = 1;
    logic [31:0] op_A_in;
    logic [31:0] op_B_in;
    logic [31:0] data_out;
    logic [3:0]  status_out;
    logic [2:0]  qual_lugar;
    
    // Instância do DUT
    PontosFlutuantes dut (
        .clock_100kHz(clock_100kHz),
        .reset(reset),
        .op_A_in(op_A_in),
        .op_B_in(op_B_in),
        .data_out(data_out),
        .status_out(status_out),
        .qual_lugar(qual_lugar)
    );
    
    // Geração de clock: 100 kHz, período de 10 us (5 us high, 5 us low)
    always #5 clock_100kHz = ~clock_100kHz;
    
    // Sequência de estímulos
    initial begin
        $display("Iniciando simulação");
        // Pulso de reset curto
        #5 reset = 0;
        #5 reset = 1;
        #5;  // Pequena espera para estabilizar
        
   
        op_A_in <= {1'b0, 6'b011111, 25'b0}; // representa 1.0
        op_B_in <= {1'b0, 6'b100000, 25'b0}; // representa 2.0
        #180;
        
    
        op_A_in <= 32'b1_011111_10000000000000000000000; // representa -1.5 (exemplo)
        op_B_in <= 32'b1_100000_01000000000000000000000; // representa -2.5 (exemplo)
        #180;
        
      =
        op_A_in <= 32'b0_100000_01000000000000000000000; // representa +2.5 (exemplo)
        op_B_in <= 32'b1_100000_01000000000000000000000; // representa -2.5 (exemplo)
        #180;
        
      
        op_A_in <= 32'b0_011010_00110101010101010101010; // valor positivo arbitrário
        op_B_in <= 32'b1_010101_11001100110011001100110; // valor negativo arbitrário
        #180;

        reset = 0; // Pulso de reset para reiniciar o DUT
        #5 reset = 1; // Reativar o DUT
        
        $finish;
    end

endmodule