import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

@cocotb.test()
async def test_mvm(dut):

    dut._log.info("start")

    clock = Clock(dut.clk, 1, units= 'ns')
    cocotb.start_soon(clock.start())

    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    dut.ena.value = 1

    VALUES = [32,14,15,7]
    ROWS = [0,1,1,2]
    COLS = [2,0,2,1]
    i = 0

    ui_in = [0]*8
    ui_in[7] = 0
    ui_in[6] = 0
    ui_in[5] = 1
    ui_in[4] = 0
    ui_in[3] = 1
    ui_in[2] = 0
    ui_in[1] = 0
    ui_in[0] = 0

    dut.ui_in.value = VALUES[i]
    dut.uio_in.value = 0b00101000
    dut._log.info(list)

    await ClockCycles(dut.clk, 10)
    
    i=1
    ui_in[7] = 0
    ui_in[6] = 1
    ui_in[5] = 0
    ui_in[4] = 0
    ui_in[3] = 1
    ui_in[2] = 0
    ui_in[1] = 0
    ui_in[0] = 0
    
    dut.ui_in.value = VALUES[i]
    dut.uio_in.value = 0b01001000
    

    await ClockCycles(dut.clk, 10)

    i=2
    ui_in[7] = 0
    ui_in[6] = 1
    ui_in[5] = 1
    ui_in[4] = 0
    ui_in[3] = 1
    ui_in[2] = 0
    ui_in[1] = 0
    ui_in[0] = 0
    
    dut.ui_in.value = VALUES[i]
    dut.uio_in.value = 0b01101000

    await ClockCycles(dut.clk, 10)

    i=3
    ui_in[7] = 1
    ui_in[6] = 0
    ui_in[5] = 0
    ui_in[4] = 1
    ui_in[3] = 1
    ui_in[2] = 0
    ui_in[0] = 0
    ui_in[1] = 0

    
    dut.ui_in.value = VALUES[i]
    dut.uio_in.value = 0b10011000

    


    for _ in range(100):    # runs for 100 clk cycles
        await RisingEdge(dut.clk)
    
    dut._log.info("Finished Test!")