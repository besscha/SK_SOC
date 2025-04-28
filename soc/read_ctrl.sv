`include "param.vh"

module read_ctrl(
    input logic [31:0] dst_read_data,
    input logic [1:0] addr,
    input logic [2:0] dst_width,

    output logic [31:0] data_out
);

    logic [31:0] data_out_byte;
    logic [31:0] data_out_ubyte;
    logic [31:0] data_out_half;
    logic [31:0] data_out_uhalf;
    logic [31:0] data_out_word;

    always@(*) begin
        case(addr)
            2'd0: begin
                data_out_byte = {{24{dst_read_data[7]}}, dst_read_data[7:0]};
                data_out_ubyte = {24'b0, dst_read_data[7:0]};
            end
            2'd1: begin
                data_out_byte = {{24{dst_read_data[15]}}, dst_read_data[15:8]};
                data_out_ubyte = {24'b0, dst_read_data[15:8]};
            end
            2'd2: begin
                data_out_byte = {{24{dst_read_data[23]}}, dst_read_data[23:16]};
                data_out_ubyte = {24'b0, dst_read_data[23:16]};
            end
            2'd3: begin
                data_out_byte = {{24{dst_read_data[31]}}, dst_read_data[31:24]};
                data_out_ubyte = {24'b0, dst_read_data[31:24]};
            end
        endcase
    end

    always@(*) begin
        case(addr[1])
            1'b0: begin
                data_out_half = {{16{dst_read_data[15]}}, dst_read_data[15:0]};
                data_out_uhalf = {16'b0, dst_read_data[15:0]};
            end
            1'b1: begin
                data_out_half = {{16{dst_read_data[31]}}, dst_read_data[31:16]};
                data_out_uhalf = {16'b0, dst_read_data[31:16]};
            end
        endcase
    end

    assign data_out_word = dst_read_data;

    always_comb begin
        case(dst_width)
            `data_width_byte: begin
                data_out = data_out_byte;
            end
            `data_width_ubyte: begin
                data_out = data_out_ubyte;
            end
            `data_width_half: begin
                data_out = data_out_half;
            end
            `data_width_uhalf: begin
                data_out = data_out_uhalf;
            end
            `data_width_word: begin
                data_out = data_out_word;
            end
            default: begin
                data_out = 32'b0;
            end
        endcase
    end

endmodule
