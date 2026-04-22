module booth_encoder(
    input  [2:0] grup_biti,
    output [2:0] cod_operatie
);

    // extragem separat bitii pentru lizibilitate
    wire bit2 = grup_biti[2];
    wire bit1 = grup_biti[1];
    wire bit0 = grup_biti[0];

    // tabel Booth Radix-4
    // 000 -> 0
    // 001 -> +M
    // 010 -> +M
    // 011 -> +2M
    // 100 -> -2M
    // 101 -> -M
    // 110 -> -M
    // 111 -> 0

    // semnale intermediare pentru fiecare operatie posibila
    wire plus_m;
    wire plus_2m;
    wire minus_m;
    wire minus_2m;

    assign plus_m   = (~bit2 & ~bit1 &  bit0) | (~bit2 &  bit1 & ~bit0);
    assign plus_2m  = (~bit2 &  bit1 &  bit0);

    assign minus_m  = ( bit2 & ~bit1 &  bit0) | ( bit2 &  bit1 & ~bit0);
    assign minus_2m = ( bit2 & ~bit1 & ~bit0);

    // cod intern:
    // bit0 = activ pentru M sau -M
    // bit1 = activ pentru 2M sau -2M
    // bit2 = activ pentru operatii negative

    assign cod_operatie[0] = plus_m | minus_m;
    assign cod_operatie[1] = plus_2m | minus_2m;
    assign cod_operatie[2] = minus_m | minus_2m;

endmodule
