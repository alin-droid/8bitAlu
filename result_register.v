module result_register(
    input clk,
    input rst,
    input load_result,
    input [1:0] operation,

    input [15:0] add_sub_res,
    input [15:0] mul_res,
    input [15:0] div_res,

    output [15:0] result
);

    // rezultat selectat in functie de operatie
    wire [15:0] selected_result;


    // alegem ce valoare intra in registru
    // 00 = add
    // 01 = sub
    // 10 = mul
    // 11 = div
    assign selected_result =
        (operation == 2'b00 || operation == 2'b01) ? add_sub_res :
        (operation == 2'b10) ? mul_res :
                               div_res;


    // registrul memoreaza rezultatul final
    // valoarea se incarca doar cand load_result = 1
    registru #(.WIDTH(16)) reg_result (
        .clk(clk),
        .rst(rst),
        .load(load_result),
        .shift_right(1'b0),
        .shift_left(1'b0),
        .data_in(selected_result),
        .data_out(result)
    );

endmodule
