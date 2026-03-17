module adder_unit (
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
	
	wire logic_op = (op_code == 4'h3 | op_code == 4'h4);
	
	always @(posedge clk or negedge rst_n) begin
        if (~rst_n) 
            internal_res <= 8'h00;
        else if (start & logic_op)
            internal_res <= (op_code == 4'h3) ? (a + b) : 
							(op_code == 4'h4) ? (a - b) : 16'h0;
    end
	always @(posedge clk or negedge rst_n) begin
        if (~rst_n) 
            busy <= 1'b0;
        else if (start & logic_op)
            busy <= 1'b1;
        else if (busy & done)
            busy <= 1'b0;
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