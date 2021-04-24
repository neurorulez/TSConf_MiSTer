//============================================================================
//  TSConf for MiSTer
// 
//  Port to MiSTer
//  Copyright (C) 2017-2019 Sorgelig
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================
`default_nettype wire
module emu
(
`ifndef CYCLONE
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [45:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        CLK_VIDEO,

	//Multiple resolutions are supported using different CE_PIXEL rates.
	//Must be based on CLK_VIDEO
	output        CE_PIXEL,

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	output  [7:0] VIDEO_ARX,
	output  [7:0] VIDEO_ARY,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,
	output [1:0]  VGA_SL,

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	// I/O board button press simulation (active high)
	// b[1]: user button
	// b[0]: osd button
	output  [1:0] BUTTONS,

	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S, // 1 - signed audio samples, 0 - unsigned
	output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

	//ADC
	inout   [3:0] ADC_BUS,

	//SD-SPI
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,
	input         SD_CD,

	//High latency DDR3 RAM interface
	//Use for non-critical time purposes
	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,

	//SDRAM interface with lower latency
	output        SDRAM_CLK,
	output        SDRAM_CKE,
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,

	input         UART_CTS,
	output        UART_RTS,
	input         UART_RXD,
	output        UART_TXD,
	output        UART_DTR,
	input         UART_DSR,

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..6 - USR2..USR6
	// Set USER_OUT to 1 to read from USER_IN.
	input   [6:0] USER_IN,
	output  [6:0] USER_OUT,

	input         OSD_STATUS
`else	
	input         CLK_50M,
	output        LED_USER,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_CLOCK, //RELOADED
	output        VGA_BLANK = 1'b1, //RELOADED
	output        AUDSG_L,
	output        AUDSG_R,

	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,

	output        SDRAM_CLK,
	output        SDRAM_CKE,
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,

	output [20:0] SRAM_ADDR, //Solo 19 Pines montados
	inout  [15:0] SRAM_DATA,
	output        SRAM_WE_N,
	output        SRAM_OE_N,
	output        SRAM_LB_N,
	output        SRAM_UB_N,
	
	inout         PS2_CLK,
	inout         PS2_DAT,
`ifndef JOYDC
	output        JOY_CLK,
	output        JOY_LOAD,
	input         JOY_DATA,
	output        JOY_SELECT,
`else
	input	wire [5:0]JOYSTICK1,
	input	wire [5:0]JOYSTICK2,
	output        JOY_SELECT = 1'b1,	
`endif	
	output        MCLK,
	output        SCLK,
	output        LRCLK,
	output        SDIN,
	output        STM_RST = 1'b0
`endif
);

assign ADC_BUS  = 'Z;
assign USER_OUT = '1;
assign VGA_F1 = 0;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;

assign LED_USER  = sd_act; //(vsd_sel & sd_act) | ioctl_download;
assign LED_DISK  = 1'b1; //{1'b1, ~vsd_sel & sd_act};
assign LED_POWER = 0;
assign BUTTONS   = 0;

assign VIDEO_ARX = status[5] ? 8'd16 : 8'd4;
assign VIDEO_ARY = status[5] ? 8'd9  : 8'd3;

`include "build_id.v" 
localparam CONF_STR = {
	"TSConf;;",
	"S,VHD,Mount virtual SD;",
	"-;",
	"O5,Aspect ratio,4:3,16:9;",
	"O12,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%;",
	"-;",
	"O34,Stereo mix,None,25%,50%,100%;",
	"OST,General Sound,512KB,1MB,2MB;",
	"-;",
	"OU,CPU Type,NMOS,CMOS;",
	"O67,CPU Speed,3.5MHz,7MHz,14MHz;",
	"O8,CPU Cache,On,Off;",
	"O9A,#7FFD span,128K,128K Auto,1024K,512K;",
	"OLN,ZX Palette,Default,B.black,Light,Pale,Dark,Grayscale,Custom;",
	"OPR,INT Offset,1,2,3,4,5,6,7,0;",
	"-;",
	"OBD,F11 Reset,boot.$C,sys.rom,ROM;",
	"OEF,           bank,TR-DOS,Basic 48,Basic 128,SYS;",
	"OGI,Shift+F11 Reset,ROM,boot.$C,sys.rom;",
	"OJK,           bank,Basic 128,SYS,TR-DOS,Basic 48;",
	"-;",
	"R0,Reset and apply settings;",
	"J,Fire 1,Fire 2;",
	"V,v",`BUILD_DATE
};

wire [27:0] CMOSCfg;

// fix default values
assign CMOSCfg[5:0]  = 0;
assign CMOSCfg[7:6]  = status[7:6];
assign CMOSCfg[8]    = ~status[8];
assign CMOSCfg[10:9] = status[10:9] + 1'd1;
assign CMOSCfg[13:11]= (status[13:11] < 2) ? status[13:11] + 3'd3 : status[13:11] - 3'd2;
assign CMOSCfg[15:14]= status[15:14];
assign CMOSCfg[18:16]= (status[18:16]) ? status[18:16] + 3'd2 : 3'd0;
assign CMOSCfg[20:19]= status[20:19] + 2'd2;
assign CMOSCfg[23:21]= status[23:21];
assign CMOSCfg[24]   = 0;
assign CMOSCfg[27:25]= status[27:25] + 1'd1;


////////////////////   CLOCKS   ///////////////////
wire clk_sys;
wire clk_vid;

pll pll
(
`ifndef CYCLONE
	.refclk(CLK_50M),
	.outclk_0(clk_sys),
	.outclk_1(clk_vid)
`else
	.inclk0(CLK_50M),
	.c0(clk_sys),
	.c1(clk_vid),
	.locked(locked)
`endif	
);

reg ce_28m;
always @(negedge clk_sys) begin
	reg [1:0] div;
	
	div <= div + 1'd1;
	if(div == 2) div <= 0;
	ce_28m <= !div;
end


//////////////////   HPS I/O   ///////////////////
`ifndef JOYDC
wire  [5:0] joy_0;
wire  [5:0] joy_1;
`else
wire  [5:0] joy_0 = ~JOYSTICK1[5:0];
wire  [5:0] joy_1 = ~JOYSTICK2[5:0];
`endif
wire [15:0] joya_0;
wire [15:0] joya_1;
wire  [1:0] buttons;
wire [31:0] status;
wire [24:0] ps2_mouse;
wire [10:0] ps2_key;

`ifndef CYCLONE
wire        forced_scandoubler;
`else
wire        forced_scandoubler=!host_scandoubler; //Negado = VGA x defecto.
`endif
wire [21:0] gamma_bus;

wire [31:0] sd_lba;
wire        sd_rd;
wire        sd_wr;
wire        sd_ack;
wire  [8:0] sd_buff_addr;
wire  [7:0] sd_buff_dout;
wire  [7:0] sd_buff_din;
wire        sd_buff_wr;
wire        img_mounted;
wire        img_readonly;
wire [63:0] img_size;
wire        sd_ack_conf;
wire [64:0] RTC;

wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;
wire        ioctl_download;
wire  [7:0] ioctl_index;
`ifndef CYCLONE
hps_io #(.STRLEN($size(CONF_STR)>>3)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),

	.conf_str(CONF_STR),

	.joystick_0(joy_0),
	.joystick_1(joy_1),
	.joystick_analog_0(joya_0),
	.joystick_analog_1(joya_1),

	.buttons(buttons),
	.status(status),
	.forced_scandoubler(forced_scandoubler),
	.gamma_bus(gamma_bus),

	.RTC(RTC),

	.ps2_mouse(ps2_mouse),
	.ps2_key(ps2_key),

	.sd_lba(sd_lba),
	.sd_rd(sd_rd),
	.sd_wr(sd_wr),
	.sd_ack(sd_ack),
	.sd_ack_conf(sd_ack_conf),
	.sd_buff_addr(sd_buff_addr),
	.sd_buff_dout(sd_buff_dout),
	.sd_buff_din(sd_buff_din),
	.sd_buff_wr(sd_buff_wr),
	.img_mounted(img_mounted),
	.img_readonly(img_readonly),
	.img_size(img_size),

	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_dout),
	.ioctl_download(ioctl_download),
	.ioctl_index(ioctl_index)
);
`else
wire [7:0]R_OSD,G_OSD,B_OSD;
wire host_scandoubler;
wire [7:0]R_IN = ~(HBlank | VBlank) ? R : 0;
wire [7:0]G_IN = ~(HBlank | VBlank) ? G : 0;
wire [7:0]B_IN = ~(HBlank | VBlank) ? B : 0;
assign VGA_CLOCK = CLK_VIDEO;

data_io data_io
(
	.clk(clk_sys),
	.CLOCK_50(CLOCK_50), //Para modulos de I2s y Joystick
	
	.debug(),
	
	.reset_n(locked),

	.vga_hsync(HS),
	.vga_vsync(VS),
	
	.red_i(R_IN),
	.green_i(G_IN),
	.blue_i(B_IN),
	.red_o(R_OSD),
	.green_o(G_OSD),
	.blue_o(B_OSD),
	
	.ps2k_clk_in(PS2_CLK),
	.ps2k_dat_in(PS2_DAT),
	.ps2_key(ps2_key),
	.host_scandoubler_disable(host_scandoubler),
	
`ifndef JOYDC
	.JOY_CLK(JOY_CLK),
	.JOY_LOAD(JOY_LOAD),
	.JOY_DATA(JOY_DATA),
	.JOY_SELECT(JOY_SELECT),
	.joy1(joystick_0),
	.joy2(joystick_1),
`endif
	.dac_MCLK(MCLK),
	.dac_LRCK(LRCLK),
	.dac_SCLK(SCLK),
	.dac_SDIN(SDIN),
	.sigma_L(AUDSG_L),
	.sigma_R(AUDSG_R),
	.L_data(AUDIO_L),
	.R_data(AUDIO_R),
	
	.spi_miso(),//SD_MISO),
	.spi_mosi(),//SD_MOSI),
	.spi_clk(),//SD_SCK),
	.spi_cs(),//SD_CS),

	.img_mounted(img_mounted),
	.img_size(img_size),

	.status(status),
	
	.ioctl_ce(1'b1),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_dout),
	.ioctl_download(ioctl_download),
	.ioctl_index(ioctl_index),
	.ioctl_file_ext()
);
`endif

////////////////////  MAIN  //////////////////////
wire [7:0] R,G,B;
wire HBlank,VBlank;
wire VS, HS;
wire ce_vid;

wire reset;

tsconf tsconf
(
	.clk(clk_sys),
	.ce(ce_28m),

	.SDRAM_DQ(SDRAM_DQ),
	.SDRAM_A(SDRAM_A),
	.SDRAM_BA(SDRAM_BA),
	.SDRAM_DQML(SDRAM_DQML),
	.SDRAM_DQMH(SDRAM_DQMH),
	.SDRAM_nWE(SDRAM_nWE),
	.SDRAM_nCAS(SDRAM_nCAS),
	.SDRAM_nRAS(SDRAM_nRAS),
	.SDRAM_CKE(SDRAM_CKE),
	.SDRAM_nCS(SDRAM_nCS),
	.SDRAM_CLK(SDRAM_CLK),

	.VGA_R(R),
	.VGA_G(G),
	.VGA_B(B),
	.VGA_HS(HS),
	.VGA_VS(VS),
	.VGA_HBLANK(HBlank),
	.VGA_VBLANK(VBlank),
	.VGA_CEPIX(ce_vid),

	.SD_SO(sdmiso),
	.SD_SI(sdmosi),
	.SD_CLK(sdclk),
	.SD_CS_N(sdss),

	.GS_ADDR(gs_mem_addr),
	.GS_DI(gs_mem_din),
	.GS_DO(gs_mem_dout | gs_mem_mask),
	.GS_RD(gs_mem_rd),
	.GS_WR(gs_mem_wr),
	.GS_WAIT(~gs_mem_ready), 	
	.SOUND_L(AUDIO_L),
	.SOUND_R(AUDIO_R),

	.COLD_RESET(RESET | status[0] | reset_img),
	.WARM_RESET(buttons[1]),
	.RESET_OUT(reset),
	.RTC(RTC),
	.OUT0(status[30]),

	.CMOSCfg(CMOSCfg),

	.PS2_KEY(ps2_key),
	.PS2_MOUSE(ps2_mouse),
	.joystick(joy_0[5:0] | joy_1[5:0]),

	.loader_addr(ioctl_addr[15:0]),
	.loader_data(ioctl_dout),
	.loader_wr(ioctl_wr && ioctl_download && !ioctl_index && !ioctl_addr[24:16])
);


assign DDRAM_CLK = clk_sys;

wire [20:0] gs_mem_addr;
wire  [7:0] gs_mem_dout;
wire  [7:0] gs_mem_din;
wire        gs_mem_rd;
wire        gs_mem_wr;
wire        gs_mem_ready;
reg   [7:0] gs_mem_mask;

always_comb begin
	gs_mem_mask = 0;
	case(status[29:28])
		0: if(gs_mem_addr[20:19]) gs_mem_mask = 8'hFF;
		1: if(gs_mem_addr[20])    gs_mem_mask = 8'hFF;
	 2,3:                        gs_mem_mask = 0;
	endcase
end
`ifndef CYCLONE
ddram ddram
(
	.*,
	.addr(gs_mem_addr),
	.dout(gs_mem_dout),
	.din(gs_mem_din),
	.we(gs_mem_wr),
	.rd(gs_mem_rd),
	.ready(gs_mem_ready)
);
`else

//always @(posedge DDRAM_CLK) begin
 assign SRAM_ADDR = gs_mem_rd ? gs_mem_addr[19:0] : 20'h00000;  //Solo 19 Pines montados
 assign SRAM_DATA = gs_mem_wr ? {gs_mem_din,gs_mem_din} : 16'hzzzz;
 assign gs_mem_dout = gs_mem_rd ? gs_mem_addr[20] ? SRAM_DATA[15:8] : SRAM_DATA[7:0] : 8'h00;
 assign SRAM_OE_N = ~gs_mem_rd | ~gs_mem_wr;
 assign SRAM_WE_N = ~gs_mem_wr;
 assign SRAM_LB_N =  gs_mem_addr[20];
 assign SRAM_UB_N = ~gs_mem_addr[20];

`endif
assign AUDIO_S = 1;
assign AUDIO_MIX = status[4:3];

reg ce_pix;
always @(posedge clk_vid) begin
	reg old_ce;

	old_ce <= ce_vid;
	ce_pix <= ~old_ce & ce_vid;
end

assign CLK_VIDEO = clk_vid;

reg VSync, HSync;
always @(posedge CLK_VIDEO) begin
	HSync <= HS;
	if(~HSync & HS) VSync <= VS;
end


wire [1:0] scale = status[2:1];
assign VGA_SL = {scale == 3, scale == 2};

video_mixer #(.GAMMA(1)) video_mixer
(
	.*,
	.ce_pix_out(CE_PIXEL),
`ifdef CYCLONE
	.R(R_OSD),
	.G(G_OSD),
	.B(B_OSD),
	.VGA_DE(),
	.VGA_VS(vsync_o),
	.VGA_HS(hsync_o),		
`endif
	.scanlines(0),
	.scandoubler(scale || forced_scandoubler),
	.hq2x(scale==1),
	.mono(0)
);

`ifdef CYCLONE
reg hsync_o, vsync_o, csync_o, csync_en;

csync csync_gen (.clk(CLK_VIDEO), .hsync(hsync_o), .vsync(vsync_o), .csync(csync_o));

assign csync_en = !(scale || forced_scandoubler);
assign VGA_VS = csync_en ? 1'b1     : ~vsync_o;
assign VGA_HS = csync_en ? ~csync_o : ~hsync_o; //~ en el orignal de Mister van Negadas

`endif


//////////////////   SD   ///////////////////
`ifndef CYCLONE
wire sdclk;
wire sdmosi;
wire sdmiso = vsd_sel ? vsdmiso : SD_MISO;
wire sdss;

reg reset_img;
reg vsd_sel = 0;
wire vsdmiso;

always @(posedge clk_sys) begin
	integer to = 0;
	
	if(to) to <= to - 1;
	else reset_img <= 0;

	if(img_mounted) begin
		vsd_sel <= |img_size;
		reset_img <= 1;
		to <= 10000000;
	end
end

sd_card sd_card
(
	.*,
	.clk_spi(clk_sys),

	.sdhc(1),

	.sck(sdclk),
	.ss(~vsd_sel | sdss),
	.mosi(sdmosi),
	.miso(vsdmiso)
);

assign SD_CS   = vsd_sel | sdss;
assign SD_SCK  = sdclk & ~SD_CS;
assign SD_MOSI = sdmosi & ~SD_CS;

`else

wire sdmosi, sdclk, sdss;
wire sdmiso = SD_MISO;
assign SD_MOSI = sdmosi;
assign SD_SCK  = sdclk;
assign SD_CS   = sdss;

`endif

reg sd_act;

always @(posedge clk_sys) begin
	reg old_mosi, old_miso;
	integer timeout = 0;

	old_mosi <= sdmosi;
	old_miso <= sdmiso;

	sd_act <= 0;
	if(timeout < 1000000) begin
		timeout <= timeout + 1;
		sd_act <= 1;
	end

	if((old_mosi ^ sdmosi) || (old_miso ^ sdmiso)) timeout <= 0;
end

endmodule
