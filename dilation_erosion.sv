module dilation_erosion(
	input            		CLK,
	input            		RST_N,
	input logic  [1:0]   iDVAL,
	input logic  [9:0] 	iDATA,
	output 	        		oDVAL,
	output logic [9:0] 	oDATA
	);
	
 wire 	[9:0] Line0;
 wire 	[9:0] Line1;
 wire 	[9:0] Line2;
 logic   [9:0] P1, P2, P3, P4, P5, P6, P7, P8, P9;
 
 /*
 LineBuffer_dilation b0(
   .clken(iDVAL),
   .clock(iCLK),
   .shiftin(iDATA),
   .taps0x(Line0),
   .taps1x(Line1),
   .taps2x(Line2)
);
*/

always@(posedge iCLK, negedge iRST_N) begin
     if(!iRST_N) begin
         P1 <=    0;
         P2 <=    0;
         P3 <=    0;
         P4 <=    0;
         P5 <=    0;
         P6 <=    0;
         P7 <=    0;
         P8 <=    0;
         P9 <=    0;
         oDVAL <= 0;
     end
     else begin
       oDVAL <= iDVAL;
         P9    <= Line0;
         P8    <= P9;
         P7    <= P8;
         P6    <= Line1;
         P5    <= P6;
         P4    <= P5;
         P3    <= Line2;
         P2    <= P3;
         P1    <= P2;
     
	  if (iDVAL==3)
       oDATA <= 1;
		 
     if (iDVAL==2)
       oDATA <= P9 | P8 | P7 | P6 | P5 | P4 | P3 | P2 | P1;
		 
	  if (iDVAL==1)
       oDATA <= P9 & P8 & P7 & P6 & P5 & P4 & P3 & P2 & P1; 
		 
     else
	    oDATA <= 0; 
     end
	end
	
	
endmodule	
