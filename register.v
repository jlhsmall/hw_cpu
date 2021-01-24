`timescale 1ns / 1ps
`include "config.v"

module register(
    input wire clk,
    input wire rst,
    //write
    input wire write_enable,
    input wire [`RegAddrLen - 1 : 0] write_addr,
    input wire [`RegLen - 1 : 0] write_data,
    //read 1
    input wire read_enable1,
    input wire [`RegAddrLen - 1 : 0] read_addr1,
    output reg [`RegLen - 1 : 0] read_data1,
    //read 2
    input wire read_enable2,
    input wire [`RegAddrLen - 1 : 0] read_addr2,
    output reg [`RegLen - 1 : 0] read_data2,

    input wire jump_or_not
    );
    
    reg[`RegLen - 1 : 0] regs[`RegNum - 1 : 0];
    
//write 1
integer i;
always @ (*) begin
    if (rst) begin
        for (i = 0; i < `RegNum; i = i + 1) regs[i] = `ZERO_WORD;
    end
    else if (write_enable) begin
        if (write_addr != `RegAddrZero) //not zero register
            regs[write_addr] = write_data;
    end
end

//read 1
always @ (*) begin
    if (!rst && !jump_or_not) begin
        if (read_enable1) begin
            if (read_addr1 == `RegAddrLen'h0)
                read_data1 = `ZERO_WORD;
            else if (read_addr1 == write_addr && write_enable == `WriteEnable)
                read_data1 = write_data;
            else
                read_data1 = regs[read_addr1];
        end
    end
    else begin
        read_data1 = `ZERO_WORD;
    end
end

//read 2
always @ (*) begin
    if (!rst && !jump_or_not) begin
        if (read_enable2) begin
            if (read_addr2 == `RegAddrLen'h0)
                read_data2 = `ZERO_WORD;
            else if (read_addr2 == write_addr && write_enable == `WriteEnable)
                read_data2 = write_data;
            else
                read_data2 = regs[read_addr2];
        end
    end
    else begin
        read_data2 = `ZERO_WORD;
    end
end

endmodule