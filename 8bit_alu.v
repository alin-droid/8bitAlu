module alu(
    input        clk,
    input        rst,
    input        start,
    input  [1:0] operation,
    input  [7:0] x_in,
    input  [7:0] y_in,
    output [15:0] result,
    output       done,
    output       overflow
);

    // semnale de control de la unitatea FSM
    wire incarca_x;
    wire incarca_y;
    wire procesare_op;
    wire incarca_rezultat;

    // selectare operatie
    wire op_add;
    wire op_sub;
    wire op_mul;
    wire op_div;

    // semnale finalizare pentru operatii iterative
    wire gata_mul;
    wire gata_div;

    // iesiri registre intrare
    wire [7:0] x_reg;
    wire [7:0] y_reg;

    // registru pentru operandul X
    registru #(.WIDTH(8)) reg_x (
        .clk(clk),
        .rst(rst),
        .load(incarca_x),
        .shift_right(1'b0),
        .shift_left(1'b0),
        .data_in(x_in),
        .data_out(x_reg)
    );

    // registru pentru operandul Y
    registru #(.WIDTH(8)) reg_y (
        .clk(clk),
        .rst(rst),
        .load(incarca_y),
        .shift_right(1'b0),
        .shift_left(1'b0),
        .data_in(y_in),
        .data_out(y_reg)
    );

    // unitatea de control
    control_unit cu (
        .clk(clk),
        .rst(rst),
        .start(start),
        .operation(operation),
        .mul_fin(gata_mul),
        .div_fin(gata_div),

        .load_x(incarca_x),
        .load_y(incarca_y),
        .procesare_op(procesare_op),
        .load_result(incarca_rezultat),

        .add(op_add),
        .sub(op_sub),
        .mul(op_mul),
        .div(op_div),

        .done(done)
    );

    // bloc adunare / scadere
    wire [15:0] rezultat_add_sub;
    wire [8:0] carry_add_sub;

    add_sub_8bit add_sub_unit (
        .operand_x(x_reg),
        .operand_y(y_reg),
        .operatie_add(op_add),
        .operatie_sub(op_sub),
        .rezultat(rezultat_add_sub),
        .carry_out(carry_add_sub),
        .overflow()
    );

    // overflow la adunare:
    // pozitiv + pozitiv = negativ
    // negativ + negativ = pozitiv

    wire overflow_add;

    assign overflow_add =
           (~x_reg[7] & ~y_reg[7] &  result[7])
        |  ( x_reg[7] &  y_reg[7] & ~result[7]);

    // overflow la scadere:
    // pozitiv - negativ = negativ
    // negativ - pozitiv = pozitiv

    wire overflow_sub;

    assign overflow_sub =
           (~x_reg[7] &  y_reg[7] &  result[7])
        |  ( x_reg[7] & ~y_reg[7] & ~result[7]);

    // alegem overflow dupa operatie

    assign overflow =
           (operation == 2'b00) ? overflow_add :
           (operation == 2'b01) ? overflow_sub :
           1'b0;

    // bloc inmultire Booth
    wire [15:0] rezultat_mul;

    booth_multiplier_radix4 mul_unit (
        .clk(clk),
        .rst(rst),
        .start_mul(op_mul),
        .X(x_reg),
        .Y(y_reg),
        .result(rezultat_mul),
        .mul_fin(gata_mul)
    );

    // bloc impartire restoring
    wire [7:0] cat;
    wire [7:0] rest;
    wire div_zero;

    restoring_divider div_unit (
        .clk(clk),
        .rst(rst),
        .start_div(op_div),
        .X(x_reg),
        .Y(y_reg),
        .result(cat),
        .remainder(rest),
        .div_fin(gata_div),
        .div_zero(div_zero)
    );

    // concatenam restul cu catul
    wire [15:0] rezultat_div;
    assign rezultat_div = {rest, cat};

    // registru final pentru rezultat
    result_register reg_result (
        .clk(clk),
        .rst(rst),
        .load_result(incarca_rezultat),
        .operation(operation),
        .add_sub_res(rezultat_add_sub),
        .mul_res(rezultat_mul),
        .div_res(rezultat_div),
        .result(result)
    );

endmodule
