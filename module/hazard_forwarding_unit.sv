module hazard_forwarding_unit(

    input logic MEN_rd_we,
    input logic [4:0] MEN_rd_addr,

    input logic WB_rd_we,
    input logic [4:0] WB_rd_addr,

    input logic [4:0] EX_rs1_addr,
    input logic [4:0] EX_rs2_addr,

    output logic [1:0] forward_rs1,
    output logic [1:0] forward_rs2
);

    always_comb begin
        // 初始化信号
        forward_rs1 = 2'b00;
        forward_rs2 = 2'b00;
        // 处理 EX_rs1_addr 的冒险
        if (EX_rs1_addr != 5'b0) begin
            if (MEN_rd_we && MEN_rd_addr == EX_rs1_addr) begin
                forward_rs1 = 2'b01; // 转发自 MEM 阶段
            end else if (WB_rd_we && WB_rd_addr == EX_rs1_addr) begin
                forward_rs1 = 2'b10; // 转发自 WB 阶段
            end
        end

        // 处理 EX_rs2_addr 的冒险
        if (EX_rs2_addr != 5'b0) begin
            if (MEN_rd_we && MEN_rd_addr == EX_rs2_addr) begin
                forward_rs2 = 2'b01; // 转发自 MEM 阶段
            end else if (WB_rd_we && WB_rd_addr == EX_rs2_addr) begin
                forward_rs2 = 2'b10; // 转发自 WB 阶段
            end
        end
    end

endmodule
