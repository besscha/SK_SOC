`include "param.vh"

module times(
    input logic clk,
    input logic rst,
    output logic [31:0] mtime
);
    parameter TIME_COUNTER = 32'd1_000_000 * `BASIC_FREQUENCY / 100; // 0.01s

    logic [31:0] time_counter;

    always_ff @(posedge clk) begin
        if (rst) begin
            time_counter <= 32'b0;
        end else if (time_counter == TIME_COUNTER)begin   // 0.01s
            time_counter <= 32'b0;
        end else begin
            time_counter <= time_counter + 1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            mtime <= 32'b0;
        end else if (time_counter == TIME_COUNTER)begin   // 0.01s
            mtime <= mtime + 1;
        end else begin
            mtime <= mtime;
        end
    end

endmodule
