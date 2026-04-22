// multiplexor 4 la 1 pe 8 biti
// se construieste din trei multiplexoare 2 la 1
module mux_4to1(
    input  [7:0] a,
    input  [7:0] b,
    input  [7:0] c,
    input  [7:0] d,
    input  [1:0] sel,
    output [7:0] out
);

    // rezultatele intermediare dupa primul nivel
    wire [7:0] mux_lo;
    wire [7:0] mux_hi;

    // primul nivel alege intre a si b, respectiv intre c si d
    mux_2to1 UUT1 (
        .a(a),
        .b(b),
        .sel(sel[0]),
        .out(mux_lo)
    );

    mux_2to1 UUT2 (
        .a(c),
        .b(d),
        .sel(sel[0]),
        .out(mux_hi)
    );

    // al doilea nivel alege intre cele doua rezultate intermediare
    mux_2to1 UUT3 (
        .a(mux_lo),
        .b(mux_hi),
        .sel(sel[1]),
        .out(out)
    );

endmodule
