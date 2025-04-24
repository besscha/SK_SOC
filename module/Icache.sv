`include "param.vh"

module Icache #(
    parameter OFFSET_WIDTH = 4,
    parameter INDEX_WIDTH = 8,
    parameter TAG_WIDTH = 20
)(
    input logic clk,
    input logic rst,

    input logic [31:0] addr,
    output logic [31:0] data,

    input flush,
    input stall,

    output logic Icache_miss,
    AXI axi_if
);
    // ---------------------------------------------
    // index
    logic [INDEX_WIDTH-1:0] w_index;
    logic [INDEX_WIDTH-1:0] r_index;
    assign r_index = stall
                    ? addr_reg [OFFSET_WIDTH+INDEX_WIDTH-1:OFFSET_WIDTH] 
                    : addr[OFFSET_WIDTH+INDEX_WIDTH-1:OFFSET_WIDTH];
    assign w_index = addr_reg [OFFSET_WIDTH+INDEX_WIDTH-1:OFFSET_WIDTH];
    // ---------------------------------------------
    // Cache Memory
    genvar i;
    logic [TAG_WIDTH+1-1:0] VT_douta[1:0];
    logic [TAG_WIDTH+1-1:0] VT_dina;
    logic VT_wea[1:0];    
    generate
        for(i=0;i<2;i++) begin :VT_BRAM_GEN
            Icache_BRAM #(
                .WIDTH(TAG_WIDTH+1),
                .DEPTH(INDEX_WIDTH)
            ) VT_BRAM (
                .clka(clk),
                .addra(w_index),
                .dina(VT_dina),
                .wea(VT_wea[i]),
                .clkb(clk),
                .addrb(r_index),
                .doutb(VT_douta[i])
            );
        end
    endgenerate

    logic [(1 << OFFSET_WIDTH) * 8-1:0] DATA_dina;
    logic [(1 << OFFSET_WIDTH) * 8-1:0] DATA_douta[1:0];
    logic DATA_wea[1:0];
    generate
        for(i=0;i<2;i++) begin :DATA_BRAM_GEN
            Icache_BRAM #(
                .WIDTH((1 << OFFSET_WIDTH) * 8),
                .DEPTH(INDEX_WIDTH)
            ) DATA_BRAM (
                .clka(clk),
                .addra(w_index),
                .dina(DATA_dina),
                .wea(DATA_wea[i]),
                .clkb(clk),
                .addrb(r_index),
                .doutb(DATA_douta[i])
            );
        end
    endgenerate

    //--------------------------------------------
    // addr_reg
    logic [31:0] addr_reg;
    always_ff @(posedge clk) begin
        if (rst || flush) begin
            addr_reg <= 32'h8000_0000;
        end else if (flush_reg) begin
            addr_reg <= addr;
        end else if (stall || Icache_miss) begin
            addr_reg <= addr_reg;
        end else begin
            addr_reg <= addr;
        end
    end
    //--------------------------------------------
    // hit
    logic hit[1:0];
    assign hit[0] = (VT_douta[0][TAG_WIDTH-1:0] == addr_reg[31:OFFSET_WIDTH+INDEX_WIDTH]) && VT_douta[0][TAG_WIDTH];
    assign hit[1] = (VT_douta[1][TAG_WIDTH-1:0] == addr_reg[31:OFFSET_WIDTH+INDEX_WIDTH]) && VT_douta[1][TAG_WIDTH];
    //--------------------------------------------
    // MAIN FSM
    enum logic [2:0] {
        IDLE,
        MISS,
        REFILL
    } state, next_state;

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        case (state)
            IDLE: begin
                if (hit[0] || hit[1]) begin
                    next_state = IDLE;
                end else begin
                    next_state = MISS;
                end
            end
            MISS: begin
                if (axi_if.rlast) begin
                    next_state = REFILL;
                end else begin
                    next_state = MISS;
                end    
            end
            REFILL: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end
    //--------------------------------------------
    // flush_reg
    logic flush_reg;
    always_ff @(posedge clk) begin
        if (rst)begin
            flush_reg <= 1'b0;
        end else if(flush) begin
            flush_reg <= 1'b1;
        end else if (next_state == IDLE) begin
            flush_reg <= 1'b0;
        end
    end
    //--------------------------------------------
    // data_out
    logic [31:0] data_out;
    always_comb begin
        if (hit[0]) begin
            data_out = DATA_douta[0][addr_reg[OFFSET_WIDTH-1:0]*8+:32];
        end else if (hit[1]) begin
            data_out = DATA_douta[1][addr_reg[OFFSET_WIDTH-1:0]*8+:32];
        end else begin
            data_out = 32'b0;
        end
    end

    assign data = flush || flush_reg ? `nop : 
                (state == REFILL) ? data_buf[addr_reg[OFFSET_WIDTH-1:0]*8+:32] :
                (state == IDLE) ? data_out : `nop;

    //--------------------------------------------
    // icache miss
    assign Icache_miss = next_state == MISS || state == MISS;
    //--------------------------------------------
    // axi FSM
    enum logic [1:0] {
        WAIT,
        ADDRESS,
        DATA
    } axi_state, axi_next_state;

    always_ff @(posedge clk) begin
        if (rst) begin
            axi_state <= WAIT;
        end else begin
            axi_state <= axi_next_state;
        end
    end

    always_comb begin
        case (axi_state)
            WAIT: begin
                if (next_state == MISS) begin
                    axi_next_state = ADDRESS;
                end else begin
                    axi_next_state = WAIT;
                end
            end
            ADDRESS: begin
                if (axi_if.arready) begin
                    axi_next_state = DATA;
                end else begin
                    axi_next_state = ADDRESS;
                end
            end
            DATA: begin
                if (axi_if.rlast) begin
                    axi_next_state = WAIT;
                end else begin
                    axi_next_state = DATA;
                end
            end
            default: begin
                axi_next_state = WAIT;
            end
        endcase
    end
    //--------------------------------------------
    // axi_if
    assign axi_if.arid = 4'b1000;
    assign axi_if.araddr = { addr_reg[31:OFFSET_WIDTH] , {OFFSET_WIDTH{1'b0}} };
    assign axi_if.arlen = ((1 << OFFSET_WIDTH) / 4) - 1;  // 4 * 4 bytes
    assign axi_if.arsize = 3'b010; // 4 bytes
    assign axi_if.arburst = 2'b01; // INCR
    assign axi_if.arvalid = axi_state == ADDRESS;
    assign axi_if.rready = axi_state == DATA;
    //--------------------------------------------
    // data_buf
    logic [(1 << OFFSET_WIDTH) * 8-1:0] data_buf;
    always_ff @(posedge clk) begin
        if (rst || flush) begin
            data_buf <= {(1 << OFFSET_WIDTH) * 8{1'b0}};
        end else if (axi_state == DATA && axi_if.rvalid) begin
            data_buf <= {axi_if.rdata, data_buf[(1 << OFFSET_WIDTH) * 8-1:32]};
        end
    end
    //--------------------------------------------
    // way_sel
    logic way_sel;
    always_comb begin
        if (VT_douta[0][TAG_WIDTH] == 1'b0) begin
            way_sel = 1'b0;
        end else if (VT_douta[1][TAG_WIDTH] == 1'b0) begin
            way_sel = 1'b1;
        end else begin
            way_sel = random_num;
        end
    end
    logic random_num;
    always_ff @(posedge clk) begin
        if (rst)begin
            random_num <= 1'b0;
        end else begin
            random_num <= ~random_num;
        end
    end

    //--------------------------------------------
    // memory_REFILL
    always_comb begin
        DATA_dina = {(1 << OFFSET_WIDTH) * 8{1'b0}};
        VT_dina = {1'b0, {TAG_WIDTH{1'b0}}};
        DATA_wea[0] = 1'b0;
        DATA_wea[1] = 1'b0;
        VT_wea[0] = 1'b0;
        VT_wea[1] = 1'b0;
        if (flush || flush_reg)begin
        end else if (state == REFILL) begin
            DATA_dina = data_buf;
            VT_dina = {1'b1, addr_reg[31:OFFSET_WIDTH+INDEX_WIDTH]};
            DATA_wea[way_sel] = 1'b1;
            VT_wea[way_sel] = 1'b1;
        end
        else begin
            DATA_dina = {(1 << OFFSET_WIDTH) * 8{1'b0}};
            VT_dina = {1'b0, {TAG_WIDTH{1'b0}}};
            DATA_wea[way_sel] = 1'b0;
            VT_wea[way_sel] = 1'b0;
        end
    end
endmodule

/* verilator lint_off DECLFILENAME */
module Icache_BRAM#(
    parameter WIDTH = 32,
    parameter DEPTH = 4
)(
    input logic clka,
    input logic [DEPTH-1:0] addra,
    input logic [WIDTH-1:0] dina,
    input logic wea,

    input logic clkb,
    input logic [DEPTH-1:0] addrb,
    output logic [WIDTH-1:0] doutb
);

    logic [WIDTH-1:0] ram [0:(1<<DEPTH)-1];

    always_ff @(posedge clka) begin
        if (wea) begin
            ram[addra] <= dina;
        end
    end

    always_ff @(posedge clkb) begin
        if (wea && addra == addrb) begin
            doutb <= dina;
        end else begin
            doutb <= ram[addrb];
        end
    end

endmodule
