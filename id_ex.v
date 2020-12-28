`timescale 1ns / 1ps
`include "config.v"

module id_ex(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire stall_or_not,
    input wire [`RegLen - 1 : 0] id_reg1,
    input wire [`RegLen - 1 : 0] id_reg2,
    input wire [`RegLen - 1 : 0] id_Imm,
    input wire [`RegLen - 1 : 0] id_rd,
    input wire id_rd_enable,
    input wire [`OpCodeLen - 1 : 0] id_aluop,
    input wire [`OpSelLen - 1 : 0] id_alusel,

    output reg [`RegLen - 1 : 0] ex_reg1,
    output reg [`RegLen - 1 : 0] ex_reg2,
    output reg [`RegLen - 1 : 0] ex_Imm,
    output reg [`RegLen - 1 : 0] ex_rd,
    output reg ex_rd_enable,
    output reg [`OpCodeLen - 1 : 0] ex_aluop,
    output reg [`OpSelLen - 1 : 0] ex_alusel
    );

always @ (posedge clk) begin
    if (rst == `ResetEnable) begin
        //TODO: ASSIGN ALL OUTPUT WITH NULL EQUIVALENT
        ex_reg1 <= `ZERO_WORD;
        ex_reg2 <= `ZERO_WORD;
        ex_Imm <= `ZERO_WORD;
        ex_rd <= `ZERO_WORD;
        ex_rd_enable <= `False;
        ex_aluop <= `OpCodeZero;
        ex_alusel <= `OpSelZero;
    end
    else if (rdy || stall_or_not) begin
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_Imm <= id_Imm;
        ex_rd <= id_rd;
        ex_rd_enable <= id_rd_enable;
        ex_aluop <= id_aluop;
        ex_alusel <= id_alusel;
    end
end

endmodule