/* RPN calculator module implementation */
module rpncalc(
/**** inputs *****************************************************************/

	input [0:0 ] clk,		/* clock */
	input [0:0 ] rst,		/* reset */
	input [1:0 ] mode,		/* mode from SW17 and SW16 */ 
	// 2bit
	input [3:0 ] key,		/* value from KEYs */	
	// 4bit
					/* Remember that the 2 bit mode and
					 * 4 bit key value are used to
					 * uniquely identify one of 16
					 * operations. Also keep in mind that
					 * they keys are onehot (i.e. only one
					 * key is pressed at a time -- if
					 * more than one key is pressed at a
					 * time, the behavior is undefined
					 * (i.e. you may choose your own
					 * behavior). */

	input [15:0] val,		/* 16 bit value from SW15...SW0 */

/**** outputs ****************************************************************/

	output [15:0] top,		/* 16 bit value at the top of the
					 * stack, to be shown on HEX3...HEX0 */
	// hex3 = [15:12]
	// hex2 = [11:8]
	// hex1 = [7:4]
	// hex0 = [3:0]

	output [15:0] next,		/* 16 bit value second-to-top in the
					 * stack, to be shown on HEX7...HEX4 */

	// hex4 = [3:0];
	output [7:0] counter		/* counter value to show on LEDG */	
);
// operations are decided by key and sw
typedef enum logic[3:0] {idle, push1, pop1, pop2, arithOp, shift, boolean, swap1,swap2, justpop, comparison} state_type;
state_type current_state, next_state;

typedef enum logic[4:0] {c1 , c2 , c3 ,c4 ,c5 , c6 ,c7 ,c8 ,c9 ,c10 , c11 , c12, c13 , c14, c15, c16} command;

logic [0:0] push, pop; // boolean logic
logic [3:0] op;
logic [31:0] a, b, hi, lo, al, bl;
logic [31:0] val_new;


// assign val = { {32-16{1'h0}}, val}; // padded 16 bits making it 32

logic [7:0] shamt; // up to 5 bits work

//logic [31:0] data_in = {16'h0, val}; 
// boolean logic to see changes in key 
// logic [5:0] stack_ptr = 6'b1; 
// assign counter = {2'b0, stack_ptr-1};
logic [3:0] key_prev;
/*
initial begin
	//a     = 32'h0;
	//b     = 32'h0;
	//op    = 4'h0;
	//shamt = 8'h0;
	//hi    = 32'h0;
	//lo    = 32'h0;
	//al = 32'h0;
	//bl = 32'h0;
	//val = 16'h0;
	push = 1'b0;
	
	// stack_ptr = 6'b1; // starting from 1 

	//stack_ptr = 6'b0; // starts from 0
end
*/




// INSTANTIATE STACK MODULE
logic [31:0] top_i, next_i; 
assign top = top_i[15:0];
assign next = next_i[15:0];

stack calstack (.clk(clk),
.rst(rst),
.pop(pop),
.push(push),
.data_in(val_new),
.stack_top(top_i),
.stack_next(next_i),
.numcnt(counter[5:0]),
.full(),
.empty());

// cnt 

/*
regfile stack (.clk(clk),
 .rst(rst),
 .we(push),
 .readaddr1(stack_ptr),
 .readaddr2(stack_ptr-1),
 .writeaddr(stack_ptr+1),
 .writedata(data_in),
 .readdata1(top),
 .readdata2(next));
*/

alu aluop (.a(al),
 .b(bl),
 .op(op),
 .shamt(shamt[4:0]),
 .hi(hi),
 .lo(lo),
 .zero());
/*
typedef enum logic [1:0] {key3, key2, key1, key0} key_type;
key_type current_key, next_key; 
*/
/*
always_ff @(posedge clk, posedge rst) begin 
	if (rst) command <= 0;
	else if (key == 
end
*/





