 
 /*组合逻辑控制单元，根据时钟生成为控制信号和内部信号*/
/*
输入：
       din：指令，8位，来自IR；
       clk：时钟信号，1位，上升沿有效；
       rst：复位信号，1位，与cpustate共同组成reset信号；
       cpustate：当前CPU的状态（IN，CHECK，RUN），2位；
       z：零标志，1位，零标志寄存器的输出，如果指令中涉及到z，可加上，否则可去掉；
输出：
      clr：清零控制信号
     自行设计的各个控制信号
*/
//省略号中是自行设计的控制信号，需要自行补充，没用到z的话去掉z
module control(din,clk,rst,z,cpustate,arload,arinc,pcload,pcinc,pcbus,drload,drhbus,drlbus,irload,trload ,trbus,r1load,r1bus,r0load,r0bus,xload,alus,zload,read,write,membus,busmem,clr);
input [7:0]din;
input clk;
input rst,z;
input [1:0] cpustate;
//输出端口说明
output reg [3:0]alus;
output arload,arinc,pcload,pcinc,pcbus,drload,drhbus,drlbus,irload,trload ,trbus,r1load,r1bus,r0load,
		r0bus,xload,zload,read,write,membus,busmem,clr;
//parameter's define
wire reset;
//在下方加上自行定义的状态
wire fetch1,fetch2,fetch3,nop1;
wire add1,add2;
wire sub1,sub2;
wire and1,and2;
wire or1,or2;
wire xor1,xor2;
wire inc1,inc2;
wire dec1,dec2;
wire not1,not2;
wire clr1;
wire mvr1;
wire shl1,shl2;
wire jmp1,jmp2,jmp3;
wire jpz1,jpz2,jpz3;
wire lad1,lad2,lad3,lad4,lad5;
wire sto1,sto2,sto3,sto4,sto5;

//加上自行设计的指令，这里是译码器的输出，所以nop指令经译码器输出后为inop。
//类似地，add指令指令经译码器输出后为iadd；inac指令经译码器输出后为iinac，......
reg inop;
reg iadd;
reg isub;
reg iand;
reg ior;
reg ixor;
reg iinc;
reg idec;
reg inot;
reg iclr;
reg imvr;
reg ishl;
reg ijmp;
reg ijpz;
reg ilad;
reg isto;

//时钟节拍，8个为一个指令周期，t0-t2分别对应fetch1-fetch3，t3-t7分别对应各指令的执行周期，当然不是所有指令都需要5个节拍的。例如add指令只需要2个节拍：t3和t4
reg t0,t1,t2,t3,t4,t5,t6,t7; //时钟节拍，8个为一个cpu周期

