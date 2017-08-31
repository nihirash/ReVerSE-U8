-------------------------------------------------------------------[01.04.2014]
-- u9-Speccy Version 0.8.8 
-- DEVBOARD ReVerSE-U9
-------------------------------------------------------------------------------
-- V0.1 	12.02.2011	������ ������.
-- V0.5 	01.11.2011	�������� GS.
-- V0.5.1 	11.12.2011	����� GS �� ������� F10.
-- V0.5.2 	14.12.2011	UART.
-- V0.5.3 	20.12.2011	INT, CPU GS @ 84MHz.
-- V0.6 	16.12.2012	ROM ������ ����������� �� M25P40.
-- V0.7 	29.05.2013	�������� T80CPU, UART. � ������ GS ���������� ������ ������� bit7_flag, bit0_flag (���������� �������), ������� 21���, ���������� ��������� �������.
-- V0.8		21.07.2013	���������� ������ ������ ZC ��� turbo on/off. � ������ GS ���������� ������ int_n (���������� �������).
-- V0.8.1	23.07.2013	��������� ������ ������������ ����� ������� � vid_wr.
-- V0.8.2	24.07.2013	����������� ������� ZC 28���.
-- V0.8.3	10.08.2013	����������� ticksPerUsec * 3500000 � ������� io_ps2_mouse � io_ps2_keyboard.
-- V0.8.4	01.09.2013	��������� SPI Master, ����������� ������ ���������� �� ��������� �������. ��������� � ����������� SDRAM.
-- V0.8.5	07.09.2013	YM2149 �������� ������� �� AY8910, ��� ������ ��� ����� ��������� ������������.
-- V0.8.6	05.03.2014	��������� � ����������� SDRAM, ��������� �����.
-- V0.8.7	27.03.2014	��������� ����� ������� pentagon, spectrum. �������� DivMMC, ������������ ����������.
-- V0.8.8	01.04.2014	����������� � ������������ ����� ������ ������ � DivMMC (shurik-ua). ��������� � ���������� SDRAM, ��������� ������� RD, WR, RFSH ��� �������������� ���������� �������


-- http://zx.pk.ru/showthread.php?t=13875

-- Copyright (c) 2011-2014 MVV, shurik-ua, Evgeny7, lisica
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- * Redistributions of source code must retain the above copyright notice,
--   this list of conditions and the following disclaimer.
--
-- * Redistributions in synthesized form must reproduce the above copyright
--   notice, this list of conditions and the following disclaimer in the
--   documentation and/or other materials provided with the distribution.
--
-- * Neither the name of the author nor the names of other contributors may
--   be used to endorse or promote products derived from this software without
--   specific prior written agreement from the author.
--
-- * License is granted for non-commercial use only.  A fee may not be charged
--   for redistributions as source code or in synthesized/hardware form without 
--   specific prior written agreement from the author.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all; 

-- M9K 46K:
-- 0000-B7FF


-- SRAM 512K:
-- 00000-07FFF		General Sound ROM 	32K
-- 08000-7FFFF		General Sound RAM 	480K


-- SDRAM 32M:
-- 0000000-1FFFFFF

-- 4 3210 9876 5432 1098 7654 3210
-- 0 00xx_xxxx xxxx_xxxx xxxx_xxxx	0000000-03FFFFF		RAM		4MB
-- 0 xxxx_xxxx xxxx_xxxx xxxx_xxxx	0400000-0FFFFFF		-----------
-- 1 0000_0xxx xxxx_xxxx xxxx_xxxx	1000000-107FFFF		divMMC 512K
-- 1 0000_1000 00xx_xxxx xxxx_xxxx	1080000-1003FFF		GLUK	16K
-- 1 0000_1000 01xx_xxxx xxxx_xxxx	1084000-1007FFF		TR-DOS	16K
-- 1 0000_1000 10xx_xxxx xxxx_xxxx	1088000-100BFFF		ROM'86	16K
-- 1 0000_1000 11xx_xxxx xxxx_xxxx	108C000-100FFFF		ROM'82	16K
-- 1 0000_1001 000x_xxxx xxxx_xxxx	1090000-1091FFF		divMMC	 8K


-- FLASH 512K:
-- 00000-5FFFF		������������ Cyclone EP3C10
-- 60000-63FFF		General Sound ROM				16K
-- 64000-67FFF		General Sound ROM				16K
-- 68000-6BFFF		GLUK 							16K
-- 6C000-6FFFF		TR-DOS 							16K
-- 70000-73FFF		OS'86 							16K
-- 74000-77FFF		OS'82 							16K
-- 78000-7AFFF		DivMMC							 8K
-- 7B000-7BFFF		��������						 8�
-- 7C000-7FFFF		��������						16�

entity u9speccy is
port (
	-- Clock (50MHz)
	CLK_50MHZ	: in std_logic;
	-- SRAM (CY7C1049DV33-10)
	SRAM_A		: out std_logic_vector(18 downto 0);
	SRAM_D		: inout std_logic_vector(7 downto 0);
	SRAM_WE_n	: out std_logic;
	SRAM_OE_n	: out std_logic;
	-- SDRAM (MT48LC32M8A2-75)
	DRAM_A		: out std_logic_vector(12 downto 0);
	DRAM_D		: inout std_logic_vector(7 downto 0);
	DRAM_BA		: out std_logic_vector(1 downto 0);
	DRAM_CLK	: out std_logic;
	DRAM_CKE	: out std_logic;
	DRAM_DQM	: out std_logic;
	DRAM_WE_n	: out std_logic;
	DRAM_CAS_n	: out std_logic;
	DRAM_RAS_n	: out std_logic;
	-- RTC (PCF8583)
	RTC_INT_n	: in std_logic;
	RTC_SCL		: inout std_logic;
	RTC_SDA		: inout std_logic;
	-- FLASH (M25P40)
	DATA0		: in std_logic;
	NCSO		: out std_logic;
	DCLK		: out std_logic;
	ASDO		: out std_logic;
	-- DAC (TDA1543)
	DAC_BCK		: out std_logic;
	-- VGA
	VGA_R		: out std_logic_vector(2 downto 0);
	VGA_G		: out std_logic_vector(2 downto 0);
	VGA_B		: out std_logic_vector(2 downto 0);
	VGA_VSYNC	: out std_logic;
	VGA_HSYNC	: out std_logic;
	-- External I/O
	RST_n		: in std_logic;
	GPI			: in std_logic;
	-- PS/2
	PS2_KBCLK	: inout std_logic;
	PS2_KBDAT	: inout std_logic;		
	PS2_MSCLK	: inout std_logic;
	PS2_MSDAT	: inout std_logic;		
	-- USB-UART (FT232RL)
	TXD			: in std_logic;
	RXD			: out std_logic;
	CBUS4		: in std_logic;
	-- SD/MMC Card
	SD_CLK		: out std_logic;
	SD_DAT0		: in std_logic;
	SD_DAT1		: in std_logic;
	SD_DAT2		: in std_logic;
	SD_DAT3		: out std_logic;
	SD_CMD		: out std_logic;
	SD_DETECT	: in std_logic;
	SD_PROT		: in std_logic);		