/*
initial begin // not sure if needed 
	clk = 1'b0;
	rst = 1'b0;
	mode = 2'b0;
	key = 4'b0;
	val = 16'b0;
	top = 16'b0;
	next = 16'b0;
	counter = 8'b0; 
	a = 32'b0;
	b = 32'b0;
	hi = 32'b0;
	lo = 32'b0;
	op = 4'b0;
	push = 2'b0;
	pop = 2'b0;
	shamt = 8'b0;
end */

/* 
	key 0111 = key 3 pressed 
	key 1011 = key 2 pressed 
	key 1101 = key 1 pressed 
	key 1110 = key 0 pressed 
	switch = mode 
	00 key 3 push current
	00 key 2 pop topmost
	00 key 1 pop2 + 
	00 key 0 pop2 -
	01 key 3 pop2 * (unsigned) ;code 7
	01 key 2 pop2 b << shift by a ;code 8
	01 key 1 pop2 b >> shift by a ;code 9
	01 key 0 pop2 if a < b : 1 else 0 ;code A 
	10 key 3 pop2 AND operation; code 0
	10 key 2 pop2 OR operation; code 1
	10 key 1 pop2 NOR operation; code 2
	10 key 0 pop2 XOR operation; code 3
	11 key 3 pop a, b then put b a code ??? 
	11 key 2 X make reset for one? 
	11 key 1 X 
	11 key 0 X 
*/
/*
initial begin
	//push = 1'b0;
	mode = 2'b0;
	// key == 4'b0000;
end
*/
always_ff @(posedge clk, posedge rst) begin
	if (rst) begin
		current_state <= idle; 
		key_prev = 0;
	end else begin
		current_state <= next_state;
		key_prev = key;
	end
end

// && key_prev != key
always_comb begin
	case (current_state)
		idle: begin

			a = 32'b0;
			b = 32'b0;
			al = 32'b0;
			bl = 32'b0;
			shamt = 8'b0;
			push = 1'b0;
			pop = 1'b0;
			op = 4'h0;
			//val_new = 32'h0;
		end 
		push1: begin
			push = 1'b1;
/*
			pop = 1'b0;
			shamt = 8'b0;
			a = 32'b0;
			b = 32'b0;
			al = 32'b0;
			bl = 32'b0;
*/
			val_new = val;
		end 
		pop2: begin
			a = top;
			pop = 1'b1;

		end 
		pop1: begin
			b = top;
			pop = 1'b1;
		end
		justpop: begin
			pop = 1'b0; // dont do anything
		end
		arithOp: begin
			pop = 1'b0; // we don't wanna pop
			al = a;
			bl = b;
			if (mode == 2'b00 && key == 4'b1101 ) begin// opcode 4 addition 
				op = 4'h4;
				push = 1'b1;
				val_new = lo;
			end else if (mode == 2'b00 && key == 4'b1110 ) begin
				op = 4'h5; // opcode 5 - 
				push = 1'b1;
				val_new = lo;
			end else if (mode == 2'b01 && key == 4'b0111) begin
				op = 4'h7; // opcode 7 * might need hi
				push = 1'b1;
				val_new = lo;
			end 
		end
		shift: begin
			//a = top;
			//pop = 1'b1;
			//b = top;
			//pop = 1'b1;
			pop = 1'b0; // we don't wanna pop
			shamt = a;
			//a = 0;
				if (mode == 2'b01 && key == 4'b1011 ) begin // b << a 
					al = 32'b0; // 0 
					bl = b;
					op = 4'h8;
					push = 1'b1;
					val_new = lo;
				end else if (mode == 2'b01 && key == 4'b1101 ) begin // b >> a
					bl = b;
					al = 32'b0;
					op = 4'h9; //opcode right shift
					push = 1'b1;
					val_new = lo;
				end
		end
		comparison: begin
			//a = top;
			//pop = 1'b1;
			//b = top;
			//pop = 1'b1;
			pop = 1'b0; // we don't wanna pop
			bl = b;
			al = a;
			op = 4'hC;
			push = 1'b1;
			val_new = lo; 
		end 
		boolean: begin
			pop = 1'b0; // we don't wanna pop
			if (mode == 2'b10 && key == 4'b0111 ) begin // AND 
				//a = top;
				//pop = 1'b1;
				//b = top;
				//pop = 1'b1;
				al = a;
				bl = b;
				op = 4'h0;
				push = 1'b1;
				val_new = lo; 
			end else if (mode == 2'b10 && key == 4'b1011 ) begin // or
				//a = top;
				//pop = 1'b1;
				//b = top;
				//pop = 1'b1;
				al = a;
				bl = b;
				op = 4'h1;
				push = 1'b1;
				val_new = lo; 
			end else if (mode == 2'b10 && key == 4'b1101) begin // NOR
				//a = top;
				//pop = 1'b1;
				//b = top;
				//pop = 1'b1;
				al = a;
				bl = b;
				op = 4'h2;
				push = 1'b1;
				val_new = lo;
			end else if (mode == 2'b10 && key == 4'b1110 ) begin // XOR 
				//a = top;
				//pop = 1'b1;
				//b = top;
				//pop = 1'b1;
				al = a;
				bl = b;
				op = 4'h3;
				push = 1'b1;
				val_new = lo; 
			end
		end
		swap1: begin
			pop = 1'b0; // we don't wanna pop
			//a = top;
			//pop = 1'b1;
			//b = top;
			//pop = 1'b1;
			val_new = a;
			push = 1'b1;
			//val_new = a;
			//push = 1'b1;
			//val_new = b;
		end
		swap2: begin
			val_new = b;
			push = 1'b1;
		end
		default: begin
			a = 32'b0;
			b = 32'b0;
			al = 32'b0;
			bl = 32'b0;
			shamt = 8'b0;
			push = 1'b0;
			pop = 1'b0;
		end
	endcase

