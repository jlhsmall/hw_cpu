`timescale 1ns / 1ps
`include "config.v"

module mem_ctrl(
    input wire clk,
    input wire rst,
    input wire rdy,
    //IF
    input wire [`AddrLen - 1 : 0] if_addr,
    input wire if_request,
    output reg [`InstLen - 1 : 0] if_inst,
    output reg if_enable,
    //MEM
    input wire [`AddrLen - 1 : 0] mem_addr,
    input wire load_or_not,
    input wire store_or_not,
    input wire [2:0] num_of_bytes,
    input wire [`RegLen - 1 : 0] store_data,
    output reg [`RegLen - 1 : 0] load_data,
    output reg mem_enable,
    //OUT
    output reg [7:0] mem_dout,
    output reg [31:0] mem_a,
    output reg mem_wr,	
    input wire [7:0] mem_din);
	
reg [2:0] cnt,ncnt;
reg [2:0] state, next_state;
reg [`RegLen - 1 : 0] out_data;

always @ (*) begin
    if (rst) begin
        ncnt = 3'b000;
        next_state = 3'b000;
        mem_dout = `ZERO_BYTE;
        mem_a = `ZERO_WORD;
        mem_wr = `False;
        if_enable = `False;
        if_inst = `ZERO_WORD;
        mem_enable = `False;
        load_data = `ZERO_WORD;
    end
    else if (rdy) begin
        if_enable = `False;
        mem_enable = `False;
        case (state)
            `S_LOAD: begin
                if (cnt == num_of_bytes + 1) begin
                    load_data = out_data;
                    mem_enable = `True;
                    ncnt = 0;
                    if (if_request) begin
                        mem_wr = 0;
                        mem_a = if_addr;
                        next_state = `S_IF;
                    end
                    else next_state = `S_FREE;
                end
                else begin
                    mem_wr = 0;
                    ncnt = cnt + 1;
                    mem_a = mem_addr + cnt;
                    next_state = `S_LOAD;
                end
            end
            `S_STORE: begin
                if (cnt == num_of_bytes + 1) begin
                    mem_enable = `True;
                    ncnt = 0;
                    if (if_request) begin
                        mem_wr = 0;
                        mem_a = if_addr;
                        next_state = `S_IF;
                    end
                    else next_state = `S_FREE;
                end
                else begin
                    mem_wr = 1;
                    mem_a = mem_addr + cnt;
                    ncnt = cnt + 1;
                    next_state = `S_STORE;
                end
            end
            `S_IF: begin
                if (cnt == 3'b101) begin
                    if_inst = out_data;
                    if_enable = `True;
                    ncnt = 0;
                    if (load_or_not) begin
                        mem_wr = 0;
                        mem_a = mem_addr;
                        next_state = `S_LOAD;
                    end
                    else if (store_or_not) begin
                        mem_wr = 1;
                        mem_a = mem_addr;
                        next_state = `S_STORE;
                    end
                    else next_state = `S_FREE;
                end
                else begin
                    mem_wr = 0;
                    mem_a = if_addr + cnt;
                    ncnt = cnt + 1;
                    next_state = `S_IF;
                end
            end
            `S_FREE: begin
                ncnt = 0;
                if (load_or_not) begin
                    mem_wr = 0;
                    mem_a = mem_addr;
                    next_state = `S_LOAD;
                end
                else if (store_or_not) begin
                    mem_wr = 1;
                    mem_a = mem_addr;
                    next_state = `S_STORE;
                end
                else if (if_request) begin
                    mem_wr = 0;
                    mem_a = if_addr;
                    next_state = `S_IF;
                end
                else next_state = `S_FREE;
            end
        endcase
    end
end
always @ (posedge clk, posedge rst) begin
    if (rst) begin
        cnt <= 3'b000;
        state <= `S_FREE;
        out_data <= `ZERO_WORD;
    end
    else if (rdy) begin
        case (state)
            `S_LOAD: begin
                case (cnt)
                    3'b001: out_data[7:0] <= mem_din;
                    3'b010: out_data[15:8] <= mem_din;
                    3'b011: out_data[23:16] <= mem_din;
                    3'b100: out_data[31:24] <= mem_din;
                endcase
            end
            `S_STORE: begin
                case (cnt)
                    3'b000: mem_dout <= store_data[7:0];
                    3'b001: mem_dout <= store_data[15:8];
                    3'b010: mem_dout <= store_data[23:16];
                    3'b011: mem_dout <= store_data[31:24];
                endcase
            end
            `S_IF: begin
                case (cnt)
                    3'b001: out_data[7:0] <= mem_din;
                    3'b010: out_data[15:8] <= mem_din;
                    3'b011: out_data[23:16] <= mem_din;
                    3'b100: out_data[31:24] <= mem_din;
                endcase
            end
        endcase
        state <= next_state;
        cnt <= ncnt;
    end
end
endmodule