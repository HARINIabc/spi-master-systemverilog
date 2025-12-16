`timescale 1ns/1ps

module spi_master_tb;

    reg clk;
    reg rst;
    reg start;
    reg [7:0] tx_data;

    wire sclk;
    wire mosi;
    wire cs;
    wire miso;
    wire [7:0] rx_data;
    wire done;

    // -----------------------------------
    // Dummy SPI slave (loopback-like)
    // -----------------------------------
    reg [7:0] slave_shift;

    assign miso = slave_shift[7];

    always @(negedge sclk) begin
        if (!cs) begin
            slave_shift <= {slave_shift[6:0], mosi};
        end
    end

    // -----------------------------------
    // DUT
    // -----------------------------------
    spi_master #(
        .CLK_FREQ(50_000_000),
        .SPI_FREQ(1_000_000)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .tx_data(tx_data),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .cs(cs),
        .rx_data(rx_data),
        .done(done)
    );

    // -----------------------------------
    // Clock (50 MHz)
    // -----------------------------------
    always #10 clk = ~clk;

    // -----------------------------------
    // Test sequence
    // -----------------------------------
    initial begin
        $dumpfile("spi_master.vcd");
        $dumpvars(0, spi_master_tb);

        clk = 0;
        rst = 1;
        start = 0;
        tx_data = 8'h00;
        slave_shift = 8'h3C; // slave sends 0x3C

        #100;
        rst = 0;

        #200;
        tx_data = 8'hA5;
        start = 1;
        #20;
        start = 0;

        wait (done);

        #200;
        $finish;
    end

    initial begin
        $monitor(
            "t=%0t | CS=%b SCLK=%b MOSI=%b MISO=%b | RX=0x%02h DONE=%b",
            $time, cs, sclk, mosi, miso, rx_data, done
        );
    end

endmodule
