`timescale 1ns / 1ps
`include "config.v"

module mem(
    input rst,
    input wire rdy,
    input wire [`RegLen - 1 : 0] rd_data_i,
    input wire [`RegAddrLen - 1 : 0] rd_addr_i,
    input wire [`OpLen - 1 : 0] op;

    output reg [`RegLen - 1 : 0] rd_data_o,
    output reg [`RegAddrLen - 1 : 0] rd_addr_o,
    output reg rd_enable_o,
    output wire [`MemStallLen - 1 : 0] mem_stall;
    );

always @ (*) begin
    if (rst == `ResetEnable) begin
        rd_data_o = `ZERO_WORD;
        rd_addr_o = `RegAddrZero;
        rd_enable_o = `False;
    end
    else if(rdy) begin
        if (op >= `ADDI) begin
            rd_addr_o = rd_addr_i;
            rd_enable_o = `True;
        end
        else begin
            rd_addr_o = `RegAddrZero;
            rd_enable_o = `False;
            rd_data_o = `ZERO_WORD;
        end
        case (op)
            LB:
            LH:
            LW:
            LBU:
            LHU:
            SB:
            SH:
            SW:
            default: begin
                if (op >= ADDI) rd_data_o = rd_data_i;
            end
        endcase
    end
end

endmodule