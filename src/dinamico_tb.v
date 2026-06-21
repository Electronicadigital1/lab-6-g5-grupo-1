`timescale 1ns/1ps

module dinamico_tb;

    reg clk;
    reg reset;
    reg ready_i;
    reg [5:0] sw;

    wire rs;
    wire rw;
    wire enable;
    wire [7:0] data;

    LCD1602_controller #(
        .NUM_COMMANDS(4),
        .NUM_DATA_ALL(32),
        .NUM_DATA_PERLINE(16),
        .DATA_BITS(8),
        .COUNT_MAX(10)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .ready_i(ready_i),
        .sw(sw),
        .rs(rs),
        .rw(rw),
        .enable(enable),
        .data(data)
    );

    // Clock 100 MHz
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("dinamico.vcd");
        $dumpvars(0, dinamico_tb);

        // Estado inicial
        reset   = 0;
        ready_i = 0;
        sw      = 6'b000000;

        #100;

        reset   = 1;
        ready_i = 1;

        // Línea 1 = 0, Línea 2 = 0
        sw = 6'b000000;

        #5000;

        // Línea 1 = 3, Línea 2 = 5
        sw = 6'b011101;

        #5000;

        // Línea 1 = 7, Línea 2 = 2
        sw = 6'b111010;

        #5000;

        // Línea 1 = 1, Línea 2 = 7
        sw = 6'b001111;

        #5000;

        $finish;
    end

endmodule