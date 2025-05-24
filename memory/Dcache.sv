`include "param.vh"

module Dcache(

    Dcache_if Dcache_if,

    output logic [31:0] data_out,
    output logic [3:0] write_we_out
);
    assign Dcache_if.Dcache_miss = 1'b0;

    logic [1:0] addr;
    assign addr = Dcache_if.dst_addr[1:0];

    logic [3:0] write_we;
    assign write_we_out = Dcache_if.dst_write_we ? write_we : 4'b0000;

    logic [3:0]  write_we_byte;
    logic [31:0] data_out_byte;
    always_comb begin
        case (addr)
            2'd0: begin
                write_we_byte = 4'b0001;
                data_out_byte = {24'b0, Dcache_if.dst_write_data[7:0]};
            end
            2'd1: begin
                write_we_byte = 4'b0010;
                data_out_byte = {16'b0, Dcache_if.dst_write_data[7:0], 8'b0};
            end
            2'd2: begin
                write_we_byte = 4'b0100;
                data_out_byte = {8'b0, Dcache_if.dst_write_data[7:0], 16'b0};
            end
            2'd3: begin
                write_we_byte = 4'b1000;
                data_out_byte = {Dcache_if.dst_write_data[7:0], 24'b0};
            end
        endcase
    end

    logic [3:0] write_we_half;
    logic [31:0] data_out_half;

    always_comb begin
        case (addr[1])
            1'b0: begin
                write_we_half = 4'b0011;
                data_out_half = {16'b0, Dcache_if.dst_write_data[15:0]};
            end
            1'b1: begin
                write_we_half = 4'b1100;
                data_out_half = {Dcache_if.dst_write_data[15:0], 16'b0};
            end 
        endcase
    end

    logic [3:0] write_we_word;
    assign write_we_word = 4'b1111;
    logic [31:0] data_out_word;
    assign data_out_word = Dcache_if.dst_write_data;

    always_comb begin
        case(Dcache_if.dst_width)
            `data_width_byte: begin
                write_we = write_we_byte;
                data_out = data_out_byte;
            end
            `data_width_half: begin
                write_we = write_we_half;
                data_out = data_out_half;
            end
            `data_width_word: begin
                write_we = write_we_word;
                data_out = data_out_word;
            end
            default: begin
                write_we = 4'b0000;
                data_out = 32'b0;
            end
        endcase
    end

endmodule
