module registru #(
    parameter WIDTH = 8
)(
    input clk,
    input rst,
    input load,
    input shift_right,
    input shift_left,
    input [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);

    // registru parametrizabil
    // poate face:
    // - incarcare paralela
    // - shift la dreapta cu pastrarea semnului
    // - shift la stanga logic

    always @(posedge clk or posedge rst) begin
        // la reset stergem continutul registrului
        if (rst) begin
            data_out <= {WIDTH{1'b0}};
        end

        // incarcare paralela prioritara
        else if (load) begin
            data_out <= data_in;
        end

        // shift la dreapta cu extensie de semn
        // pastram bitul cel mai semnificativ pentru numere signed
        else if (shift_right) begin
            data_out <= {data_out[WIDTH-1], data_out[WIDTH-1:1]};
        end

        // shift la stanga logic
        // introducem 0 pe bitul cel mai putin semnificativ
        else if (shift_left) begin
            data_out <= {data_out[WIDTH-2:0], 1'b0};
        end
    end

endmodule
