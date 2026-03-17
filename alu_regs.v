module alu_regs (
    input             clk, 
    input             rst_n, 
    input             vld, 
    input             rw,
    input      [1:0]  addr,
    input      [7:0]  din,
    output     [7:0]  dout,
    output     [7:0]  op1, 
    output     [7:0]  op2,
    output     [3:0]  op_code,
    output            start,
    input      [15:0] res_in  
);
    reg [7:0]  reg_ctrl, reg_op1, reg_op2;
	reg [1:0]  start_cnt;
	reg [15:0] internal_res;
    // validare a scrierii
    wire we_ctrl = vld & rw & (addr == 2'd0);
    wire we_op1  = vld & rw & (addr == 2'd1);
    wire we_op2  = vld & rw & (addr == 2'd2);

    
    //CTRL
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) 
            reg_ctrl <= 8'h00;
        else if (we_ctrl)
            reg_ctrl <= din;
    end

    //OP1
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) 
            reg_op1 <= 8'h00;
        else if (we_op1)
            reg_op1 <= din;
    end

    //OP2
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) 
            reg_op2 <= 8'h00;
        else if (we_op2)
            reg_op2 <= din;
    end

    //REZ-actualizare cand calc s a terminat
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) 
            internal_res <= 16'h0000;
        else
            internal_res <= res_in; 
    end
	
	always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        start_cnt <= 2'd0;
    else if (we_ctrl)
        start_cnt <= 2'd1;      
    else if (start_cnt != 2'd0)
        start_cnt <= start_cnt - 1'b1;
end

    //start-poarta and
    assign start 	 = (start_cnt != 2'd0); 
    assign op_code   = reg_ctrl[3:0];
    assign op1       = reg_op1;
    assign op2       = reg_op2;
	assign dout		 = (addr == 2'd3) ? internal_res[15:8] : 8'h0;

endmodule