end u9speccy;

architecture u9speccy_arch of u9speccy is

-- CPU0
signal cpu0_reset_n		: std_logic;
signal cpu0_clk			: std_logic;
signal cpu0_a_bus		: std_logic_vector(15 downto 0);
signal cpu0_do_bus		: std_logic_vector(7 downto 0);
signal cpu0_di_bus		: std_logic_vector(7 downto 0);
signal cpu0_mreq_n		: std_logic;
signal cpu0_iorq_n		: std_logic;
signal cpu0_wr_n		: std_logic;
signal cpu0_rd_n		: std_logic;
signal cpu0_int_n		: std_logic;
signal cpu0_inta_n		: std_logic;
signal cpu0_m1_n		: std_logic;
signal cpu0_rfsh_n		: std_logic;
signal cpu0_ena			: std_logic;
signal cpu0_mult		: std_logic_vector(1 downto 0);
signal cpu0_mem_wr		: std_logic;
signal cpu0_mem_rd		: std_logic;
signal cpu0_nmi_n		: std_logic;
-- Memory
signal rom_do_bus		: std_logic_vector(7 downto 0);
signal ram_a_bus		: std_logic_vector(11 downto 0);
-- Port
signal port_xxfe_reg	: std_logic_vector(7 downto 0) := "00000000";
signal port_1ffd_reg	: std_logic_vector(7 downto 0);
signal port_7ffd_reg	: std_logic_vector(7 downto 0);
signal port_dffd_reg	: std_logic_vector(7 downto 0);
signal port_0000_reg	: std_logic_vector(7 downto 0) := "00000000";
signal port_0001_reg	: std_logic_vector(7 downto 0) := "00000000";
-- PS/2 Keyboard
signal kb_do_bus		: std_logic_vector(4 downto 0);
signal kb_f_bus			: std_logic_vector(12 downto 1);
signal kb_joy_bus		: std_logic_vector(4 downto 0);
signal kb_num			: std_logic;
-- PS/2 Mouse
signal ms_but_bus		: std_logic_vector(7 downto 0);
signal ms_present		: std_logic;
signal ms_left			: std_logic;
signal ms_x_bus			: std_logic_vector(7 downto 0);
signal ms_y_bus			: std_logic_vector(7 downto 0);
signal ms_clk_out		: std_logic;
signal ms_buf_out		: std_logic;
-- Video
signal vid_a_bus		: std_logic_vector(12 downto 0);
signal vid_di_bus		: std_logic_vector(7 downto 0);
signal vid_wr			: std_logic;
signal vid_scr			: std_logic;
signal vid_hsync		: std_logic;
signal vid_vsync		: std_logic;
signal vid_hcnt			: std_logic_vector(8 downto 0);
signal vid_int			: std_logic;
--signal vid_border		: std_logic;
--signal vid_attr		: std_logic_vector(7 downto 0);
signal rgb				: std_logic_vector(5 downto 0);
-- Z-Controller
signal zc_do_bus		: std_logic_vector(7 downto 0);
signal zc_rd			: std_logic;
signal zc_wr			: std_logic;
signal zc_cs_n			: std_logic;
signal zc_sclk			: std_logic;
signal zc_mosi			: std_logic;
signal zc_miso			: std_logic;
-- SPI
signal spi_si			: std_logic;

signal spi_clk			: std_logic;
signal spi_wr			: std_logic;
signal spi_cs_n			: std_logic;
signal spi_do_bus		: std_logic_vector(7 downto 0);
signal spi_busy			: std_logic;
-- PCF8583
signal rtc_do_bus		: std_logic_vector(7 downto 0);
signal rtc_wr			: std_logic;
-- MC146818A
signal mc146818_wr		: std_logic;
signal mc146818_a_bus	: std_logic_vector(5 downto 0);
signal mc146818_do_bus	: std_logic_vector(7 downto 0);
signal port_bff7		: std_logic;
signal port_eff7_reg	: std_logic_vector(7 downto 0);
-- TDA1543
signal dac_data			: std_logic;
signal dac_ws			: std_logic;




