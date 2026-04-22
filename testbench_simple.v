`timescale 1ns/1ps

module tb_alu;

// semnale testbench

reg clk;
reg rst;
reg start;
reg [1:0] operation;
reg signed [7:0] x_in;
reg signed [7:0] y_in;

wire signed [15:0] result;
wire done;

// instantiere ALU

alu DUT (
    .clk(clk),
    .rst(rst),
    .start(start),
    .operation(operation),
    .x_in(x_in),
    .y_in(y_in),
    .result(result),
    .done(done)
);

// clock

initial clk = 0;
always #5 clk = ~clk;


// task operatie

task executa_operatie;
input [1:0] op;
input signed [7:0] a;
input signed [7:0] b;
begin
    @(negedge clk);
    operation = op;
    x_in = a;
    y_in = b;
    start = 1'b1;

    @(negedge clk);
    start = 1'b0;

    wait(done == 1'b1);
    #1;

    //afisare pentru fiecvare operatie diferita
 
    case(op)

        // ADD
        2'b00:
        $display("T=%0t | ADD | X=%0d | Y=%0d | RESULT=%0d",
                 $time, a, b, $signed(result[7:0]));

        // SUB
        2'b01:
        $display("T=%0t | SUB | X=%0d | Y=%0d | RESULT=%0d",
                 $time, a, b, $signed(result[7:0]));

        // MUL
        2'b10:
        $display("T=%0t | MUL | X=%0d | Y=%0d | RESULT=%0d",
                 $time, a, b, $signed(result));

        // DIV
        2'b11:
        $display("T=%0t | DIV | X=%0d | Y=%0d | QUOTIENT=%0d | REMAINDER=%0d",
                 $time, a, b, result[7:0], result[15:8]);

    endcase

    @(negedge clk);

end
endtask

// simulare

initial begin

    rst = 1;
    start = 0;
    operation = 0;
    x_in = 0;
    y_in = 0;

    #20;
    rst = 0;

    // ADD
    executa_operatie(2'b00, 10, 5);
    executa_operatie(2'b00, -8, 3);
    executa_operatie(2'b00, -7, -2);

    // SUB
    executa_operatie(2'b01, 10, 4);
    executa_operatie(2'b01, 5, 9);
    executa_operatie(2'b01, -7, -3);

    // MUL
    executa_operatie(2'b10, 6, 4);
    executa_operatie(2'b10, -3, 5);
    executa_operatie(2'b10, -4, -2);

    // DIV
    executa_operatie(2'b11, 20, 4);
    executa_operatie(2'b11, 15, 3);
    executa_operatie(2'b11, 9, 2);

    #50;
    $finish;

end

endmodule
