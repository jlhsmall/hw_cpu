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

    input wire pred_jump_or_not_i,
    output reg pred_jump_or_not_o,
    input wire failed,
    input wire if_stall
    );
    
always @ (posedge clk) begin
    if (rst) begin
        id_inst <= `ZERO_WORD;
        id_pc <= `ZERO_WORD;
        pred_jump_or_not_o <= `False;
    end
    else if (rdy) begin
        if (!if_id_stall) begin
            if (failed || if_stall) begin
                id_inst <= `ZERO_WORD;
                id_pc <= `ZERO_WORD;
                pred_jump_or_not_o <= `False;
            end
            else begin
                id_pc <= if_pc;
                id_inst <= if_inst;
                pred_jump_or_not_o <= pred_jump_or_not_i;
            end
            
        end
    end
end
endmodule