-- SDRAM
signal sdr_do_bus		: std_logic_vector(7 downto 0);
signal sdr_wr			: std_logic;
signal sdr_rd			: std_logic;
signal sdr_rfsh			: std_logic;
-- TurboSound
signal ssg_sel			: std_logic;
signal ssg_cn0_bus		: std_logic_vector(7 downto 0);
signal ssg_cn0_a		: std_logic_vector(7 downto 0);
signal ssg_cn0_b		: std_logic_vector(7 downto 0);
signal ssg_cn0_c		: std_logic_vector(7 downto 0);
signal ssg_cn1_bus		: std_logic_vector(7 downto 0);
signal ssg_cn1_a		: std_logic_vector(7 downto 0);
signal ssg_cn1_b		: std_logic_vector(7 downto 0);
signal ssg_cn1_c		: std_logic_vector(7 downto 0);
signal audio_l			: std_logic_vector(15 downto 0);
signal audio_r			: std_logic_vector(15 downto 0);
signal sound			: std_logic_vector(7 downto 0);
-- Soundrive
signal covox_a			: std_logic_vector(7 downto 0);
signal covox_b			: std_logic_vector(7 downto 0);
signal covox_c			: std_logic_vector(7 downto 0);
signal covox_d			: std_logic_vector(7 downto 0);
-- General Sound
signal gs_a				: std_logic_vector(13 downto 0);
signal gs_b				: std_logic_vector(13 downto 0);
signal gs_c				: std_logic_vector(13 downto 0);
signal gs_d				: std_logic_vector(13 downto 0);
signal gs_do_bus		: std_logic_vector(7 downto 0);
signal gs_mdo			: std_logic_vector(7 downto 0);
signal gs_ma			: std_logic_vector(18 downto 0);
signal gs_mwe_n			: std_logic;
-- UART
signal uart_do_bus		: std_logic_vector(7 downto 0);
signal uart_wr			: std_logic;
signal uart_rd			: std_logic;
signal uart_tx_busy		: std_logic;
signal uart_rx_avail	: std_logic;
signal uart_rx_error	: std_logic;
-- CLOCK
signal clk_bus			: std_logic;
signal clk_sdr			: std_logic;
signal clk_interface	: std_logic;
signal clk_codec		: std_logic;
------------------------------------
signal ena_14mhz		: std_logic;
signal ena_7mhz			: std_logic;
signal ena_3_5mhz		: std_logic;
signal ena_1_75mhz		: std_logic;
signal ena_0_4375mhz	: std_logic;
signal ena_cnt			: std_logic_vector(5 downto 0);
-- System
signal reset			: std_logic;
signal areset			: std_logic;
signal key_reset		: std_logic;
signal locked			: std_logic;
signal loader_act		: std_logic := '1';
signal dos_act			: std_logic := '1';
signal cpuclk			: std_logic;
signal selector			: std_logic_vector(4 downto 0);
signal key_f			: std_logic_vector(12 downto 1);
signal key				: std_logic_vector(12 downto 1) := "000100000100";	-- F9=14.0, F3=7.0
-- CNTR
signal cntr_rgb			: std_logic_vector(5 downto 0);
signal cntr_hs			: std_logic;
signal cntr_vs			: std_logic;
signal cntr_rd			: std_logic;
signal cntr_io_flag		: std_logic;
signal cntr_addr_reg	: std_logic_vector(15 downto 0);
signal cntr_data_reg	: std_logic_vector(7 downto 0);
-- divmmc
signal divmmc_do		: std_logic_vector(7 downto 0);
signal divmmc_amap		: std_logic;
signal divmmc_e3reg		: std_logic_vector(7 downto 0);	
signal divmmc_cs_n		: std_logic;
signal divmmc_sclk		: std_logic;
signal divmmc_mosi		: std_logic;
signal mux				: std_logic_vector(3 downto 0);


begin

-- PLL
U0: entity work.altpll0
port map (
	areset	=> areset,
	inclk0	=> CLK_50MHZ,		-- 50.0 MHz
	locked	=> locked,
	c0		=> clk_bus,			-- 28.0 MHz
	c1		=> clk_codec,		--  9.2 MHz
	c2		=> clk_interface,	-- 21.0 MHz
	c3		=> clk_sdr);		-- 84.0 MHz

-- Zilog Z80A CPU
U1: entity work.T80s
generic map (
	Mode		=> 0,	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
	T2Write		=> 1,	-- 0 => WR_n active in T3, 1 => WR_n active in T2
	IOWait		=> 1)	-- 0 => Single cycle I/O, 1 => Std I/O cycle
port map(
	RESET_n		=> cpu0_reset_n,
	CLK_n		=> cpuclk,
	WAIT_n		=> '1',
	INT_n		=> cpu0_int_n,
	NMI_n		=> cpu0_nmi_n,
	BUSRQ_n		=> '1',
	M1_n		=> cpu0_m1_n,
	MREQ_n		=> cpu0_mreq_n,
	IORQ_n		=> cpu0_iorq_n,
	RD_n		=> cpu0_rd_n,
	WR_n		=> cpu0_wr_n,
	RFSH_n		=> cpu0_rfsh_n,
	HALT_n		=> open,
	BUSAK_n		=> open,
	A			=> cpu0_a_bus,
	DI			=> cpu0_di_bus,
	DO			=> cpu0_do_bus,
	SavePC      => open,
	SaveINT     => open,
	RestorePC   => (others => '1'),
	RestoreINT  => (others => '1'),
	RestorePC_n => '1');

-- Video Spectrum/Pentagon
U2: entity work.video
port map (
	CLK			=> clk_bus,
	ENA			=> ena_7mhz & ena_14mhz,
	INTA		=> cpu0_inta_n,
	INT			=> cpu0_int_n,
	BORDER		=> port_xxfe_reg(2 downto 0),	-- ���� D0..D2 ����� xxFE ���������� ���� �������
	BORDON		=> open, --vid_border,
	ATTR		=> open, --vid_attr,
	A			=> vid_a_bus,
	DI			=> vid_di_bus,
	MODE		=> key_f(7) & key_f(12),		-- 0: Spectrum; 1: Pentagon
	RGB			=> rgb,
	HSYNC		=> vid_hsync,
	VSYNC		=> vid_vsync);
	
-- Video memory
U3: entity work.altram1
port map (
	clock_a		=> clk_bus,
	clock_b		=> clk_bus,
	address_a	=> vid_scr & cpu0_a_bus(12 downto 0),
	address_b	=> port_7ffd_reg(3) & vid_a_bus,
	data_a		=> cpu0_do_bus,
	data_b		=> "11111111",
	q_a			=> open,
	q_b			=> vid_di_bus,
	wren_a		=> vid_wr,
	wren_b		=> '0');

-- Keyboard
U4: entity work.keyboard
generic map (
	ledStatusSupport=> true,	-- Include code for LED status updates
	clockFilter		=> 15,		-- Number of system-cycles used for PS/2 clock filtering
	ticksPerUsec	=> 28)		-- Timer calibration 28Mhz
