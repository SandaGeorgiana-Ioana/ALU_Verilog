module op_log (
	input         clk,
    input         rst_n,
    input  [7:0]  a, b,
    input  [3:0]  op_code,
	input		  start,
    output [15:0] res,
	output reg	  busy,
	output reg	  done
);
	reg[15:0] internal_res;
	
	wire logic_op = start & (op_code == 4'h0 | op_code == 4'h1 | op_code == 4'h2);
	
	always @(posedge clk or negedge rst_n) begin
        if (~rst_n) 
            internal_res <= 16'h0;
        else if (start & logic_op)
            internal_res <= (op_code == 4'h0) ? {8'h0, a & b} :
							(op_code == 4'h1) ? {8'h0, a | b} :
							(op_code == 4'h2) ? {8'h0, a ^ b} : 16'h0;
    end
	always @(posedge clk or negedge rst_n) begin
        if (~rst_n) 
            busy <= 1'b0;
        else if (busy & done)
            busy <= 1'b0;
        else if (logic_op)
            busy <= 1'b1;
    end
	always @(posedge clk or negedge rst_n) begin
        if (~rst_n) 
            done <= 1'b0;
        else if (done & busy)
            done <= 1'b0;
        else if (busy)
            done <= 1'b1;
    end
    assign res = internal_res;
endmodule