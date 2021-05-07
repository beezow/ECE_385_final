module dilation(
	input            		CLK,
	input            		RST,
	input logic  		   Value,
	input logic   			Data_in,
	output logic 		 	Data_out
	);
	
 wire 	Line1_in, Line2_in, Line1_out, Line2_out, Line3_in, Line3_out;
 logic   P0 =1'b1;
 logic   P1 =1'b1;
 logic   P2 =1'b1;
 logic   P3 =1'b1;
 logic   P4 =1'b1;
 logic   P5 =1'b1;
 logic   P6 =1'b1;
 logic   P7 =1'b1;
 logic   P8 =1'b1;
 logic 	sum1, sum2, sum3;
 wire outputs1, outputs2;
 
reg_640 line1(.CLK, .RESET(RST), .Shift_In(Line1_in), 
				.Shift_En(Value), .Shift_Out(Line1_out));
reg_800 line2(.CLK, .RESET(RST), .Shift_In(Line2_in), 
				.Shift_En(Value), .Shift_Out(Line2_out));	
reg_800 line3(.CLK, .RESET(RST), .Shift_In(Line3_in), 
				.Shift_En(Value), .Shift_Out(Line3_out));	
		
reg_320 out1(.CLK, .RESET(RST), .Shift_In(outputs1), 
				.Shift_En(Value), .Shift_Out(outputs2));	
reg_640 out2(.CLK, .RESET(RST), .Shift_In(outputs2), 
				.Shift_En(Value), .Shift_Out(Data_out));					

always_comb 

outputs1 = sum1|sum2|sum3;			

always_ff@(posedge CLK) begin
     begin
			P8 <=    	P7;
			P7 <=    	P6;
			P6 <=	Line3_out;
			P5 <=    	P4;
			P4 <=    	P3;
			P3 <=Line2_out;
			P2 <=    	P1;
			P1 <=    	P0;
			P0 <= Line1_out;
			Line3_in <= Line2_out;
			Line2_in <= Line1_out;
			Line1_in<=Data_in;
			sum1 <= P0 | P2 | P1;
			sum2 <= P3 | P4 | P5;
			sum3 <= P6 | P7 | P8;
     end
	end
	
	
endmodule	
