// multiplexor 2 la 1 pe 8 biti
// sel=0 ? iese a
// sel=1 ? iese b
module mux_2to1(
    input  [7:0] a,
    input  [7:0] b,
    input        sel,
    output [7:0] out
);
    wire sel_n;

    invertor_1bit UUT1 (
        .bit_intrare(sel),
        .bit_iesire(sel_n)
    );

    // sel=0 ? sel_n=1 ? iese a
    // sel=1 ? sel_n=0 ? iese b
    assign out = (a & {8{sel_n}}) | (b & {8{sel}});

endmodule
