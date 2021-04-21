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
												  
												  
ball 	  baller(.Reset (Reset_h), .frame_clk(VGA_VS),
					.keycode (keycode),
               .BallX(ballxsig), .BallY(ballysig),
					.BallS(ballsizesig));

//color_mapper colormaple( .BallX(ballxsig), .BallY(ballysig),
//								 .DrawX(drawxsig), .DrawY(drawysig), 
//								 .Ball_size(ballsizesig),
//								 .Red, .Green, .Blue);	


logic latest_bit, bit_on; 
logic we;
logic [17:0] write_addr, read_addr;

assign read_addr = drawysig * 640 + drawxsig;

ram307200x1 ram(.out(bit_on), .in(1'b1), .clk(MAX10_CLK1_50), .write_addr( { 8'h00, SW} ) , .read_addr(read_addr), .rst(Reset_h), .we(KEY[1]));

always_comb begin
	if (blank) begin
		unique case (bit_on)
			1'b0: begin
				Red = 8'hff;
				Green = 8'h55;
				Blue = 8'h00;
			end
			1'b1: begin
				Red = 8'h00;
				Green = 8'hff;
				Blue = 8'h00;
			end
		endcase
	end
	else begin
		Red = 8'h00;
		Green = 8'h00;
		Blue = 8'h00;
	end
end


endmodule