module uart_tx (
    input clk, rst, start,
    input [7:0] data_in,
    output reg tx,
    output reg busy
);

parameter BAUD_COUNT = 5208;

reg [12:0] baud_cnt;
reg baud_tick;
reg [3:0] bit_cnt;
reg [9:0] shift_reg;

// ---------------- BAUD GENERATOR ----------------
always @(posedge clk or posedge rst) begin
    if (rst) begin
        baud_cnt <= 0;
        baud_tick <= 0;
    end 
    else if (busy) begin
        if (baud_cnt == BAUD_COUNT-1) begin
            baud_cnt <= 0;
            baud_tick <= 1;
        end else begin
            baud_cnt <= baud_cnt + 1;
            baud_tick <= 0;
        end
    end 
    else begin
        baud_cnt <= 0;
        baud_tick <= 0;
    end
end

// ---------------- TRANSMITTER ----------------
always @(posedge clk or posedge rst) begin
    if (rst) begin
        tx <= 1;
        busy <= 0;
        bit_cnt <= 0;
        shift_reg <= 0;
    end 
    else begin
        // Start transmission
        if (start && !busy) begin
            shift_reg <= {1'b1, data_in, 1'b0}; // stop + data + start
            busy <= 1;
            bit_cnt <= 0;
        end 
        // Transmitting bits
        else if (busy && baud_tick) begin
            tx <= shift_reg[0];
            shift_reg <= shift_reg >> 1;
            bit_cnt <= bit_cnt + 1;

            if (bit_cnt == 9) begin   // 10 bits total
                busy <= 0;
                tx <= 1;  // idle state
            end
        end
    end
end

endmodule