module reg_800 (input CLK, RESET, Shift_In, Shift_En,
					 output Shift_Out);
					 
		logic [799:0]Data = ~0;
		assign Shift_Out = Data[799];
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