//modulul implemteaza un RCA pentru 8 biti
module rca_8bit(
    input  [7:0] x,
    input  [7:0] y,
    input        cin,
    output [7:0] z,
    output [8:0] c
);
 
    assign c[0] = cin;
    
    //instantieri ale sumelor pe 1 bit
    fac_cell b0 (.x(x[0]), .y(y[0]), .cin(c[0]), .z(z[0]), .cout(c[1]));
    fac_cell b1 (.x(x[1]), .y(y[1]), .cin(c[1]), .z(z[1]), .cout(c[2]));
    fac_cell b2 (.x(x[2]), .y(y[2]), .cin(c[2]), .z(z[2]), .cout(c[3]));
    fac_cell b3 (.x(x[3]), .y(y[3]), .cin(c[3]), .z(z[3]), .cout(c[4]));
    fac_cell b4 (.x(x[4]), .y(y[4]), .cin(c[4]), .z(z[4]), .cout(c[5]));
    fac_cell b5 (.x(x[5]), .y(y[5]), .cin(c[5]), .z(z[5]), .cout(c[6]));
    fac_cell b6 (.x(x[6]), .y(y[6]), .cin(c[6]), .z(z[6]), .cout(c[7]));
    fac_cell b7 (.x(x[7]), .y(y[7]), .cin(c[7]), .z(z[7]), .cout(c[8]));

endmodule