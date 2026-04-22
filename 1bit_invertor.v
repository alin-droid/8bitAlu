// invertor pe 1 bit
// intoarce complementul valorii de intrare

module invertor_1bit(
    input  bit_intrare,
    output bit_iesire
);

    // daca intrarea este 0 => iesirea devine 1
    // daca intrarea este 1 => iesirea devine 0
    assign bit_iesire = bit_intrare ^ 1'b1;

endmodule
