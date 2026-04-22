module restoring_divider(
    input        clk,
    input        rst,
    input        start_div,
    input  [7:0] X,
    input  [7:0] Y,
    output [7:0] result,
    output [7:0] remainder,
    output reg   div_fin,
    output       div_zero
);

    // daca impartitorul este 0 semnalizam cazul special
    assign div_zero = (Y == 8'b00000000);

    // registrele principale ale algoritmului
    // A = rest partial
    // Q = cat
    // M = impartitor
    reg [8:0] reg_A;
    reg [7:0] reg_Q;
    reg [7:0] reg_M;
    reg [3:0] reg_count;

    // la fiecare pas deplasam la stanga perechea {A,Q}
    // bitul cel mai mare din Q intra in A
    wire [8:0] A_shift;
    wire [7:0] Q_shift;

    assign A_shift = {reg_A[7:0], reg_Q[7]};
    assign Q_shift = {reg_Q[6:0], 1'b0};

    // pentru scadere folosim complement fata de 2:
    // A_shift - M = A_shift + (~M + 1)
    wire [7:0] M_inversat;
    wire [7:0] rezultat_low;
    wire [8:0] carry_sub;
    wire [8:0] A_scazut;

    invertor_8bit INV1 (.x(reg_M), .y(M_inversat));

    rca_8bit RCA1 (
        .x(A_shift[7:0]),
        .y(M_inversat),
        .cin(1'b1),
        .z(rezultat_low),
        .c(carry_sub)
    );

    // bitul extra il calculam separat
    fac_cell FA1 (.x(A_shift[8]), .y(1'b1), .cin(carry_sub[8]), .z(A_scazut[8]), .cout());

    assign A_scazut[7:0] = rezultat_low;

    // daca bitul de semn este 1 inseamna ca rezultatul a iesit negativ
    wire rezultat_negativ;
    assign rezultat_negativ = A_scazut[8];

    // daca a iesit negativ restauram valoarea veche
    // altfel pastram scaderea si scriem 1 in cat
    wire [8:0] A_next;
    wire [7:0] Q_next;

    assign A_next = rezultat_negativ ? A_shift : A_scazut;
    assign Q_next = rezultat_negativ ? Q_shift : {reg_Q[6:0], 1'b1};

    // partea secventiala actualizeaza doar registrele
    always @(posedge clk or posedge rst) begin

        // reset general
        if (rst) begin
            reg_A     <= 9'b0;
            reg_Q     <= 8'b0;
            reg_M     <= 8'b0;
            reg_count <= 4'b0;
            div_fin   <= 1'b0;
        end

        // incarcam valorile initiale pentru o impartire noua
        else if (start_div) begin
            reg_A     <= 9'b0;
            reg_Q     <= X;
            reg_M     <= Y;
            reg_count <= 4'b0;
            div_fin   <= 1'b0;
        end

        // la impartire la zero terminam imediat
        else if (div_zero) begin
            div_fin <= 1'b1;
        end

        // executam cei 8 pasi ai algoritmului
        else if (!div_fin && reg_count < 4'd8) begin
            reg_A     <= A_next;
            reg_Q     <= Q_next;
            reg_count <= reg_count + 1'b1;
        end

        // dupa ultimul pas ridicam semnalul done
        else begin
            div_fin <= 1'b1;
        end
    end

    // iesirile finale
    assign result    = reg_Q;
    assign remainder = reg_A[7:0];

endmodule
