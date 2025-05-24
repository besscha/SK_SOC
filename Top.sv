`include "param.vh"
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSED */
module Top(
    input logic clk,
    input logic rst,

    input logic [15:0] SW,
    output logic [15:0] LED
);
    logic [31:0] ist_data;

    logic [31:0] dst_write_data;
    logic [3:0]  dst_write_we;
    //logic flush;

    Icache_if Icache_if();
    Dcache_if Dcache_if();
    //logic nop;
    
    CPU u_CPU(
        .clk            	(clk             ),
        .rst            	(rst             ),
        .Icache_if     	    (Icache_if.master      ),
        .Dcache_if     	    (Dcache_if.master      )
    );
    
    assign Icache_if.Icache_miss = 1'b0;
    Icache u_Icache(
        .clk          	(clk           ),
        .rst          	(rst           ),
        .flush        	(Icache_if.slave.flush         ),
        .stall        	(Icache_if.slave.stall         ),
        .ist_data_in    (ist_data      ),
        .ist_data 	    (Icache_if.slave.ist_data  )
    );

    assign Dcache_if.Dcache_miss = 1'b0;
    Dcache u_Dcache(
        .Dcache_if     	(Dcache_if.slave      ),
        .data_out      	(dst_write_data       ),
        .write_we_out   	(dst_write_we        )
    );
    

    bus u_bus(
        .clk            	(clk             ),
        .soc_addr       	(Dcache_if.slave.dst_addr[31:2]    ),
        .soc_read_data   	(Dcache_if.slave.dst_read_data    ),
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
        .a              	(Dcache_if.slave.dst_addr[21:2]),
        .d              	(dst_write_data  ),
        .we             	(slave1_write_we    ),
        .spo            	(slave1_read_data   ),
        .dpra           	(Icache_if.slave.ist_addr[21:2]),
        .dpo            	(ist_data        ),
        .flush              (Icache_if.slave.flush)
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
        .addr(Dcache_if.slave.dst_addr[3:0]),
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
/* verilator lint_off WIDTH */

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

