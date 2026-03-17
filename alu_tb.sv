module alu_tb();
    reg         clk;
    reg         rst_n;
    reg         vld;
    reg         rw;
    reg  [1:0]  addr;
    reg  [7:0]  din;
    wire [7:0] 	dout;
	wire [15:0] result;
    wire        busy;
    wire        done;
	wire		err;
	wire start;


    alu_complet dut (
		.clk		(clk), 
		.rst_n		(rst_n), 
		.vld		(vld), 
		.rw			(rw),
		.addr		(addr),
		.din		(din),
		.dout		(dout),
		.res_o		(result),
		.busy		(busy),
		.done		(done),
		.err		(err),
		
		.start_o(start)

    );
	//scriere
    task write_reg(input [1:0] r_addr, input [7:0] r_data);
        begin
            @(posedge clk);
            vld <= 1; 
			rw <= 1; 
			addr <= r_addr; 
			din <= r_data; 
            @(posedge clk);
            vld <= 0;
			rw <= 0;
        end
    endtask

    //citire
    task read_result();
        begin
            @(posedge clk);
            vld <= 1;			
			rw <= 0; 
			addr <= 2'd3; 
            @(posedge clk);
			vld <= 0;
			#1;
			$display("RES = %0d (0b%0b)", result, result);
        end
    endtask
	
	initial begin
		clk = 0;
		forever #1 clk = ~clk;
	end

    initial begin
        rst_n = 1;
		vld = 0;
		rw = 0;
		addr = 0; 
		din = 0;
        #2 rst_n = 0;
		#5 rst_n = 1; 

        //op aritmetice
        $display("\n Test ADUNARE (10 + 20) ---");
        write_reg(2'd1, 8'd10);
		write_reg(2'd2, 8'd20);
		write_reg(2'd0, 8'h03); 
        @(posedge done); read_result();
		#20;
        $display("\n Test SCADERE (50 - 15) ---");
        write_reg(2'd1, 8'd50);
		write_reg(2'd2, 8'd15); 
		write_reg(2'd0, 8'h04); 
        @(posedge done); read_result();
		#20;
        
		
		
        $display("\n Test AND (10101010 & 11110000) ->");
        write_reg(2'd1, 8'b10101010);
		write_reg(2'd2, 8'b11110000);
		write_reg(2'd0, 8'h00); 
        @(posedge done); read_result(); // 160
		#20;
        $display("\n Test OR (10101010 | 11110000) ->");
        write_reg(2'd0, 8'h01); 
        @(posedge done);
		read_result(); //250
		#20;
        $display("\n Test XOR (10101010 ^ 11110000) ->");
        write_reg(2'd0, 8'h02); 
        @(posedge done);
		read_result(); // 90
		#20;
		
		
		
        $display("\n--- Test INMULTIRE (50 * 10) ->");
        write_reg(2'd1, 8'd50); write_reg(2'd2, 8'd10); write_reg(2'd0, 8'h05); 
        @(posedge done) read_result(); //500
		#20;
        $display("\n--- Test IMPARTIRE (50 / 10) ->");
        write_reg(2'd0, 8'h06); 
        @(posedge done) read_result(); //5
		#20;
        
		
        $display("\n--- Test SHIFT LEFT (5 << 2) ->");
        write_reg(2'd1, 8'd5); 
		write_reg(2'd2, 8'd2); 
		write_reg(2'd0, 8'h08); 
        @(posedge done); read_result(); // 20
		#20;
        $display("\n Test SHIFT RIGHT GOLIRE (8 >> 3) ->");
        write_reg(2'd1, 8'd8);
		write_reg(2'd2, 8'd3);
		write_reg(2'd0, 8'h07); 
        @(posedge done); read_result(); //0
		
		$display("\n--- Test IMPARTIRE (50 / 0) ->");
        write_reg(2'd1, 8'd50); write_reg(2'd2, 8'd0); write_reg(2'd0, 8'h06); 
		#20;
		
		
		vld = 0;
		rw = 0;
		addr = 0; 
		din = 0;
        #2 rst_n = 0;
		#5 rst_n = 1;
		
		$display("\n--- Test IMPARTIRE (100 / 2) ->");
        write_reg(2'd1, 8'd100); write_reg(2'd2, 8'd2); write_reg(2'd0, 8'h06); 
        @(posedge done) read_result(); //50
		
		#20;
        #5;
        $display("\n Finalizare! ");
        $stop;
    end
endmodule