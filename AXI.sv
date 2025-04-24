/* verilator lint_off UNUSEDSIGNAL */

interface AXI();
    logic [3:0] arid;
    logic [31:0] araddr;
    logic [7:0] arlen;
    logic [2:0] arsize;
    logic [1:0] arburst;
    logic arvalid;
    logic arready;
    
    logic [3:0] rid;
    logic [31:0] rdata;
    logic [1:0] rresp;
    logic rlast;
    logic rvalid;
    logic rready;

    modport MASTER (
        output arid,araddr,arlen,arsize,arburst,arvalid,
        input arready,
        input rid,rdata,rresp,rlast,rvalid,
        output rready
    );
    modport SLAVER (
        input arid,araddr,arlen,arsize,arburst,arvalid,
        output arready,
        output rid,rdata,rresp,rlast,rvalid,
        input rready
    );
endinterface
