module control_unit(
    input clk,
    input rst,
    input start,
    input [1:0] operation,
    input mul_fin,
    input div_fin,
    output reg load_x,
    output reg load_y,
    output reg procesare_op,
    output reg load_result,
    output reg add,
    output reg sub,
    output reg mul,
    output reg div,
    output reg done
);  
//codificare stari
    localparam st_idle      = 4'b0000;
    localparam st_load_x    = 4'b0001;
    localparam st_load_y    = 4'b0010;
    localparam st_decode    = 4'b0011;
    localparam st_add       = 4'b0100;
    localparam st_sub       = 4'b0101;
    localparam st_mul_start = 4'b0110;
    localparam st_div_start = 4'b0111;
    localparam st_mul_wait  = 4'b1000;
    localparam st_div_wait  = 4'b1001;
    localparam st_writeback = 4'b1010;
    localparam st_done      = 4'b1011;

    reg [3:0] stare_curenta;
    reg [3:0] stare_urmatoare;

    always @(posedge clk or posedge rst) begin
        if (rst)
            stare_curenta <= st_idle;
        else
            stare_curenta <= stare_urmatoare;
    end
    //logica de parcurgere a fsm
    always @(*) begin
        stare_urmatoare = stare_curenta;
        case (stare_curenta)
            st_idle:
                if (start) stare_urmatoare = st_load_x;
            st_load_x:
                stare_urmatoare = st_load_y;
            st_load_y:
                stare_urmatoare = st_decode;
            st_decode:
                if      (operation == 2'b00) stare_urmatoare = st_add;
                else if (operation == 2'b01) stare_urmatoare = st_sub;
                else if (operation == 2'b10) stare_urmatoare = st_mul_start;
                else                         stare_urmatoare = st_div_start;

            // ADD si SUB merg direct la st_done
            // load_result=1 in aceeasi stare cu add/sub
            // deci add_sub_8bit are operatia corecta cand se captureaza
            st_add:
                stare_urmatoare = st_done;
            st_sub:
                stare_urmatoare = st_done;

            st_mul_start:
                stare_urmatoare = st_mul_wait;
            st_mul_wait:
                if (mul_fin) stare_urmatoare = st_writeback;
            st_div_start:
                stare_urmatoare = st_div_wait;
            st_div_wait:
                if (div_fin) stare_urmatoare = st_writeback;
            st_writeback:
                stare_urmatoare = st_done;
            st_done:
                if (!start) stare_urmatoare = st_idle;
            default:
                stare_urmatoare = st_idle;
        endcase
    end

    always @(*) begin
        load_x       = 1'b0;
        load_y       = 1'b0;
        procesare_op = 1'b0;
        load_result  = 1'b0;
        add          = 1'b0;
        sub          = 1'b0;
        mul          = 1'b0;
        div          = 1'b0;
        done         = 1'b0;

        case (stare_curenta)
            st_load_x:
                load_x = 1'b1;
            st_load_y:
                load_y = 1'b1;
            st_decode:
                procesare_op = 1'b1;

            // add=1 si load_result=1 simultan
            // result_register captureaza rezultatul ADD corect
            st_add: begin
                add         = 1'b1;
                load_result = 1'b1;
            end

            // sub=1 si load_result=1 simultan
            // result_register captureaza rezultatul SUB corect
            st_sub: begin
                sub         = 1'b1;
                load_result = 1'b1;
            end

            st_mul_start:
                mul = 1'b1;
            st_div_start:
                div = 1'b1;
            st_mul_wait: ; // asteapta
            st_div_wait: ; // asteapta
            st_writeback:
                load_result = 1'b1;
            st_done:
                done = 1'b1;
        endcase
    end

endmodule