// 内部信号：clr清零，inc自增
wire clr;
wire inc;
assign reset = rst&(cpustate == 2'b11);
// assign signals for the cunter

//clr信号是每条指令执行完毕后必做的清零，下面clr赋值语句要修改，需要“或”各指令的最后一个周期
assign clr=nop1||add2||sub2||and2||or2||inc2||dec2||not2||xor2||clr1||mvr1||shl2||jmp3||jpz3||lad5||sto5;

assign inc=~clr;

//generate the control signal using state information
//取公过程-取指
assign fetch1=t0;
assign fetch2=t1;
assign fetch3=t2;

//什么都不做的译码
assign nop1=inop&&t3;//inop表示nop指令，nop1是nop指令的执行周期的第一个状态也是最后一个状态，因为只需要1个节拍t3完成

//以下写出各条指令状态的表达式
assign add1=iadd&&t3;
assign add2=iadd&&t4;

assign sub1=isub&&t3;
assign sub2=isub&&t4;

assign and1=iand&&t3;
assign and2=iand&&t4;

assign or1=ior&&t3;
assign or2=ior&&t4;

assign xor1=ixor&&t3;
assign xor2=ixor&&t4;

assign inc1=iinc&&t3;
assign inc2=iinc&&t4;

assign dec1=idec&&t3;
assign dec2=idec&&t4;

assign not1=inot&&t3;
assign not2=inot&&t4;

assign clr1=iclr&&t3;

assign mvr1=imvr&&t3;

assign shl1=ishl&&t3;
assign shl2=ishl&&t4;

assign jmp1=ijmp&&t3;
assign jmp2=ijmp&&t4;
assign jmp3=ijmp&&t5;

assign jpz1=ijpz&&t3;
assign jpz2=ijpz&&t4;
assign jpz3=ijpz&&t5;

assign lad1=ilad&&t3;
assign lad2=ilad&&t4;
assign lad3=ilad&&t5;
assign lad4=ilad&&t6;
assign lad5=ilad&&t7;
assign sto1=isto&&t3;
assign sto2=isto&&t4;
assign sto3=isto&&t5;
assign sto4=isto&&t6;
assign sto5=isto&&t7;


//以下给出了pcbus的逻辑表达式，写出其他控制信号的逻辑表达式
assign pcbus=fetch1||fetch3;
assign arload=fetch1||fetch3||lad3||sto3;
assign r0bus=mvr1||add1||sub1||and1||or1||xor1||inc1||dec1||not1||sto4||shl1;
assign trbus=jmp3||(jpz3&&z)||lad3||sto3;
assign drhbus=jmp3||(jpz3&&z)||lad3||sto3;
assign drlbus=lad5||sto5;
assign membus=fetch2||jmp1||jmp2||(jpz1&&z)||(jpz2&&z)||lad1||sto1||lad2||sto2||lad4;
assign pcload=jmp3||(jpz3&&z);
assign pcinc=fetch2||lad1||sto1||lad2||sto2||(jpz1&&!z);
assign arinc=jmp1||(jpz1&&z)||lad1||sto1;
assign r1load=mvr1;
assign r1bus=add2||sub2||and2||or2||xor2;
assign busmem=sto5;
assign drload=fetch2||jmp1||jmp2||(jpz1&&z)||(jpz2&&z)||lad1||sto1||lad2||sto2||lad4||sto4;
assign read=fetch2||jmp1||jmp2||(jpz1&&z)||(jpz2&&z)||lad1||sto1||lad2||sto2||lad4;
assign write=sto5;
assign irload=fetch3;
assign trload=jmp2||(jpz2&&z)||lad2||sto2;
assign zload=inc2||add2||sub2||clr1||and2||or2||xor2||not2||shl2;
assign r0load=add2||sub2||clr1||and2||or2||xor2||inc2||dec2||not2||shl2||lad5;
assign xload=add1||sub1||and1||or1||xor1||inc1||dec1||not1||shl1;

//the finite state

always@(posedge clk or negedge reset)
begin
	if(!reset)
		begin//各指令清零，以下已为nop指令清零，请补充其他指令，为其他指令清零
			inop<=0;
			iadd<=0;
			isub<=0;
			iand<=0;
			ior<=0;
			ixor<=0;
			iinc<=0;
			idec<=0;
			inot<=0;
			iclr<=0;
			imvr<=0;
			ishl<=0;
			ijmp<=0;
			ijpz<=0;
			ilad<=0;
			isto<=0;
		end
	else 
	begin
	
		//alus初始化为x，加上将alus初始化为x的语句，后续根据不同指令为alus赋值
		alus<=4'bxxxx;
		if(din[3:0]==0000)//译码处理过程
		begin
			case(din[7:4])
			4'd0: begin//指令高4位为0，应该是nop指令，因此这里inop的值是1，而其他指令应该清零，请补充为其他指令清零的语句
				inop<=1;
				iadd<=0;
				isub<=0;
				iand<=0;
				ior<=0;
				ixor<=0;
				iinc<=0;
				idec<=0;
				inot<=0;
				iclr<=0;
				imvr<=0;
				ishl<=0;
				ijmp<=0;
				ijpz<=0;
				ilad<=0;
				isto<=0;		
				end
			4'd1:  begin
				//指令高4位为0001，应该是add指令，因此iadd指令为1，其他指令都应该是0。
				//该指令需要做加法运算，详见《示例机的设计Quartus II和使用说明文档》中“ALU的设计”，因此这里要对alus赋值
				//后续各分支类似，只有一条指令为1，其他指令为0，以下分支都给出nop指令的赋值，需要补充其他指令，注意涉及到运算的都要对alus赋值
				inop<=0;
				iadd<=1;
				isub<=0;
				iand<=0;
				ior<=0;
				ixor<=0;
				iinc<=0;
				idec<=0;
				inot<=0;
				iclr<=0;
				imvr<=0;
				ishl<=0;
				ijmp<=0;
				ijpz<=0;
				ilad<=0;
				isto<=0;	
				//alus=？，需要为alus赋值
				alus<=4'b0000;
				end
			4'd2:  begin
				inop<=0;
				iadd<=0;
				isub<=1;
				iand<=0;
				ior<=0;
				ixor<=0;
				iinc<=0;
				idec<=0;
				inot<=0;
				iclr<=0;
				imvr<=0;
				ishl<=0;
				ijmp<=0;
				ijpz<=0;
				ilad<=0;
				isto<=0;	
				alus<=4'b0001;
				end
			4'd3:  begin
				inop<=0;
				iadd<=0;
				isub<=0;
				iand<=1;
				ior<=0;
				ixor<=0;
				iinc<=0;
				idec<=0;
				inot<=0;
				iclr<=0;
				imvr<=0;
				ishl<=0;
				ijmp<=0;
				ijpz<=0;
				ilad<=0;
				isto<=0;	
				alus<=4'b0010;
				end
			4'd4:  begin
				inop<=0;
				iadd<=0;
				isub<=0;
				iand<=0;
				ior<=1;
				ixor<=0;
				iinc<=0;
				idec<=0;
				inot<=0;
				iclr<=0;
				imvr<=0;
				ishl<=0;
				ijmp<=0;
				ijpz<=0;
				ilad<=0;
				isto<=0;	
				alus<=4'b0011;
				end
			4'd5:  begin
				inop<=0;
				iadd<=0;
				isub<=0;
				iand<=0;
				ior<=0;
				ixor<=1;
				iinc<=0;
				idec<=0;
				inot<=0;
				iclr<=0;
				imvr<=0;
				ishl<=0;
				ijmp<=0;
				ijpz<=0;
				ilad<=0;
				isto<=0;	
				alus<=4'b0100;
				end
			4'd6:	begin
				inop<=0;
				iadd<=0;
				isub<=0;
				iand<=0;
				ior<=0;
				ixor<=0;
				iinc<=1;
				idec<=0;
				inot<=0;
				iclr<=0;
				imvr<=0;
				ishl<=0;
				ijmp<=0;
				ijpz<=0;
				ilad<=0;
				isto<=0;	
				alus<=4'b0101;
				end
			4'd7:	begin
				inop<=0;
				iadd<=0;
				isub<=0;
				iand<=0;
				ior<=0;
				ixor<=0;
				iinc<=0;
				idec<=1;
				inot<=0;
				iclr<=0;
				imvr<=0;
				ishl<=0;
				ijmp<=0;
				ijpz<=0;
				ilad<=0;
				isto<=0;	
				alus<=4'b0110;
				end
			4'd8:  begin
				inop<=0;
				iadd<=0;
				isub<=0;
				iand<=0;
				ior<=0;
				ixor<=0;
				iinc<=0;
				idec<=0;
				inot<=1;
				iclr<=0;
				imvr<=0;
				ishl<=0;
				ijmp<=0;
				ijpz<=0;
				ilad<=0;
				isto<=0;	
				alus<=4'b0111;
				end
			4'd9:  begin
				inop<=0;
				iadd<=0;
				isub<=0;
				iand<=0;
				ior<=0;
				ixor<=0;
				iinc<=0;
				idec<=0;
				inot<=0;
				iclr<=1;
				imvr<=0;
				ishl<=0;
				ijmp<=0;
				ijpz<=0;
				ilad<=0;
				isto<=0;	
				alus<=4'b1000;
				end
			4'd10:  begin
				inop<=0;
				iadd<=0;
				isub<=0;
				iand<=0;
				ior<=0;
				ixor<=0;
				iinc<=0;
				idec<=0;
				inot<=0;
				iclr<=0;
				imvr<=1;
				ishl<=0;
				ijmp<=0;
				ijpz<=0;
				ilad<=0;
				isto<=0;	
				end
			4'd11:  begin
				inop<=0;
				iadd<=0;
				isub<=0;
				iand<=0;
				ior<=0;
				ixor<=0;
				iinc<=0;
				idec<=0;
				inot<=0;
				iclr<=0;
				imvr<=0;
				ishl<=1;
				ijmp<=0;
				ijpz<=0;
				ilad<=0;
				isto<=0;	
				alus<=4'b1001;
				end
			4'd12:  begin
				inop<=0;
				iadd<=0;
				isub<=0;
				iand<=0;
				ior<=0;
				ixor<=0;
				iinc<=0;
				idec<=0;
				inot<=0;
				iclr<=0;
				imvr<=0;
				ishl<=0;
				ijmp<=1;
				ijpz<=0;
				ilad<=0;
				isto<=0;	
				end
			
			4'd13:  begin
				inop<=0;
				iadd<=0;
				isub<=0;
				iand<=0;
				ior<=0;
				ixor<=0;
				iinc<=0;
				idec<=0;
				inot<=0;
				iclr<=0;
				imvr<=0;
				ishl<=0;
				ijmp<=0;
				ijpz<=1;
				ilad<=0;
				isto<=0;	
				end
			4'd14:  begin
				inop<=0;
				iadd<=0;
				isub<=0;
				iand<=0;
				ior<=0;
				ixor<=0;
				iinc<=0;
				idec<=0;
				inot<=0;
				iclr<=0;
				imvr<=0;
				ishl<=0;
				ijmp<=0;
				ijpz<=0;
				ilad<=1;
				isto<=0;	
				alus<=4'b1010;
				end
			4'd15:  begin
				inop<=0;
				iadd<=0;
				isub<=0;
				iand<=0;
				ior<=0;
				ixor<=0;
				iinc<=0;
				idec<=0;
				inot<=0;
				iclr<=0;
				imvr<=0;
				ishl<=0;
				ijmp<=0;
				ijpz<=0;
				ilad<=0;
				isto<=1;	
				end
				//如果还有分支，可以继续写，如果没有分支了，写上defuault语句	
			default:	begin
				inop<=0;
				iadd<=0;
				isub<=0;
				iand<=0;
				ior<=0;
				ixor<=0;
				iinc<=0;
				idec<=0;
				inot<=0;
				iclr<=0;
				imvr<=0;
				ishl<=0;
				ijmp<=0;
				ijpz<=0;
				ilad<=0;
				isto<=0;
				end
			endcase
		end
	end
end

/*——————8个节拍t0-t7————*/
always @(posedge clk or negedge reset)
begin
	if(!reset) //reset清零
	begin
		t0<=1;
		t1<=0;
		t2<=0;
		t3<=0;
		t4<=0;
		t5<=0;
		t6<=0;
		t7<=0;
	end
	else
	begin
		if(inc) //运行
		begin
			t7<=t6;
			t6<=t5;
			t5<=t4;
			t4<=t3;
			t3<=t2;
			t2<=t1;
			t1<=t0;
			t0<=0;
	end
		else if(clr) //清零
		begin
			t0<=1;
			t1<=0;
			t2<=0;
			t3<=0;
			t4<=0;
			t5<=0;
			t6<=0;
			t7<=0;
		end
	end
end
/*—————结束—————*/
endmodule
	
		