// ============================================================
// ALU TESTBENCH V11 ELITE - FULL REWRITE
// Afiseaza x, y, expected, actual, cicluri
// Compatibil ModelSim / Verilog-2001
// ============================================================

`timescale 1ns/1ps

module tb_alu;

// ------------------------------------------------------------
// INPUTS
// ------------------------------------------------------------
reg clk;
reg rst;
reg start;
reg [1:0] operation;
reg [7:0] x_in;
reg [7:0] y_in;

// ------------------------------------------------------------
// OUTPUTS
// ------------------------------------------------------------
wire [15:0] result;
wire done;
wire overflow;

// ------------------------------------------------------------
// UUT
// ------------------------------------------------------------
alu UUT1(
    .clk(clk),
    .rst(rst),
    .start(start),
    .operation(operation),
    .x_in(x_in),
    .y_in(y_in),
    .result(result),
    .done(done),
    .overflow(overflow)
);

// ------------------------------------------------------------
// CLOCK
// ------------------------------------------------------------
initial clk = 0;
always #5 clk = ~clk;

// ------------------------------------------------------------
// STATISTICI
// ------------------------------------------------------------
integer i;

integer pass_total;
integer fail_total;

integer pass_add, pass_sub, pass_mul, pass_div;
integer fail_add, fail_sub, fail_mul, fail_div;

integer cycles;
integer min_cycles;
integer max_cycles;

integer total_cycles_add, total_cycles_sub;
integer total_cycles_mul, total_cycles_div;

integer count_add, count_sub;
integer count_mul, count_div;

// ------------------------------------------------------------
// AUX
// ------------------------------------------------------------
reg signed [7:0] rx;
reg signed [7:0] ry;
reg signed [7:0] r8;
reg signed [15:0] r16;

reg rovf;

reg [7:0] ux;
reg [7:0] uy;
reg [7:0] q_div;
reg [7:0] r_div;

// ------------------------------------------------------------
// NUME OPERATIE
// ------------------------------------------------------------
function [31:0] op_name;
input [1:0] op;
begin
    case(op)
        2'b00: op_name = "ADD ";
        2'b01: op_name = "SUB ";
        2'b10: op_name = "MUL ";
        2'b11: op_name = "DIV ";
    endcase
end
endfunction

// ------------------------------------------------------------
// PASS
// ------------------------------------------------------------
task mark_pass;
input [1:0] op;
begin
    pass_total = pass_total + 1;

    case(op)
        2'b00: pass_add = pass_add + 1;
        2'b01: pass_sub = pass_sub + 1;
        2'b10: pass_mul = pass_mul + 1;
        2'b11: pass_div = pass_div + 1;
    endcase
end
endtask

// ------------------------------------------------------------
// FAIL
// ------------------------------------------------------------
task mark_fail;
input [1:0] op;
begin
    fail_total = fail_total + 1;

    case(op)
        2'b00: fail_add = fail_add + 1;
        2'b01: fail_sub = fail_sub + 1;
        2'b10: fail_mul = fail_mul + 1;
        2'b11: fail_div = fail_div + 1;
    endcase
end
endtask

// ------------------------------------------------------------
// SAVE CYCLES
// ------------------------------------------------------------
task save_cycles;
input [1:0] op;
input integer c;
begin
    if(c < min_cycles) min_cycles = c;
    if(c > max_cycles) max_cycles = c;

    case(op)

        2'b00:
        begin
            total_cycles_add = total_cycles_add + c;
            count_add = count_add + 1;
        end

        2'b01:
        begin
            total_cycles_sub = total_cycles_sub + c;
            count_sub = count_sub + 1;
        end

        2'b10:
        begin
            total_cycles_mul = total_cycles_mul + c;
            count_mul = count_mul + 1;
        end

        2'b11:
        begin
            total_cycles_div = total_cycles_div + c;
            count_div = count_div + 1;
        end

    endcase
end
endtask

// ------------------------------------------------------------
// TEST GENERAL
// ------------------------------------------------------------
task run_test;

input [1:0] op;
input [7:0] x;
input [7:0] y;
input [7:0] exp_lo;
input [7:0] exp_hi;
input exp_ovf;

begin

    @(negedge clk);
    x_in = x;
    y_in = y;
    operation = op;
    start = 1;

    @(negedge clk);
    start = 0;

    cycles = 0;

    while(done == 0)
    begin
        @(posedge clk);
        cycles = cycles + 1;
    end

    #1;

    case(op)

    // --------------------------------------------------------
    // ADD
    // --------------------------------------------------------
    2'b00:
    begin
        if(result[7:0] == exp_lo && overflow == exp_ovf)
        begin
            $display("[PASS] ADD | x=%4d y=%4d | exp=%4d | got=%4d | ovf=%b | cyc=%0d",
            $signed(x), $signed(y),
            $signed(exp_lo),
            $signed(result[7:0]),
            overflow,
            cycles);

            mark_pass(op);
            save_cycles(op, cycles);
        end
        else
        begin
            $display("[FAIL] ADD | x=%4d y=%4d | exp=%4d | got=%4d | expovf=%b got=%b",
            $signed(x), $signed(y),
            $signed(exp_lo),
            $signed(result[7:0]),
            exp_ovf,
            overflow);

            mark_fail(op);
        end
    end

    // --------------------------------------------------------
    // SUB
    // --------------------------------------------------------
    2'b01:
    begin
        if(result[7:0] == exp_lo && overflow == exp_ovf)
        begin
            $display("[PASS] SUB | x=%4d y=%4d | exp=%4d | got=%4d | ovf=%b | cyc=%0d",
            $signed(x), $signed(y),
            $signed(exp_lo),
            $signed(result[7:0]),
            overflow,
            cycles);

            mark_pass(op);
            save_cycles(op, cycles);
        end
        else
        begin
            $display("[FAIL] SUB | x=%4d y=%4d | exp=%4d | got=%4d | expovf=%b got=%b",
            $signed(x), $signed(y),
            $signed(exp_lo),
            $signed(result[7:0]),
            exp_ovf,
            overflow);

            mark_fail(op);
        end
    end

    // --------------------------------------------------------
    // MUL
    // --------------------------------------------------------
    2'b10:
    begin
        if(result == {exp_hi,exp_lo})
        begin
            $display("[PASS] MUL | x=%4d y=%4d | exp=%6d | got=%6d | cyc=%0d",
            $signed(x), $signed(y),
            $signed({exp_hi,exp_lo}),
            $signed(result),
            cycles);

            mark_pass(op);
            save_cycles(op, cycles);
        end
        else
        begin
            $display("[FAIL] MUL | x=%4d y=%4d | exp=%6d | got=%6d",
            $signed(x), $signed(y),
            $signed({exp_hi,exp_lo}),
            $signed(result));

            mark_fail(op);
        end
    end

    // --------------------------------------------------------
    // DIV
    // --------------------------------------------------------
    2'b11:
    begin
        if(result[7:0] == exp_lo && result[15:8] == exp_hi)
        begin
            $display("[PASS] DIV | x=%4d y=%4d | q=%4d r=%4d | cyc=%0d",
            x, y,
            result[7:0],
            result[15:8],
            cycles);

            mark_pass(op);
            save_cycles(op, cycles);
        end
        else
        begin
            $display("[FAIL] DIV | x=%4d y=%4d | expq=%4d expr=%4d | gotq=%4d gotr=%4d",
            x, y,
            exp_lo, exp_hi,
            result[7:0], result[15:8]);

            mark_fail(op);
        end
    end

    endcase

    @(negedge clk);

end
endtask

// ------------------------------------------------------------
// MAIN
// ------------------------------------------------------------
initial begin

pass_total = 0;
fail_total = 0;

pass_add = 0; pass_sub = 0; pass_mul = 0; pass_div = 0;
fail_add = 0; fail_sub = 0; fail_mul = 0; fail_div = 0;

total_cycles_add = 0;
total_cycles_sub = 0;
total_cycles_mul = 0;
total_cycles_div = 0;

count_add = 0;
count_sub = 0;
count_mul = 0;
count_div = 0;

min_cycles = 9999;
max_cycles = 0;

// reset
rst = 1;
start = 0;
x_in = 0;
y_in = 0;
operation = 0;

#20;
rst = 0;

$display("==========================================");
$display("         ALU TESTBENCH");
$display("==========================================");

// ------------------------------------------------------------
// ADD
// ------------------------------------------------------------
for(i=0;i<75;i=i+1)
begin
    rx = $random;
    ry = $random;
    r8 = rx + ry;
    rovf = (rx[7]==ry[7]) && (r8[7]!=rx[7]);

    run_test(2'b00, rx, ry, r8, 8'd0, rovf);
end

// ------------------------------------------------------------
// SUB
// ------------------------------------------------------------
for(i=0;i<75;i=i+1)
begin
    rx = $random;
    ry = $random;
    r8 = rx - ry;
    rovf = (rx[7]!=ry[7]) && (r8[7]!=rx[7]);

    run_test(2'b01, rx, ry, r8, 8'd0, rovf);
end

// ------------------------------------------------------------
// MUL
// ------------------------------------------------------------
for(i=0;i<75;i=i+1)
begin
    rx = $random;
    ry = $random;
    r16 = rx * ry;

    run_test(2'b10, rx, ry, r16[7:0], r16[15:8], 0);
end

// ------------------------------------------------------------
// DIV
// ------------------------------------------------------------
for(i=0;i<75;i=i+1)
begin
    ux = $random;
    uy = $random;

    if(uy == 0)
        uy = 1;

    q_div = ux / uy;
    r_div = ux % uy;

    run_test(2'b11, ux, uy, q_div, r_div, 0);
end

// ------------------------------------------------------------
// REZULTATE
// ------------------------------------------------------------
$display("==========================================");
$display("TOTAL PASS = %0d", pass_total);
$display("TOTAL FAIL = %0d", fail_total);
$display("SCOR = %0d%%", (pass_total*100)/(pass_total+fail_total));

$display("------------------------------------------");
$display("ADD PASS=%0d FAIL=%0d", pass_add, fail_add);
$display("SUB PASS=%0d FAIL=%0d", pass_sub, fail_sub);
$display("MUL PASS=%0d FAIL=%0d", pass_mul, fail_mul);
$display("DIV PASS=%0d FAIL=%0d", pass_div, fail_div);

$display("------------------------------------------");
$display("AVG ADD = %0f", total_cycles_add*1.0/count_add);
$display("AVG SUB = %0f", total_cycles_sub*1.0/count_sub);
$display("AVG MUL = %0f", total_cycles_mul*1.0/count_mul);
$display("AVG DIV = %0f", total_cycles_div*1.0/count_div);

$display("------------------------------------------");
$display("MIN CYC = %0d", min_cycles);
$display("MAX CYC = %0d", max_cycles);

$display("==========================================");

#50;
$finish;

end

endmodule
