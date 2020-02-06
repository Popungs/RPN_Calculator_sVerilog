module stack (input clk, rst,pop,push, 
	input [31:0] data_in, 
	output [31:0] stack_top, stack_next, 
	output [5:0] numcnt,
	output full, empty); // cnt ?

logic [5:0] stack_top_ptr, stack_ptr;


cnt6 stackctr(.clk(clk), .rst(rst), .en_up(push), .en_down(pop), .cnt(stack_ptr));

assign numcnt = stack_ptr;
assign stack_top_ptr = stack_ptr-6'b1;

assign full = stack_ptr == 6'd32 ? 1'd1 : 1'd0;
assign empty = stack_ptr == 6'd0 ? 1'd1 : 1'd0;
// INSTANTIATED REG FILE MODULE
regfile stackreg (.clk(clk),
.rst(rst),
.we(push),
.readaddr1(stack_top_ptr[4:0]),
.readaddr2(stack_top_ptr[4:0]-1),
.writeaddr(stack_ptr[4:0]),
.writedata(data_in),
.readdata1(stack_top),
.readdata2(stack_next));
initial begin 
	//stack_ptr = 6'b0;
	//push = 1'b0;
	//pop = 1'b0;
end
/*
always_ff @(posedge clk) begin
	if (push == 1'b1) begin 
		stack_ptr = stack_ptr + 6'b1;
	end else if (pop == 1'b1) begin
		stack_ptr = stack_ptr - 6'b1;
	end 

end
*/
endmodule
