module add_sub_8bit(
    input  [7:0] operand_x,
    input  [7:0] operand_y,
    input        operatie_add,
    input        operatie_sub,
    output [15:0] rezultat,
    output [8:0] carry_out,
    output       overflow
);

wire sub;
wire [7:0] y_inversat;
wire [7:0] y_final;
wire [7:0] rez8;
wire overflow_add;
wire overflow_sub;

assign sub = operatie_sub;

// inversam y pentru complement fata de 2
invertor_8bit INV1 (
    .x(operand_y),
    .y(y_inversat)
);

// mux: sel=0(add) -> y original, sel=1(sub) -> y inversat
mux_2to1 MUX_Y (
    .a(operand_y),
    .b(y_inversat),
    .sel(sub),
    .out(y_final)
);

// adunator principal
// cin=1 la scadere (completeaza complementul fata de 2)
rca_8bit adder(
    .x(operand_x),
    .y(y_final),
    .cin(sub),
    .z(rez8),
    .c(carry_out)
);

// extensie semn la 16 biti
assign rezultat = {{8{rez8[7]}}, rez8};

// overflow add: + + = - sau - - = +
assign overflow_add =
       ( operand_x[7] &  operand_y[7] & ~rez8[7]) |
       (~operand_x[7] & ~operand_y[7] &  rez8[7]);

// overflow sub: + - - = - sau - - + = +
assign overflow_sub =
       ( operand_x[7] & ~operand_y[7] & ~rez8[7]) |
       (~operand_x[7] &  operand_y[7] &  rez8[7]);

// mux: sel=0(add) -> overflow_add, sel=1(sub) -> overflow_sub
// overflow e pe 1 bit, folosim logica directa echivalenta cu mux 2:1
assign overflow = (~sub & overflow_add) | (sub & overflow_sub);

endmodule