module centroid
(	
input logic image[307200],
output wire[10:0] x,y
);

logic[31:0] M00 = 0;
logic[31:0] M01 = 0;
logic[31:0] M10 = 0;

logic[639:0] col_sum = 0;

//always_comb begin
//	
////	for (int y1 = 0; y1 < 480; y1++) begin
////			col_sum += image[y1*640:(y1+1)*640];
////	end
//	
////	for (x = 0; x < 640; x++) begin
////		for (y = 0; y < 480; y++) begin
////			logic [18:0] idx = x+y*640;
////			M00 += image[idx];
////			M01 += x * image[idx];
////			M10 += y * image[idx];
////		end
////	end
//
//end

always_comb begin
	x = M10/M00;
	y = M01/M00;
end

endmodule