module cam_wrp
(
	input rst_n,
	input [7:0]		data_cam,
	input 					VSYNC_cam,
	input 					HREF_cam,
	input 					PCLK_cam,	
	output logic[18:0] 			cam_count,
	output    			pixel,
	output  				blank,
	input override
);
	
	//only need evry other byte for greyscale
	logic eo_toggle = 0;
	
	assign pixel = data_cam[7];
	assign blank = !(HREF_cam & eo_toggle);
	
	always_ff @( posedge PCLK_cam) begin
		if (!rst_n) begin
			cam_count <= 19'b0;
			eo_toggle <= 1'b0;
		end else 
			if (HREF_cam) begin
				eo_toggle <= ~eo_toggle;
				if (~eo_toggle)
					cam_count <= cam_count +1;
			end else begin
				eo_toggle <= 0;
			end
			if (VSYNC_cam)
				cam_count <= 19'b0;
	end

				
endmodule


module camera_read(
	input wire PCLK_cam,
	input wire VSYNC_cam,
	input wire HREF_cam,
	input wire [7:0] data_cam,
	output reg [15:0] pixel_data =0,
	output reg pixel_valid = 0,
	output reg frame_done = 0,
	output logic[18:0] 			cam_count
    );
	 
	
	reg [1:0] FSM_state = 0;
    reg pixel_half = 0;
	
	localparam WAIT_FRAME_START = 0;
	localparam ROW_CAPTURE = 1;
	
	
	always@(posedge PCLK_cam)
	begin 
	
	case(FSM_state)
	
	WAIT_FRAME_START: begin //wait for VSYNC
	   FSM_state <= (!VSYNC_cam) ? ROW_CAPTURE : WAIT_FRAME_START;
	   frame_done <= 0;
	   pixel_half <= 0;
		cam_count <= 0;
	end
	
	ROW_CAPTURE: begin 
	   FSM_state <= VSYNC_cam ? WAIT_FRAME_START : ROW_CAPTURE;
	   frame_done <= VSYNC_cam ? 1 : 0;
	   pixel_valid <= (HREF_cam && pixel_half) ? 1 : 0; 
	   if (HREF_cam) begin
	       pixel_half <= ~ pixel_half;
	       if (pixel_half) pixel_data[7:0] <= data_cam;
	       else begin
				pixel_data[15:8] <= data_cam;
				cam_count <= cam_count+1;
			 end
	   end
	end
	
	
	endcase
	end
	
	
endmodule

