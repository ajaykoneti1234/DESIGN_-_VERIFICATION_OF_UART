module uart_rx (
    input clk,
    input rst,
    input rx,
    output reg [7:0] data_out,
    output reg valid
);

parameter BAUD_COUNT = 5208;

reg [12:0] baud_cnt;
reg baud_tick;
reg [3:0] bit_cnt;
reg [1:0] state;
reg [7:0] data_reg;

parameter IDLE=0, START=1, DATA=2, STOP=3;

// ---------------- BAUD ----------------
always @(posedge clk or posedge rst) begin
    if (rst) begin
        baud_cnt <= 0;
        baud_tick <= 0;
    end 
    else if (state != IDLE) begin
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

// ---------------- FSM ----------------
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        valid <= 0;
        bit_cnt <= 0;
    end 
    else begin
        case(state)

        IDLE: begin
            valid <= 0;
            if (rx == 0) begin
                state <= START;
                baud_cnt <= BAUD_COUNT/2; // mid sampling
            end
        end

        START: begin
            if (baud_tick) begin
                if (rx == 0) begin
                    state <= DATA;
                    bit_cnt <= 0;
                end else
                    state <= IDLE;
            end
        end

        DATA: begin
            if (baud_tick) begin
                data_reg[bit_cnt] <= rx;
                bit_cnt <= bit_cnt + 1;

                if (bit_cnt == 7)
                    state <= STOP;
            end
        end

        STOP: begin
            if (baud_tick) begin
                if (rx == 1) begin
                    data_out <= data_reg;
                    valid <= 1;
                end
                state <= IDLE;
            end
        end

        endcase
    end
end

endmodule