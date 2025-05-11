`include "param.vh"

module CSR(
    input logic clk, // Clock signal
    input logic rst,

    input logic [11:0] csr_addr, // CSR address
    output logic [31:0] csr_rdata, // CSR read data
    input logic [31:0] csr_wdata, // CSR write data
    input logic csr_we, // CSR write enable
    input logic [11:0] csr_waddr, // CSR write address

    output logic [31:0] mtvec_global, // Global trap vector base address
    output logic [31:0] mepc_global, // Global exception program counter
    input  logic [31:0] mepc_in, // Exception program counter input
    input logic [31:0] mcause_in, // Cause input
    input logic exp_in,
    input logic mret_in
    );

    logic [31:0] mcpuid; // Machine CPU ID
    logic [31:0] mimpid; // Machine IMP ID


    logic [31:0] mstatus; // Machine status register

    logic [31:0] mtvec; // Machine trap vector base address
    
    logic [31:0] mepc; // Machine exception program counter
    
    logic [31:0] mcause; // Machine cause register

    assign mcpuid = `mcpuid; // Assign machine CPU ID
    assign mimpid = `mimpid; // Assign machine IMP ID

    always@(*) begin
        case(csr_addr)
            `mcpuid_addr : csr_rdata = mcpuid; // Read machine CPU ID
            `mimpid_addr : csr_rdata = mimpid; // Read machine IMP ID
            `mstatus_addr : csr_rdata = (csr_waddr == `mstatus_addr && csr_we) ? csr_wdata : mstatus; // Read machine status register
            `mtvec_addr : csr_rdata = (csr_waddr == `mtvec_addr && csr_we) ? {csr_wdata[31:2],2'b0} : mtvec; // Read machine trap vector base address
            `mepc_addr : csr_rdata = (csr_waddr == `mepc_addr && csr_we) ? csr_wdata : mepc; // Read machine exception program counter
            `mcause_addr : csr_rdata = (csr_waddr == `mcause_addr && csr_we) ? csr_wdata : mcause; // Read machine cause register
            default : csr_rdata = 32'b0; // Default case for other addresses
        endcase
    end

    assign mtvec_global = mtvec; // Assign global trap vector base address
    assign mepc_global = mepc; // Assign global exception program counter

    always_ff @(posedge clk) begin
        if (rst)begin
            mstatus <= 32'b110; // Reset machine status register
        end else if (exp_in) begin
            mstatus[2:0] <= 3'b110;
            mstatus[5:3] <= mstatus[2:0]; // Save previous status to mstatus[6:4]
            mstatus[8:6] <= mstatus[5:3]; // Save previous status to mstatus[11:9]
            mstatus[11:9] <= mstatus[8:6]; // Save previous status to mstatus[14:12]
        end else if (mret_in) begin
            mstatus[2:0] <= mstatus[5:3]; // Restore previous status from mstatus[6:4]
            mstatus[5:3] <= mstatus[8:6]; // Restore previous status from mstatus[11:9]
            mstatus[8:6] <= mstatus[11:9]; // Restore previous status from mstatus[14:12]
            mstatus[11:9] <= 3'b001;
        end else if(csr_we && csr_waddr == `mstatus_addr) begin
            mstatus <= csr_wdata; // Write machine status register
        end else begin
            mstatus <= mstatus; // Keep current status
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            mtvec <= 32'h4; // Reset machine trap vector base address
        end else if (csr_we && csr_waddr == `mtvec_addr) begin
            mtvec <= {csr_wdata[31:2], 2'b00}; // Write machine trap vector base address
        end else begin
            mtvec <= mtvec; // Keep current trap vector base address
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            mepc <= 32'b0; // Reset machine exception program counter
        end else if (exp_in) begin
            mepc <= mepc_in; // Set machine exception program counter to input value
        end else if (csr_we && csr_waddr == `mepc_addr) begin
            mepc <= csr_wdata; // Write machine exception program counter
        end else begin
            mepc <= mepc; // Keep current exception program counter
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            mcause <= 32'b0; // Reset machine cause register
        end else if (exp_in) begin
            mcause <= mcause_in; // Set machine cause register to input value
        end else if (csr_we && csr_waddr == `mcause_addr) begin
            mcause <= csr_wdata; // Write machine cause register
        end else begin
            mcause <= mcause; // Keep current cause register value
        end
    end


    always begin
        update_csr({20'b0,`mstatus_addr}, mstatus); // Update machine status register
        update_csr({20'b0,`mtvec_addr}, mtvec); // Update machine trap vector base address
        update_csr({20'b0,`mepc_addr}, mepc); // Update machine exception program counter
        update_csr({20'b0,`mcause_addr}, mcause); // Update machine cause register
    end

endmodule
