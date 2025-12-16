`timescale 1ns/1ps

module spi_master #(
    parameter CLK_FREQ = 50_000_000, // Hz
    parameter SPI_FREQ = 1_000_000   // 1 MHz SPI clock
)(
    input  wire clk,
    input  wire rst,

    input  wire        start,     // start transaction
    input  wire [7:0]  tx_data,   // data to send

    output reg         sclk,      // SPI clock
    output reg         mosi,      // master out
    input  wire        miso,      // master in
    output reg         cs,        // chip select (active low)

    output reg  [7:0]  rx_data,   // received data
    output reg         done       // 1-cycle pulse when done
);

    // --------------------------------------------------
    // Clock divider for SPI clock
    // --------------------------------------------------
    localparam integer DIV = CLK_FREQ / (2 * SPI_FREQ);

    reg [$clog2(DIV)-1:0] div_cnt;
    reg spi_tick;

    always @(posedge clk) begin
        if (rst) begin
            div_cnt <= 0;
            spi_tick <= 0;
        end else if (div_cnt == DIV - 1) begin
            div_cnt <= 0;
            spi_tick <= 1'b1;
        end else begin
            div_cnt <= div_cnt + 1'b1;
            spi_tick <= 1'b0;
        end
    end

    // --------------------------------------------------
    // FSM states
    // --------------------------------------------------
    localparam IDLE  = 2'd0;
    localparam LOAD  = 2'd1;
    localparam SHIFT = 2'd2;
    localparam DONE  = 2'd3;

    reg [1:0] state;
    reg [2:0] bit_cnt;
    reg [7:0] tx_shift;
    reg [7:0] rx_shift;

    // --------------------------------------------------
    // SPI Master FSM (Mode 0: CPOL=0, CPHA=0)
    // --------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            state    <= IDLE;
            cs       <= 1'b1;
            sclk     <= 1'b0;
            mosi     <= 1'b0;
            done     <= 1'b0;
            bit_cnt  <= 3'd0;
            tx_shift <= 8'd0;
            rx_shift <= 8'd0;
            rx_data  <= 8'd0;
        end else begin
            done <= 1'b0;

            case (state)

                // ---------------- IDLE ----------------
                IDLE: begin
                    cs   <= 1'b1;
                    sclk <= 1'b0;

                    if (start) begin
                        tx_shift <= tx_data;
                        bit_cnt  <= 3'd7;
                        cs        <= 1'b0;
                        state     <= LOAD;
                    end
                end

                // ---------------- LOAD ----------------
                LOAD: begin
                    mosi  <= tx_shift[7]; // MSB first
                    state <= SHIFT;
                end

                // ---------------- SHIFT ----------------
                SHIFT: begin
                    if (spi_tick) begin
                        sclk <= ~sclk;

                        // Rising edge: sample MISO
                        if (sclk == 1'b0) begin
                            rx_shift <= {rx_shift[6:0], miso};
                        end
                        // Falling edge: shift MOSI
                        else begin
                            tx_shift <= {tx_shift[6:0], 1'b0};

                            if (bit_cnt == 0) begin
                                state <= DONE;
                            end else begin
                                bit_cnt <= bit_cnt - 1'b1;
                                mosi    <= tx_shift[6];
                            end
                        end
                    end
                end

                // ---------------- DONE ----------------
                DONE: begin
                    cs      <= 1'b1;
                    sclk    <= 1'b0;
                    rx_data <= rx_shift;
                    done    <= 1'b1;
                    state   <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
