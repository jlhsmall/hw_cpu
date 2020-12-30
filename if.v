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

reg [39:0] cache[`CacheSize - 1 : 0];
always @ (*) begin
    if(rst) begin
        if_pc_o = `ZERO_WORD;
        if_inst_o = `ZERO_WORD;
        if_stall = `False;
        if_addr = `ZERO_WORD;
        if_request = `False;
    end
    else if (rdy && pc_reg_rdy) begin
        if (if_request) begin
            if(if_enable) begin
                if_inst_o = if_inst_i;
                if_pc_o = if_pc_i;
                if_addr = if_pc_i;
                if_request = `False;
                cache[if_pc_i[9:2]][31:0] = if_inst_i;
            end
            else begin
                if_stall = `True;
            end
        end
        else if (cache[if_pc_i[9:2]][39:32] == if_pc_i[17:10]) begin
            if_inst_o = cache[31:0];
        end
        else begin
            if_addr = if_pc_i;
            if_request = `True;
            if_stall = `True;
        end
        if (!if_request) begin
            case (if_inst_i[6:0])
                7'b1101111: if_stall = `True;
                7'b1100111: if_stall = `True;
                7'b1100011: if_stall = `True;
                default: if_stall = `False;
            endcase
        end
    end
    else begin
        if_stall = `False;
    end
end
endmodule