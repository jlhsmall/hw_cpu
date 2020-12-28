`timescale 1ns / 1ps
`include "config.v"

module ex_mem(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire stall_or_not,
    input wire [`RegLen - 1 : 0] ex_rd_data,
    input wire [`RegAddrLen - 1 : 0] ex_rd_addr,
    input wire [`OpLen - 1 : 0] ex_op,

    output reg [`RegLen - 1 : 0] mem_rd_data,
    output reg [`RegAddrLen - 1 : 0] mem_rd_addr,
    output wire [`OpLen - 1 : 0] mem_op
    );

always @ (posedge clk) begin
    if (rst == `ResetEnable) begin
        //TODO: Reset
        mem_rd_data <= `ZeroReg;
        mem_rd_addr <= `RegAddrZero;
        mem_op <= `NOP;
    end
    else if (rdy || !stall_or_not) begin
        mem_rd_data <= ex_rd_data;
        mem_rd_addr <= ex_rd_addr;
        mem_op <= ex_op;
    end
end

endmodule