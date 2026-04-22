// aceasta este o celula de full adder pe 1 bit
// ea primeste doi biti si carry-ul de intrare
module fac_cell(
    input  x,
    input  y,
    input  cin,
    output z,
    output cout
);

    // suma pe bitul curent
    assign z = x ^ y ^ cin;

    // carry-ul iese daca cel putin doua intrari sunt 1
    assign cout = (x & y) | (x & cin) | (y & cin);

endmodule
