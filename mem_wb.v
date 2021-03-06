`timescale 1ns / 1ps
`include "config.v"

module mem_wb(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire mem_wb_stall,
    input wire [`RegLen - 1 : 0] mem_rd_data,
    input wire [`RegAddrLen - 1 : 0] mem_rd_addr,
    input wire mem_rd_enable,

    output reg [`RegLen - 1 : 0] wb_rd_data,
    output reg [`RegAddrLen - 1 : 0] wb_rd_addr,
    output reg wb_rd_enable,
    input wire mem_stall
    );

always @ (posedge clk) begin
    if (rst) begin
        wb_rd_data <= `ZERO_WORD;
        wb_rd_addr <= `RegAddrZero;
        wb_rd_enable <= `WriteDisable;
    end
    else if (rdy) begin
        if (!mem_wb_stall) begin
            wb_rd_data <= mem_rd_data;
            wb_rd_addr <= mem_rd_addr;
            wb_rd_enable <= mem_stall ? `False :mem_rd_enable;
        end
    end
end
endmodule