port map(
	CLK			=>	clk_bus,
	RESET		=>	areset,
	A			=>	cpu0_a_bus(15 downto 8),
	KEYB		=>	kb_do_bus,
	KEYF		=>	kb_f_bus,
	KEYJOY		=>	kb_joy_bus,
	KEYNUMLOCK	=>	kb_num,
	KEYRESET	=>	key_reset,
	KEYLED		=>  key_f(6) & key_f(12) & key_f(9),
	PS2_KBCLK	=>	PS2_KBCLK,
	PS2_KBDAT	=>	PS2_KBDAT);

-- PS/2 Mouse Controller
U5: entity work.mouse
generic map (
	-- This allows the use of the scroll-wheel on mice that have them.
	intelliMouseSupport => true,	-- Enable support for intelli-mouse mode.
	clockFilter 		=> 15,		-- Number of system-cycles used for PS/2 clock filtering
	ticksPerUsec		=> 28)		-- Timer calibration 28Mhz clock
port map (
	clk				=> clk_bus,
	reset			=> reset,
	ps2_clk			=> PS2_MSCLK,
	ps2_dat		 	=> PS2_MSDAT,
	mousePresent 	=> ms_present,
	leftButton 		=> ms_but_bus(1),
	middleButton 	=> ms_but_bus(2),
	rightButton 	=> ms_but_bus(0),
	X 				=> ms_x_bus,
	Y 				=> ms_y_bus,
	Z				=> ms_but_bus(7 downto 4));	

-- ROM 1K
U6: entity work.altram0
port map (
	clock_a		=> clk_bus,
	clock_b		=> clk_bus,
	address_a	=> cpu0_a_bus(9 downto 0),
	address_b	=> "0000000000",
	data_a	 	=> cpu0_do_bus,
	data_b	 	=> "00000000",
	q_a	 		=> rom_do_bus,
	q_b	 		=> open,
	wren_a	 	=> '0',
	wren_b	 	=> '0');
	
-- Z-Controller
U7: entity work.zcontroller
port map (
	RESET		=> reset,
	CLK			=> clk_bus,
	A			=> cpu0_a_bus(5),
	DI			=> cpu0_do_bus,
	DO			=> zc_do_bus,
	RD			=> zc_rd,
	WR			=> zc_wr,
	SDDET		=> SD_DETECT,
	SDPROT		=> SD_PROT,
	CS_n		=> zc_cs_n,
	SCLK		=> zc_sclk,
	MOSI		=> zc_mosi,
	MISO		=> SD_DAT0);
	
-- SPI (M25P40) 25MHz Max SCK
U8: entity work.spi
port map (
	RESET		=> reset,
	CLK			=> clk_bus,
	SCK			=> clk_interface,
	A			=> cpu0_a_bus(0),
	DI			=> cpu0_do_bus,
	DO			=> spi_do_bus,
	WR			=> spi_wr,
	BUSY		=> spi_busy,
	CS_n		=> spi_cs_n,
	SCLK		=> spi_clk,
	MOSI		=> spi_si,
	MISO		=> DATA0);

-- TurboSound
U9: entity work.turbosound
port map (
	RESET		=> reset,
	CLK			=> clk_bus,
	ENA			=> ena_1_75mhz,
	A			=> cpu0_a_bus,
	DI			=> cpu0_do_bus,
	WR_n		=> cpu0_wr_n,
	IORQ_n		=> cpu0_iorq_n,
	M1_n		=> cpu0_m1_n,
	SEL			=> ssg_sel,
	CN0_DO		=> ssg_cn0_bus,
	CN0_A		=> ssg_cn0_a,
	CN0_B		=> ssg_cn0_b,
	CN0_C		=> ssg_cn0_c,
	CN1_DO		=> ssg_cn1_bus,
	CN1_A		=> ssg_cn1_a,
	CN1_B		=> ssg_cn1_b,
	CN1_C		=> ssg_cn1_c);

-- TDA1543 I2S Controller
U10: entity work.tda1543
port map (
	RESET		=> not locked or not RST_n,
	CS			=> not port_0001_reg(0),
	CLK			=> clk_codec,
	DATA_L		=> audio_l,
	DATA_R		=> audio_r,
	BCK			=> DAC_BCK,
	WS			=> dac_ws,
	DATA		=> dac_data);







-- SDRAM Controller
U11: entity work.sdram
port map (
	CLK			=> clk_sdr,
	A			=> ram_a_bus & cpu0_a_bus(12 downto 0),
	DI			=> cpu0_do_bus,
	DO			=> sdr_do_bus,
	DM	 		=> '0',
	WR			=> sdr_wr,
	RD			=> sdr_rd,
	RFSH		=> sdr_rfsh,
	RFSHREQ		=> open,
	IDLE		=> open,
	CK			=> DRAM_CLK,
	CKE			=> DRAM_CKE,
	RAS_n		=> DRAM_RAS_n,
	CAS_n		=> DRAM_CAS_n,
	WE_n		=> DRAM_WE_n,
	DQM			=> DRAM_DQM,
	BA1			=> DRAM_BA(1),
	BA0			=> DRAM_BA(0),
	MA			=> DRAM_A,
	DQ			=> DRAM_D);

-- RTC PCF8583 I2C Controller
U12: entity work.i2c
port map (
	RESET		=> reset,
	CLK			=> clk_bus,
	ENA			=> ena_0_4375mhz,
	A			=> cpu0_a_bus(4),
	DI			=> cpu0_do_bus,
	DO			=> rtc_do_bus,
	WR			=> rtc_wr,
	I2C_SCL		=> RTC_SCL,
	I2C_SDA		=> RTC_SDA);

-- MC146818A
U13: entity work.mc146818a
port map (
	RESET		=> reset,
	CLK			=> clk_bus,
	ENA			=> ena_0_4375mhz,
	CS			=> '1',
	WR			=> mc146818_wr,
	A			=> mc146818_a_bus,
	DI			=> cpu0_do_bus,
	DO			=> mc146818_do_bus);

