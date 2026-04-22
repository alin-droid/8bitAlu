module booth_multiplier_radix4(
    input        clk,
    input        rst,
    input        start_mul,
    input  [7:0] X,
    input  [7:0] Y,
    output [15:0] result,
    output reg   mul_fin
);

    // registrul superior al produsului partial
    reg [8:0] A;

    // registrul inferior / multiplier
    reg [7:0] Q;

    // bit suplimentar Booth
    reg Q_1;

    // contor pentru cele 4 iteratii
    wire [7:0] pas_curent;
    wire       carry_count;

    reg reset_count;
    reg enable_count;

    counter_8bit contor_pasi (
        .clk(clk),
        .rst(reset_count),
        .en(enable_count),
        .q(pas_curent),
        .cout(carry_count)
    );

    // grupul analizat de encoder
    wire [2:0] grup_biti;
    wire [2:0] cod_operatie;

    assign grup_biti = {Q[1], Q[0], Q_1};

    booth_encoder encoder_booth (
        .grup_biti(grup_biti),
        .cod_operatie(cod_operatie)
    );

    // variantele operandului X
    wire [8:0] M;
    wire [8:0] M2;
    wire [8:0] negM;
    wire [8:0] negM2;

    booth_datapath generator_operanzi (
        .operand_m(X),
        .m_extins(M),
        .dublu_m(M2),
        .minus_m(negM),
        .minus_dublu_m(negM2)
    );

    // operand selectat de encoder
    wire [8:0] operand_selectat;

    booth_selector selector_booth (
    .cod_operatie(cod_operatie),
    .plus_M(M),
    .plus_2M(M2),
    .minus_M(negM),
    .minus_2M(negM2),
    .operand_selectat(operand_selectat)
    );

    // adunare pe primii 8 biti
    wire [7:0] suma_low;
    wire [8:0] carry_suma;

    rca_8bit adder (
        .x(A[7:0]),
        .y(operand_selectat[7:0]),
        .cin(1'b0),
        .z(suma_low),
        .c(carry_suma)
    );

    // ultimul bit separat
    wire suma_msb;
    wire carry_nefolosit;

    fac_cell adder_msb (
        .x(A[8]),
        .y(operand_selectat[8]),
        .cin(carry_suma[8]),
        .z(suma_msb),
        .cout(carry_nefolosit)
    );

    // rezultatul complet al adunarii
    wire [8:0] suma_totala;

    assign suma_totala = {suma_msb, suma_low};

    // concatenam tot registrul si facem shift aritmetic cu 2 pozitii
    wire [17:0] registru_total;
    wire [17:0] registru_shiftat;

    assign registru_total = {suma_totala, Q, Q_1};

    assign registru_shiftat = {
        registru_total[17],
        registru_total[17],
        registru_total[17:2]
    };

    // valori urmatoare
    wire [8:0] A_next;
    wire [7:0] Q_next;
    wire       Q_1_next;

    assign A_next   = registru_shiftat[17:9];
    assign Q_next   = registru_shiftat[8:1];
    assign Q_1_next = registru_shiftat[0];

    // control contor
    always @(*) begin
        reset_count  = rst | start_mul;
        enable_count = (pas_curent < 8'd4);
    end

    // executia secventiala
    always @(posedge clk or posedge rst) begin

        if (rst) begin
            A       <= 9'b0;
            Q       <= 8'b0;
            Q_1     <= 1'b0;
            mul_fin <= 1'b0;
        end

        else if (start_mul) begin
            A       <= 9'b0;
            Q       <= Y;
            Q_1     <= 1'b0;
            mul_fin <= 1'b0;
        end

        else if (pas_curent < 8'd4) begin
            A   <= A_next;
            Q   <= Q_next;
            Q_1 <= Q_1_next;
        end

        else begin
            mul_fin <= 1'b1;
        end
    end

    // rezultatul final pe 16 biti
    assign result = {A[7:0], Q};

endmodule
