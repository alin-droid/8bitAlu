module booth_datapath(
    input  [7:0] operand_m,
    output [8:0] m_extins,
    output [8:0] dublu_m,
    output [8:0] minus_m,
    output [8:0] minus_dublu_m
);

    // extindem operandul la 9 biti pentru a pastra semnul
    assign m_extins = {operand_m[7], operand_m};

    // 2M obtinut prin shift la stanga
    assign dublu_m[0]   = 1'b0;
    assign dublu_m[7:1] = m_extins[6:0];
    assign dublu_m[8]   = m_extins[8];

    // pentru -M facem complement fata de 2
    // inversam partea de 8 biti cu modulul existent
    wire [7:0] biti_inversati;
    wire [7:0] suma_low;
    wire [8:0] carry_negare;

    invertor_8bit inversor_m (
        .x(operand_m),
        .y(biti_inversati)
    );

    // adunam +1 pe primii 8 biti
    rca_8bit adder_negare (
        .x(biti_inversati),
        .y(8'b00000000),
        .cin(1'b1),
        .z(suma_low),
        .c(carry_negare)
    );

    // ultimul bit trateaza extensia de semn
    fac_cell bit_semn (
        .x(m_extins[8]),
        .y(1'b1),
        .cin(carry_negare[8]),
        .z(minus_m[8]),
        .cout()
    );

    assign minus_m[7:0] = suma_low;

    // -2M obtinut prin shift la stanga din -M
    assign minus_dublu_m[0]   = 1'b0;
    assign minus_dublu_m[7:1] = minus_m[6:0];
    assign minus_dublu_m[8]   = minus_m[8];

endmodule
