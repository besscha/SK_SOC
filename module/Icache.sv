`include "param.vh"

module Icache(
    input logic clk,
    input logic rst,
    
    input logic flush,
    input logic stall,

    input logic [31:0]  ist_data,
    output logic [31:0] IF2_ist_data
);

    logic [31:0] ist_data_reg;
    logic stall_reg;
    logic flush_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            ist_data_reg <= `nop;
        end else if (stall_reg) begin
            ist_data_reg <= ist_data_reg;
        end else begin
            ist_data_reg <= ist_data;
        end
    end

    always_ff @(posedge clk) begin
        stall_reg <= stall;
        flush_reg <= flush;
    end

    always_comb begin
        if (flush_reg) begin
            IF2_ist_data = `nop;
        end else if (stall_reg) begin
            IF2_ist_data = ist_data_reg;
        end else begin
            IF2_ist_data = ist_data;
        end
    end

endmodule
