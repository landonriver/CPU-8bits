//the relatively complex cpu 
//design by cgy,2020.11
//modify by zhy,2022.11
//实例化，将分频模块，cpu模块,存储器模块,显示模块连接到一起。

module top(clk,rst,A1,SW_choose,SW1,SW2,D,addr,rambus,data,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7,r0dbus,r1dbus,cpustate_led,
				check_out,quick_low_led,read_led,write_led,arload_led,arinc_led,pcinc_led,pcload_led,drload_led,trload_led,irload_led,
				r1load_led,r0load_led,zload_led,pcbus_led,drhbus_led,drlbus_led,trbus_led,r1bus_led,r0bus_led,membus_led,busmem_led,
				clr_led);
input clk, rst;
input A1;
input SW_choose,SW1,SW2;
input [7:0] D;
//output[7:0]data;
output [15:0]addr;
output [7:0]rambus;
output [7:0] data;
output [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7;
output [7:0] r0dbus;//r0通用寄存器的输出
output [7:0] r1dbus;//r1通用寄存器的输出
output [1:0] cpustate_led;
output [7:0] check_out;
output quick_low_led;
output read_led,write_led,arload_led,arinc_led,pcinc_led,pcload_led,drload_led,trload_led,irload_led,r1load_led,r0load_led,zload_led,pcbus_led,drhbus_led,drlbus_led,trbus_led,r1bus_led,r0bus_led,membus_led,busmem_led,clr_led;
wire Z;
wire read,write,arload,arinc,pcinc,pcload,drload,trload,irload,r1load,r0load,zload,pcbus,drhbus,drlbus,trbus,r1bus,r0bus,membus,busmem,clr,xload,xbus;
wire clk_quick,clk_slow,clk_delay,clk_mem,clk_light;
wire [1:0] cpustate;

/*----------分频程序---------------*/
//综合用
//clk_div quick(.clk(clk),.reset(rst),.symbol(32'd16384000),.div_clk(clk_quick));
//clk_div slow(.clk(clk),.reset(rst),.symbol(32'd49152000),.div_clk(clk_slow));
//clk_div delay(.clk(clk),.reset(rst),.symbol(32'd2048000),.div_clk(clk_delay));
//clk_div mem(.clk(clk),.reset(rst),.symbol(32'd2048000),.div_clk(clk_mem));
//clk_div light(.clk(clk),.reset(rst),.symbol(32'd2048000),.div_clk(clk_light));
//仿真用
clk_div quick(.clk(clk),.reset(rst),.symbol(32'd3),.div_clk(clk_quick));
clk_div slow(.clk(clk),.reset(rst),.symbol(32'd6),.div_clk(clk_slow));
clk_div delay(.clk(clk),.reset(rst),.symbol(32'd1),.div_clk(clk_delay));
clk_div mem(.clk(clk),.reset(rst),.symbol(32'd3),.div_clk(clk_mem));
clk_div light(.clk(clk),.reset(rst),.symbol(32'd3),.div_clk(clk_light));
/*-------------------------------*/

/*CPU_Controller(SW1,SW2,CPU_state);*/
CPU_Controller controller(.SW1(SW1),.SW2(SW2),.CPU_state(cpustate));

//补充cpu实例化的语句
cpu mcpu(.data_in(rambus),.clk_quick(clk_quick),.clk_slow(clk_slow),.clk_delay(clk_delay),
		.rst(rst),.SW_choose(SW_choose),.A1(A1),.cpustate(cpustate),.addr(addr),.data_out(data),
		.r0dbus(r0dbus),.r1dbus(r1dbus),.membus(membus),.busmem(busmem),.read(read),.write(write),.clr(clr),.zout(Z));

/*ram(clk,data_in,addr,A1,reset,read,write,cpustate,D,data_out,check_out);*/
ram mm(.clk(clk_mem),.data_in(data),.addr(addr),.A1(A1),.reset(rst),.read(read),.write(write),
		.cpustate(cpustate),.D(D),.data_out(rambus),.check_out(check_out));


/*light_show(light_clk,SW_choose,check_in,read,write,arload,arinc,pcinc,pcload,drload,trload,irload,r1load,r0load,zload,pcbus,drhbus,drlbus,trbus,r1bus,r0bus,membus,busmem,clr,State,MAR,r0,R,Z,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7,State_LED,quick_low_led,read_led,write_led,arload_led,arinc_led,pcinc_led,pcload_led,drload_led,trload_led,irload_led,r1load_led,r0load_led,zload_led,pcbus_led,drhbus_led,drlbus_led,trbus_led,r1bus_led,r0bus_led,membus_led,busmem_led,clr_led);*/
light_show show(.light_clk(clk_light),.SW_choose(SW_choose),.check_in(check_out),.State(cpustate),.MAR(addr[7:0]),.r0(r0dbus),.r1(r1dbus),.Z(Z),.HEX0(HEX0),
					.HEX1(HEX1),.HEX2(HEX2),.HEX3(HEX3),.HEX4(HEX4),.HEX5(HEX5),.HEX6(HEX6),.HEX7(HEX7),.State_LED(cpustate_led),
					.quick_low_led(quick_low_led));

endmodule

