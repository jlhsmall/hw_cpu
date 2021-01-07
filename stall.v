`timescale 1ns / 1ps
`include "config.v"

module stall (
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire if_stall, id_stall, ex_stall, mem_stall,
    output reg pc_reg_stall, if_id_stall, id_ex_stall ,ex_mem_stall, mem_wb_stall
);
always @ (*) begin
    if (rst) begin
        mem_wb_stall = `False;
        ex_mem_stall = `False;
        id_ex_stall = `False;
        if_id_stall = `False;
        pc_reg_stall = `False;
    end
    else begin
        mem_wb_stall = mem_stall;
        ex_mem_stall = ex_stall || mem_wb_stall;
        id_ex_stall = id_stall || ex_stall;
        if_id_stall = if_stall || id_ex_stall;
        pc_reg_stall = if_id_stall;
    end
end
endmodule