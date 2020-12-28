`timescale 1ns / 1ps
`include "config.v"

module id_ex(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire stall_or_not,
    input wire [`AddrLen - 1 : 0] id_pc;
    input wire [`RegLen - 1 : 0] id_reg1,
    input wire [`RegLen - 1 : 0] id_reg2,
    input wire [`RegLen - 1 : 0] id_Imm,
    input wire [`RegAddrLen - 1 : 0] id_rd,
    input wire [`OpLen - 1 : 0] id_op,
    
    output wire [`AddrLen - 1 : 0] ex_pc;
    output wire [`RegLen - 1 : 0] ex_reg1,
    output wire [`RegLen - 1 : 0] ex_reg2,
    output wire [`RegLen - 1 : 0] ex_Imm,
    output wire [`RegAddrLen - 1 : 0] ex_rd,
    output wire [`OpLen - 1 : 0] ex_op
    );

always @ (posedge clk) begin
    if (rst == `ResetEnable) begin
        //TODO: ASSIGN ALL OUTPUT WITH NULL EQUIVALENT
        ex_reg1 <= `ZERO_WORD;
        ex_reg2 <= `ZERO_WORD;
        ex_Imm <= `ZERO_WORD;
        ex_rd <= `ZERO_WORD;
        ex_op <= `NOP;
    end
    else if (rdy || !stall_or_not) begin
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_Imm <= id_Imm;
        ex_rd <= id_rd;
        ex_op <= id_op;
    end
end

endmodule