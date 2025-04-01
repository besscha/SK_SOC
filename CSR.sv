`include "param.vh"

module CSR(
    input logic clk, // Clock signal
    input logic rst,

    input logic [11:0] csr_addr, // CSR address
    output logic [31:0] csr_rdata, // CSR read data
    input logic [31:0] csr_wdata, // CSR write data
    input logic csr_we, // CSR write enable
    input logic [11:0] csr_waddr // CSR write address
);

    logic [31:0] mcpuid; // Machine CPU ID
    logic [31:0] mimpid; // Machine IMP ID


    logic [31:0] mstatus; // Machine status register

    logic [31:2] mtvec_reg; // Machine trap vector base address
    logic [31:0] mtvec; // Machine trap vector base address
    assign mtvec = {mtvec_reg, 2'b00}; // Align to 4-byte boundary
    
    logic [31:0] mepc; // Machine exception program counter
    
    logic [31:0] mcause; // Machine cause register

    assign mcpuid = `mcpuid; // Assign machine CPU ID
    assign mimpid = `mimpid; // Assign machine IMP ID

    always_comb begin
        case(csr_addr)
            `mcpuid_addr : csr_rdata = mcpuid; // Read machine CPU ID
            `mimpid_addr : csr_rdata = mimpid; // Read machine IMP ID
            `mstatus_addr : csr_rdata = csr_waddr == `mstatus_addr ? csr_wdata : mstatus; // Read machine status register
            `mtvec_addr : csr_rdata = csr_waddr == `mtvec_addr ? {csr_wdata[31:2],2'b0} : mtvec; // Read machine trap vector base address
            `mepc_addr : csr_rdata = csr_waddr == `mepc_addr ? csr_wdata : mepc; // Read machine exception program counter
            `mcause_addr : csr_rdata = csr_waddr == `mcause_addr ? csr_wdata : mcause; // Read machine cause register
            default : csr_rdata = 32'b0; // Default case for other addresses
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst)begin
            mstatus <= 32'b110; // Reset machine status register
            mtvec_reg <= 30'b1; // Reset machine trap vector base address
            mepc <= 32'b0; // Reset machine exception program counter
            mcause <= 32'b0; // Reset machine cause register
        end else begin
            if (csr_we) begin
                case(csr_waddr)
                    `mstatus_addr : mstatus <= csr_wdata; // Write machine status register
                    `mtvec_addr : mtvec_reg <= csr_wdata[31:2]; // Write machine trap vector base address
                    `mepc_addr : mepc <= csr_wdata; // Write machine exception program counter
                    `mcause_addr : mcause <= csr_wdata; // Write machine cause register
                    default :begin
                    end
                endcase
            end
        end
    end


    always begin
        update_csr({20'b0,`mstatus_addr}, mstatus); // Update machine status register
        update_csr({20'b0,`mtvec_addr}, mtvec); // Update machine trap vector base address
        update_csr({20'b0,`mepc_addr}, mepc); // Update machine exception program counter
        update_csr({20'b0,`mcause_addr}, mcause); // Update machine cause register
    end

endmodule
