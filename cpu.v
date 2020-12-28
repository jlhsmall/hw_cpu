// RISCV32I CPU top module
// port modification allowed for debugging purposes
`include "config.v"

module cpu(
  input  wire                 clk_in,			// system clock signal
  input  wire                 rst_in,			// reset signal
	input  wire					        rdy_in,			// ready signal, pause cpu when low

  input  wire [ 7:0]          mem_din,		// data input bus
  output wire [ 7:0]          mem_dout,		// data output bus
  output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
  output wire                 mem_wr,			// write/read signal (1 for write)
	
	input  wire                 io_buffer_full, // 1 if uart buffer is full
	
	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read result will be returned in the next cycle. Write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)
//PC -> IF
reg [`AddrLen - 1 : 0] pc;
//IF -> IF/ID
wire [`AddrLen - 1 : 0] if_pc;
wire [`InstLen - 1 : 0] if_inst;
//IF/ID -> ID
wire [`AddrLen - 1 : 0] id_pc;
wire [`InstLen - 1 : 0] id_inst;
wire [`AddrLen - 1 : 0] id_pc_o;
//Register -> ID
wire [`RegLen - 1 : 0] reg1_data;
wire [`RegLen - 1 : 0] reg2_data;

//ID -> Register
wire [`RegAddrLen - 1 : 0] reg1_addr;
wire reg1_read_enable;
wire [`RegAddrLen - 1 : 0] reg2_addr;
wire reg2_read_enable;

//ID -> ID/EX
wire [`OpLen - 1 : 0] id_op;
wire [`RegLen - 1 : 0] id_reg1, id_reg2, id_Imm;
wire [`RegAddrLen - 1 : 0] id_rd;

//ID/EX -> EX
wire [`AddrLen - 1 : 0] ex_pc;
wire [`OpLen - 1 : 0] ex_op;
wire [`RegLen - 1 : 0] ex_reg1, ex_reg2, ex_Imm;

wire jump_or_not;
wire [`AddrLen - 1 : 0] npc;

//EX -> EX/MEM
wire [`RegLen - 1 : 0] ex_rd_data;
wire [`RegAddrLen - 1 : 0] ex_rd_addr;
wire [`OpLen - 1 : 0] ex_op_o;

//EX/MEM -> MEM
wire mem_op;
wire [`RegLen - 1 : 0] mem_rd_data_i;
wire [`RegAddrLen - 1 : 0] mem_rd_addr_i;
wire mem_rd_enable_i;

//MEM -> MEM/WB
wire [`RegLen - 1 : 0] mem_rd_data_o;
wire [`RegAddrLen - 1 : 0] mem_rd_addr_o;
wire mem_rd_enable_o;

//MEM/WB -> Register
wire write_enable;
wire [`RegAddrLen - 1 : 0] write_addr;
wire [`RegLen - 1 : 0] write_data;

//STALL
wire [2:0] if_stall;
wire [2:0] mem_stall;
wire stall_or_not;

assign rom_addr_o = pc;

//Instantiation
pc_reg pc_reg0(.clk(clk_in), .rst(rst_in), .rdy(rdy_in), .stall_or_not(stall_or_not), .pc(pc)/*, .chip_enable(rom_ce_o)*/);

ifetch if0(.clk(clk_in), .rst(rst_in), .rdy(rdy_in), .pc(pc), .if_pc_o(if_pc), .if_inst_o(if_inst));

if_id if_id0(.clk(clk_in), .rst(rst_in), .rdy(rdy_in), .stall_or_not(stall_or_not), .if_pc(if_pc), .if_inst(if_inst), .id_pc(id_pc), .id_inst(id_inst));

id id0(.rst(rst_in), .rdy(rdy_in), .pc(id_pc), .inst(id_inst), .reg1_data_i(reg1_data), .reg2_data_i(reg2_data), 
      .reg1_addr_o(reg1_addr), .reg1_read_enable(reg1_read_enable), .reg2_addr_o(reg2_addr), .reg2_read_enable(reg2_read_enable),
      .pc_o(id_pc_o), .reg1(id_reg1), .reg2(id_reg2), .Imm(id_Imm), .rd(id_rd), .op(op));
      
register register0(.clk(clk_in), .rst(rst_in), .rdy(rdy_in), 
                  .write_enable(write_enable), .write_addr(write_addr), .write_data(write_data),
                  .read_enable1(reg1_read_enable), .read_addr1(reg1_addr), .read_data1(reg1_data),
                  .read_enable2(reg2_read_enable), .read_addr2(reg2_addr), .read_data2(reg2_data));
id_ex id_ex0(.clk(clk_in), .rst(rst_in), .rdy(rdy_in), .stall_or_not(stall_or_not),
            .id_pc(id_pc_0), .id_reg1(id_reg1), .id_reg2(id_reg2), .id_Imm(id_Imm), .id_rd(id_rd), .id_op(id_aluop),
            .ex_pc(ex_pc), .ex_reg1(ex_reg1), .ex_reg2(ex_reg2), .ex_Imm(ex_Imm), .ex_rd(ex_rd), .ex_op(ex_aluop));

ex ex0(.rst(rst_in), .rdy(rdy_in),
      .pc(ex_pc), .reg1(ex_reg1), .reg2(ex_reg2), .Imm(ex_Imm), .rd(ex_rd), .op(ex_op),
      .rd_data_o(ex_rd_data), .rd_addr(ex_rd_addr), .ex_op_o(ex_op_o), 
      .npc(npc), .jump_or_not(jump_or_not));
      
ex_mem ex_mem0(.clk(clk_in), .rst(rst_in), .rdy(rdy_in), .stall_or_not(stall_or_not),
              .ex_rd_data(ex_rd_data), .ex_rd_addr(ex_rd_addr), .ex_op(ex_op_o),
              .mem_rd_data(mem_rd_data_i), .mem_rd_addr(mem_rd_addr_i), .mem_op(mem_op), .mem_stall(mem_stall));
              
mem mem0(.rst(rst_in), .rdy(rdy_in),
        .rd_data_i(mem_rd_data_i), .rd_addr_i(mem_rd_addr_i), .rd_enable_i(mem_rd_enable_i),
        .rd_data_o(mem_rd_data_o), .rd_addr_o(mem_rd_addr_o), .rd_enable_o(mem_rd_enable_o));
        
mem_wb mem_wb0(.clk(clk_in), .rst(rst_in), .rdy(rdy_in), .stall_or_not(stall_or_not),
              .mem_rd_data(mem_rd_data_o), .mem_rd_addr(mem_rd_addr_o), .mem_rd_enable(mem_rd_enable_o),
              .wb_rd_data(write_data), .wb_rd_addr(write_addr), .wb_rd_enable(write_enable));

stall stall0(.clk(clk_in), .rst(rst_in), .rdy(rdy_in),
              .
/*always @(posedge clk_in)
  begin
    if (rst_in)
      begin
      
      end
    else if (!rdy_in)
      begin
      
      end
    else
      begin
      
      end
  end
*/
endmodule