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
wire [`AddrLen - 1 : 0] pc;
//IF -> IF/ID
wire [`AddrLen - 1 : 0] if_pc;
wire [`InstLen - 1 : 0] if_inst_o;

//IF <-> MEM_CTRL
wire [`AddrLen - 1 : 0] if_addr;
wire if_request;
wire [`InstLen - 1 : 0] if_inst_i;
wire if_enable;

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
wire [`RegLen - 1 : 0] id_reg1, id_reg2, id_imm;
wire [`RegAddrLen - 1 : 0] id_rd;

//ID/EX -> EX
wire [`AddrLen - 1 : 0] ex_pc;
wire [`OpLen - 1 : 0] ex_op;
wire [`RegLen - 1 : 0] ex_reg1, ex_reg2, ex_imm;
wire[`RegLen - 1 : 0] ex_rd;
wire [`AddrLen - 1 : 0] npc;
//EX -> EX/MEM
wire jump_or_not;
wire [`RegLen - 1 : 0] ex_rd_data;
wire [`RegAddrLen - 1 : 0] ex_rd_addr;
wire [`AddrLen - 1 : 0] mem_addr_ex;
wire [`OpLen - 1 : 0] ex_op_o;

//EX/MEM -> MEM
wire [`RegLen - 1 : 0] mem_rd_data_i;
wire [`RegAddrLen - 1 : 0] mem_rd_addr_i;
wire [`AddrLen - 1 : 0] mem_addr_i;
wire [`OpLen - 1 : 0] mem_op;
wire mem_rd_enable_i;

//MEM -> MEM/WB
wire [`RegLen - 1 : 0] mem_rd_data_o;
wire [`RegAddrLen - 1 : 0] mem_rd_addr_o;
wire mem_rd_enable_o;

