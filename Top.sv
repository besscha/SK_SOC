`include "./module/param.vh"

module Top(
    input logic clk,
    input logic rst
);

    logic [29:0] ist_addr;
    logic [31:0] ist_data;
    logic [29:0] dst_addr;
    logic [31:0] dst_write_data;
    logic [31:0] dst_read_data;
    logic [3:0]  dst_write_we;
    logic flush;
    logic nop;
    
    soc u_soc(
        .clk            	(clk             ),
        .rst            	(rst             ),
        .ist_addr       	(ist_addr        ),
        .ist_data       	(ist_data        ),
        .flush_output              (flush),
        .nop_output       (nop       ),
        .dst_addr       	(dst_addr        ),
        .dst_write_data 	(dst_write_data  ),
        .dst_read_data  	(dst_read_data   ),
        .dst_write_we   	(dst_write_we    )
    );

    bram u_bram(
        .clk            	(clk             ),
        .a              	(dst_addr        ),
        .d              	(dst_write_data  ),
        .we             	(dst_write_we    ),
        .spo            	(dst_read_data   ),
        .dpra           	(ist_addr        ),
        .dpo            	(ist_data        ),
        .flush              (flush),
        .nop            	(nop            )
    );
    


endmodule
/* verilator lint_off DECLFILENAME */
/* verilator lint_off WIDTHEXPAND */
module bram #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 30
)(
    input logic clk,
    input logic [DEPTH-1:0] a,
    input logic [WIDTH-1:0] d,
    input logic [3:0] we,             
    output logic [WIDTH-1:0] spo,
    input logic flush,
    input logic nop,

    input logic [DEPTH-1:0] dpra,
    output logic [WIDTH-1:0] dpo
);

    always_ff @(posedge clk) begin
        if (nop) begin
            dpo <= dpo;
        end else begin
            dpo <= pmem_read(!flush, dpra);
        end
    end

    always_ff @(posedge clk) begin
        if (nop) begin
            spo <= spo;
        end else begin
           spo <= pmem_read(1'b1, a); 
        end
    end

    always_ff @(posedge clk) begin
        pmem_write({28'b0,we}, a, d);
    end

endmodule

