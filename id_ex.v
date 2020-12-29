`timescale 1ns / 1ps
`include "config.v"

module id_ex(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire id_ex_stall,
    output wire id_ex_rdy,

    input wire [`AddrLen - 1 : 0] id_pc;
    input wire [`RegLen - 1 : 0] id_reg1,
    input wire [`RegLen - 1 : 0] id_reg2,
    input wire [`RegLen - 1 : 0] id_Imm,
    input wire [`RegAddrLen - 1 : 0] id_rd,
    input wire [`OpLen - 1 : 0] id_op,
    
    output reg [`AddrLen - 1 : 0] ex_pc;
    output reg [`RegLen - 1 : 0] ex_reg1,
    output reg [`RegLen - 1 : 0] ex_reg2,
    output reg [`RegLen - 1 : 0] ex_Imm,
    output reg [`RegAddrLen - 1 : 0] ex_rd,
    output reg [`OpLen - 1 : 0] ex_op
    );

always @ (posedge clk) begin
    if (rst == `True) begin
        id_ex_rdy = `False;
        ex_pc <= `ZERO_WORD;
        ex_reg1 <= `ZERO_WORD;
        ex_reg2 <= `ZERO_WORD;
        ex_Imm <= `ZERO_WORD;
        ex_rd <= `ZERO_WORD;
        ex_op <= `NOP;
    end
    else if (rdy && !id_ex_stall) begin
        id_ex_rdy <= `True;
        ex_pc <= id_pc;
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_Imm <= id_Imm;
        ex_rd <= id_rd;
        ex_op <= id_op;
    end
    else id_ex_rdy = `False;
end

endmodule