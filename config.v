`define ZERO_WORD 32'h00000000
`define ONE_WORD 32'h00000001
`define ZERO_BYTE 8'h00

`define InstLen 32
`define AddrLen 32
`define RegAddrLen 5
`define RegLen 32
`define RegNum 32
`define StallLen 6
`define RegAddrZero 5'b00000

`define ResetEnable 1'b1
`define ResetDisable 1'b0
`define ChipEnable 1'b1
`define ChipDisable 1'b0
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0
`define True 1'b1
`define False 1'b0

`define RAM_SIZE 100
`define RAM_SIZELOG2 17

//OPCODE
`define OpLen 6
`define NOP 6'b000000
`define LUI 6'b101011
`define AUIPC 6'b101100
`define JAL 6'b101101
`define JALR 6'b101110
`define BEQ 6'b000101
`define BNE 6'b000110
`define BLT 6'b000111
`define BGE 6'b001000
`define BLTU 6'b001001
`define BGEU 6'b001010
`define LB 6'b101111
`define LH 6'b110000
`define LW 6'b110001
`define LBU 6'b110010
`define LHU 6'b110011
`define SB 6'b110110
`define SH 6'b110111
`define SW 6'b111000
`define ADDI 6'b010011
`define SLTI 6'b010100
`define SLTIU 6'b010101
`define XORI 6'b010110
`define ORI 6'b010111
`define ANDI 6'b011000
`define SLLI 6'b011001
`define SRLI 6'b011010
`define SRAI 6'b100000
`define ADD 6'b100001
`define SUB 6'b100010
`define SLL 6'b100011
`define SLT 6'b100100
`define SLTU 6'b100101
`define XOR 6'b100110
`define SRL 6'b100111
`define SRA 6'b101000
`define OR 6'b101001
`define AND 6'b101010

//Stall
`define MemStallLen 2
`define IfStallLen 2
`define MemStallZero 2'b00
`define IfStallZero 2'b00

//MemCtrl
`define S_FREE 2'b00
`define S_IF 2'b01
`define S_LOAD 2'b10
`define S_STORE 2'b11

//CACHE
`define CacheSize 256