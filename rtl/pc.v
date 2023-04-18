/*程序计数器，输出当前执行的指令地址
可仿照ar地址寄存器来写，注意替换控制信号*/
module pc(din, clk, rst,pcload, pcinc, dout);
input[15:0]din;
input clk,rst, pcload, pcinc;
output[15:0]dout; 
reg[15:0]dout;
always@(posedge clk or negedge rst)
    if(!rst)
		begin
			dout<=0;
		end
    else if(pcload)		
	     dout<=din;
	 else if(pcinc)
		  dout<=dout+1;
endmodule