-- Soundrive
U14: entity work.soundrive
port map (
	RESET		=> reset,
	CLK			=> clk_bus,
	CS			=> key_f(11),
	WR_n		=> cpu0_wr_n,
	A			=> cpu0_a_bus(7 downto 0),
	DI			=> cpu0_do_bus,
	IORQ_n		=> cpu0_iorq_n,
	DOS			=> dos_act,
	OUTA		=> covox_a,
	OUTB		=> covox_b,
	OUTC		=> covox_c,
	OUTD		=> covox_d);

-- General Sound
U15: entity work.gs
port map (
	RESET		=> not port_0001_reg(2) or kb_f_bus(10) or areset,	-- ������� [F10] reset GS
	CLK			=> clk_bus,
	CLKGS		=> clk_interface,
	A			=> cpu0_a_bus,
	DI			=> cpu0_do_bus,
	DO			=> gs_do_bus,
	WR_n		=> cpu0_wr_n,
	RD_n		=> cpu0_rd_n,
	IORQ_n		=> cpu0_iorq_n,
	M1_n		=> cpu0_m1_n,
	OUTA		=> gs_a,
	OUTB		=> gs_b,
	OUTC		=> gs_c,
	OUTD		=> gs_d,
	MA			=> gs_ma,
	MDI			=> SRAM_D,
	MDO			=> gs_mdo,
	MWE_n		=> gs_mwe_n);

-- UART
U16: entity work.uart
generic map (
	-- divisor = 28MHz / 115200 Baud = 243
	divisor		=> 243)
port map (
	CLK			=> clk_bus,
	RESET		=> reset,
	WR			=> uart_wr,
	RD			=> uart_rd,
	DI			=> cpu0_do_bus,
	DO			=> uart_do_bus,
	TXBUSY		=> uart_tx_busy,
	RXAVAIL		=> uart_rx_avail,
	RXERROR		=> uart_rx_error,
	RXD			=> TXD,
	TXD			=> RXD);

-- CNTR
U17: entity work.cntr
port map (
	CLK			=> CLK_50MHZ,
	RESET		=> areset,
	SEL			=> key_f(8),
	IOADDR		=> cntr_addr_reg,
	IODATA		=> cntr_data_reg,
	IORD		=> cntr_rd,
	IOFLAG		=> cntr_io_flag,
	RGB			=> cntr_rgb,
	HSYNC		=> cntr_hs,
	VSYNC		=> cntr_vs);

-- divmmc interface
U18: entity work.divmmc
port map (
	CLK			=> clk_bus,
	EN			=> key_f(6),
	RESET		=> reset,
	ADDR		=> cpu0_a_bus,
	DI			=> cpu0_do_bus,
	DO			=> divmmc_do,
	WR_N		=> cpu0_wr_n,
	RD_N		=> cpu0_rd_n,
	IORQ_N		=> cpu0_iorq_n,
	MREQ_N		=> cpu0_mreq_n,
	M1_N		=> cpu0_m1_n,
	E3REG		=> divmmc_e3reg,
	AMAP		=> divmmc_amap,
	CS_N		=> divmmc_cs_n,
	SCLK		=> divmmc_sclk,
	MOSI		=> divmmc_mosi,
	MISO		=> SD_DAT0);
	
-------------------------------------------------------------------------------
-- ������������ ���������� ��������
process (clk_bus)
begin
	if clk_bus'event and clk_bus = '0' then
		ena_cnt <= ena_cnt + 1;
	end if;
end process;

ena_14mhz <= ena_cnt(0);
ena_7mhz <= ena_cnt(1) and ena_cnt(0);
ena_3_5mhz <= ena_cnt(2) and ena_cnt(1) and ena_cnt(0);
ena_1_75mhz <= ena_cnt(3) and ena_cnt(2) and ena_cnt(1) and ena_cnt(0);
ena_0_4375mhz <= ena_cnt(5) and ena_cnt(4) and ena_cnt(3) and ena_cnt(2) and ena_cnt(1) and ena_cnt(0);

areset <= not RST_n;							-- ���������� �����
reset <= areset or key_reset or not locked;		-- ������� �����
cpu0_reset_n <= not(reset) and not(kb_f_bus(4));-- CPU �����
cpu0_inta_n <= cpu0_iorq_n or cpu0_m1_n;		-- INTA
cpu0_nmi_n	<= kb_f_bus(5);						-- NMI

-------------------------------------------------------------------------------
-- SDRAM
--sdr_wr <= '1' when cpu0_mreq_n = '0' and cpu0_wr_n = '0' and ((mux = "1001" and (divmmc_e3reg(1 downto 0) /= "11" and divmmc_e3reg(6) /= '1')) or mux(3 downto 2) = "11" or mux(3 downto 2) = "01" or mux(3 downto 1) = "101" or mux(3 downto 1) = "001") else '0';
sdr_wr <= '1' when cpu0_mreq_n = '0' and cpu0_wr_n = '0' and (mux = "1001" or mux(3 downto 2) = "11" or mux(3 downto 2) = "01" or mux(3 downto 1) = "101" or mux(3 downto 1) = "001") else '0';
sdr_rd <= not (cpu0_mreq_n or cpu0_rd_n);
sdr_rfsh <= not cpu0_rfsh_n;

-------------------------------------------------------------------------------
-- ��������
cpuclk <= clk_bus and cpu0_ena;
cpu0_mult <= key_f(9) & key_f(3);	-- 00 = 3.5MHz; 01 = 7.0MHz; 10 = 7MHz; 11 = 14MHz
process (cpu0_mult, ena_3_5mhz, ena_7mhz, ena_14mhz)
begin
	case cpu0_mult is
		when "00" => cpu0_ena <= ena_3_5mhz;
		when "01" => cpu0_ena <= ena_7mhz;
		when "10" => cpu0_ena <= ena_7mhz;
		when "11" => cpu0_ena <= ena_14mhz;
		when others => null;
	end case;
end process;

