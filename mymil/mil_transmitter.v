module mil_transmitter(
input iCLK,
input iRESET,
input iCD,
input iEN,
input [15:0]iDATA, 
output reg [1:0]oDO,
output reg oBUSY
);

reg [15:0]	data_buf;
reg 			cd_buf;
reg [2:0]	length_bit;
reg [5:0]	count_bit;

wire [31:0]DATA_MANCHESTER;
wire [39:0]WORD_MANCHESTER;
wire PARITY;




always@(posedge iCLK or posedge iRESET)begin
if(iRESET)begin
	length_bit <= 3'd0;
end
else begin
	if(iEN)begin
		length_bit <= 3'd0;
	end
	else begin
		length_bit <= length_bit + 3'd1;
	end
end
end


always@(posedge iCLK or posedge iRESET)begin
if(iRESET)begin
	data_buf <= 16'd0;
	cd_buf <= 1'b0;
end
else begin
	if(iEN)begin
		data_buf <= iDATA;
		cd_buf <= iCD;
	end
end
end

always@(posedge iCLK or posedge iRESET)begin
if(iRESET)begin
	count_bit <= 6'd0; 
end
else begin
	if(iEN)begin
		count_bit <= 6'd39;
	end
	else if((count_bit != 6'd0)&(length_bit == 3'd7))begin
		count_bit <= count_bit-1'b1;
	end
end
end


always@(posedge iCLK or posedge iRESET)begin
if(iRESET)begin
	oBUSY <= 1'b0;
end
else begin
	if(iEN)begin
		oBUSY <= 1'b1;
	end
	else if((count_bit != 6'd0)&(length_bit == 3'd7))begin
			oBUSY <= 1'b0;
	end
end
end


always @(posedge iCLK)begin
if(oBUSY)begin
	oDO[1] <= DATA_MANCHESTER[count_bit];
	oDO[0] <= ~DATA_MANCHESTER[count_bit];
end
else begin
	oDO[1] <= 1'b0;
	oDO[0] <= 1'b0;
end
end

genvar i;
generate for(i=0; i<16; i=i+1)begin: gen_manchester
	assign DATA_MANCHESTER[2*i]= ~data_buf[i];
	assign DATA_MANCHESTER[2*i+1]= data_buf[i];
end
endgenerate


assign WORD_MANCHESTER[39:34] = cd_buf ? 6'b000111:6'b111000;
assign WORD_MANCHESTER[33:2]  = DATA_MANCHESTER;
assign WORD_MANCHESTER[1:0] = PARITY ? 2'b10:2'b01;
assign PARITY = ~(^data_buf);


endmodule
