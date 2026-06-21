`timescale 1ns/1ps

module LCD1602_controller_tb;

    reg clk;
    reg reset;
    reg ready_i;

    wire rs;
    wire rw;
    wire enable;
    wire [7:0] data;

    LCD1602_controller #(
        .NUM_COMMANDS(4),
        .NUM_DATA_ALL(32),
        .NUM_DATA_PERLINE(16),
        .DATA_BITS(8),
        .COUNT_MAX(10)      // Reducido para simular rápido
    ) DUT (
        .clk(clk),
        .reset(reset),
        .ready_i(ready_i),
        .rs(rs),
        .rw(rw),
        .enable(enable),
        .data(data)
    );

    // Clock de 100 MHz
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("lcd.vcd");
        $dumpvars(0, LCD1602_controller_tb);

        reset = 0;
        ready_i = 0;

        #100;

        reset = 1;
        ready_i = 1;

        #5000;

        $finish;
    end

endmodule