-------------------------------------------------------------------------------
-- SD					
SD_DAT3	<= divmmc_cs_n when key_f(6) = '1' else zc_cs_n;
SD_CLK 	<= divmmc_sclk when key_f(6) = '1' else zc_sclk;
SD_CMD 	<= divmmc_mosi when key_f(6) = '1' else zc_mosi;

-------------------------------------------------------------------------------
-- ��������
process (areset, clk_bus, cpu0_a_bus, port_0000_reg, cpu0_mreq_n, cpu0_wr_n, cpu0_do_bus, port_0001_reg)
begin
	if areset = '1' then
		port_0000_reg <= (others => '0');	-- ����� �� AND ����� #DFFD
		port_0001_reg <= (others => '0');	-- bit2 = 0:Loader ON, 1:Loader OFF; bit1 = 0:SRAM<->CPU0, 1:SRAM<->GS; bit0 = 0:TDA1543, 1:M25P40
		loader_act <= '1';
	elsif clk_bus'event and clk_bus = '1' then
		if cpu0_iorq_n = '0' and cpu0_wr_n = '0' and cpu0_a_bus(15 downto 0) = X"0000" then port_0000_reg <= cpu0_do_bus; end if;
		if cpu0_iorq_n = '0' and cpu0_wr_n = '0' and cpu0_a_bus(15 downto 0) = X"0001" then port_0001_reg <= cpu0_do_bus; end if;
		if cpu0_m1_n = '0' and cpu0_mreq_n = '0' and cpu0_a_bus = X"0000" and port_0001_reg(2) = '1' then loader_act <= '0'; end if;
	end if;
end process;

process (reset, clk_bus, cpu0_a_bus, dos_act, port_1ffd_reg, port_7ffd_reg, port_dffd_reg, cpu0_mreq_n, cpu0_wr_n, cpu0_do_bus)
begin
	if reset = '1' then
		port_eff7_reg <= (others => '0');
		port_1ffd_reg <= (others => '0');
		port_7ffd_reg <= (others => '0');
		port_dffd_reg <= (others => '0');
		dos_act <= '1';
	elsif clk_bus'event and clk_bus = '1' then
		if cpu0_iorq_n = '0' and cpu0_wr_n = '0' and cpu0_a_bus(7 downto 0) = X"FE" then port_xxfe_reg <= cpu0_do_bus; end if;
		if cpu0_iorq_n = '0' and cpu0_wr_n = '0' and cpu0_a_bus = X"EFF7" then port_eff7_reg <= cpu0_do_bus; end if;
		if cpu0_iorq_n = '0' and cpu0_wr_n = '0' and cpu0_a_bus = X"1FFD" then port_1ffd_reg <= cpu0_do_bus; end if;
		if cpu0_iorq_n = '0' and cpu0_wr_n = '0' and cpu0_a_bus = X"7FFD" and port_7ffd_reg(5) = '0' then port_7ffd_reg <= cpu0_do_bus; end if;
		if cpu0_iorq_n = '0' and cpu0_wr_n = '0' and cpu0_a_bus = X"DFFD" and port_7ffd_reg(5) = '0' then port_dffd_reg <= cpu0_do_bus; end if;
		if cpu0_iorq_n = '0' and cpu0_wr_n = '0' and cpu0_a_bus = X"DFF7" and port_eff7_reg(7) = '1' then mc146818_a_bus <= cpu0_do_bus(5 downto 0); end if;
		if cpu0_m1_n = '0' and cpu0_mreq_n = '0' and cpu0_a_bus(15 downto 8) = X"3D" and port_7ffd_reg(4) = '1' then dos_act <= '1';
		elsif cpu0_m1_n = '0' and cpu0_mreq_n = '0' and cpu0_a_bus(15 downto 14) /= "00" then dos_act <= '0'; end if;
	end if;
end process;

------------------------------------------------------------------------------
-- ��������
mux <= ((divmmc_amap or divmmc_e3reg(7)) and key_f(6)) & cpu0_a_bus(15 downto 13);

process (mux, port_7ffd_reg, port_dffd_reg, port_0000_reg, ram_a_bus, cpu0_a_bus, dos_act, port_1ffd_reg, divmmc_e3reg, key_f)
begin
	case mux is
--		when "1000" => ram_a_bus <= "10000" & not(divmmc_e3reg(6)) & "00" & not(divmmc_e3reg(6)) & '0' & divmmc_e3reg(6) & divmmc_e3reg(6);	-- ESXDOS ROM 0000-1FFF
		when "0000" => ram_a_bus <= "100001000" & ((not(dos_act) and not(port_1ffd_reg(1))) or key_f(6)) & (port_7ffd_reg(4) and not(port_1ffd_reg(1))) & '0';	-- Seg0 ROM 0000-1FFF
		when "0001" => ram_a_bus <= "100001000" & ((not(dos_act) and not(port_1ffd_reg(1))) or key_f(6)) & (port_7ffd_reg(4) and not(port_1ffd_reg(1))) & '1';	-- Seg0 ROM 2000-3FFF
		when "1000" => ram_a_bus <= "100001001000";	-- ESXDOS ROM 0000-1FFF
		when "1001" => ram_a_bus <= "100000" & divmmc_e3reg(5 downto 0);	-- ESXDOS RAM 2000-3FFF
		when "0010"|"1010" => ram_a_bus <= "000000001010";	-- Seg1 RAM 4000-5FFF
		when "0011"|"1011" => ram_a_bus <= "000000001011";	-- Seg1 RAM 6000-7FFF
		when "0100"|"1100" => ram_a_bus <= "000000000100";	-- Seg2 RAM 8000-9FFF
		when "0101"|"1101" => ram_a_bus <= "000000000101";	-- Seg2 RAM A000-BFFF
		when "0110"|"1110" => ram_a_bus <= (port_dffd_reg and port_0000_reg) & port_7ffd_reg(2 downto 0) & '0';	-- Seg3 RAM C000-DFFF
		when "0111"|"1111" => ram_a_bus <= (port_dffd_reg and port_0000_reg) & port_7ffd_reg(2 downto 0) & '1';	-- Seg3 RAM E000-FFFF
		when others => null;
	end case;
