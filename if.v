`timescale 1ns / 1ps
`include "config.v"

module ifetch(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire [7:0] mem_din,
    output reg [`AddrLen - 1 : 0] pc;
    output wire [`AddrLen - 1 : 0] if_pc_o;
    output wire [`InstLen - 1 : 0] if_inst_o;
    output wire [`IfStallLen - 1 : 0] if_stall;
)
reg [`InstLen - 1 : 0] inst;
reg [3 : 0] cnt;
always @ (posedge clk) begin
    case (cnt)
        3'b000: inst[7:0] <= mem_din;
        3'b001: inst[15:8] <= mem_din;
        3'b010: inst[23:16] <= mem_din;
        3'b011: inst[31:24] <= mem_din;
    endcase
    cnt <= cnt + 1;
end
always @ (*) begin
    if (cnt == 4) begin
        if_pc_o = pc;
        pc = pc + 4;
        if_inst_o = inst;
        cnt = 3'b000;
        if_stall = 3;
    end
end
endmodule