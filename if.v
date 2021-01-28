`timescale 1ns / 1ps
`include "config.v"

module ifetch(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire [`AddrLen - 1 : 0] if_pc_i,

    output reg [`AddrLen - 1 : 0] if_pc_o,
    output reg [`InstLen - 1 : 0] if_inst_o,
    output reg if_stall,

    output reg [`AddrLen - 1 : 0] if_addr,
    output reg if_request,
    input wire [`InstLen - 1 : 0] if_inst_i,
    input wire if_enable,
    input wire jump_or_not
);

reg [40:0] cache[`CacheSize - 1 : 0];
reg valid[`CacheSize - 1 : 0];
reg nxt_if_request;
integer i;
always @ (posedge clk) begin
    if (rst) begin
        for (i = 0; i < `CacheSize; i = i + 1) valid[i] <= `False;
        if_request <= `False;
    end
    else if (rdy) begin
        if(jump_or_not) begin
            if_request <= `False;
        end
        else begin
            if (if_enable) begin
                cache[if_pc_i[8:2]] <= {if_pc_i[17:9], if_inst_i};
                valid[if_pc_i[8:2]] <= `True;
            end
            if_request <= nxt_if_request;
        end
    end
end

always @ (*) begin
    if_pc_o = `ZERO_WORD;
    if_inst_o = `ZERO_WORD;
    if_stall = `False;
    if_addr = `ZERO_WORD;
    nxt_if_request = `False;
    if(!rst && !jump_or_not) begin
        if (if_request) begin
            if(if_enable) begin
                if_inst_o = if_inst_i;
                if_pc_o = if_pc_i;
            end
            else begin
                if_stall = `True;
                nxt_if_request = `True;
            end
        end
        else begin
            if (valid[if_pc_i[8:2]] && cache[if_pc_i[8:2]][40:32] == if_pc_i[17:9]) begin
                if_inst_o = cache[if_pc_i[8:2]][31:0];
                if_pc_o = if_pc_i;
            end
            else begin
                if_addr = if_pc_i;
                nxt_if_request = `True;
                if_stall = `True;
            end
        end
    end
end
endmodule