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
    AXI icache_axi();
    
    soc u_soc(
        .clk            	(clk             ),
        .rst            	(rst             ),
        .icache_axi          (icache_axi.MASTER         ),      
        .flush_output              (flush),
        //.nop_output       (nop       ),
        .dst_addr       	(dst_addr        ),
        .dst_write_data 	(dst_write_data  ),
        .dst_read_data  	(dst_read_data   ),
        .dst_write_we   	(dst_write_we    )
    );

    bram u_bram(
        .clk            	(clk             ),
        .axi            	(icache_axi.SLAVER         )
    );

    /* logic uart_din_vld;
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
    ); */



endmodule
/* verilator lint_off DECLFILENAME */
/* verilator lint_off WIDTHEXPAND */
module bram (
    input logic clk,
    AXI axi
);

    assign axi.rid = axi.arid;

    enum logic {
        IDLE,
        READ
    } read_state=IDLE, next_read_state;

    always_ff @(posedge clk) begin
        read_state <= next_read_state;
    end

    always_comb begin
        next_read_state = read_state;
        case (read_state)
            IDLE: begin
                if (axi.arvalid) begin
                    next_read_state = READ;
                end
            end
            READ: begin
                if (axi.rlast) begin
                    next_read_state = IDLE;
                end
            end
        endcase
    end
    logic [31:0] addr_reg;
    logic [31:0] addr_reg_end;

    always_ff @(posedge clk) begin
        if(read_state == IDLE) begin
            axi.rlast <= 1'b0;
            if (axi.arvalid) begin
                axi.arready <= 1'b1;
                addr_reg <= axi.araddr;
                addr_reg_end <= axi.araddr + axi.arlen * (1 << axi.arsize);
                axi.rvalid <= 1'b1;
            end 
        end else if(read_state == READ) begin
            if (axi.rready) begin
                if (addr_reg < addr_reg_end) begin
                    axi.rvalid <= 1'b1;
                    addr_reg <= addr_reg + 4;
                end else begin
                    axi.rvalid <= 1'b0;
                    axi.rlast <= 1'b1;
                end
            end
        end
    end

    always_comb begin
        axi.rdata = pmem_read(1,addr_reg[19:2]);
    end

    

endmodule

