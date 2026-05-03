module uart_top (
    input clk,
    input rst,
    input start,
    input [7:0] data_in,
    output [7:0] data_out,
    output valid,
    output tx_busy
);

// Internal wire for loopback connection
wire tx_line;

// ---------------- TX ----------------
uart_tx tx_inst (
    .clk(clk),
    .rst(rst),
    .start(start),
    .data_in(data_in),
    .tx(tx_line),
    .busy(tx_busy)
);

// ---------------- RX ----------------
uart_rx rx_inst (
    .clk(clk),
    .rst(rst),
    .rx(tx_line),     // loopback connection
    .data_out(data_out),
    .valid(valid)
);

endmodule