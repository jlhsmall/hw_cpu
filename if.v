`timescale 1ns / 1ps
`include "config.v"

module ifetch(
    input wire rst,
    input wire rdy,
    input wire pc_reg_rdy,
    input wire [`AddrLen - 1 : 0] if_pc_i;
    output reg [`AddrLen - 1 : 0] if_pc_o;
    output reg [`InstLen - 1 : 0] if_inst_o;
    output wire if_stall;

    output reg [`AddrLen - 1 : 0] if_addr,
    output reg if_request,
    input wire [`InstLen - 1 : 0] if_inst_i,
    input wire if_enable
)
always @ (*) begin
    if(rst) begin
        if_pc_o = `ZERO_WORD;
        if_inst_o = `ZERO_WORD;
        if_stall = `False;
        if_addr = `ZERO_WORD;
        if_request = `False;
    end
    else if (rdy && pc_reg_rdy) begin
        if(if_enable) begin
            if_stall = `False;
            if_inst_o = if_inst_i;
            if_pc_o = if_pc_i;
            if_addr = if_pc_i;
            if_request = `True;
        end
        else begin
            if_stall = `True;
            if_request = `False;
        end
    end
    else begin
        if_stall = `False;
    end
end
endmodule