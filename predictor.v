module predictor(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire [`AddrLen - 1 : 0] if_pc,
    input wire [`InstLen - 1 : 0] inst,
    output reg pred_jump_or_not,
    output reg [`AddrLen - 1 : 0] pred_pc,
    input wire is_btype;
    input wire jump_or_not,
    input wire [3:0] ex_pc_bus
)
reg [1:0] pred[`PredSize - 1 : 0];//3 bits for history, 4 bits for pc
reg [2:0] global;
integer i;
reg [`PredSizeLen - 1 : 0] bus;
reg [`RegLen - 1 : 0] imm;
always @ (*) begin
    pred_jump_or_not = `False;
    pred_pc = `ZERO_WORD;
    bus = `PredBusZero;
    imm = `ZERO_WORD;
    if (!rst && !failed) begin
        if (inst[6]) begin
            if (inst[3]) begin//jal
                imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
                pred_jump_or_not = `True;
                pred_pc = if_pc + imm;
            end
            else if (!inst[2]) begin//b-type
                imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                bus = {global,pc[5:2]};
                if(pred[bus][1]) begin
                    pred_jump_or_not = `True;
                    pred_pc = if_pc + imm;
                end
                else pred_jump_or_not = `False;
            end
        end
    end
end
always @ (posedge clk) begin
    if (rst) begin
        global <= 3'b000;
        for (i = 0; i < `PredSize; i = i + 1) pred[i] <= 2'b10;
    end
    else if (rdy) begin
        if (is_btype) begin
            global <= {global[1:0], jump_or_not};
            if(jump_or_not && pred[{global, ex_pc_bus}] < 2'b11)
                pred[{global, ex_pc_bus}] <= pred[{global, ex_pc_bus}] + 1;
            if(!jump_or_not && pred[{global, ex_pc_bus}] > 2'b00)
                pred[{global, ex_pc_bus}] <= pred[{global, ex_pc_bus}] - 1;
        end
    end
end