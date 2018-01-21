module mil_control(
input iCLK,
input iRESET,

input iRX_DONE,
input [15:0]iRX_DATA,
input iRX_CD,
input iPARITY_ERROR,

output oTX_EN,
output [15:0]oTX_DATA,
output oTX_CD, 
input iTX_BUSY,

input [4:0]iA_RD_M,
input iCLK_RD_M,
output [15:0]oD_RD_M,
output oBUSY_M,

input [15:0] iD_WR_G,
input [4:0] iA_WR_G,
input iCLK_WE_G,
input iWE_G,
output oBUSY_G

);



endmodule
