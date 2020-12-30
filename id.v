`timescale 1ns / 1ps
`include "config.v"

module id(
    input wire rst,
    input wire rdy,
    input wire if_id_rdy,
    input wire [`AddrLen - 1 : 0] pc,
    input wire [`InstLen - 1 : 0] inst,
    input wire [`RegLen - 1 : 0] reg1_data_i,
    input wire [`RegLen - 1 : 0] reg2_data_i,

    //EX Forwarding
    input wire [`RegLen - 1 : 0] rd_data_ex,
    input wire [`RegAddrLen - 1 : 0] rd_addr_ex,
    input wire [`OpLen - 1 : 0] op_ex,
    //MEM Forwarding
    input wire load_or_not;
    input wire [`RegLen - 1 : 0] rd_data_mem,
    input wire [`RegAddrLen - 1 : 0] rd_addr_mem,
    //To Register
    output reg [`RegAddrLen - 1 : 0] reg1_addr_o,
    output wire reg1_read_enable,
    output reg [`RegAddrLen - 1 : 0] reg2_addr_o,
    output wire reg2_read_enable,
    //To next stage
    output reg [`AddrLen - 1 : 0] pc_o,
    output reg [`RegLen - 1 : 0] reg1,
    output reg [`RegLen - 1 : 0] reg2,
    output reg [`RegLen - 1 : 0] Imm,
    output reg [`RegAddrLen - 1 : 0] rd,
    output reg [`OpCodeLen - 1 : 0] op,
    output wire id_stall
    );
    
//Decode: Get opcode, imm, rd, and the addr of rs1&rs2
always @ (*) begin
    if (rst) begin
        reg1_addr_o = `RegAddrZero;
        reg2_addr_o = `RegAddrZero;
    end
    else begin
        reg1_addr_o = inst[19 : 15];
        reg2_addr_o = inst[24 : 20];
    end
end
always @ (*) begin
    if(rst) begin
        reg1_addr_o = `RegAddrZero;
        reg1_read_enable = `False;
        reg2_addr_o = `RegAddrZero;
        reg2_read_enable = `False;
        pc_o = `ZERO_WORD;
        reg1 = `ZERO_WORD;
        reg2 = `ZERO_WORD;
        Imm = `ZERO_WORD;
        rd = `RegAddrZero; 
        op = `NOP;
        id_stall = `False;
    end
    else if (rdy && if_id_rdy) begin
        id_stall = `False;
        pc_o = pc;
        case (inst[6:0])
            7'b0110111: begin
                op = `LUI;
                rd = inst[11:7];
                imm = {inst[31:12], {12'h000}};
                reg1_read_enable = `False;
                reg2_read_enable = `False;
            end
            7'b0010111: begin
                op = `AUIPC;
                rd = inst[11:7];
                imm = {inst[31:12], {12'h000}};
                reg1_read_enable = `False;
                reg2_read_enable = `False;
            end
            7'b1101111: begin
                op = `JAL;
                rd = inst[11:7];
                imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
                reg1_read_enable = `False;
                reg2_read_enable = `False;
            end
            7'b1100111: begin
                op = `JALR;
                rd = inst[11:7];
                reg1_read_enable = `True;
                reg2_read_enable = `False;
                imm = {{21{inst[31]}}, inst[30:20]};
            end
            7'b1100011: begin
                case (inst[14:12])
                    3'b000: begin
                        op = `BEQ;
                        reg1_read_enable = `True;
                        reg2_read_enable = `True;
                        imm = pc + {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                    end
                    3'b001: begin
                        op = `BNE;
                        reg1_read_enable = `True;
                        reg2_read_enable = `True;
                        imm = pc + {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                    end
                    3'b100: begin
                        op = `BLT;
                        reg1_read_enable = `True;
                        reg2_read_enable = `True;
                        imm = pc + {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                    end
                    3'b101: begin
                        op = `BGE;
                        reg1_read_enable = `True;
                        reg2_read_enable = `True;
                        imm = pc + {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                    end
                    3'b110: begin
                        op = `BLTU;
                        reg1_read_enable = `True;
                        reg2_read_enable = `True;
                        imm = pc + {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                    end
                    3'b111: begin
                        op = `BGEU;
                        reg1_read_enable = `True;
                        reg2_read_enable = `True;
                        imm = pc + {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                    end
                endcase
            7'b0000011: begin
                case (inst[14:12])
                    3'b000: begin
                        op = `LB;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `False;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b001: begin
                        op = `LH;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `False;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b010: begin
                        op = `LW;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `False;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b100: begin
                        op = `LBU;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `False;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b101: begin
                        op = `LHU;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `False;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                endcase
            end
            7'b0100011: begin
                case (inst[14:12])
                    3'b000: begin
                        op = `SB;
                        reg1_read_enable = `True;
                        reg2_read_enable = `True;
                        imm = {21{inst[31]}, inst[30:25], inst[11:7]};
                    end
                    3'b001: begin
                        op = `SH;
                        reg1_read_enable = `True;
                        reg2_read_enable = `True;
                        imm = {21{inst[31]}, inst[30:25], inst[11:7]};
                    end
                    3'b010: begin
                        op = `SW;
                        reg1_read_enable = `True;
                        reg2_read_enable = `True;
                        imm = {21{inst[31]}, inst[30:25], inst[11:7]};
                    end
                endcase
            end
            7'b0010011: begin
                case (inst[14:12])
                    3'b000: begin
                        op = `ADDI;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `False;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b010: begin
                        op = `SLTI;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `False;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b011: begin
                        op = `SLTIU;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `False;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b100: begin
                        op = `XORI;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `False;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b110: begin
                        op = `ORI;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `False;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b111: begin
                        op = `ANDI;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `False;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b001: begin
                        op = `SLLI;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `False;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b101: begin
                        op = inst[30] ? `SRAI : `SRLI;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `False;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                endcase
            end
            7'b0110011: begin
                case (inst[14:12])
                    3'b000: begin
                        op = inst[30] ? `SUB : `ADD;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `True;
                    end
                    3'b001: begin
                        op = `SLL;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `True;
                    end
                    3'b010: begin
                        op = `SLT;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `True;
                    end
                    3'b011: begin
                        op = `SLTU;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `True;
                    end
                    3'b100: begin
                        op = `XOR;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `True;
                    end
                    3'b101: begin
                        op = inst[30] ? `SRA : `SRL;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `True;
                    end
                    3'b110: begin
                        op = `OR;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `True;
                    end
                    3'b111: begin
                        op = `AND;
                        rd = inst[11:7];
                        reg1_read_enable = `True;
                        reg2_read_enable = `True;
                    end
                endcase
            end
        endcase
    end
    else begin 
        id_stall = `False;
        reg1_read_enable = `False;
        reg2_read_enable = `False;
    end
end

always @ (*) begin
    if (rst || !reg1_read_enable) reg1 = `ZERO_WORD;
    else if (rd_addr_ex == reg1_addr) begin
        if (ex_op >= `LB) id_stall = `True;
        else if (ex_op >= `ADDI) reg1 = rd_data_ex;
        else reg1 = reg1_data_i;
    end
    else if (rd_addr_mem == reg1_addr) begin
        if (load_or_not) reg1 = rd_data_mem;
        else reg1 = reg1_data_i;
    end
    else reg1 = reg1_data_i;
end

always @ (*) begin
    if (rst || !reg2_read_enable) reg2 = `ZERO_WORD;
    else if (rd_addr_ex == reg2_addr) begin
        if (ex_op >= `LB) id_stall = `True;
        else if (ex_op >= `ADDI) reg2 = rd_data_ex;
        else reg2 = reg2_data_i;
    end
    else if (rd_addr_mem == reg2_addr) begin
        if (load_or_not) reg2 = rd_data_mem;
        else reg2 = reg2_data_i;
    end
    else reg2 = reg2_data_i;
end
endmodule