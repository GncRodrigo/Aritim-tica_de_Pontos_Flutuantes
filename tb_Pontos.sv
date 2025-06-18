`timescale 1us/1ns
module tb;

    // Declaração dos sinais
    logic clock_100kHz = 0;
    logic reset = 1;
    logic [31:0] op_A_in;
    logic [31:0] op_B_in;
    logic [31:0] data_out;
    logic [3:0]  status_out;
    
    // Instância do DUT
    PontosFlutuantes dut (
        .clock_100kHz(clock_100kHz),
        .reset(reset),
        .op_A_in(op_A_in),
        .op_B_in(op_B_in),
        .data_out(data_out),
        .status_out(status_out)
    );
    
    // Geração de clock: 100 kHz, período de 10 us (5 us high, 5 us low)
    always #5 clock_100kHz = ~clock_100kHz;
    
    // Sequência de estímulos
    initial begin

        // Pulso de reset curto
        #5 reset = 0;
        #5 reset = 1;
        #5;  // Pequena espera para estabilizar
        
        // Teste 1
        op_A_in <= {1'b0, 6'b011111, 25'b0}; // representa 1.0
        op_B_in <= {1'b0, 6'b100000, 25'b0}; // representa 2.0
        #180;
        
        // Teste 2
        op_A_in <= 32'b1_011111_10000000000000000000000; // representa -1.5
        op_B_in <= 32'b1_100000_01000000000000000000000; // representa -2.5
        #180;
        
        // Teste 3
        op_A_in <= 32'b0_100000_01000000000000000000000; // +2.5
        op_B_in <= 32'b1_100000_01000000000000000000000; // -2.5
        #180;
        
        // Teste 4
        op_A_in <= 32'b0_011010_00110101010101010101010; // valor positivo arbitrário
        op_B_in <= 32'b1_010101_11001100110011001100110; // valor negativo arbitrário
        #180;

        // Teste 5 - Overflow simulado
        op_A_in <= {1'b0, 6'd63, 25'd0};
        op_B_in <= {1'b0, 6'd63, 25'd0};
        #180;

        // Teste 6 - Underflow simulado
        op_A_in <= {1'b0, 6'd1, 25'd0};
        op_B_in <= {1'b1, 6'd1, 25'd0};
        #180;

        // Teste 7 - Soma simples com mesmo expoente
        op_A_in <= {1'b0, 6'd40, 25'd1234567};
        op_B_in <= {1'b0, 6'd40, 25'd7654321};
        #180;

        // Teste 8 - Pequenos valores
        op_A_in <= {1'b0, 6'd35, 25'd1};
        op_B_in <= {1'b1, 6'd34, 25'd2};
        #180;

        // Teste 9 - Cancelamento: -x + x
        op_A_in <= {1'b1, 6'd31, 25'd1000000};
        op_B_in <= {1'b0, 6'd31, 25'd1000000};
        #180;

        // Teste 10 - Expoente com diferença de 1
        op_A_in <= {1'b0, 6'd40, 25'd3333333};
        op_B_in <= {1'b0, 6'd39, 25'd1111111};
        #180;

        
        #5 reset = 0;
        #5 reset = 1;
        #5;  // Pequena espera para estabilizar
        
        #20;
        $finish;
    end

endmodule