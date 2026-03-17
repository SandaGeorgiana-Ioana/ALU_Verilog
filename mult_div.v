module mult_div (
    input             clk,
    input             rst_n,
    input             start,
    input      [3:0]  op_code,
    input      [7:0]  a,
    input      [7:0]  b,
    output     [15:0] res,
    output reg        busy,
	output reg		  done,
	output reg		  err
);

    reg [7:0] counter;
    reg [7:0] temp_val;
	reg [15:0] res_internal;
	reg [15:0] res_calcul;
	
    wire mult_div = start & (op_code == 4'h5 | op_code == 4'h6);

  //busy
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) 
            busy <= 1'b0;
        else if (busy & done)
            busy <= 1'b0;
        else if (mult_div)
            busy <= 1'b1;
    end
	
	always @(posedge clk or negedge rst_n) begin
        if (~rst_n) 
            done <= 1'b0;
        else if (done & busy)
            done <= 1'b0;
        else if (busy & ((counter == b & op_code == 4'h5) | (temp_val < b & op_code == 4'h6)))
            done <= 1'b1;
    end
   //counter inmultire
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= 8'd0;
        else if (mult_div)
            counter <= 8'd0;
        else if (busy & op_code == 4'h5)
            counter <= counter + 8'd1;
    end
   //val temporara pt impartire
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            temp_val <= 8'd0;
        else if (mult_div)
            temp_val <= a;
        else if (busy & op_code == 4'h6 & temp_val >= b & b != 8'h0)
            temp_val <= temp_val - b;
    end
  //rezultat
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            res_calcul <= 16'd0;
        else if (mult_div)
            res_calcul <= 16'd0;
        else if (busy & !done) begin
            if (op_code == 4'h5)
                res_calcul <= res_calcul + a;
            else if (op_code == 4'h6) begin
                if (b == 8'h0)
                    res_calcul <= 16'hFFFF;
                else if (temp_val >= b)
                    res_calcul <= res_calcul + 16'd1;
            end
        end
    end
	
	always @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            err <= 1'd0;
        else if (op_code == 4'h6 & b == 0)
            err <= 1'd1;
    end
	
	always @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            res_internal <= 16'd0;
        else if ((counter == b & op_code == 4'h5) | (temp_val < b & op_code == 4'h6) | (op_code == 4'h6 & b == 8'h0))
            res_internal <= res_calcul;
    end
	
	assign res = res_internal;
endmodule
