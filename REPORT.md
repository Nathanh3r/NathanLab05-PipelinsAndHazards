# Lab 05 — Pipelined Datapath Report

**Name:** Nathan Herrera
**Email:** nherr044@ucr.edu

## Section 1 — Pipelined Output Table

Looking at the pipelines from each clk using gtkwave we found the values as follows

| Cycle | PC       | Opcode | src1_addr  | src1_out | dst_addr | dst_data |
|------ |----------|--------|------------|----------|----------|----------|
| 1     | 00000000 | 23     | 00         | 00000000 | 00       | 00000000 |
| 2     | 00000004 | 23     | 00         | 00000000 | 00       | 00000000 |
| 3     | 00000008 | 00     | 02         | 00000000 | 00       | XXXXXXXX |
| 4     | 0000000C | 2B     | 00         | 00000000 | 02       | 00000056 |
| 5     | 00000010 | 00     | 03         | 00000000 | 02       | 00000056 |
| 6     | 00000014 | 08     | 03         | 00000000 | 03       | 00000000 |
| 7     | 00000018 | 00     | 05         | 00000000 | 03       | 00000084 |
| 8     | 0000001C | 00     | 06         | 00000000 | 04       | FFFFFFAA |
| 9     | 00000020 | 00     | 06         | 00000000 | 05       | 0000000C |
| 10    | 00000024 | 00     | 05         | 0000000C | 06       | 00000000 |
| 11    | 00000028 | 04     | 05         | 0000000C | 07       | 00000056 |
| 12    | 0000002C | 23     | 00         | 00000000 | 08       | FFFFFFA9 |
| 13    | 00000030 | 00     | 00         | 00000000 | 06       | 00000000 |
| 14    | 00000034 | 00     | 00         | 00000000 | 1F       | 0000000C |
| 15    | 00000038 | 00     | 00         | 00000000 | 08       | 00000000 |


## Section 2 — Why the pipelined output differs
Even though the program is the same as the one we ran on the single-cycle datapath the results end up different because the pipelined processor is working on lot of instructions at the same time. Since the instructions overlap some of them try to read register values before the earlier ones have finished writing their results. 
When that happens the wrong values get used and it throws off the rest of the program.

The main problem happens right at the start in between lw  $v0, 31($zero)  and add $v1, $v0, $v0  

This is a load-use hazard. 
The lw instruction doesn’t put the new value into $v0 until later in the pipeline but the add tries to read $v0 before that happens. 
This is because this pipeline doesn’t have hazard detection or delays the add ends up using the old value instead of the one that was just loaded. 
That’s a read-after-write hazard and it makes $v1 wrong. Since later instructions depend on $v1 the mistake keeps going and the outputs don’t match what we saw with the single-cycle processor.

There’s also a control hazard at the beq instruction. The processor keeps fetching instructions before it knows whether the branch will actually be taken so extra instructions can move through the pipeline even if they shouldn’t. That also contributes to the differences in the results.

So overall, the mismatch mostly comes from the load-use hazard at the beginning and the control hazard from the branch.
Moving from this we can find the fix for them in section 3.


## Section 3 — Instruction to avoid a hazard
In order to fix this issue of load use hazard a instruction can be inserted to be able to fix this issue.
this instruction is sll $zero, $zero, 0

This instruction allows for a no-op that does not change the value of any register or memory location. 
 If we put this in between the lw and the add then we are able to add a one cycle delay that is
able to give lw enough time to finish writing to $v0. Which allows add to have more time. 

This then gets rid of the load use data hazard because the add instruction no longer reads the register too early. Which now allows the pieline to work correctly.

