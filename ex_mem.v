`timescale 1ns / 1ps
`include "config.v"

module ex_mem(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire ex_mem_stall,
    output wire ex_mem_rdy,

    input wire [`RegLen - 1 : 0] ex_rd_data,
    input wire [`RegAddrLen - 1 : 0] ex_rd_addr,
    input wire [`AddrLen - 1 : 0] mem_addr_ex;
    input wire [`OpLen - 1 : 0] ex_op,

    output reg [`RegLen - 1 : 0] mem_rd_data,
    output reg [`RegAddrLen - 1 : 0] mem_rd_addr,
    output reg [`AddrLen - 1 : 0] mem_addr_i;
    output wire [`OpLen - 1 : 0] mem_op
    );

always @ (posedge clk) begin
    if (rst == `True) begin
        ex_mem_rdy = `False;
        mem_rd_data <= `ZeroReg;
        mem_rd_addr <= `RegAddrZero;
        mem_addr_i <= `ZeroReg;
        mem_op <= `NOP;
    end
    else if (rdy && !ex_mem_stall) begin
        ex_mem_rdy = `True
        mem_rd_data <= ex_rd_data;
        mem_rd_addr <= ex_rd_addr;
        mem_addr_i <= mem_addr_ex;
        mem_op <= ex_op;
    end
    else ex_mem_rdy = `False;
end

endmodule