end process;

-------------------------------------------------------------------------------
-- SRAM <- GS/SYS
process (cpu0_a_bus, port_0001_reg, cpu0_mreq_n, cpu0_wr_n, cpu0_do_bus, gs_mwe_n, gs_mdo, gs_ma)
begin
	if port_0001_reg(2) = '0' then
		if cpu0_mreq_n = '0' and cpu0_wr_n = '0' then
			SRAM_D <= cpu0_do_bus;
		else
			SRAM_D <= (others => 'Z');
		end if;
		SRAM_A		<= "0000" & cpu0_a_bus(14 downto 0);
		SRAM_WE_n	<= cpu0_mreq_n or cpu0_wr_n or not cpu0_a_bus(15);
	else
		if gs_mwe_n = '0' then
			SRAM_D 	<= gs_mdo;
		else
			SRAM_D 	<= (others => 'Z');
		end if;
		SRAM_A		<= gs_ma;
		SRAM_WE_n	<= gs_mwe_n;
	end if;
end process;

SRAM_OE_n	<= '0';

-------------------------------------------------------------------------------
-- TDA1543 <> MP25P40
process (port_0001_reg, spi_si, spi_clk, spi_cs_n, dac_data, dac_ws)
begin
	if port_0001_reg(0) = '0' then
		ASDO 		<= dac_data;
		DCLK 		<= dac_ws;
		NCSO		<= '1';
	else
		ASDO 		<= spi_si;
		DCLK 		<= spi_clk;
		NCSO		<= spi_cs_n;
	end if;
end process;



-------------------------------------------------------------------------------
-- Audio mixer
audio_l <= ("000" & port_xxfe_reg(4) & "00000000000") + ("000" & ssg_cn0_a & "0000") + ("000" & ssg_cn0_b & "0000") + ("000" & ssg_cn1_a & "0000") + ("000" & ssg_cn1_b & "0000") + ("000" & covox_a & "0000") + ("000" & covox_b & "0000") + ("00" & gs_a) + ("00" & gs_b);
audio_r <= ("000" & port_xxfe_reg(4) & "00000000000") + ("000" & ssg_cn0_c & "0000") + ("000" & ssg_cn0_b & "0000") + ("000" & ssg_cn1_c & "0000") + ("000" & ssg_cn1_b & "0000") + ("000" & covox_c & "0000") + ("000" & covox_d & "0000") + ("00" & gs_c) + ("00" & gs_d);


-------------------------------------------------------------------------------
-- Port I/O
rtc_wr 			<= '1' when (cpu0_a_bus(7 downto 5) = "100" and cpu0_a_bus(3 downto 0) = "1100" and cpu0_wr_n = '0' and cpu0_iorq_n = '0') else '0';	-- Port xx8C/xx9C[xxxxxxxx_100n1100]
mc146818_wr 	<= '1' when (port_bff7 = '1' and cpu0_wr_n = '0') else '0';
port_bff7 		<= '1' when (cpu0_iorq_n = '0' and cpu0_a_bus = X"BFF7" and cpu0_m1_n = '1' and port_eff7_reg(7) = '1') else '0';
spi_wr 			<= '1' when (cpu0_iorq_n = '0' and cpu0_wr_n = '0' and cpu0_a_bus(7 downto 1) = "0000001") else '0';
uart_wr 		<= '1' when (cpu0_iorq_n = '0' and cpu0_wr_n = '0' and cpu0_a_bus(7 downto 0) = X"BC") else '0';	-- Port xxBC[xxxxxxxx_10111100]
uart_rd 		<= '1' when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus(7 downto 0) = X"BC") else '0';	-- Port xxBC[xxxxxxxx_10111100]
ms_left 		<= not(ms_left) when (ms_but_bus(1)'event and ms_but_bus(1) = '1' and ms_but_bus(0) = '1');
zc_wr 			<= '1' when (cpu0_iorq_n = '0' and cpu0_wr_n = '0' and cpu0_a_bus(7 downto 6) = "01" and cpu0_a_bus(4 downto 0) = "10111") else '0';
zc_rd 			<= '1' when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus(7 downto 6) = "01" and cpu0_a_bus(4 downto 0) = "10111") else '0';


-------------------------------------------------------------------------------
-- �������������� ������� Fx