end 
// state machine
always_comb begin
	case (current_state)
		idle: begin
			if (mode == 2'b00 && key == 4'b0111 ) next_state = push1; 
			else if (mode == 2'b00 && key == 4'b1011) next_state = pop1;
			else if (mode == 2'b00 && key == 4'b1101 || mode == 2'b00 && key == 4'b1110 || mode == 2'b01 && key == 4'b0111 
				|| mode == 2'b01 && key == 4'b1011  || mode == 2'b01 && key == 4'b1101 || mode == 2'b01 && key == 4'b1110 ||
				mode == 2'b10 && key == 4'b0111 || mode == 2'b10 && key == 4'b1011 || 
				     mode == 2'b10 && key == 4'b1101 || mode == 2'b10 && key == 4'b1110 || mode == 2'b11 && key == 4'b0111)
				next_state = pop2;
			else next_state = idle;
		end

		pop2: next_state = pop1;

		pop1: begin //if (mode == 2'b00 && key == 4'b1011 && key_prev != key) next_state = idle; // just pop 1
			if (mode == 2'b00 && key == 4'b1101 || mode == 2'b00 && key == 4'b1110 ||
				     mode == 2'b01 && key == 4'b0111 ) next_state = arithOp;
			else if(mode == 2'b01 && key == 4'b1011  || mode == 2'b01 && key == 4'b1101 ) 
				     next_state = shift;
			else if(mode == 2'b01 && key == 4'b1110 ) next_state = comparison;
			else if(mode == 2'b10 && key == 4'b0111 || mode == 2'b10 && key == 4'b1011 || 
				     mode == 2'b10 && key == 4'b1101 || mode == 2'b10 && key == 4'b1110 ) 	
				     next_state = boolean;
			else if(mode == 2'b11 && key == 4'b0111 ) next_state = swap1;
			else next_state = justpop; // if the non of the statement above is true meaning just pop top
		end
		swap1: next_state = swap2;
		swap2: next_state = idle;
		push1: next_state = idle;
		arithOp: next_state = idle;
		shift: next_state = idle;
		comparison: next_state = idle;
		justpop: next_state = idle;
		default: next_state = idle;
	endcase
		
end 
// fix this



endmodule
