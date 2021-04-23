module ram307200x1 (
	output logic out,
	input in,
	input [18:0] write_addr, read_addr,
	input we, 
//	output logic out2,
//	input in2,
//	input [18:0] write_addr2, read_addr2,
//	input we2, 
	input clk, rst
	
);

logic mem [307200];

always_ff @ (posedge clk) begin
//	if (rst)
//		mem = '{307200'{0}};
	if (we)
		mem[write_addr] <= in;
		
	out <= mem[read_addr];
//	
//	if (we2)
//		mem[write_addr2] <= in2;
//		
//	out2 <= mem[read_addr2];
end

endmodule