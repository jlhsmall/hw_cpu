`timescale 1ns / 1ps
`include "config.v"

module id_ex(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire id_ex_stall,

    input wire [`AddrLen - 1 : 0] id_pc,
    input wire [`RegLen - 1 : 0] id_reg1,
    input wire [`RegLen - 1 : 0] id_reg2,
    input wire [`RegLen - 1 : 0] id_imm,
    input wire [`RegAddrLen - 1 : 0] id_rd,
    input wire [`OpLen - 1 : 0] id_op,
    
    output reg [`AddrLen - 1 : 0] ex_pc,
    output reg [`RegLen - 1 : 0] ex_reg1,
    output reg [`RegLen - 1 : 0] ex_reg2,
    output reg [`RegLen - 1 : 0] ex_imm,
    output reg [`RegAddrLen - 1 : 0] ex_rd,
    output reg [`OpLen - 1 : 0] ex_op,
    input wire jump_or_not,
    input wire id_stall
    );

always @ (posedge clk) begin
    if (rst) begin
        ex_pc <= `ZERO_WORD;
        ex_reg1 <= `ZERO_WORD;
        ex_reg2 <= `ZERO_WORD;
        ex_imm <= `ZERO_WORD;
        ex_rd <= `ZERO_WORD;
        ex_op <= `NOP;
    end
    else if (rdy) begin
        if (jump_or_not) begin
            ex_pc <= `ZERO_WORD;
            ex_reg1 <= `ZERO_WORD;
            ex_reg2 <= `ZERO_WORD;
            ex_imm <= `ZERO_WORD;
            ex_rd <= `ZERO_WORD;
            ex_op <= `NOP;
        end
        else if(!id_ex_stall) begin
            if (id_stall) begin
                ex_pc <= `ZERO_WORD;
                ex_reg1 <= `ZERO_WORD;
                ex_reg2 <= `ZERO_WORD;
                ex_imm <= `ZERO_WORD;
                ex_rd <= `RegAddrZero;
                ex_op <= `NOP;
            end
            else begin
                ex_pc <= id_pc;
                ex_reg1 <= id_reg1;
                ex_reg2 <= id_reg2;
                ex_imm <= id_imm;
                ex_rd <= id_rd;
                ex_op <= id_op;
            end
        end
    end
end

endmodule