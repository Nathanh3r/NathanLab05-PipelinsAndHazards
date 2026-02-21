`timescale 1ns / 1ps

module processor_tb;

// Inputs
reg clk;
reg rst;

// Outputs
wire [31:0] prog_count;
wire [5:0] instr_opcode;
wire [4:0] reg1_addr;
wire [31:0] reg1_data;
wire [4:0] reg2_addr;
wire [31:0] reg2_data;
wire [4:0] write_reg_addr;
wire [31:0] write_reg_data;
integer idx;

initial begin
    $dumpfile("lab05.vcd");
    for (idx = 0; idx < 9; idx = idx + 1) begin
      $dumpvars(0, uut.cpu_registers_i1.RFILE[idx]);
    end
    $dumpvars(0, processor_tb);
end

initial begin 
	$readmemb("init.coe", uut.DIG_RAMDualAccess_i4.memory,0,255);
end 

lab05_pipelined uut (
    .clk(clk),
    .rst(rst),
    .PC(prog_count),
    .opcode(instr_opcode),
    .src1_addr(reg1_addr),
    .src1_out(reg1_data),
    .src2_addr(reg2_addr),
    .src2_out(reg2_data),
    .dst_addr(write_reg_addr),
    .dst_data(write_reg_data)
);
  
initial begin 
    clk = 0; rst = 1; #50; 
    clk = 1; rst = 1; #45; 
    rst = 0; #5; clk = 0;  

    forever begin 
        #50 clk = ~clk;
    end 
end 

reg[31:0] result;
reg[31:0] expected;
integer last_instruction; 
integer passedTests = 0;
integer totalTests = 0;
integer ticks = 0;

initial begin

   /* Individual tests... Check the result after each instruction */
    @(negedge rst); // Wait for reset
    @(posedge clk); #100;

    $display("------------------------------------------------------------------");
    for (ticks = 0; ticks < 14; ticks = ticks + 1) begin
        @(posedge clk);
        $display("PC: %2d opcode: %06b write reg addr: %2d write reg data: %4h", prog_count, instr_opcode, write_reg_addr, write_reg_data);        
    end
    $display("------------------------------------------------------------------");
    $finish();
end
endmodule
