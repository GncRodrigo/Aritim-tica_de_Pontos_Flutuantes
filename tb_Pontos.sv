`timescale 1us/1ps
module tb;

    logic clock_100kHz= 0;
    logic reset = 1;
    logic[31:0] op_A_in;
    logic[31:0] op_B_in;

    logic[31:0] data_out;
    logic[3:0] status_out;
tbPontos dut(
     .clock_100kHz(clock_100kHz),
     .reset(reset), 
     .Op_A_in(op_A_in),
     .Op_B_in(op_B_in),
     .data_out(da),
     .status_out(status_out)
);

always begin
        #5 clock_100kHz = ~clock_100kHz;
    end

    initial begin
        #5;
        reset = 0;
        #5;
        reset = 1; 
        #5;
        op_A_in <= {1'b0, 6'b011111, 25'b0}; // 1.0
        op_B_in <= {1'b0, 6'b100000, 25'b0}; // 2.0
        #180;
        $finish;
    end



endmodule