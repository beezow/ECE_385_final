module final_proj(
	      ///////// Clocks /////////
      input     MAX10_CLK1_50,

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N

);

wire [7:0]		    data_cam;
wire 				 VSYNC_cam;
wire 				 HREF_cam;
wire 				 PCLK_cam;
wire 				 sioc;
wire  			 siod;	
logic 				 MCLK_cam;
logic scam;

assign data_cam[7:0] = ARDUINO_IO[7:0];
assign LEDR[7:0] = data_cam[7:0];
assign LEDR[9:8] = 2'b10;
assign VSYNC_cam = ARDUINO_IO[12];
assign HREF_cam = ARDUINO_IO[13];
assign PCLK_cam = ARDUINO_IO[10];
assign sioc = ARDUINO_IO[15];
assign siod = ARDUINO_IO[14];

always_ff @(posedge MAX10_CLK1_50) begin
	MCLK_cam = ~MCLK_cam;
end
assign ARDUINO_IO[11] = MCLK_cam;


logic Reset_h, vssig, blank, sync, VGA_Clk;

logic [9:0] drawxsig, drawysig, ballxsig, ballysig, ballsizesig;
logic [7:0] Red, Blue, Green;
logic [7:0] keycode;

//Assign one button to reset
assign {Reset_h}=~ (KEY[0]);

//Our A/D converter is only 12 bit
assign VGA_R = Red[7:4];
assign VGA_B = Blue[7:4];
assign VGA_G = Green[7:4];
assign VGA_Clk = MAX10_CLK1_50;
logic frame_clk; 
	
	
//instantiate a vga_controller, ball, and color_mapper here with the ports.
vga_controller vga0(.Clk (VGA_Clk),       // 50 MHz clock
                    .Reset (Reset_h),     // reset signal
                    .hs(VGA_HS),        // Horizontal sync pulse.  Active low
						  .vs(VGA_VS),        // Vertical sync pulse.  Active low
						  .pixel_clk(frame_clk), // 25 MHz pixel clock output
						  .blank,     // Blanking interval indicator.  Active low.
						  // sync,      // Composite Sync signal.  Active low.  We don't use it in this lab,
												             //   but the video DAC on the DE2 board requires an input for it.
						  .DrawX(drawxsig), 
						  .DrawY(drawysig));   // vertical and horizontal coordinate
												  
							
							

wire cam_pixel, cam_blank;
wire pixel_valid;
logic[18:0] cam_count;

//cam_wrp cam_wrp(.data_cam, .VSYNC_cam, .HREF_cam, .PCLK_cam, 
	//			.cam_count, .pixel(cam_pixel), .blank(cam_blank), .rst_n(KEY[0]), .override(SW[0])) ;
				
logic[15:0] pixel_data;
camera_read cam_read(.data_cam, .VSYNC_cam, .HREF_cam, .PCLK_cam, 
				.cam_count, .pixel_data, .pixel_valid) ;
				
assign cam_pixel = pixel_data[7];


//
//logic idval;
//assign idval = 1;
//
//module dilation_erosion(
//	.CLK(PCLK_cam),. RST_N(Reset_h), .iDVAL(idval), iDATA, .oDVAL,
//	output logic [9:0] 	oDATA
//	);

logic bit_on; 
logic we;
logic [18:0] write_addr, read_addr;

assign read_addr = drawysig * 640 + (640-drawxsig);

//logic[10:0] hand_x, hand_y;
//HexDriver hex1(.In0(hand_x[3:0]), .Out0(HEX5));
//HexDriver hex2(.In0(hand_x[7:4]), .Out0(HEX4));

//centroid cent(.image(par_out), .x(hand_x), .y(hand_y));


//ram_2port ram(.address_a_write(cam_count), .adress_a_read(read_addr), .data_a(cam_pixel), .wren_a(pixel_valid), .q_a(bit_on),
//					.address_b()
//					, .clock(MAX10_CLK1_50);

