`timescale 1ns / 1ps
`include "config.v"
module ex(
    input wire rst,
    input wire [`AddrLen - 1 : 0] pc,
    input wire [`RegLen - 1 : 0] reg1,
    input wire [`RegLen - 1 : 0] reg2,
    input wire [`RegLen - 1 : 0] imm,
    input wire [`RegAddrLen - 1 : 0] rd,
    input wire [`OpLen - 1 : 0] op,

    output reg [`RegLen - 1 : 0] rd_data_o,
    output reg [`RegAddrLen - 1 : 0] rd_addr,
    output reg [`AddrLen - 1 : 0] mem_addr,
    output reg [`OpLen - 1 : 0] op_o,

    input wire pred_jump_or_not,
    output reg is_btype,
    output reg jump_or_not,
    output reg ex_pc_bus,
    output reg failed,
    output reg [`RegLen - 1 : 0] npc,
    output reg ex_stall
    );
always @ (*) begin
    rd_data_o = `ZERO_WORD;
    rd_addr = `RegAddrZero;
    mem_addr = `ZERO_WORD;
    op_o = `NOP;
    npc = `ZERO_WORD;
    is_btype = `False;
    jump_or_not = `False;
    ex_stall = `False;
    failed = `False;
    if (!rst) begin
        op_o = op;
        case (op)
            `LUI: begin
                rd_data_o = imm;
                rd_addr = rd;
            end
            `AUIPC: begin
                rd_data_o = pc + imm;
                rd_addr = rd;
            end
            `JAL: begin
                rd_data_o = pc + 4;
                rd_addr = rd;
            end
            `JALR: begin
                rd_data_o = pc + 4;
                rd_addr = rd;
                npc = reg1 + imm;
                failed = `True;
            end
            `BEQ: begin
                is_btype = `True;
                jump_or_not = (reg1 == reg2);
                if (pred_jump_or_not != jump_or_not) begin
                    failed = `True;
                    ex_pc_bus = pc[5:2];
                    npc = reg1 == reg2 ? pc + imm : pc + 4;
                end
            end
            `BNE: begin
                is_btype = `True;
                jump_or_not = (reg1 != reg2);
                if (pred_jump_or_not != jump_or_not) begin
                    failed = `True;
                    ex_pc_bus = pc[5:2];
                    npc = reg1 != reg2 ? pc + imm : pc + 4;
                end
            end
            `BLT: begin
                is_btype = `True;
                jump_or_not = (($signed(reg1)) < ($signed(reg2)));
                if (pred_jump_or_not != jump_or_not) begin
                    failed = `True;
                    ex_pc_bus = pc[5:2];
                    npc = ($signed(reg1)) < ($signed(reg2)) ? pc + imm : pc + 4;
                end
            end
            `BGE: begin
                is_btype = `True;
                jump_or_not = (($signed(reg1)) >= ($signed(reg2)));
                if (pred_jump_or_not != jump_or_not) begin
                    failed = `True;
                    ex_pc_bus = pc[5:2];
                    npc = ($signed(reg1)) >= ($signed(reg2)) ? pc + imm : pc + 4;
                end
            end
            `BLTU: begin
                is_btype = `True;
                jump_or_not = (reg1 < reg2);
                if (pred_jump_or_not != jump_or_not)  begin
                    failed = `True;
                    ex_pc_bus = pc[5:2];
                    npc = reg1 < reg2 ? pc + imm : pc + 4;
                end
            end
            `BGEU: begin
                is_btype = `True;
                jump_or_not = (reg1 >= reg2);
                if (pred_jump_or_not != jump_or_not) begin
                    failed = `True;
                    ex_pc_bus = pc[5:2];
                    npc = reg1 >= reg2 ? pc + imm : pc + 4;
                end
            end
            `LB: begin
                mem_addr = reg1 + imm;
                rd_addr = rd;
            end
            `LH: begin
                mem_addr = reg1 + imm;
                rd_addr = rd;
            end
            `LW: begin
                mem_addr = reg1 + imm;
                rd_addr = rd;
            end
            `LBU: begin
                mem_addr = reg1 + imm;
                rd_addr = rd;
            end
            `LHU: begin
                mem_addr = reg1 + imm;
                rd_addr = rd;
            end
            `SB: begin
                mem_addr = reg1 + imm;
                rd_data_o = reg2;
            end
            `SH: begin
                mem_addr = reg1 + imm;
                rd_data_o = reg2;
            end
            `SW: begin
                mem_addr = reg1 + imm;
                rd_data_o = reg2;
            end
            `ADDI: begin
                rd_data_o = reg1 + imm;
                rd_addr = rd;
            end
            `SLTI: begin
                rd_data_o = ($signed(reg1)) < ($signed(imm)) ;
                rd_addr = rd;
            end
            `SLTIU: begin
                rd_data_o = reg1 < imm;
                rd_addr = rd;
            end
            `XORI: begin
                rd_data_o = reg1 ^ imm;
                rd_addr = rd;
            end
            `ORI: begin
                rd_data_o = reg1 | imm;
                rd_addr = rd;
            end
            `ANDI: begin
                rd_data_o = reg1 & imm;
                rd_addr = rd;
            end
            `SLLI: begin
                rd_data_o = reg1 << imm[4:0];
                rd_addr = rd;
            end
            `SRLI: begin
                rd_data_o = reg1 >> imm[4:0];
                rd_addr = rd;
            end
            `SRAI: begin
                rd_data_o = ($signed(reg1)) >>> imm[4:0];
                rd_addr = rd;
            end
            `ADD: begin
                rd_data_o = reg1 + reg2;
                rd_addr = rd;
            end
            `SUB: begin
                rd_data_o = reg1 - reg2;
                rd_addr = rd;
            end
            `SLT: begin
                rd_data_o = ($signed(reg1)) < ($signed(reg2)) ;
                rd_addr = rd;
            end
            `SLTU: begin
                rd_data_o = reg1 < reg2;
                rd_addr = rd;
            end
            `XOR: begin
                rd_data_o = reg1 ^ reg2;
                rd_addr = rd;
            end
            `OR: begin
                rd_data_o = reg1 | reg2;
                rd_addr = rd;
            end
            `AND: begin
                rd_data_o = reg1 & reg2;
                rd_addr = rd;
            end
            `SLL: begin
                rd_data_o = reg1 << reg2[4:0];
                rd_addr = rd;
            end
            `SRL: begin
                rd_data_o = reg1 >> reg2[4:0];
                rd_addr = rd;
            end
            `SRA: begin
                rd_data_o = ($signed(reg1)) >>> reg2[4:0];
                rd_addr = rd;
            end
        endcase
    end
end
    
endmodule