`include "param.vh"

module regfile(
    input clk,
    input rst,

    input logic [4:0] rs1_addr,
    output logic [31:0] rs1,
    input logic [4:0] rs2_addr,
    output logic [31:0] rs2,

    input logic [4:0] rd_addr,
    input logic rd_we,
    input logic [31:0] rd
);  

    logic [31:0] regfile[31:1];

    always_comb begin
        if (rs1_addr == 5'b0) begin
            rs1 = 32'b0;
        end else if (rs1_addr == rd_addr && rd_we) begin
            rs1 = rd;
        end else begin
            rs1 = regfile[rs1_addr];
        end
    end
    
    always_comb begin
        if (rs2_addr == 5'b0) begin
            rs2 = 32'b0;
        end else if (rs2_addr == rd_addr && rd_we) begin
            rs2 = rd;
        end else begin
            rs2 = regfile[rs2_addr];
        end
    end

    always_ff @(posedge clk) begin
        if (rst)begin
            for (int i = 1; i < 31; i++) begin
                regfile[i] <= 32'b0;
            end
        end
        else begin
            if (rd_we & rd_addr != 5'b0) begin
                regfile[rd_addr] <= rd;
            end
        end
    end

    `ifdef DEBUG
    always_comb begin
        for(int i = 1; i < 32; i++) begin
            update_reg(i, regfile[i]);
        end
    end
    `endif
endmodule
