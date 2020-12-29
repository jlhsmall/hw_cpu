`timescale 1ns / 1ps
`include "config.v"

module stall (
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire if_stall, id_stall, ex_stall, mem_stall,
    output wire pc_reg_stall, if_id_stall, id_ex_stall ,ex_mem_stall;
)
always @ (*){
    ex_mem_stall = mem_stall;
    id_ex_stall = ex_stall || ex_mem_stall;
    if_id_stall = id_stall || id_ex_stall;
    pc_reg_stall = if_stall || if_id_stall;
}
endmodule