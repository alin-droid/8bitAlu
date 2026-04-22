module invertor_8bit(
    input  [7:0] x,
    output [7:0] y
);

// modulul inverseaza cei 8 biti ai intrarii x
// pentru fiecare bit folosim un invertor pe 1 bit

invertor_1bit inv0 (.bit_intrare(x[0]), .bit_iesire(y[0]));
invertor_1bit inv1 (.bit_intrare(x[1]), .bit_iesire(y[1]));
invertor_1bit inv2 (.bit_intrare(x[2]), .bit_iesire(y[2]));
invertor_1bit inv3 (.bit_intrare(x[3]), .bit_iesire(y[3]));
invertor_1bit inv4 (.bit_intrare(x[4]), .bit_iesire(y[4]));
invertor_1bit inv5 (.bit_intrare(x[5]), .bit_iesire(y[5]));
invertor_1bit inv6 (.bit_intrare(x[6]), .bit_iesire(y[6]));
invertor_1bit inv7 (.bit_intrare(x[7]), .bit_iesire(y[7]));

endmodule
