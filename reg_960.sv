module reg_960 (input CLK, RESET, Shift_In, Shift_En,
					 output Shift_Out);
					 
		logic [959:0]Data = ~0;
		assign Shift_Out = Data[959];
		always_ff @ (posedge CLK)
		begin
			if(RESET)
				Data <=0;
			else if (Shift_En)
			begin 
				Data <= Data<<1;
				Data[0] <= Shift_In;
			end
		end
		
endmodule 					