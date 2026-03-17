module alu_complet (
    input             clk, rst_n, vld, rw,
    input      [1:0]  addr,
    input      [7:0]  din,
	output	   [7:0]  dout,
    output     [15:0] res_o,
    output reg    	  busy,
	output reg	      done,
	output     	  	  err,
	
	output start_o
);
    wire [7:0]  w_op1, w_op2;
    wire [3:0]  w_code;
    wire        w_start;
    wire [15:0] r_add, r_log, r_md, r_sh;
    wire        busy_log, busy_add, busy_md, busy_sh;
	wire        done_log, done_add, done_md, done_sh;
	wire		err_md;
	reg [15:0]  result;
    
	
	alu_regs regs_i(
    .clk        (clk),
    .rst_n      (rst_n),
    .vld        (vld),
    .rw         (rw),
    .addr       (addr),
    .din        (din),
    .dout       (dout),
    .op1        (w_op1),
    .op2        (w_op2),
    .op_code    (w_code),
    .start      (w_start),
    .res_in     (result)
	);              	
	op_log lg_i(
	.clk		(clk), 
	.rst_n		(rst_n),
    .a			(w_op1),
	.b			(w_op2),
    .op_code	(w_code),
	.start		(w_start),
    .res		(r_log),
	.busy		(busy_log),
	.done		(done_log)
	);
	adder_unit ad_i(
	.clk		(clk), 
	.rst_n		(rst_n),
	.a			(w_op1),
	.b			(w_op2),
    .op_code	(w_code),
	.start		(w_start),
    .res		(r_add),
	.busy		(busy_add),
	.done		(done_add)
	);
    
    mult_div   md_i (
    .clk		(clk), 
	.rst_n		(rst_n),
	.a			(w_op1),
	.b			(w_op2),
    .op_code	(w_code),
	.start		(w_start),
    .res		(r_md),
	.busy		(busy_md),
	.done		(done_md),
	.err 		(err_md)
	);
                     
    shifter    sh_i (
	.clk		(clk), 
	.rst_n		(rst_n),
	.a			(w_op1),
	.b			(w_op2),
    .op_code	(w_code),
	.start		(w_start),
    .res		(r_sh),
	.busy		(busy_sh),
	.done		(done_sh)
	);
	always @(posedge clk or negedge rst_n) begin
        if (~rst_n) 
            result <= 8'h00;
        else case (w_code)
			4'd0: result <= r_log;
			4'd1: result <= r_log;
			4'd2: result <= r_log;
			4'd3: result <= r_add;
			4'd4: result <= r_add;
			4'd5: result <= r_md;
			4'd6: result <= r_md;
			4'd7: result <= r_sh;
			4'd8: result <= r_sh;
			default: result <= 1'd0;
		endcase
    end
	always @(posedge clk or negedge rst_n) begin
        if (~rst_n) 
            busy <= 8'h00;
        else  case (w_code)
			4'd0: busy <= busy_log;
			4'd1: busy <= busy_log;
			4'd2: busy <= busy_log;
			4'd3: busy <= busy_add;
			4'd4: busy <= busy_add;
			4'd5: busy <= busy_md;
			4'd6: busy <= busy_md;
			4'd7: busy <= busy_sh;
			4'd8: busy <= busy_sh;
			default: busy <= 1'd0;
		endcase
    end
	always @(posedge clk or negedge rst_n) begin
        if (~rst_n) 
            done <= 8'h00;
        else case (w_code)
			4'd0: done <= done_log;
			4'd1: done <= done_log;
			4'd2: done <= done_log;
			4'd3: done <= done_add;
			4'd4: done <= done_add;
			4'd5: done <= done_md;
			4'd6: done <= done_md;
			4'd7: done <= done_sh;
			4'd8: done <= done_sh;
			default: done <= 1'd0;
		endcase
    end
    
	assign dout = (addr == 2'd3) ?  res_o [15:8] : 8'h00;
	assign res_o = result;
	assign err = err_md;
	assign start_o = w_start;

	
endmodule