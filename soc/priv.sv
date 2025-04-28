
module priv(
    input logic [31:0] csr_rdata,
    input logic [31:0] rs,
    input logic [4:0] zimm,
    input logic [2:0] csr_sel,
    output logic [31:0] csr_wdata
);

    logic [31:0] imm;
    assign imm = {{27'b0}, zimm};

    always_comb begin
        case(csr_sel)
            3'b001: csr_wdata = rs; // Write rs to CSR
            3'b101: csr_wdata = imm; // Write immediate to CSR
            3'b010: csr_wdata = rs | csr_rdata; // Set bits in CSR
            3'b110: csr_wdata = imm | csr_rdata; // Set bits in CSR
            3'b011: csr_wdata = ~rs & csr_rdata; // Clear bits in CSR
            3'b111: csr_wdata = ~imm & csr_rdata; // Clear bits in CSR
            default: csr_wdata = csr_rdata; // Default case, no change
        endcase
    end

endmodule