//ram307200x1 ram(.out(bit_on), .in(1'b1), .clk(MAX10_CLK1_50), .write_addr( { 9'h00, SW} ) , .read_addr(read_addr), .rst(Reset_h), .we(KEY[1]));
ram307200x1 ram(.out(bit_on), .in(cam_pixel), .clk(MAX10_CLK1_50), .write_addr( cam_count ) , .read_addr(read_addr), .rst(Reset_h), .we(pixel_valid),
				    //.out2(ball_pixel), .read_addr2(ball_read_addr)
					 );
					
logic paddle_col [480];
logic [9:0] paddlexsig, paddleysig, paddlesizesig;
logic paddle2_col [480];
logic [9:0] paddle2xsig, paddle2ysig, paddle2sizesig;

ram480x1 ram_small(.out(paddle_col), .in(bit_on), .clk(MAX10_CLK1_50), .write_addr( drawysig ) , .rst(Reset_h), .we(drawxsig == paddlexsig),
				    //.out2(ball_pixel), .read_addr2(ball_read_addr)
					 );
					

ram480x1 ram_smal2l(.out(paddle2_col), .in(bit_on), .clk(MAX10_CLK1_50), .write_addr( drawysig ) , .rst(Reset_h), .we(drawxsig == paddle2xsig),
				    //.out2(ball_pixel), .read_addr2(ball_read_addr)
					 );					
//ram307200x1 ram(.out(bit_on), .in(cam_pixel), .clk(MAX10_CLK1_50), .write_addr( cam_count ) , .readt_addr(read_addr), .rst(Reset_h), .we(!cam_blank));

logic [3:0] Score1, Score2; 

ball 	  baller(.Reset (Reset_h), .frame_clk(VGA_VS),
               .BallX(ballxsig), .BallY(ballysig),
					.BallS(ballsizesig),
					.PaddleX(paddlexsig), .PaddleY(paddleysig), .PaddleS(paddlesizesig),
					.Paddle2X(paddle2xsig), .Paddle2Y(paddle2ysig), .Paddle2S(paddle2sizesig),
					.Score1, .Score2);			

assign paddlexsig = 30;
assign paddlesizesig = 80;
center col_cent(.col(paddle_col), .center(paddleysig))	;							 

assign paddle2xsig = 610;
assign paddle2sizesig = 80;
center col_cent2(.col(paddle2_col), .center(paddle2ysig))	;							 

HexDriver hex1(.In0(paddle2ysig[3:0]), .Out0(HEX3));
HexDriver hex2(.In0(paddle2ysig[7:4]), .Out0(HEX4));
HexDriver hex3(.In0(paddle2ysig[9:8]), .Out0(HEX5));		
					
logic ball_on;
//
//
color_mapper colormaple( .BallX(ballxsig), .BallY(ballysig),
								 .DrawX(drawxsig), .DrawY(drawysig), 
								 .Ball_size(ballsizesig),
								 .ball_on);
//							//	 .Red, .Green, .Blue);	

logic shape_on1, shape_on2, shape_on3;
logic [10:0] shape_x1 = 308;
logic [10:0] shape_y1 = 10;
logic [10:0] shape_x2 = 320;
logic [10:0] shape_y2 = 10;	
logic [10:0] shape_x3 = 332;
logic [10:0] shape_y3 = 10;		
logic [10:0] shape_size_x = 8;
logic [10:0] shape_size_y = 16;

logic [10:0] sprite_addr1, sprite_addr2, sprite_addr3;
logic [7:0] sprite_data1, sprite_data2, sprite_data3;
font_rom score1(.addr(sprite_addr1), .data(sprite_data1));
font_rom score2(.addr(sprite_addr2), .data(sprite_data2));
font_rom score3(.addr(sprite_addr3), .data(sprite_data3));

