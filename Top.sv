`include "param.vh"
/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off IMPLICIT */
/* verilator lint_off UNDRIVEN */
module Top(
    input logic clk,
    input logic rst,

    input logic [15:0] SW,
    output logic [15:0] LED
);

    logic [29:0] ist_addr;
    logic [31:0] ist_data;
    logic [29:0] dst_addr;
    logic [31:0] dst_write_data;
    logic [31:0] dst_read_data;
    logic [3:0]  dst_write_we;
    logic flush;
    //logic nop;
    
    soc u_soc(
        .clk            	(clk             ),
        .rst            	(rst             ),
        .ist_addr       	(ist_addr        ),
        .ist_data       	(ist_data        ),
        .flush_output              (flush),
        //.nop_output       (nop       ),
        .dst_addr       	(dst_addr        ),
        .dst_write_data 	(dst_write_data  ),
        .dst_read_data  	(dst_read_data   ),
        .dst_write_we   	(dst_write_we    )
    );

    bus u_bus(
        .clk            	(clk             ),
        .soc_addr       	(dst_addr        ),
        .soc_read_data   	(dst_read_data    ),
        .soc_write_we    	(dst_write_we     ),

        .slave1_read_data  (slave1_read_data   ),
        .slave1_write_we   (slave1_write_we    ),
        .slave2_read_data  (slave2_read_data   ),
        .slave2_write_we   (slave2_write_we    )
    );

    logic [31:0] slave1_read_data;
    logic [3:0] slave1_write_we;
    logic [31:0] slave2_read_data;
    logic [3:0] slave2_write_we;

    bram u_bram(
        .clk            	(clk             ),
        .a              	(dst_addr[19:0]       ),
        .d              	(dst_write_data  ),
        .we             	(slave1_write_we    ),
        .spo            	(slave1_read_data   ),
        .dpra           	(ist_addr[19:0]        ),
        .dpo            	(ist_data        ),
        .flush              (flush           )
        //.nop            	(nop            )
    );

    logic uart_din_vld;
    logic [7:0] uart_din_data;
    logic [7:0] uart_dout_data;
    logic uart_dout_vld;
    logic uart_dout_end;
    logic [31:0] mtime;
    
    mmo u_mmo(
        .clk(clk),
        .rst(rst),
        .we(slave2_write_we),
        .addr(dst_addr[3:0]),
        .din(dst_write_data),
        .dout(slave2_read_data),
        .led(LED),
        .sw(SW),
        .uart_din_vld(uart_din_vld),
        .uart_din_data(uart_din_data),
        .uart_dout_data(uart_dout_data),
        .uart_dout_vld(uart_dout_vld),
        .uart_dout_end(uart_dout_end),
        .mtime_input(mtime)
    );



endmodule
/* verilator lint_off DECLFILENAME */
/* verilator lint_off WIDTHEXPAND */
module bram #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 20
)(
    input logic clk,
    input logic [DEPTH-1:0] a,
    input logic [WIDTH-1:0] d,
    input logic [3:0] we,             
    output logic [WIDTH-1:0] spo,
    input logic flush,
    //input logic nop,

    input logic [DEPTH-1:0] dpra,
    output logic [WIDTH-1:0] dpo
);

    always_ff @(posedge clk) begin
        dpo <= pmem_read(!flush, dpra);
    end

    always_ff @(posedge clk) begin
        spo <= pmem_read(1'b1, a); 
    end

    always_ff @(posedge clk) begin
        pmem_write({28'b0,we}, a, d);
    end

endmodule

