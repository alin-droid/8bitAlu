module booth_selector(
    input  [2:0] cod_operatie,
    input  [8:0] plus_M,
    input  [8:0] plus_2M,
    input  [8:0] minus_M,
    input  [8:0] minus_2M,
    output [8:0] operand_selectat
);

    // codurile vin din encoder
    // 000 = 0
    // 001 = +M
    // 010 = +2M
    // 101 = -M
    // 110 = -2M

    wire sel_plus_M;
    wire sel_plus_2M;
    wire sel_minus_M;
    wire sel_minus_2M;

    assign sel_plus_M   = (~cod_operatie[2]) & (~cod_operatie[1]) &  cod_operatie[0];
    assign sel_plus_2M  = (~cod_operatie[2]) &  cod_operatie[1]  & (~cod_operatie[0]);
    assign sel_minus_M  =  cod_operatie[2]  & (~cod_operatie[1]) &  cod_operatie[0];
    assign sel_minus_2M =  cod_operatie[2]  &  cod_operatie[1]  & (~cod_operatie[0]);

    // activam doar magistrala dorita

    wire [8:0] cale_plus_M;
    wire [8:0] cale_plus_2M;
    wire [8:0] cale_minus_M;
    wire [8:0] cale_minus_2M;

    assign cale_plus_M   = {9{sel_plus_M}}   & plus_M;
    assign cale_plus_2M  = {9{sel_plus_2M}}  & plus_2M;
    assign cale_minus_M  = {9{sel_minus_M}}  & minus_M;
    assign cale_minus_2M = {9{sel_minus_2M}} & minus_2M;

    // o singura cale este activa, restul sunt 0

    assign operand_selectat = cale_plus_M | cale_plus_2M | cale_minus_M | cale_minus_2M;

endmodule
