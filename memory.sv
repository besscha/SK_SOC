
`include "param.vh"

/* verilator lint_off DECLFILENAME */
/* verilator lint_off VARHIDDEN */
/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNDRIVEN */

module memory(
    input logic clk,

    input logic [31:0] ist_addr,
    output logic [31:0] ist_data,
    
    input logic [31:0] dst_addr,
    output logic [31:0] output_data,
    input logic [2:0] dst_width,
    input logic dst_write_we,
    input logic [31:0] dst_write_data
);

    logic [31:0] dst_data;

    logic [29:0] d_addr;
    assign d_addr = dst_addr[31:2];

    logic [31:0] w_data;

    logic [31:0] w_data_32;    
    assign w_data_32 = dst_write_data;
    
    logic [31:0] w_data_16;
    assign w_data_16 = dst_addr[1] == 0 ? {dst_data[31:16], dst_write_data[15:0]} : {dst_write_data[15:0],dst_data[15:0]};
    
    logic [31:0] w_data_8;
    logic [1:0] data_8_sel;
    assign data_8_sel = dst_addr[1:0];
    always@(*) begin
        case(data_8_sel)
            2'b00: w_data_8 = {dst_data[31:8], dst_write_data[7:0]};
            2'b01: w_data_8 = {dst_data[31:16], dst_write_data[7:0], dst_data[7:0]};
            2'b10: w_data_8 = {dst_data[31:24], dst_write_data[7:0], dst_data[15:0]};
            2'b11: w_data_8 = {dst_write_data[7:0], dst_data[23:0]};
        endcase 
    end

    logic [1:0] dst_write_width;
    assign dst_write_width = dst_width[1:0];
    always_comb begin
        case(dst_write_width)
            2'b00: w_data = w_data_8;
            2'b01: w_data = w_data_16;
            2'b10: w_data = w_data_32;
            2'b11: w_data = w_data_32;
        endcase
    end

    logic [7:0] r_data_8;

    always@(*) begin
        case(data_8_sel)
            2'b00: r_data_8 = dst_data[7:0];
            2'b01: r_data_8 = dst_data[15:8];
            2'b10: r_data_8 = dst_data[23:16];
            2'b11: r_data_8 = dst_data[31:24];
        endcase 
    end

    logic [15:0] r_data_16;

    always@(*) begin
        case(dst_addr[1])
            1'b0: r_data_16 = dst_data[15:0];
            1'b1: r_data_16 = dst_data[31:16];
        endcase 
    end

    always @(*) begin
        case(dst_width)
            3'h0: begin
                output_data = {{24{r_data_8[7]}}, r_data_8[7:0]};
            end
            3'h1: begin
                output_data = {{16{r_data_16[15]}}, r_data_16[15:0]};
            end
            3'h2: begin
                output_data = dst_data;
            end
            3'h4: begin
                output_data = {{24'b0}, r_data_8[7:0]};
            end
            3'h5: begin
                output_data = {{16'b0}, r_data_16[15:0]};
            end
            default: begin
                output_data = 32'b0;
            end
        endcase
    end

    dram#(
        .WIDTH(32),
        .DEPTH(20)
    ) dram(
        .clk(clk),
        .a(d_addr[19:0]),
        .d(w_data),
        .we(dst_write_we),
        .spo(dst_data),
        .dpra(ist_addr[21:2]),
        .dpo(ist_data)
    );

endmodule

module dram #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 32
)(
    input logic clk,
    input logic [DEPTH-1:0] a,
    input logic [WIDTH-1:0] d,
    input logic we,             
    output logic [WIDTH-1:0] spo,

    input logic [DEPTH-1:0] dpra,
    output logic [WIDTH-1:0] dpo
);

    logic [WIDTH-1:0] mem[0 : 2 ** DEPTH-1];

    assign spo = mem[a];
    assign dpo = mem[dpra];

    always_ff @(posedge clk) begin
        if(we) begin
            mem[a] <= d;
        end
    end

    initial begin
       $readmemh("t.txt", mem, 0, 2 ** DEPTH-1); 
    end

    /* initial begin
        for(int i=0; i<10; i=i+1)
            $display("%d: %h", i, mem[i]); 
    end */

endmodule
