# SPI Master (SystemVerilog)

A synthesizable **SPI Master** implemented in **SystemVerilog**, supporting **Mode 0 (CPOL = 0, CPHA = 0)** operation with 8-bit data transfers.  
The design uses FSM-based control, parameterized clock division, and waveform-level verification.

---

## Overview

This project implements a simple and reliable SPI Master suitable for FPGA-based systems.  
The design generates the SPI clock internally and manages chip-select, data transmission, and reception according to the SPI Mode 0 timing specification.

---

## Features

- SPI Master (Mode 0)
- 8-bit data transfers
- Parameterized SPI clock frequency
- FSM-based control logic
- Proper MOSI/MISO timing
- Single-slave support
- Fully synthesizable design

---

## SPI Configuration

- Mode: **SPI Mode 0**
- Clock polarity (CPOL): 0
- Clock phase (CPHA): 0
- Data order: MSB first

Timing behavior:
- MOSI changes on falling edge of SCLK
- MISO sampled on rising edge of SCLK
- CS active low during transaction

---

## File Structure
.
├── spi_master.v # SPI Master RTL
├── spi_master_tb.v # Testbench with dummy slave
└── README.md

---

## Verification

A testbench with a dummy SPI slave was used to verify:
- Correct chip-select behavior
- Proper SPI clock generation
- MOSI/MISO timing correctness
- End-to-end data transfer

Waveforms were analyzed using **GTKWave**.

---

## Simulation

### Requirements
- Icarus Verilog
- GTKWave

### Run simulation
```bash
iverilog -g2012 -o spi_master_tb.vvp spi_master.v spi_master_tb.v
vvp spi_master_tb.vvp
gtkwave spi_master.vcd

Tools Used:
SystemVerilog
Icarus Verilog
GTKWave

