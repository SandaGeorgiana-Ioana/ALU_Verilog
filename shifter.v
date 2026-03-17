module shifter (
    input             clk, 
    input             rst_n, 
    input             start,
    input      [3:0]  op_code,
    input      [7:0]  a, 
    input      [7:0]  b,
    output reg [15:0] res,
    output reg        busy,
	output reg		  done
);
    reg [7:0] counter;
	reg [15:0] res_internal;
	reg [15:0] res_calcul;

    //siftare stanga sau dreapta
    wire shift = start & (op_code == 4'h7 | op_code == 4'h8);

    //busy
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) 
            busy <= 1'b0;
        else if (shift)
            busy <= 1'b1;
        else if (busy & done)
            busy <= 1'b0;
    end
	always @(posedge clk or negedge rst_n) begin
        if (~rst_n) 
            done <= 1'b0;
        else if (done & busy)
            done <= 1'b0;
        else if (busy & counter == b)
            done <= 1'b1;
    end
    //counter pt shift
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) 
            counter <= 8'h00;
        else if (shift)
            counter <= 8'h00;
        else if (busy & counter < b)
            counter <= counter + 8'h01;
    end

    //rez
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) 
            res_calcul <= 16'h0000;
        else if (shift)
            res_calcul <= {8'h00, a}; 
        else if (busy & counter < b) begin
            // 8-dr, 9-stanga
            if (op_code == 4'h7)
                res_calcul <= {1'b0, res_calcul[15:1]};
            else if (op_code == 4'h8)
                res_calcul <= {res_calcul[14:0], 1'b0}; 
        end
    end
	always @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            res_internal <= 16'd0;
        else if (counter == b & (op_code == 4'h7 | op_code == 4'h8))
            res_internal <= res_calcul;
    end
	
	//assign res = res_internal;
	always @(posedge clk or negedge rst_n) begin
		if (~rst_n)
			res <= 16'd0;
		else
			res <= res_internal;
	end

endmodule