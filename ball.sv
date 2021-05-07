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
module  ball ( input Reset, frame_clk,
              input [9:0] PaddleX, PaddleY, PaddleS,
              input [9:0] Paddle2X, Paddle2Y, Paddle2S,
              output [9:0]  BallX, BallY, BallS,
              output [3:0] Score1, Score2);

  logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Size;

  parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
  parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
  parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
  parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
  parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
  parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
  parameter [9:0] Ball_X_Step_start=2;      // Step size on the X axis
  parameter [9:0] Ball_Y_Step_start=2;      // Step size on the Y axis

  logic [9:0] Ball_X_Step=Ball_X_Step_start;      // Step size on the X axis
  logic [9:0] Ball_Y_Step=Ball_Y_Step_start;      // Step size on the Y axis

  assign Ball_Size = 4;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"

  int DistX, DistY;
  assign DistX = PaddleX - Ball_X_Pos;
  assign DistY = PaddleY - Ball_Y_Pos;


  logic in_paddle;
  assign in_paddle = ((DistX*DistX/8) + ( DistY*DistY/(PaddleS*PaddleS) ) <= 1);

  int launch_angle = 0;
  assign launch_angle = ((DistY)/PaddleS);
  logic [9:0] launch_bytes;
  always_comb begin
    if (launch_angle > 0)
		launch_bytes = launch_angle;
	 else 
	   launch_bytes = (-launch_angle);
  end

  assign Score1 = Ball_Y_Motion;
  assign Score2 = launch_bytes;

  int DistX2, DistY2;
  assign DistX2 = Paddle2X - Ball_X_Pos;
  assign DistY2 = Paddle2Y - Ball_Y_Pos;

  logic in_paddle2;
  assign in_paddle2 = ((DistX2*DistX2/8) + ( DistY2*DistY2/(Paddle2S*Paddle2S) ) <= 1);


  always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
      if (Reset)  // Asynchronous Reset
        begin 
          // Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
          //	Ball_X_Motion <= 10'd0; //Ball_X_Step;
          Ball_Y_Pos <= Ball_Y_Center;
          Ball_X_Pos <= Ball_X_Center;
			 Ball_X_Step <= Ball_X_Step_start;
			 Ball_Y_Step <= Ball_Y_Step_start;

          Ball_X_Motion <= -Ball_X_Step;
          Ball_Y_Motion <= -Ball_Y_Step;
//          Score1 <=0;
//          Score2 <=0;

        end

      else 
        begin 
          if (1'b1 | Score1<=9 && Score2<=9) begin 
            if ( (Ball_Y_Pos + Ball_Size-1) >= Ball_Y_Max - Ball_Y_Step)  // Ball is at the bottom edge, BOUNCE!
              Ball_Y_Motion <= (~ (Ball_Y_Step) + 1'b1);  // 2's complement.

            else if ( (Ball_Y_Pos - Ball_Size+1) <= Ball_Y_Min + Ball_Y_Step )  // Ball is at the top edge, BOUNCE!
              Ball_Y_Motion <= Ball_Y_Step;

            else  if (in_paddle2) begin
              Ball_X_Motion <= (~ (Ball_X_Step) + 1'b1);  // 2's complement.
            end
            else if (in_paddle) begin
					Ball_Y_Step <= launch_bytes;				
					//Ball_X_Step <= Ball_X_Step;
					if (launch_angle > 0) begin
						Ball_Y_Motion <= (launch_bytes);
					end else begin
						//Ball_Y_Motion <= (~(launch_bytes) + 1'b1);
						Ball_Y_Motion <= (launch_bytes);
					end
					Ball_X_Motion <= (Ball_X_Step);
				   
					
            end
            else 
              Ball_Y_Motion <= Ball_Y_Motion;  // Ball is somewhere in the middle, don't bounce, just keep moving


            if ( (Ball_X_Pos + Ball_Size) >= Ball_X_Max - Ball_X_Step)  // Ball is at the Right edge, BOUNCE!
              begin  
                //  Ball_X_Motion <= (~ (Ball_X_Step) + 1'b1);  // 2's complement.
                Ball_Y_Pos <= Ball_Y_Center;
                Ball_X_Pos <= Ball_X_Center;
					 Ball_X_Step <= Ball_X_Step_start;
					 Ball_Y_Step <= Ball_Y_Step_start;
   				 Ball_X_Motion <= -(Ball_X_Step_start);
					 Ball_Y_Motion <= (Ball_Y_Step_start);

                //Score1 <= (Score1+1'b1);
              end	  
            else if ( (Ball_X_Pos - Ball_Size) <= Ball_X_Min + Ball_X_Step)
              begin// Ball is at the Left edge, BOUNCE!
                //Ball_X_Motion <= (Ball_X_Step);
                Ball_Y_Pos <= Ball_Y_Center;
                Ball_X_Pos <= Ball_X_Center;
					 Ball_X_Step <= Ball_X_Step_start;
					 Ball_Y_Step <= Ball_Y_Step_start;
   				 Ball_X_Motion <= -(Ball_X_Step_start);
					 Ball_Y_Motion <= (Ball_Y_Step_start);
                //Score2 <= (Score2+1'b1);
              end	  
            else begin
              Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
              Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
				  
              //						Score1 <= Score1;
              //						Score2 <= Score2;
            end
          end 
          else begin
            Ball_Y_Pos <= Ball_Y_Center;
            Ball_X_Pos <= Ball_X_Center;
				Ball_X_Step <= Ball_X_Step_start;
				Ball_Y_Step <= Ball_Y_Step_start;
   			Ball_X_Motion <= -(Ball_X_Step_start);
				Ball_Y_Motion <= (Ball_Y_Step_start);
//            Score1 <= 0;
//            Score2 <= 0;
          end	 
        end  
    end

  assign BallX = Ball_X_Pos;

  assign BallY = Ball_Y_Pos;

  assign BallS = Ball_Size;


endmodule