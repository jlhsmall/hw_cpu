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
        ncnt = 2'b00;
        next_state = `S_FREE;
    end
    else begin
        case (state)
            `S_LOAD: begin
                if (ncnt == num_of_bytes - 1) begin
                    ncnt = 2'b00;
                    if (if_request) next_state = `S_IF;
                    else next_state = `S_FREE;
                end
                else begin
                    ncnt = cnt + 1;
                    next_state = `S_LOAD;
                end
            end
            `S_STORE: begin
                if (cnt == num_of_bytes - 1) begin
                    ncnt = 2'b00;
                    if (if_request) next_state = `S_IF;
                    else next_state = `S_FREE;
                end
                else begin
                    ncnt = cnt + 1;
                    next_state = `S_STORE;
                end
            end
            `S_IF: begin
                if (jump_or_not) begin
                    ncnt = 2'b00;
                    if (load_or_not) next_state = `S_LOAD;
                    else if (store_or_not) next_state = `S_STORE;
                    else next_state = `S_FREE;
                end
                else if (cnt == 2'b11) begin
                    ncnt = 2'b00;
                    if (load_or_not) next_state = `S_LOAD;
                    else if (store_or_not) next_state = `S_STORE;
                    else next_state = `S_FREE;
                end
                else begin
                    ncnt = cnt + 1;
                    next_state = `S_IF;
                end
            end
            `S_FREE: begin
                ncnt = 2'b00;
                if (load_or_not) next_state = `S_LOAD;
                else if (store_or_not) next_state = `S_STORE;
                else if (if_request) next_state = `S_IF;
                else next_state = `S_FREE;
            end
        endcase
    end
end
always @ (posedge clk, posedge rst) begin
    if (rst) begin
        cnt <= 2'b00;
        state <= `S_FREE;
        mem_dout <= `ZERO_BYTE;
        mem_a <= `ZERO_WORD;
        mem_wr <= `False;
        if_enable <= `False;
        if_inst <= `ZERO_WORD;
        mem_enable <= `False;
        load_data <= `ZERO_WORD;
    end
    else if (rdy) begin
        state <= next_state;
        cnt <= ncnt;
        case (next_state)
            `S_LOAD: begin
                if_enable <= `False;
                case (ncnt)
                    2'b00: begin
                        load_data[7:0] <= mem_din;
                    end
                    2'b01: begin
                        load_data[15:8] <= mem_din;
                    end
                    2'b10: begin
                        load_data[23:16] <= mem_din;
                    end
                    2'b11: begin
                        load_data[31:24] <= mem_din;
                    end
                endcase
                if (ncnt == num_of_bytes - 1) begin
                    mem_enable <= `True;
                    if (if_request) mem_a <= if_addr;
                end
                else begin
                    mem_a <= mem_addr + cnt + 1;
                end
            end
            `S_STORE: begin
                if_enable <= `False;
                if (cnt == num_of_bytes - 1) begin
                    mem_enable <= `True;
                    mem_wr <= `False;
                    if (if_request) mem_a <= if_addr;
                end
                else begin
                    case (ncnt)
                        2'b00: begin
                            mem_dout = store_data[15:8];
                            mem_a = mem_addr + 1;
                        end
                        2'b01: begin
                            mem_dout = store_data[23:16];
                            mem_a = mem_addr + 2;
                        end
                        2'b10: begin
                            mem_dout = store_data[31:24];
                            mem_a = mem_addr + 3;
                        end
                    endcase
                end
            end
            `S_IF: begin
                mem_enable <= `False;
                if (jump_or_not) begin
                    if (load_or_not) begin
                        mem_a <= mem_addr;
                    end
                    else if (store_or_not) begin
                        mem_wr <= `True;
                        mem_a <= mem_addr;
                        mem_dout <= store_data[7:0];
                    end
                end
                else begin
                    case (ncnt)
                        2'b00: begin
                            if_inst[7:0] <= mem_din;
                            mem_a <= if_addr + 1;
                        end
                        2'b01: begin
                            if_inst[15:8] <= mem_din;
                            mem_a <= if_addr + 2;
                        end
                        2'b10: begin
                            if_inst[23:16] <= mem_din;
                            mem_a <= if_addr + 3;
                        end
                        2'b11: begin
                            if_inst[31:24] <= mem_din;
                            if_enable <= `True;
                            if (load_or_not) begin
                                mem_a <= mem_addr;
                            end
                            else if (store_or_not) begin
                                mem_wr <= `True;
                                mem_a <= mem_addr;
                                mem_dout <= store_data[7:0];
                            end
                        end
                    endcase
                end
                
            end
            `S_FREE: begin
                if_enable <= `False;
                mem_enable <= `False;
                if (load_or_not) begin
                    mem_a <= mem_addr;
                end
                else if (store_or_not) begin
                    mem_wr <= `True;
                    mem_a <= mem_addr;
                    mem_dout <= store_data[7:0];
                end
                else if (if_request) begin
                    mem_a <= if_addr;
                end
            end
        endcase
    end
end
endmodule