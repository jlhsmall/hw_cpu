`timescale 1ns / 1ps
`include "config.v"

module pc_reg(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire pc_reg_stall,
    
    input wire pred_jump_or_not,
    input wire [`AddrLen - 1 : 0] pred_pc,
    input wire failed,
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
        if (!pc_reg_stall) begin
            if (failed) begin
                pc <= npc + 4;
                pc_o <= npc;
            end
            else if (pred_jump_or_not) begin
                pc <= pred_pc + 4;
                pc_o <= pred_pc;
            end
            else begin
                pc_o <= pc;
                pc <= pc + 4;
            end
        end
    end
end

endmodule