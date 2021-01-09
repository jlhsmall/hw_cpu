`timescale 1ns / 1ps
`include "config.v"

module if_id(
    input wire clk, 
    input wire rst,
    input wire rdy,
    input wire if_id_stall,
    output reg if_id_rdy,
    input wire [`AddrLen - 1 : 0] if_pc,
    input wire [`InstLen - 1 : 0] if_inst,
    output reg [`AddrLen - 1 : 0] id_pc,
    output reg [`InstLen - 1 : 0] id_inst,
    input wire jump_or_not,
    input wire if_stall
    );
    
always @ (posedge clk) begin
    if (rst || jump_or_not) begin
        if_id_rdy <= `False;
        id_inst <= `ZERO_WORD;
        id_pc <= `ZERO_WORD;
    end
    else if (rdy && !if_id_stall) begin
        if_id_rdy <= `True;
        id_pc <= if_pc;
        id_inst <= if_stall ? `ZERO_WORD : if_inst;
    end
    else if_id_rdy <= `False;
end
endmodule