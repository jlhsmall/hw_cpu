`timescale 1ns / 1ps
`include "config.v"

module stall (
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire[`IfStallLen - 1 : 0] if_stall,
    input wire[`MemStallLen - 1 : 0] mem_stall,
    output wire stall_or_not
)
reg stall_time;
always @ (posedge clk){
    if (rst) stall_time <= 1'b0;
    else if(rdy) begin
        if (if_stall) stall_time <= if_stall;
        else if (mem_stall) stall_time <= mem_stall;
        if (stall_time > 0) begin
            stall_time = stall_time-1;
            stall_or_not = `True;
        end
        else begin
            stall_or_not = `False;
        end
    end 
}
endmodule