`timescale 1ns / 1ps
`include "config.v"
module ex(
    input wire rst,
    input wire rdy,
    input wire id_ex_rdy,
    input wire [`AddrLen - 1 : 0] pc,
    input wire [`RegLen - 1 : 0] reg1,
    input wire [`RegLen - 1 : 0] reg2,
    input wire [`RegLen - 1 : 0] Imm,
    input wire [`RegAddrLen - 1 : 0] rd,
    input wire [`OpLen - 1 : 0] op,

    output reg [`RegLen - 1 : 0] rd_data_o,
    output reg [`RegAddrLen - 1 : 0] rd_addr,
    output reg [`AddrLen - 1 : 0] mem_addr,
    output reg [`OpLen - 1 : 0] op_o,

    output reg [`RegLen - 1 : 0] npc,
    output reg jump_or_not,
    output wire ex_stall
    );
always @ (*) begin
    if (rst) begin
        rd_data_o = `ZERO_WORD;
        rd_addr = `RegAddrZero;
        op_o = `NOP;
        npc = `ZERO_WORD;
        jump_or_not = `False;
        ex_stall = `False;
    end
    else if (rdy && id_ex_rdy) begin
        ex_stall = `False;
        op_o = op;
        case (op)
            `LUI: begin
                rd_data_o = Imm;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = `False;
            end
            `AUIPC: begin
                rd_data_o = pc + Imm;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = `False;
            end
            `JAL: begin
                rd_data_o = pc + 4;
                rd_addr = rd;
                npc = reg1 + Imm;
                jump_or_not = `True;
            end
            `JALR: begin
                rd_data_o = pc + 4;
                rd_addr = rd;
                npc = reg1 + Imm;
                jump_or_not = `True;
            end
            `BEQ: begin
                rd_data_o = `ZERO_WORD;
                rd_addr = `RegAddrZero;
                npc = reg1 == reg2 ? pc + Imm : pc + 4;
                jump_or_not = `True;
            end
            `BNE: begin
                rd_data_o = `ZERO_WORD;
                rd_addr = `RegAddrZero;
                npc = reg1 != reg2 ? pc + Imm : pc + 4;
                jump_or_not = `True;
            end
            `BLT: begin
                rd_data_o = `ZERO_WORD;
                rd_addr = `RegAddrZero;
                npc = ($signed(reg1)) < ($signed(reg2)) ? pc + Imm : pc + 4;
                jump_or_not = `True;
            end
            `BGE: begin
                rd_data_o = `ZERO_WORD;
                rd_addr = `RegAddrZero;
                npc = ($signed(reg1)) >= ($signed(reg2)) ? pc + Imm : pc + 4;
                jump_or_not = `True;
            end
            `BLTU: begin
                rd_data_o = `ZERO_WORD;
                rd_addr = `RegAddrZero;
                npc = reg1 < reg2 ? pc + Imm : pc + 4;
                jump_or_not = `True;
            end
            `BGEU: begin
                rd_data_o = `ZERO_WORD;
                rd_addr = `RegAddrZero;
                npc = reg1 >= reg2 ? pc + Imm : pc + 4;
                jump_or_not = `True;
            end
            `LB: begin
                mem_addr = reg1 + Imm;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `LH: begin
                mem_addr = reg1 + Imm;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `LW: begin
                mem_addr = reg1 + Imm;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `LH: begin
                mem_addr = reg1 + Imm;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `LBU: begin
                mem_addr = reg1 + Imm;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `LHU: begin
                mem_addr = reg1 + Imm;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `SB: begin
                mem_addr = reg1 + Imm;
                rd_data_o = reg2;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `SH: begin
                mem_addr = reg1 + Imm;
                rd_data_o = reg2;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `SW: begin
                mem_addr = reg1 + Imm;
                rd_data_o = reg2;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `ADDI: begin
                rd_data_o = reg1 + Imm;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `SLTI: begin
                rd_data_o = ($signed(reg1)) < ($signed(Imm)) ;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `SLTIU: begin
                rd_data_o = reg1 < Imm;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `XORI: begin
                rd_data_o = reg1 ^ Imm;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `ORI: begin
                rd_data_o = reg1 | Imm;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `ANDI: begin
                rd_data_o = reg1 & Imm;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `SLLI: begin
                rd_data_o = reg1 << Imm[4:0];
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `SRLI: begin
                rd_data_o = reg1 >> Imm[4:0];
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `SRAI: begin
                rd_data_o = ($signed(reg1)) >>> Imm[4:0];
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `ADD: begin
                rd_data_o = reg1 + reg2;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `SUB: begin
                rd_data_o = reg1 - reg2;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `SLT: begin
                rd_data_o = ($signed(reg1)) < ($signed(reg2)) ;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `SLTU: begin
                rd_data_o = reg1 < reg2;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `XOR: begin
                rd_data_o = reg1 ^ reg2;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `OR: begin
                rd_data_o = reg1 | reg2;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `AND: begin
                rd_data_o = reg1 & reg2;
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `SLL: begin
                rd_data_o = reg1 << reg2[4:0];
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `SRL: begin
                rd_data_o = reg1 >> reg2[4:0];
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
            `SRA: begin
                rd_data_o = ($signed(reg1)) >>> reg2[4:0];
                rd_addr = rd;
                npc = `ZERO_WORD;
                jump_or_not = False;
            end
        endcase
    end
    else ex_stall = `False;
end
    
endmodule