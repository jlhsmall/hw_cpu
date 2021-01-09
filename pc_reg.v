`timescale 1ns / 1ps
`include "config.v"

module pc_reg(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire pc_reg_stall,
    output reg pc_reg_rdy,

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
        pc_reg_rdy <= `False;
    end
    else if (jump_or_not) begin
        pc <= npc;
        pc_o <= `ZERO_WORD;
        pc_reg_rdy <= `False;
    end
    else if (rdy && !pc_reg_stall) begin
        pc_o <= pc;
        pc_reg_rdy <= `True;
        pc <= pc + 4;
    end
    else pc_reg_rdy <= `False;
end
/*always @ (posedge clk) begin
    if (rst == `ResetEnable)
        chip_enable <= `ChipDisable;
    else
        chip_enable <= `ChipEnable;
end

always @ (posedge clk) begin
    if (chip_enable == `ChipDisable) begin
        pc <= `ZERO_WORD;
    end
    else begin
        pc <= pc + 4'h4;
    end
end*/

endmodule