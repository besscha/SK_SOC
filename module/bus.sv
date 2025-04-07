`include "./module/param.vh"
/* verilator lint_off UNUSEDSIGNAL */
module bus(
    input logic clk,

    input logic [29:0] soc_addr,
    output logic [31:0] soc_read_data,
    input logic [3:0] soc_write_we,
    //input logic soc_nop,

    //output logic [29:0] slave_addr,
    //output logic [31:0] slave_write_data,
    //output logic slave_nop,

    input logic [31:0] slave1_read_data,
    output logic [3:0] slave1_write_we,

    input logic [31:0] slave2_read_data,
    output logic [3:0] slave2_write_we
);

    logic [3:0] divice_id;

    always_ff @(posedge clk) begin
        divice_id <= soc_addr[29:26];
    end

    always_comb begin
        case(divice_id)
            `main_memory_id: begin
                soc_read_data = slave1_read_data;
            end
            `mmo_memory_id: begin
                soc_read_data = slave2_read_data;
            end
            default: begin
                soc_read_data = 32'b0;
            end
        endcase
    end

    assign slave1_write_we = soc_addr[29:26] == `main_memory_id ? soc_write_we : 4'b0000;
    assign slave2_write_we = soc_addr[29:26] == `mmo_memory_id ? soc_write_we : 4'b0000;


endmodule

