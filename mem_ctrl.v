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
    input wire [7:0] mem_din,
    
    input wire failed,
    input wire io_buffer_full
);
	
reg [1:0] cnt, ncnt;
reg [31:0] data_in;
reg [1:0] state, next_state;

always @ (*) begin
    ncnt = 2'b00;
    mem_dout = `ZERO_BYTE;
    mem_a = `ZERO_WORD;
    mem_wr = `False;
    next_state = `S_FREE;
    if_inst = `ZERO_WORD;
    load_data = `ZERO_WORD;
    if (!rst) begin
        case (state)
            `S_LOAD: begin
                if (mem_enable) begin
                    load_data = data_in;
                    if (if_request) begin
                        mem_a = if_addr;
                        next_state = `S_IF;
                    end
                end
                else begin
                    if (cnt != num_of_bytes - 1) begin
                        ncnt = cnt + 1;
                        mem_a = mem_addr + ncnt;
                    end
                    next_state = `S_LOAD;
                end
            end
            `S_STORE: begin
                if (mem_enable) begin
                    ncnt = 2'b00;
                    if (if_request) begin
                        mem_a = if_addr;
                        next_state = `S_IF;
                    end
                end
                else begin
                    if (cnt != num_of_bytes - 1) ncnt = cnt + 1;
                    mem_a = mem_addr + cnt;
                    mem_wr = `True;
                    case (cnt)
                        2'b00: mem_dout = store_data[7:0];
                        2'b01: mem_dout = store_data[15:8];
                        2'b10: mem_dout = store_data[23:16];
                        2'b11: mem_dout = store_data[31:24];
                    endcase
                    next_state = `S_STORE;
                end
            end
            `S_IF: begin
                if (failed) begin
                    if (load_or_not) begin
                        mem_a = mem_addr;
                        next_state = `S_LOAD;
                    end
                    else if (store_or_not) begin
                        mem_wr = `True;
                        mem_a = mem_addr;
                        mem_dout = store_data[7:0];
                        next_state = `S_STORE;
                    end
                end
                else if (if_enable) begin
                    if_inst = data_in;
                    if (load_or_not) begin
                        mem_a = mem_addr;
                        next_state = `S_LOAD;
                    end
                    else if (store_or_not) begin
                        next_state = `S_STORE;
                    end
                end
                else begin
                    if (cnt != 2'b11) begin
                        ncnt = cnt + 1;
                        mem_a = if_addr + ncnt;
                    end
                    next_state = `S_IF;
                end
            end
            `S_FREE: begin
                ncnt = 2'b00;
                if (load_or_not) begin
                    mem_a = mem_addr;
                    next_state = `S_LOAD;
                end
                else if (store_or_not) begin
                    next_state = `S_STORE;
                end
                else if (!failed && if_request) begin
                    mem_a = if_addr;
                    next_state = `S_IF;
                end
            end
        endcase
    end
end
always @ (posedge clk, posedge rst) begin
if (!io_buffer_full) begin
    if (rst) begin
        cnt <= 2'b00;
        state <= `S_FREE;
        if_enable <= `False;
        mem_enable <= `False;
        data_in <= `ZERO_WORD;
    end
    else if (rdy) begin
        case (state)
            `S_LOAD: begin
                if_enable <= `False;
                case (cnt)
                    2'b00: data_in[7:0] <= mem_din;
                    2'b01: data_in[15:8] <= mem_din;
                    2'b10: data_in[23:16] <= mem_din;
                    2'b11: data_in[31:24] <= mem_din;
                endcase
                if (cnt == num_of_bytes - 1) mem_enable <= `True;
                else mem_enable <= `False;
            end
            `S_STORE: begin
                if_enable <= `False;
                if (cnt == num_of_bytes - 1) mem_enable <= `True;
                else mem_enable <= `False;
            end
            `S_IF: begin
                mem_enable <= `False;
                if (failed) if_enable <= `False;
                else begin
                    case (cnt)
                        2'b00: data_in[7:0] <= mem_din;
                        2'b01: data_in[15:8] <= mem_din;
                        2'b10: data_in[23:16] <= mem_din;
                        2'b11: data_in[31:24] <= mem_din;
                    endcase
                    if (cnt == 2'b11) if_enable <= `True;
                    else if_enable <= `False;
                end
            end
        endcase
        state <= next_state;
        cnt <= ncnt;
    end
end
end
endmodule