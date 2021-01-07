`timescale 1ns / 1ps
`include "config.v"

module mem(
    input rst,
    input wire rdy,
    input wire ex_mem_rdy,
    input wire [`RegLen - 1 : 0] rd_data_i,
    input wire [`RegAddrLen - 1 : 0] rd_addr_i,
    input wire [`AddrLen -  1 : 0] mem_addr_i,
    input wire [`OpLen - 1 : 0] op,

    output reg [`RegLen - 1 : 0] rd_data_o,
    output reg [`RegAddrLen - 1 : 0] rd_addr_o,
    output reg rd_enable_o,
    output reg mem_stall,

    output reg [`AddrLen - 1 : 0] mem_addr_o,
    output reg load_or_not,
    output reg store_or_not,
    output reg [2:0] num_of_bytes,
    output reg [`RegLen - 1 : 0] store_data,
    input wire [`RegLen - 1 : 0] load_data,
    input wire mem_enable
    );

always @ (*) begin
    if (rst == `True) begin
        rd_data_o = `ZERO_WORD;
        rd_addr_o = `RegAddrZero;
        rd_enable_o = `False;
        mem_stall = `False;
        mem_addr_o = `ZERO_WORD;
        load_or_not = `False;
        store_or_not = `False;
        num_of_bytes = 3'b000;
        store_data = `ZERO_WORD;
    end
    else if (rdy) begin
        if (load_or_not || store_or_not) begin
            if (mem_enable) begin
                mem_stall = `False;
                case (op)
                    `LB: begin
                        rd_data_o = {{24{load_data[7]}}, load_data[7:0]};
                        rd_enable_o = `True;
                    end
                    `LH: begin
                        rd_data_o = {{16{load_data[7]}}, load_data[15:0]};
                        rd_enable_o = `True;
                    end
                    `LW: begin
                        rd_data_o = load_data;
                        rd_enable_o = `True;
                    end
                    `LBU: begin
                        rd_data_o = {24'h000000, load_data[7:0]};
                        rd_enable_o = `True;
                    end
                    `LHU: begin
                        rd_data_o = {16'h0000, load_data[15:0]};
                        rd_enable_o = `True;
                    end
                    default: rd_enable_o = `False;
                endcase
            end
            else begin
                mem_stall = `True;
            end
        end
        else if(ex_mem_rdy) begin
            if (op >= `ADDI) begin
                mem_stall = `False;
                rd_data_o = rd_data_i;
                rd_addr_o = rd_addr_i;
                rd_enable_o = `True;
                load_or_not = `False;
                store_or_not = `False;
            end
            else if (op >= `LB) begin
                mem_stall = `True;
                mem_addr_o = mem_addr_i;
                case (op)
                    `LB: begin
                        num_of_bytes = 3'b001;
                        load_or_not = `True;
                        store_or_not = `False;
                        rd_enable_o = `True;
                    end
                    `LH: begin
                        num_of_bytes = 3'b010;
                        load_or_not = `True;
                        store_or_not = `False;
                        rd_enable_o = `True;
                    end
                    `LW: begin
                        num_of_bytes = 3'b100;
                        load_or_not = `True;
                        store_or_not = `False;
                        rd_enable_o = `True;
                    end
                    `LBU: begin
                        num_of_bytes = 3'b001;
                        load_or_not = `True;
                        store_or_not = `False;
                        rd_enable_o = `True;
                    end
                    `LHU: begin
                        num_of_bytes = 3'b010;
                        load_or_not = `True;
                        store_or_not = `False;
                        rd_enable_o = `True;
                    end
                    `SB: begin
                        num_of_bytes = 3'b001;
                        store_data = {24'h000000, rd_data_i[7:0]};
                        load_or_not = `False;
                        store_or_not = `True;
                        rd_enable_o = `False;
                    end
                    `SH: begin
                        num_of_bytes = 3'b010;
                        store_data = {16'h0000, rd_data_i[15:0]};
                        load_or_not = `False;
                        store_or_not = `True;
                        rd_enable_o = `False;
                    end
                    `SW: begin
                        num_of_bytes = 3'b100;
                        store_data = rd_data_i;
                        load_or_not = `False;
                        store_or_not = `True;
                        rd_enable_o = `False;
                    end
                endcase
            end
        end
        else mem_stall = `False;
    end
    else mem_stall = `False;
end

endmodule