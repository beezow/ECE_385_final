module center(input col[480],
					output logic[9:0] center);
					
										
//assign center = 240;	
logic [17:0] w_sum = 0;
logic [17:0] sum = 0;
logic [9:0] next_center = 0;
always_comb begin
	sum = 0;
	w_sum = 0;
	for (int i = 0; i < 480; i++) begin
		if (col[i]) begin
			w_sum = w_sum + i;
			sum = sum + 1;
		end
	end
	next_center = (w_sum/sum);
end

always_ff begin
	if (sum != 10'h0000)
		center <= next_center;
end
					
endmodule