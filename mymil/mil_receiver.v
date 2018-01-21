module mil_receiver(
input iCLK,
input iRESET,
input [1:0]iDI,

output reg [15:0]oDATA,
output reg oCD,
output reg oDONE,
output reg oPARITY_ERROR

);

reg [2:0]pos_shift;
reg [2:0]neg_shift;
reg [2:0]sig_shift;
reg [2:0]length_bit;
reg det_sig;
reg [39:0]manchester;
reg ena_wr;

wire IN_DATA;
wire RESET_LENGTH_BIT;
wire MIDDLE_BIT = (length_bit == 3'd3);
wire TRUE_DATA_PACKET;
wire [15:0]DATA_BUF;
wire PARITY_BUF;
wire CD_BUF;



always@(posedge iCLK or posedge iRESET)begin
if(iRESET)begin
	pos_shift <= 3'd0;
	neg_shift <= 3'd0;
end
else begin
	pos_shift <= {pos_shift, iDI[1]};
	neg_shift <= {neg_shift, iDI[0]};
end
end


always@(posedge iCLK or posedge iRESET)begin
if(iRESET)begin
	det_sig <= 1'b0;
end
else case({pos_shift[2], neg_shift[2]})
	2'b00:det_sig<=~det_sig;
	2'b01:det_sig<=1'b0;
	2'b10:det_sig<=1'b1;
	2'b11:det_sig<=~det_sig;
endcase
end



always@(posedge iCLK or posedge iRESET)begin
if(iRESET)begin
	sig_shift <= 3'd0;
end
else begin
	sig_shift[2:0] <= {sig_shift[1:0], det_sig};
end
end

always@(posedge iCLK or posedge iRESET)begin
if(iRESET)begin
	length_bit<=3'd0;
end
else begin
	if(RESET_LENGTH_BIT)begin
		length_bit<=3'd0;
	end
	else begin
		length_bit<=length_bit + 3'd1;
	end
end
end

always@(posedge iCLK or posedge iRESET)begin
if(iRESET)begin
	manchester<=40'd0;
end
else if(MIDDLE_BIT)begin
	manchester[39:0]<={manchester[38:0], IN_DATA};
end
end

genvar i;
generate for(i=0; i<=15; i=i+1)begin: bit_a
	assign DATA_BUF[i]=manchester[2*i+3];
end
endgenerate


always@(posedge iCLK )begin
	oDONE <=  TRUE_DATA_PACKET & ena_wr;
end

always@(posedge iCLK or posedge iRESET)begin
if(iRESET)begin
	oDATA <= 16'd0;
	oCD <= 1'd0;
	ena_wr <= 1'b0;
	oPARITY_ERROR <= 1'b0;
end
else begin
	ena_wr <= MIDDLE_BIT;
	if(TRUE_DATA_PACKET &ena_wr)begin
		oCD <= CD_BUF;
		oDATA <= DATA_BUF[15:0];
		oPARITY_ERROR <= ~(^({DATA_BUF,PARITY_BUF}));
	end
end
end

assign IN_DATA = sig_shift[2];

assign RESET_LEGTH_BIT = sig_shift[2]^sig_shift[1];

assign TRUE_DATA_PACKET = ((manchester[39:34]==6'b000111)|(manchester[39:34]==6'b111000)) 
								 &(manchester[33]^manchester[32]&manchester[31]^manchester[30]);

assign PARITY_BUF = manchester[1];
assign CD_BUF = manchester[35];
								 
endmodule
