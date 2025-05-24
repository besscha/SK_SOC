/* verilator lint_off DECLFILENAME */
/* verilator lint_off UNUSED */

interface Icache_if;
    logic flush;
    logic stall;
    logic Icache_miss;
    logic [31:0] ist_addr;
    logic [31:0] ist_data;

    modport master(
        output flush, 
        output stall,
        input  Icache_miss,
        output ist_addr,
        input  ist_data
    );

    modport slave(
        input  flush, 
        input  stall,
        output Icache_miss,
        input  ist_addr,
        output ist_data
    );

endinterface


interface Dcache_if;

    logic flush;
    logic stall;
    logic Dcache_miss;
    logic [2:0] dst_width;
    logic [31:0] dst_addr;
    logic [31:0] dst_write_data;
    logic        dst_write_we;
    logic [31:0] dst_read_data;

    modport master(
        output flush, 
        output stall,
        input  Dcache_miss,
        output dst_width,
        output dst_addr,
        output dst_write_data,
        output dst_write_we,
        input  dst_read_data
    );

    modport slave(
        input  flush, 
        input  stall,
        output Dcache_miss,
        input  dst_width,
        input  dst_addr,
        input  dst_write_data,
        input  dst_write_we,
        output dst_read_data
    );

endinterface
