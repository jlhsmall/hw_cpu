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
    
    input wire jump_or_not
);
	
reg [1:0] cnt, ncnt;
reg [1:0] state, next_state;

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
    else begin
        if_enable = `False;
        mem_enable = `False;
        case (state)
            `S_LOAD: begin
                case (cnt)
                    2'b00: begin
                        ncnt = 2'b01;
                        load_data[7:0] = mem_din;
                        mem_a = mem_addr + 1;
                    end
                    2'b01: begin
                        ncnt = 2'b10;
                        load_data[15:8] = mem_din;
                        mem_a = mem_addr + 2;
                    end
                    2'b10: begin
                        ncnt = 2'b11;
                        load_data[23:16] = mem_din;
                        mem_a = mem_addr + 3;
                    end
                    2'b11: begin
                        load_data[31:24] = mem_din;
                        ncnt = 2'b00;
                    end
                endcase
                if (cnt == num_of_bytes - 1) begin
                    mem_enable = `True;
                    ncnt = 2'b00;
                    if (if_request) begin
                        mem_a = if_addr;
                        next_state = `S_IF;
                    end
                    else next_state = `S_FREE;
                end
                else  next_state = `S_LOAD;
            end
            `S_STORE: begin
                if (cnt == num_of_bytes - 1) begin
                    mem_enable = `True;
                    mem_wr = `False;
                    mem_a = `ZERO_WORD;
                    ncnt = 2'b00;
                    if (if_request) begin
                        mem_a = if_addr;
                        next_state = `S_IF;
                    end
                    else next_state = `S_FREE;
                end
                else begin
                    case (cnt)
                        2'b00: begin
                            ncnt = 2'b01;
                            mem_dout = store_data[15:8];
                            mem_a = mem_addr + 1;
                        end
                        2'b01: begin
                            ncnt = 2'b10;
                            mem_dout = store_data[23:16];
                            mem_a = mem_addr + 2;
                        end
                        2'b10: begin
                            ncnt = 2'b11;
                            mem_dout = store_data[31:24];
                            mem_a = mem_addr + 3;
                        end
                    endcase
                end
            end
            `S_IF: begin
                if (jump_or_not) begin
                    ncnt = 2'b00;
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
                    else next_state = `S_FREE;
                end
                else begin
                    case (cnt)
                        2'b00: begin
                            ncnt = 2'b01;
                            if_inst[7:0] = mem_din;
                            mem_a = if_addr + 1;
                        end
                        2'b01: begin
                            ncnt = 2'b10;
                            if_inst[15:8] = mem_din;
                            mem_a = if_addr + 2;
                        end
                        2'b10: begin
                            ncnt = 2'b11;
                            if_inst[23:16] = mem_din;
                            mem_a = if_addr + 3;
                        end
                        2'b11: begin
                            ncnt = 2'b00;
                            if_inst[31:24] = mem_din;
                            if_enable = `True;
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
                            else next_state = `S_FREE;
                        end
                    endcase
                end
                
            end
            `S_FREE: begin
                ncnt = 0;
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
                else if (if_request) begin
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
        cnt <= 2'b00;
        state <= `S_FREE;
    end
    else if (rdy) begin
        state <= next_state;
        cnt <= ncnt;
    end
end
endmodule