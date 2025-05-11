
module mmo(
    input logic clk,
    input logic rst,

    input logic [3:0] we,
    input logic [3:0] addr,
    input logic [31:0] din,
    output logic [31:0] dout,

    output logic [15:0] led,
    input logic [15:0] sw,

    input logic uart_din_vld,
    input logic [7:0] uart_din_data,
    input logic uart_dout_end,
    output logic [7:0] uart_dout_data,
    output logic uart_dout_vld,

    input logic [31:0] mtime_input
);

    logic [31:0] LED;
    assign led = LED[15:0];
    logic [31:0] SW;
    logic [7:0] uart_send;
    logic [7:0] uart_receive;
    logic uart_send_enable;
    logic uart_receive_end;
    logic [31:0] mtime;

    always_ff @(posedge clk) begin
        case(addr)
            4'b0000: dout <= LED;
            4'b0001: dout <= SW;
            4'b0010: dout <= {7'b0,uart_receive_end,uart_receive,7'b0,uart_send_enable,
                            uart_send};
            4'b0011: dout <= mtime;
            default: dout <= 32'h00000000;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            LED <= 32'b0;
        end else if (addr == 4'b0000)begin
            if (we[0]) begin
                LED[7:0] <= din[7:0];
            end
            if (we[1]) begin
                LED[15:8] <= din[15:8];
            end
            if (we[2]) begin
                LED[23:16] <= din[23:16];
            end
            if (we[3]) begin
                LED[31:24] <= din[31:24];
            end
        end
    end
    

    always_ff @(posedge clk) begin
        SW <= {16'b0, sw};
    end

    logic din_vld_reg;
    always_ff @(posedge clk) begin
        din_vld_reg <= uart_din_vld;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            uart_receive_end <= 1'b0;
            uart_receive <= 8'b0;
        end
        else if (din_vld_reg == 1'b0 && uart_din_vld == 1'b1) begin
            uart_receive_end <= 1'b1;
            uart_receive <= uart_din_data;
        end else if (addr == 4'b0010)begin
            if (we[3])begin
                uart_receive_end <= din[0];
            end
        end
    end

    assign uart_dout_data = uart_send;

    always_ff @(posedge clk) begin
        if (rst) begin
            uart_send_enable <= 1'b0;
        end else begin
            uart_send_enable <= uart_dout_end;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            uart_dout_vld <= 1'b0;
            uart_send <= 8'b0;
        end
        else if (addr == 4'b0010 && we[0] == 1'b1 && uart_dout_end == 1'b1)begin
            uart_send <= din[7:0];
            uart_dout_vld <= 1'b1;
        end else if (uart_dout_end == 1'b0)begin
            uart_dout_vld <= 1'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            mtime <= 32'b0;
        end else begin
            mtime <= mtime_input;
        end
    end

endmodule

