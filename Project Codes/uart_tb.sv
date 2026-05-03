`timescale 1ns/1ps

module uart_tb;

logic clk = 0, rst, start;
logic [7:0] data_in, data_out;
logic valid, tx_busy;

// DUT
uart_top dut (.*);

// Clock
always #10 clk = ~clk;

// Send task
task send(input [7:0] d);
begin
    @(posedge clk);
    while (tx_busy) @(posedge clk);
    data_in = d; 
    start = 1;
    @(posedge clk);
    start = 0;
end
endtask

// Test
initial begin
    rst = 1; start = 0; data_in = 0;

    repeat(5) @(posedge clk);   // hold reset for 5 clock cycles
    rst = 0;
    send(8'hA5); wait(valid);
    send(8'h3C); wait(valid);
    send(8'hF0); wait(valid);

    repeat(3) begin
        send($urandom_range(0,255));
        wait(valid);
    end

    #200 $finish;
end

// Display result
always @(posedge clk)
    if (valid)
        $display("Received = %h", data_out);

endmodule