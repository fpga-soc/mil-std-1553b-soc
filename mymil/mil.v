module mil(

input iCLK,
input iRESET,

// MKO interface - channel A
input [1:0]iDA,
output [1:0]oDA,
output oRX_STROB_A,
output oTX_INHIBIT_A,


// MKO interface - channel B
input [1:0]iDB,
output [1:0]oDB,
output oRX_STROB_B,
output oTX_INHIBIT_B,

// RAM device M
input [4:0] iA_RD_M,
input iCLK_RD_M,
output [15:0] oD_RD_M,
output oBUSY_M,

// RAM device G
input [15:0] iD_WR_G,
input [4:0] iA_WR_G,
input iCLK_WE_G,
input iWE_G,
output oBUSY_G

);


reg clk25 = 1'b0;
reg [4:0]ena_reg = 5'd0;

wire [1:0]DO;
wire [1:0]DI = {iDA[1]|iDB[1], iDA[0]|iDB[0]};

wire [15:0]RX_DATA;
wire RX_CD;
wire RX_DONE;
wire PARITY_ERROR;
wire [15:0]TX_DATA;
wire TX_CD;
wire TX_EN;
wire TX_BUSY;

always @(posedge iCLK)begin
	clk25 <= !clk25;
end

always @(posedge clk25 or posedge iRESET)begin
if(iRESET)begin
	ena_reg = 5'd0;
end
else begin
	ena_reg <= {ena_reg[3:0], TX_BUSY};
end
end

mil_control CONTROL(
.iCLK(clk25),
.iRESET(iRESET),

.iRX_DONE(RX_DONE),
.iRX_DATA(RX_DATA),
.iRX_CD(RX_CD),
.iPARITY_ERROR(PARITY_ERROR),

.oTX_EN(TX_EN),
.oTX_DATA(TX_DATA),
.oTX_CD(TX_CD), 
.iTX_BUSY(TX_BUSY),

.iA_RD_M(iA_RD_M),
.iCLK_RD_M(iCLK_RD_M),
.oD_RD_M(oD_RD_M),
.oBUSY_M(oBUSY_M),

.iD_WR_G(iD_WE_G),
.iA_WR_G(iA_WR_G),
.iCLK_WE_G(iCLK_WE_G),
.iWE_G(iWE_G),
.oBUSY_G(oBUSY_G)
);



mil_transmitter TRANSMITTER(
.iCLK(clk25),
.iRESET(iRESET),
.iCD(TX_CD),
.iEN(TX_EN),
.iDATA(TX_DATA), 
.oDO(DO),
.oBUSY(TX_BUSY)
);


mil_receiver RECEIVER(
.iCLK(clk25),
.iRESET(iRESET),
.iDI(DI),
.oDATA(RX_DATA),
.oCD(RX_CD),
.oDONE(RX_DONE),
.oPARITY_ERROR(PARITY_ERROR)
);


assign oDA = DO;
assign oDB = DO;

assign oRX_STROB_A = 	~{|ena_reg};
assign oTX_INHIBIT_A = 	~{|ena_reg};
assign oRX_STROB_B = 	~{|ena_reg};
assign oTX_INHIBIT_B = 	~{|ena_reg};

endmodule
