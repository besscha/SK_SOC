module hazard_forwarding_unit(

    input logic EX_rd_we,
    input logic [4:0] EX_rd_addr,

    input logic MEN_rd_we,
    input logic [4:0] MEN_rd_addr,

    input logic [4:0] ID_rs1_addr,
    input logic [4:0] ID_rs2_addr,

    output logic [1:0] forward_rs1,
    output logic [1:0] forward_rs2
);

    always_comb begin
        // 初始化信号
        forward_rs1 = 2'b00;
        forward_rs2 = 2'b00;
        // 处理 ID_rs1_addr 的冒险
        if (ID_rs1_addr != 5'b0) begin
            if (EX_rd_we && EX_rd_addr == ID_rs1_addr) begin
                forward_rs1 = 2'b01; // 转发自 EX 阶段
            end else if (MEN_rd_we && MEN_rd_addr == ID_rs1_addr) begin
                forward_rs1 = 2'b10; // 转发自 MEN 阶段
            end
        end

        // 处理 ID_rs2_addr 的冒险
        if (ID_rs2_addr != 5'b0) begin
            if (EX_rd_we && EX_rd_addr == ID_rs2_addr) begin
                forward_rs2 = 2'b01; // 转发自 EX 阶段
            end else if (MEN_rd_we && MEN_rd_addr == ID_rs2_addr) begin
                forward_rs2 = 2'b10; // 转发自 MEN 阶段
            end
        end
    end

endmodule
