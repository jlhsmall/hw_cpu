`timescale 1ns / 1ps
`include "config.v"

module if_id(
    input wire clk, 
    input wire rst,
    input wire rdy,
    input wire if_id_stall,
    input wire [`AddrLen - 1 : 0] if_pc,
    input wire [`InstLen - 1 : 0] if_inst,
    output reg [`AddrLen - 1 : 0] id_pc,
    output reg [`InstLen - 1 : 0] id_inst,
    input wire jump_or_not,
    input wire if_stall
    );
    
always @ (posedge clk) begin
    if (rst) begin
        id_inst <= `ZERO_WORD;
        id_pc <= `ZERO_WORD;
    end
    else if (rdy) begin
        if (jump_or_not) begin
            id_inst <= `ZERO_WORD;
            id_pc <= `ZERO_WORD;
        end
        if (!if_id_stall) begin
            id_pc <= if_pc;
            id_inst <= if_stall ? `ZERO_WORD : if_inst;
        end
    end
end
endmodule