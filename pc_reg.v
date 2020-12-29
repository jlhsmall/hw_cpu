`timescale 1ns / 1ps
`include "config.v"

module pc_reg(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire pc_reg_stall,
    output wire pc_reg_rdy,

    output reg [`AddrLen - 1 : 0] pc,
    /*,
    output reg chip_enable*/);

always @ (posedge clk) begin
    if (rst) begin
        pc <= `ZERO_WORD;
        pc_reg_rdy <= `false;
    end
    else if (rdy && !pc_reg_stall) begin
        pc <= pc + 4;
        pc_reg_rdy <= `True;
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