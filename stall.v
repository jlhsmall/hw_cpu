`timescale 1ns / 1ps
`include "config.v"

module stall (
    input wire rst,
    input wire if_stall, id_stall, ex_stall, mem_stall,
    output reg pc_reg_stall, if_id_stall, id_ex_stall ,ex_mem_stall, mem_wb_stall,
    input wire io_buffer_full
);
always @ (*) begin
    if (rst) begin
        ex_mem_stall = `False;
        id_ex_stall = `False;
        if_id_stall = `False;
        pc_reg_stall = `False;
    end
    else begin
        mem_wb_stall = io_buffer_full;
        ex_mem_stall = mem_stall || mem_wb_stall;
        id_ex_stall = ex_stall || ex_mem_stall;
        if_id_stall = id_stall || id_ex_stall;
        pc_reg_stall = if_stall || if_id_stall;
    end
end
endmodule