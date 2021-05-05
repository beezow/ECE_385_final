//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  paddle ( input Reset, frame_clk, vga_clk, bit_on,
					input [9:0] drawxsig, drawysig,
               output [9:0]  paddleX, paddleY, paddleS );
    
    logic [9:0] Paddle_X_Pos, Paddle_Y_Pos, Paddle_Y_Motion, Paddle_Size;
	 
    parameter [9:0] Paddle_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Paddle_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Paddle_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Paddle_Y_Step=1;      // Step size on the Y axis

    assign Paddle_Size = 80;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   
	logic bottom_pix;
	logic top_pix;
	
	always_ff @ (posedge vga_clk or posedge Reset) begin
		if (Reset) begin
			bottom_pix <= 1'b1;
			top_pix <= 1'b1;
		end else begin		
			if (drawysig == Paddle_Y_Pos + Paddle_Size)
				bottom_pix <= bit_on;
				
			if (drawysig == Paddle_Y_Pos - Paddle_Size)
				top_pix <= bit_on;
		end
	end
	
	always_ff @ (posedge frame_clk or posedge Reset) begin
		if (Reset)  // Asynchronous Reset
        begin 
            Paddle_Y_Pos <= Paddle_Y_Center; //Ball_Y_Step;
				Paddle_X_Pos <= 9'd20;
				Paddle_Y_Motion <= 10'd0; //Ball_Y_Step;
				Paddle_Y_Motion <= 1;
			//	Ball_Y_Motion <= 0;
        end
		else begin
			if ( (Paddle_Y_Pos + Paddle_Size) >= Paddle_Y_Max)  // Paddle is at the bottom edge, BOUNCE!
				Paddle_Y_Motion <= (~ (Paddle_Y_Step) + 1'b1);  // 2's complement.					  
			else if ( (Paddle_Y_Pos - Paddle_Size) <= Paddle_Y_Min)  // Paddle is at the top edge, BOUNCE!
				Paddle_Y_Motion <= Paddle_Y_Step;		  
			else 
				Paddle_Y_Motion <= Paddle_Y_Motion;  // Paddle is somewhere in the middle, don't bounce, just keep moving
					  
				 
					
				 
			Paddle_Y_Pos <= (Paddle_Y_Pos + Paddle_Y_Motion);  // Update Paddle position
		//	Paddle_X_Pos <= (Paddle_X_Pos + Paddle_X_Motion);
			
		end
	end

    assign paddleX = Paddle_X_Pos;
   
    assign paddleY = Paddle_Y_Pos;
   
    assign paddleS = Paddle_Size;
    

endmodule
