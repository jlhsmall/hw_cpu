`timescale 1ns / 1ps
`include "config.v"

module stall (
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire if_stall, id_stall, ex_stall, mem_stall,
    output wire pc_reg_stall, if_id_stall, id_ex_stall ,ex_mem_stall;
)
reg [1:0] if_cnt;
always @ (*) begin
    mem_wb_stall = mem_stall;
    ex_mem_stall =ex_stall || mem_wb_stall;
    id_ex_stall = id_stall || ex_stall;
    if_id_stall = if_stall || id_ex_stall;
    if (if_stall) begin
        if_cnt = 2'b10;
        pc_reg_stall = `True;
    end
    else pc_reg_stall = if_cnt || if_id_stall;
end
always @ (negedge clk) begin
    if (rdy && if_cnt) if_cnt = if_cnt - 1;
end
always @ (posedge clk) begin
    if (rst) if_cnt = 2'b00;
end
endmodule