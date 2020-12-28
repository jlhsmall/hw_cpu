`timescale 1ns / 1ps
`include "config.v"

module id(
    input wire rst,
    input wire rdy,
    input wire [`AddrLen - 1 : 0] pc,
    input wire [`InstLen - 1 : 0] inst,
    input wire [`RegLen - 1 : 0] reg1_data_i,
    input wire [`RegLen - 1 : 0] reg2_data_i,

    //To Register
    output reg [`RegAddrLen - 1 : 0] reg1_addr_o,
    output reg [`RegAddrLen - 1 : 0] reg2_addr_o,

    //To next stage
    output reg [`RegLen - 1 : 0] reg1,
    output reg [`RegLen - 1 : 0] reg2,
    output reg [`RegLen - 1 : 0] Imm,
    output reg [`RegLen - 1 : 0] rd,
    output reg [`OpCodeLen - 1 : 0] op
    );
    
//Decode: Get opcode, imm, rd, and the addr of rs1&rs2
always @(*) begin
    if(rst) begin
        reg1_addr_o = `RegAddrZero;
        reg2_addr_o = `RegAddrZero;
        reg1 = `ZERO_WORD;
        reg2 = `ZERO_WORD;
        Imm = `ZERO_WORD;
        rd = `ZERO_WORD; 
        op = `NOP;
    end
    else if (rdy) begin
        case (inst[6:0])
            7'b0110111: begin
                op = `LUI;
                rd = inst[11:7];
                imm = {inst[31:12], {12{1'b0}}};
            end
            7'b0010111: begin
                op = `AUIPC;
                rd = inst[11:7];
                reg1 = pc;
                imm = {inst[31:12], {12{1'b0}}};
            end
            7'b1101111: begin
                op = `JAL;
                reg1 = pc + 4;
                imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            end
            7'b1100111: begin
                op = `JALR;
                reg1 = pc + reg1_data_i;
                reg2 = pc + 4;
                imm = {{21{inst[31]}}, inst[30:20]};
            end
            7'b1100011: begin
                case (inst[14:12])
                    3'b000: begin
                        op = `BEQ;
                        reg1 = reg1_data_i;
                        reg2 = reg2_data_i;
                        imm = pc + {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                    end
                    3'b001: begin
                        op = `BNE;
                        reg1 = reg1_data_i;
                        reg2 = reg2_data_i;
                        imm = pc + {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                    end
                    3'b100: begin
                        op = `BLT;
                        reg1 = reg1_data_i;
                        reg2 = reg2_data_i;
                        imm = pc + {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                    end
                    3'b101: begin
                        op = `BGE;
                        reg1 = reg1_data_i;
                        reg2 = reg2_data_i;
                        imm = pc + {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                    end
                    3'b110: begin
                        op = `BLTU;
                        reg1 = reg1_data_i;
                        reg2 = reg2_data_i;
                        imm = pc + {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                    end
                    3'b111: begin
                        op = `BGEU;
                        reg1 = reg1_data_i;
                        reg2 = reg2_data_i;
                        imm = pc + {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                    end
                endcase
            7'b0000011: begin
                case (inst[14:12])
                    3'b000: begin
                        op = `LB;
                        reg1 = reg1_data_i;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b001: begin
                        op = `LH;
                        reg1 = reg1_data_i;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b010: begin
                        op = `LW;
                        reg1 = reg1_data_i;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b100: begin
                        op = `LBW;
                        reg1 = reg1_data_i;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b101: begin
                        op = `LHU;
                        reg1 = reg1_data_i;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                endcase
            end
            7'b0100011: begin
                case (inst[14:12])
                    3'b000: begin
                        op = `SB;
                        reg1 = reg1_data_i;
                        imm = {21{inst[31]}, inst[30:25], inst[11:7]};
                    end
                    3'b001: begin
                        op = `SH;
                        reg1 = reg1_data_i;
                        imm = {21{inst[31]}, inst[30:25], inst[11:7]};
                    end
                    3'b010: begin
                        op = `SW;
                        reg1 = reg1_data_i;
                        imm = {21{inst[31]}, inst[30:25], inst[11:7]};
                    end
                endcase
            end
            7'b0010011: begin
                case (inst[14:12])
                    3'b000: begin
                        op = `ADDI;
                        reg1 = reg1_data_i;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b010: begin
                        op = `SLTI;
                        reg1 = reg1_data_i;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b011: begin
                        op = `SLTIU;
                        reg1 = reg1_data_i;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b100: begin
                        op = `XORI;
                        reg1 = reg1_data_i;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b110: begin
                        op = `ORI;
                        reg1 = reg1_data_i;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b111: begin
                        op = `ANDI;
                        reg1 = reg1_data_i;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b001: begin
                        op = `SLLI;
                        reg1 = reg1_data_i;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                    3'b101: begin
                        op = inst[30] ? `SRAI : `SRLI;
                        reg1 = reg1_data_i;
                        imm = {{21{inst[31]}}, inst[30:20]};
                    end
                endcase
            end
            7'b0110011: begin
                case (inst[14:12])
                    3'b000: begin
                        op = inst[30] ? `SUB : `ADD;
                        reg1 = reg1_data_i;
                        reg2 = reg2_data_i;
                    end
                    3'b001: begin
                        op = `SLL;
                        reg1 = reg1_data_i;
                        reg2 = reg2_data_i;
                    end
                    3'b010: begin
                        op = `SLT;
                        reg1 = reg1_data_i;
                        reg2 = reg2_data_i;
                    end
                    3'b011: begin
                        op = `SLTU;
                        reg1 = reg1_data_i;
                        reg2 = reg2_data_i;
                    end
                    3'b100: begin
                        op = `XOR;
                        reg1 = reg1_data_i;
                        reg2 = reg2_data_i;
                    end
                    3'b101: begin
                        op = inst[30] ? `SRA : `SRL;
                        reg1 = reg1_data_i;
                        reg2 = reg2_data_i;
                    end
                    3'b110: begin
                        op = `OR;
                        reg1 = reg1_data_i;
                        reg2 = reg2_data_i;
                    end
                    3'b111: begin
                        op = `AND;
                        reg1 = reg1_data_i;
                        reg2 = reg2_data_i;
                    end
                endcase
            end
        endcase
    end
end


endmodule