`timescale 1us/1ns
module tb;

    logic clock_100kHz = 0;
    logic reset = 1;
    logic [31:0] op_A_in;
    logic [31:0] op_B_in;

    logic [31:0] data_out;
    logic [3:0]  status_out;

    PontosFlutuantes dut (
        .clock_100kHz(clock_100kHz),
        .reset(reset), 
        .op_A_in(op_A_in),
        .op_B_in(op_B_in),
        .data_out(data_out),
        .status_out(status_out)
    );

    // Clock: 100kHz → período de 10us = 5us por toggle
    always #5 clock_100kHz = ~clock_100kHz;

    initial begin
        // Reset curto no início
        #5 reset = 0;
        #5 reset = 1;

        // Envio dos operandos: 1.0 e 2.0
        #5;
        op_A_in <= {1'b0, 6'b011111, 25'b0}; // 1.0
        op_B_in <= {1'b0, 6'b100000, 25'b0}; // 2.0

        // Espera o processamento e finaliza simulação
        #180;
        $finish;
    end

endmodule