always_comb 
begin
	if(drawxsig>= shape_x1 && drawxsig<shape_x1+shape_size_x &&
	drawysig>= shape_y1 && drawysig<shape_y1+shape_size_y)
	begin
		shape_on1 = 1'b1;
		sprite_addr1 = (drawysig-shape_y1+16*'h30+16*Score1);
	end
	else 
	begin
		shape_on1 = 1'b0;
		sprite_addr1 = 10'b0;
	end	
end

logic paddle_on;			 
paddle_mapper paddlemap( .BallX(paddlexsig), .BallY(paddleysig),
								 .DrawX(drawxsig), .DrawY(drawysig), 
								 .Ball_size(paddlesizesig),
								 .ball_on(paddle_on));
							//	 .Red, .Green, .Blue);	
logic paddle2_on;			 
paddle_mapper paddlemap2( .BallX(paddle2xsig), .BallY(paddle2ysig),
								 .DrawX(drawxsig), .DrawY(drawysig), 
								 .Ball_size(paddle2sizesig),
								 .ball_on(paddle2_on));
							//	 .Red, .Green, .Blue);	
							

always_comb 
begin
	if(drawxsig>= shape_x2 && drawxsig<shape_x2+shape_size_x &&
	drawysig>= shape_y2 && drawysig<shape_y2+shape_size_y)
	begin
		shape_on2 = 1'b1;
		sprite_addr2 = (drawysig-shape_y2+16*'h3a);
	end
	else 
	begin
		shape_on2= 1'b0;
		sprite_addr2 = 10'b0;
	end	
end

always_comb 
begin
	if(drawxsig>= shape_x3 && drawxsig<shape_x3+shape_size_x &&
	drawysig>= shape_y3 && drawysig<shape_y3+shape_size_y)
	begin
		shape_on3 = 1'b1;
		sprite_addr3 = (drawysig-shape_y3+16*'h30+16*Score2);
	end
	else 
	begin
		shape_on3= 1'b0;
		sprite_addr3 = 10'b0;
	end	
end		

logic eros_on, eros_on2, dilat_on;
erosion erosion1(.CLK(MCLK_cam), .RST(Reset_h), .Value(1'b1), .Data_in(bit_on), .Data_out(eros_on));												
erosion erosion2(.CLK(MCLK_cam), .RST(Reset_h), .Value(1'b1), .Data_in(eros_on), .Data_out(eros_on2));												
dilation dilation1(.CLK(MCLK_cam), .RST(Reset_h), .Value(1'b1), .Data_in(eros_on2), .Data_out(dilat_on));

always_comb begin
	if (blank) begin
		if (ball_on) begin
			Red = 8'h44;
			Green = 8'h00;
			Blue = 8'h00;
		end
		else if (paddle_on | paddle2_on) begin
			Red = 8'h00;
			Green = 8'h00;
			Blue = 8'h44;
		end
		else begin
			unique case (dilat_on)
				1'b1: begin
					Red = 8'hDD;
					Green = 8'hDD;
					Blue = 8'hDD;
				end
				1'b0: begin
					Red = 8'h1D;
					Green = 8'h1D;
					Blue = 8'h1D;
				end
			endcase
			if ((shape_on1 == 1'b1) && sprite_data1[shape_x1 - drawxsig] == 1'b1)
			begin
				Red = 8'h00;
				Green = 8'hff;
				Blue = 8'h00;
			end
			if ((shape_on2 == 1'b1) && sprite_data2[drawxsig - shape_x2] == 1'b1)
			begin
				Red = 8'h00;
				Green = 8'hff;
				Blue = 8'h00;
			end
			if ((shape_on3 == 1'b1) && sprite_data3[shape_x3 - drawxsig] == 1'b1)
			begin
				Red = 8'h00;
				Green = 8'hff;
				Blue = 8'h00;
			end
//			else begin
//				Red = 8'h4f - drawxsig[9:3];
//				Green = 8'h00;
//				Blue = 8'h44;
//			end
		end	
	end
	else begin
		Red = 8'h00;
		Green = 8'h00;
		Blue = 8'h00;
	end
end


endmodule