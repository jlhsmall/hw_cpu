`timescale 1ns / 1ps
`include "config.v"

module pc_reg(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire pc_reg_stall,

    input wire jump_or_not,
    input wire [`AddrLen - 1 : 0] npc,
    output reg [`AddrLen - 1 : 0] pc_o
    /*,
    output reg chip_enable*/);
reg [`AddrLen - 1 : 0] pc;
always @ (posedge clk) begin
    if (rst) begin
        pc <= `ZERO_WORD;
        pc_o <= `ZERO_WORD;
    end
    else if (rdy) begin
        if (jump_or_not) begin
            pc <= npc + 4;
            pc_o <= npc;
        end
        else if (!pc_reg_stall) begin
            pc_o <= pc;
            pc <= pc + 4;
        end
    end
end

endmodule