module ram307200x1 (
	output logic out,
	input in,
	input [17:0] write_addr, read_addr,
	input we, clk, rst
);
logic mem [307200];

always_ff @ (posedge clk) begin
//	if (rst)
//		mem = '{307200'{0}};
	if (we)
		mem[write_addr] <= in;
		
	out <= mem[read_addr];
end

endmodule