//MEM <-> MEM_CTRL
wire [`AddrLen - 1 : 0] mem_addr_o;
wire load_or_not;
wire store_or_not;
wire [2:0] num_of_bytes;
wire [`RegLen - 1 : 0] store_data;
wire [`RegLen - 1 : 0] load_data;
wire mem_enable;

//MEM/WB -> Register
wire write_enable;
wire [`RegAddrLen - 1 : 0] write_addr;
wire [`RegLen - 1 : 0] write_data;

//STALL
wire pc_reg_stall, if_id_stall, id_ex_stall, ex_mem_stall;
wire pc_reg_rdy, if_id_rdy, id_ex_rdy, ex_mem_rdy, mem_wb_rdy;
wire if_stall, id_stall, ex_stall, mem_stall;


//Instantiation
pc_reg pc_reg0(.clk(clk_in), .rst(rst_in), .rdy(rdy_in), .pc_reg_stall(pc_reg_stall), .pc_reg_rdy(pc_reg_rdy), 
              .jump_or_not(jump_or_not), .npc(npc), .pc_o(pc)/*, .chip_enable(rom_ce_o)*/);

ifetch if0(.rst(rst_in), .rdy(rdy_in), .pc_reg_rdy(pc_reg_rdy), 
          .if_pc_i(pc), .if_pc_o(if_pc), .if_inst_o(if_inst_o),.if_stall(if_stall),
          .if_addr(if_addr), .if_request(if_request), .if_inst_i(if_inst_i), .if_enable(if_enable), .jump_or_not(jump_or_not));

if_id if_id0(.clk(clk_in), .rst(rst_in), .rdy(rdy_in), .if_id_stall(if_id_stall), .if_id_rdy(if_id_rdy),  
            .if_pc(if_pc), .if_inst(if_inst_o), .id_pc(id_pc), .id_inst(id_inst), .jump_or_not(jump_or_not), .if_stall(if_stall));

id id0(.rst(rst_in), .rdy(rdy_in), .if_id_rdy(if_id_rdy), 
      .pc(id_pc), .inst(id_inst), .reg1_data_i(reg1_data), .reg2_data_i(reg2_data), 
      .rd_data_ex(ex_rd_data), .rd_addr_ex(ex_rd_addr), .op_ex(ex_op_o), 
      .load_or_not(load_or_not), .rd_data_mem(mem_rd_data_o), .rd_addr_mem(mem_rd_addr_o), 
      .reg1_addr_o(reg1_addr), .reg1_read_enable(reg1_read_enable), .reg2_addr_o(reg2_addr), .reg2_read_enable(reg2_read_enable),
      .pc_o(id_pc_o), .reg1(id_reg1), .reg2(id_reg2), .imm(id_imm), .rd(id_rd), .op(id_op), .id_stall(id_stall), .jump_or_not(jump_or_not));
      
register register0(.clk(clk_in), .rst(rst_in), 
                  .write_enable(write_enable), .write_addr(write_addr), .write_data(write_data),
                  .read_enable1(reg1_read_enable), .read_addr1(reg1_addr), .read_data1(reg1_data),
                  .read_enable2(reg2_read_enable), .read_addr2(reg2_addr), .read_data2(reg2_data), .jump_or_not(jump_or_not));

id_ex id_ex0(.clk(clk_in), .rst(rst_in), .rdy(rdy_in), .id_ex_stall(id_ex_stall), .id_ex_rdy(id_ex_rdy), 
            .id_pc(id_pc_o), .id_reg1(id_reg1), .id_reg2(id_reg2), .id_imm(id_imm), .id_rd(id_rd), .id_op(id_op),
            .ex_pc(ex_pc), .ex_reg1(ex_reg1), .ex_reg2(ex_reg2), .ex_imm(ex_imm), .ex_rd(ex_rd), .ex_op(ex_op), .jump_or_not(jump_or_not), .id_stall(id_stall));

ex ex0(.rst(rst_in), .rdy(rdy_in), .id_ex_rdy(id_ex_rdy), 
      .pc(ex_pc), .reg1(ex_reg1), .reg2(ex_reg2), .imm(ex_imm), .rd(ex_rd), .op(ex_op),
      .rd_data_o(ex_rd_data), .rd_addr(ex_rd_addr), .mem_addr(mem_addr_ex), .op_o(ex_op_o), 
      .npc(npc), .jump_or_not(jump_or_not), .ex_stall(ex_stall));
      
ex_mem ex_mem0(.clk(clk_in), .rst(rst_in), .rdy(rdy_in), .ex_mem_stall(ex_mem_stall), .ex_mem_rdy(ex_mem_rdy), 
              .ex_rd_data(ex_rd_data), .ex_rd_addr(ex_rd_addr), .mem_addr_ex(mem_addr_ex), .ex_op(ex_op_o),
              .mem_rd_data(mem_rd_data_i), .mem_rd_addr(mem_rd_addr_i), .mem_addr_i(mem_addr_i), .mem_op(mem_op), .ex_stall(ex_stall));
              
mem mem0(.rst(rst_in), .rdy(rdy_in), .ex_mem_rdy(ex_mem_rdy), 
        .rd_data_i(mem_rd_data_i), .rd_addr_i(mem_rd_addr_i), .mem_addr_i(mem_addr_i), .op(mem_op),
        .rd_data_o(mem_rd_data_o), .rd_addr_o(mem_rd_addr_o), .rd_enable_o(mem_rd_enable_o), .mem_stall(mem_stall),
        .mem_addr_o(mem_addr_o), .load_or_not(load_or_not), .store_or_not(store_or_not), .num_of_bytes(num_of_bytes),
        .store_data(store_data), .load_data(load_data), .mem_enable(mem_enable));
        
mem_wb mem_wb0(.clk(clk_in), .rst(rst_in), .rdy(rdy_in), .mem_wb_rdy(mem_wb_rdy), 
              .mem_rd_data(mem_rd_data_o), .mem_rd_addr(mem_rd_addr_o), .mem_rd_enable(mem_rd_enable_o),
              .wb_rd_data(write_data), .wb_rd_addr(write_addr), .wb_rd_enable(write_enable), .mem_stall(mem_stall));

mem_ctrl mem_ctrl0(.clk(clk_in), .rst(rst_in), .rdy(rdy_in),
                  .if_addr(if_addr), .if_request(if_request), .if_inst(if_inst_i), .if_enable(if_enable),
                  .mem_addr(mem_addr_o), .load_or_not(load_or_not), .store_or_not(store_or_not), .num_of_bytes(num_of_bytes),
                  .store_data(store_data), .load_data(load_data), .mem_enable(mem_enable),
                  .mem_dout(mem_dout), .mem_a(mem_a), .mem_wr(mem_wr), .mem_din(mem_din), .jump_or_not(jump_or_not));

stall stall0(.clk(clk_in), .rst(rst_in), .rdy(rdy_in),
            .if_stall(if_stall), .id_stall(id_stall), .ex_stall(ex_stall), .mem_stall(mem_stall),
            .pc_reg_stall(pc_reg_stall), .if_id_stall(if_id_stall), .id_ex_stall(id_ex_stall), .ex_mem_stall(ex_mem_stall));
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