-- F3 = 3.5/7.0MHz, F4 = CPU RESET, F5 = NMI, F6 = divMMC, F7 = �����, F8 = ������������ ����������, F9 = turbo 7.0/14.0MHz, F11 = soundrive, F12 = ����� ����� 0: Spectrum; 1: Pentagon;
process (clk_bus, key, kb_f_bus, key_f)
begin
	if (clk_bus'event and clk_bus = '1') then
		key <= kb_f_bus;
		if (kb_f_bus /= key) then
			key_f <= key_f xor key;
		end if;
	end if;
end process;

-------------------------------------------------------------------------------
-- ���� ������ CPU0
process (selector, rom_do_bus, SRAM_D, sdr_do_bus, spi_do_bus, spi_busy, rtc_do_bus, mc146818_do_bus, kb_do_bus, zc_do_bus, ms_but_bus, ms_x_bus, ms_y_bus, kb_joy_bus, ssg_cn0_bus, ssg_cn1_bus, uart_tx_busy, CBUS4, uart_rx_error,
		 uart_rx_avail, uart_do_bus, gs_do_bus, divmmc_do, port_7ffd_reg, port_dffd_reg)
begin
	case selector is
		when "00000" => cpu0_di_bus <= rom_do_bus;
		when "00001" => cpu0_di_bus <= SRAM_D;
		when "00010" => cpu0_di_bus <= sdr_do_bus;
		when "00011" => cpu0_di_bus <= spi_do_bus;
		when "00100" => cpu0_di_bus <= spi_busy & "1111111";
		when "00101" => cpu0_di_bus <= rtc_do_bus;
		when "00110" => cpu0_di_bus <= mc146818_do_bus;
		when "00111" => cpu0_di_bus <= "111" & kb_do_bus;
		when "01000" => cpu0_di_bus <= zc_do_bus;
		when "01001" => cpu0_di_bus <= ms_but_bus(7 downto 4) & '1' & not(ms_but_bus(2) & ms_but_bus(0) & ms_but_bus(1));
		when "01010" => cpu0_di_bus <= ms_but_bus(7 downto 4) & '1' & not(ms_but_bus(2) & ms_but_bus(1) & ms_but_bus(0));
		when "01011" => cpu0_di_bus <= ms_x_bus;
		when "01100" => cpu0_di_bus <= ms_y_bus;
		when "01101" => cpu0_di_bus <= "000" & kb_joy_bus;
		when "01110" => cpu0_di_bus <= ssg_cn0_bus;
		when "01111" => cpu0_di_bus <= ssg_cn1_bus;
		when "10000" => cpu0_di_bus <= uart_tx_busy & CBUS4 & "1111" & uart_rx_error & uart_rx_avail;
		when "10001" => cpu0_di_bus <= uart_do_bus;
		when "10010" => cpu0_di_bus <= gs_do_bus;
		when "10011" => cpu0_di_bus <= divmmc_do;
		when "10100" => cpu0_di_bus <= port_7ffd_reg;
		when "10101" => cpu0_di_bus <= port_dffd_reg;
--		when "10110" => cpu0_di_bus <= vid_attr;
		when others  => cpu0_di_bus <= (others => '1');
	end case;
end process;

selector <= "00000" when (cpu0_mreq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus(15 downto 14) = "00" and loader_act = '1') else
			"00001" when (cpu0_mreq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus(15) = '1' and port_0001_reg(2) = '0') else
			"00010" when (cpu0_mreq_n = '0' and cpu0_rd_n = '0') else 																				-- MT48LC32M82A-75
			"00011" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus( 7 downto 0) = X"02") else 											-- M25P40
			"00100" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus( 7 downto 0) = X"03") else 											-- M25P40
			"00101" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus( 7 downto 5) = "100" and cpu0_a_bus(3 downto 0) = "1100") else 		-- PCF8583
			"00110" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and port_bff7 = '1' and port_eff7_reg(7) = '1') else 								-- MC146818A
			"00111" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus( 7 downto 0) = X"FE") else 											-- ����������, ���� xxFE
			"01000" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus( 7 downto 6) = "01" and cpu0_a_bus(4 downto 0) = "10111") else 		-- Z-Controller
			"01001" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus(15 downto 0) = X"FADF" and ms_present = '1' and ms_left = '0') else 	-- Mouse Port FADF[11111010_11011111] = <Z>1<MB><LB><RB>
			"01010" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus(15 downto 0) = X"FADF" and ms_present = '1' and ms_left = '1') else
			"01011" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus(15 downto 0) = X"FBDF" and ms_present = '1') else					-- Port FBDF[11111011_11011111] = <X>
			"01100" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus(15 downto 0) = X"FFDF" and ms_present = '1') else					-- Port FFDF[11111111_11011111] = <Y>
			"01101" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus( 7 downto 0) = X"1F" and dos_act = '0' and kb_num = '1') else 		-- Joystick, ���� xx1F
			"01110" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus(15 downto 0) = X"FFFD" and ssg_sel = '0') else 						-- TurboSound
			"01111" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus(15 downto 0) = X"FFFD" and ssg_sel = '1') else
			"10000" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus( 7 downto 0) = X"AC") else											-- UART
			"10001" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus( 7 downto 0) = X"BC") else
			"10010" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus( 7 downto 4) = "1011" and cpu0_a_bus(2 downto 0) = "011") else		-- General Sound
			"10011" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus( 7 downto 0) = X"EB" and key_f(6) = '1') else						-- DivMMC
			"10100" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus(15 downto 0) = X"7FFD") else											-- ������ ����� 7FFD
			"10101" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus(15 downto 0) = X"DFFD") else											-- ������ ����� DFFD
--			"10110" when (cpu0_iorq_n = '0' and cpu0_rd_n = '0' and cpu0_a_bus( 7 downto 0) = X"FF" and vid_border = '1') else						-- ���� ��������� #FF
			(others => '1');

-------------------------------------------------------------------------------
-- Video
vid_wr		<= '1' when cpu0_mreq_n = '0' and cpu0_wr_n = '0' and ((ram_a_bus = "000000001010") or (ram_a_bus = "000000001110")) else '0'; 
vid_scr		<= '1' when (ram_a_bus = "000000001110") else '0';

process (key_f(8), rgb, vid_hsync, vid_vsync, cntr_rgb, cntr_hs, cntr_vs)
begin
	if (key_f(8) = '0') then
		VGA_R		<= rgb(5) & rgb(5 downto 4);
		VGA_G		<= rgb(3) & rgb(3 downto 2);
		VGA_B		<= rgb(1) & rgb(1 downto 0);
		VGA_HSYNC 	<= vid_hsync;
		VGA_VSYNC 	<= vid_vsync;
	else
		VGA_R		<= cntr_rgb(5) & cntr_rgb(5 downto 4);
		VGA_G		<= cntr_rgb(3) & cntr_rgb(3 downto 2);
		VGA_B		<= cntr_rgb(1) & cntr_rgb(1 downto 0);
		VGA_HSYNC 	<= cntr_hs;
		VGA_VSYNC 	<= cntr_vs;
	end if;
end process;


-------------------------------------------------------------------------------
-- ������������ ����������

-- IO
process (reset, clk_bus, cntr_rd, cntr_io_flag)
begin
	if (cntr_rd = '1' or reset = '1') then
		cntr_io_flag <= '0';
	elsif (clk_bus'event and clk_bus = '1') then
		if (cpu0_iorq_n = '0' and cpu0_m1_n = '1' and cntr_io_flag = '0') then
			cntr_addr_reg <= cpu0_a_bus;
			cntr_data_reg <= cpu0_do_bus;
			cntr_io_flag <= '1';
		end if;
	end if;
end process;

end u9speccy_arch;