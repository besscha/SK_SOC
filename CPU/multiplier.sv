/* verilator lint_off DECLFILENAME */
/* verilator lint_off GENUNNAMED */

module multiplier(
    input clk,
    input rst,
    input [1:0] symbolic,

    input [31:0] x,
    input [31:0] y,
    output logic [63:0] p
);

    logic [32:0] x_input;
    logic [32:0] y_input;

    assign x_input = symbolic[0] ? {x[31],x} : {1'b0,x};
    assign y_input = symbolic[1] ? {y[31],y} : {1'b0,y};

    multi i_multi(
        .clk(clk),
        .rst(rst),
        .x(x_input),
        .y(y_input),
        .p(p)
    );

endmodule

module multi(
    input clk,
    input rst,

    input [32:0] x,
    input [32:0] y,

    output logic [63:0] p
    );

    logic [63:0] PP[17:0];
    logic neq[17:0];

    genvar i;
    generate
        for(i=0;i<17;i=i+1)begin
            if(i==0)begin
                booth#(
                    .m(2*i)
                ) i_bs(
                    .y({y[1:0],1'b0}),
                    .x(x),
                    .p(PP[i]),
                    .neq(neq[i])
                );
            end else if(i==16)begin
                booth#(
                    .m(2*i)
                ) i_bs(
                    .y({y[32],y[32:31]}),
                    .x(x),
                    .p(PP[i]),
                    .neq(neq[i])
                );
            end else begin
                booth#(
                    .m(2*i)
                ) i_bs(
                    .y(y[2*i+1:2*i-1]),
                    .x(x),
                    .p(PP[i]),
                    .neq(neq[i])
                );
            end
        end
    endgenerate

    assign PP[17] = {31'b0,neq[16],1'b0,neq[15],1'b0,neq[14],1'b0,neq[13],1'b0,neq[12],
    1'b0,neq[11],1'b0,neq[10],1'b0,neq[9],1'b0,neq[8],1'b0,neq[7],1'b0,
    neq[6],1'b0,neq[5],1'b0,neq[4],1'b0,neq[3],1'b0,neq[2],1'b0,neq[1],1'b0,neq[0]};

    //---------------
    // S1
    logic [63:0] PP1[11:0];

    generate
        for(i=0;i<6;i++)begin
            CSA#(
                .WIDTH(64)
            ) i_csa1(
                .a(PP[3*i]),
                .b(PP[3*i+1]),
                .c(PP[3*i+2]),
                .s(PP1[2*i]),
                .cout(PP1[2*i+1])
            );
        end
    endgenerate

    //---------------
    // S2
    logic [63:0] PP2[7:0];
    generate
        for(i=0;i<4;i++)begin
            CSA#(
                .WIDTH(64)
            ) i_csa2(
                .a(PP1[3*i]),
                .b(PP1[3*i+1]),
                .c(PP1[3*i+2]),
                .s(PP2[2*i]),
                .cout(PP2[2*i+1])
            );
        end
    endgenerate

    //---------------
    // S3
    logic [63:0] PP3[5:0];

    generate
        for(i=0;i<2;i++)begin
            CSA#(
                .WIDTH(64)
            ) i_csa3(
                .a(PP2[3*i]),
                .b(PP2[3*i+1]),
                .c(PP2[3*i+2]),
                .s(PP3[2*i]),
                .cout(PP3[2*i+1])
            );
        end
    endgenerate

    assign PP3[4] = PP2[6];
    assign PP3[5] = PP2[7];
    //---------------
    // S4

    logic [63:0] PP4[3:0];
    
    generate
        for(i=0;i<2;i++)begin
            CSA#(
                .WIDTH(64)
            ) i_csa4(
                .a(PP3[3*i]),
                .b(PP3[3*i+1]),
                .c(PP3[3*i+2]),
                .s(PP4[2*i]),
                .cout(PP4[2*i+1])
            );
        end
    endgenerate

    //---------------
    // S5
    logic [63:0] PP5[2:0];
    CSA#(
        .WIDTH(64)
    ) i_csa5(
        .a(PP4[0]),
        .b(PP4[1]),
        .c(PP4[2]),
        .s(PP5[0]),
        .cout(PP5[1])
    );
    assign PP5[2] = PP4[3];

    //---------------
    // S6
    logic [63:0] PP6[1:0];
    CSA#(
        .WIDTH(64)
    ) i_csa6(
        .a(PP5[0]),
        .b(PP5[1]),
        .c(PP5[2]),
        .s(PP6[0]),
        .cout(PP6[1])
    );

    //---------------
    // add

    logic [63:0] PP6_reg[1:0];

    always_ff @(posedge clk)begin
        if(rst)begin
            PP6_reg[0] <= 64'b0;
            PP6_reg[1] <= 64'b0;
        end else begin
            PP6_reg[0] <= PP6[0];
            PP6_reg[1] <= PP6[1];
        end
    end

    assign p = PP6_reg[0] + PP6_reg[1];
endmodule

module CSA#(
    parameter WIDTH = 64
)(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    input [WIDTH-1:0] c,

    output logic [WIDTH-1:0] s,
    output logic [WIDTH-1:0] cout
    );

    assign s = a ^ b ^ c;
    logic [WIDTH-1:0] cout_temp;
    assign cout_temp = a & b | b & c | c & a;
    assign cout = cout_temp << 1;

endmodule
/* verilator lint_off UNUSEDSIGNAL */
module booth#(
    parameter m         //base left shift bits
)(
    input [2:0] y,
    input [32:0] x,

    output logic [63:0] p,
    output logic neq
    );

    logic z0;
    logic z1;
    logic [65:0] pt1;
    logic [65:0] pt2;
    logic [65:0] pt3;
    
    assign z0 = y[1] ^ y[0];
    assign z1 = (~y[2] & y[1] & y[0]) | (y[2] & ~y[1] & ~y[0]); 
    assign neq = y[2] & ~(y[0] & y[1]);
    assign pt1 = z1 ? {{32{x[32]}},x,1'b0} :
                z0 ? {{33{x[32]}},x} :
                66'b0; 
    assign pt2 = neq ? ~pt1 : pt1;
    assign pt3 = pt2 << m;
    assign p = pt3[63:0];

endmodule
