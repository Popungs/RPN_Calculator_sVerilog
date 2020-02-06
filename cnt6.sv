module cnt6 (input clk, rst, en_up, en_down,
	    output logic [5:0] cnt);
always_ff @(posedge clk) begin
	if (rst) cnt <= 0;
	else if (en_up) cnt <= cnt+6'b1;
	else if (en_down) cnt <= cnt-6'b1;
end
endmodule

