module counter_8bit(
    input        clk,
    input        rst,
    input        en,
    output [7:0] q,
    output       cout
);

    // counter pe 8 biti
    // cand en=1 valoarea creste cu 1
    // cand en=0 isi pastreaza valoarea

    // iesirea adderului

    wire [7:0] q_plus_1;

    // carry-urile adderului

    wire [8:0] carry;

    // valoarea ce intra in registru

    wire [7:0] data_next;

    // incrementare: q + 1

    rca_8bit ADDER_INC (
        .x(q),
        .y(8'b00000000),
        .cin(1'b1),
        .z(q_plus_1),
        .c(carry)
    );

    // carry final la overflow

    assign cout = carry[8];

    // daca enable este activ incarcam valoarea incrementata
    // altfel pastram valoarea actuala

    mux_2to1 SEL_NEXT (
        .a(q),
        .b(q_plus_1),
        .sel(en),
        .out(data_next)
    );

    // registrul memoreaza starea counterului

    registru #(.WIDTH(8)) REG_COUNTER (
        .clk(clk),
        .rst(rst),
        .load(1'b1),
        .shift_right(1'b0),
        .shift_left(1'b0),
        .data_in(data_next),
        .data_out(q)
    );

endmodule
