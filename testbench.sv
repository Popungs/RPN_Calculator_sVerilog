module testbench;

logic clk, rst;
// logic [17:0] SW;
//logic [1:0] mode;
//logic [15:0] val;
//logic [17:0] SW;
logic [7:0] LEDG;
logic [3:0] KEY, KEY_dly;
logic [15:0] raw_out1, raw_out2;
logic [31:0] i;
logic [1:0] mode;
logic [15:0] val;
/*
assign val = SW[15:0];
assign mode = SW[17:16];
*/
// expected val 
logic [15:0] raw_out1_e, raw_out2_e;
logic [7:0] LEDG_e;

logic [62:0] vectors [999:0];
/*
initial begin 
  KEY = 4'hF; #50
  KEY = 4'h7; #77
  KEY = 4'hF;
end
*/



/*
always_ff @(posedge clk) KEY_dly <= KEY;

assign start = &KEY_dly && ~&KEY;
*/

initial begin
	//raw_out1_e = 16'h0;
	//raw_out2_e = 16'h0;
	//LEDG_e = 8'h0;
	//LEDG = 8'h0;
	raw_out1 = 16'h0;
	raw_out2 = 16'h0;
/*
	SW = 18'h0;

	val = 16'h0;
	mode = 2'h0;
	rst = 1'b0;
 	KEY = 4'b0;
*/
	i = 32'b0;
end
/*
rpncalc rpn (.clk(),
.rst(),
.mode(),
.key(),
.val(),
.top(),
.next(),
.counter());
*/

rpncalc rpn (.clk(clk), .rst(rst), .mode(mode), .key(KEY), .val(val), .top(raw_out1), .next(raw_out2), .counter(LEDG));
// raw_out1 = 16 bits raw_out1 = top of the stack 
// raw_out2 = 16 bits raw_out2 = next to top of the stack
// LEDG = 8 bits 
// 40 + 23


always begin
	$readmemb("testvec.dat",vectors);
	clk = 1'b1; #5;

	{mode, KEY, val,rst, raw_out1_e, raw_out2_e, LEDG_e } = vectors[i];
	clk = 1'b0; #5;

	// $readmemb("testvec.dat",vectors);

	// val = SW[15:0]
	// mode = SW[17:16] 
	//#5;
	// {mode, KEY, val,rst, raw_out1_e, raw_out2_e, LEDG_e } = vectors[i]; 
	// {mode, val, KEY, rst, raw_out1_e, raw_out2_e, LEDG_e} = vectors[i];
	
	if (raw_out1 !== raw_out1_e) begin
		$display("Error: inputs %h", {raw_out1_e});
		$display (" outputs = %h (%h expected) at time %d",raw_out1,raw_out1_e, $time);
	end
	if (raw_out2 !== raw_out2_e) begin
		$display("Error: inputs %h", {raw_out2_e});
		$display (" outputs = %h (%h expected) at time %d",raw_out2,raw_out2_e, $time);
	end
	if (LEDG !== LEDG_e) begin
		$display("Error: inputs %h", {raw_out1_e});
		$display (" outputs = %h (%h expected) at time %d",raw_out1,raw_out1_e, $time);
	end
	
	i = i + 1'b1;
	
	// $stop();
end



 
/*
always_comb begin
	clk = 0;
	SW = 18'b000000000000000011;
	KEY = 4'b1110;
	#5
end 
*/
endmodule
