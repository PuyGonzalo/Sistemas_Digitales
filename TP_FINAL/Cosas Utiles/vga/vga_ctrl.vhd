---------------------------------------------------------
--
-- Controlador de VGA
-- Version actualizada a 07/06/2016
--
-- Modulos:
--    vga_sync
--    gen_pixels
--
---------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_ctrl is
	port(
		clk, rst: in std_logic;
		sw: in std_logic_vector (2 downto 0);
		hsync , vsync : out std_logic;
		rgb : out std_logic_vector(7 downto 0)
    );
    
	-- Mapeo de pines
	attribute LOC: string;
	attribute LOC of clk: signal is "B8";
	attribute LOC of rst: signal is "B18";
	attribute LOC of sw: signal is "K18 H18 G18";
	attribute LOC of hsync: signal is "T4";
	attribute LOC of vsync: signal is "U3";
	attribute LOC of rgb: signal is "R9 T8 R8 N8 P8 P6 U5 U4";

end vga_ctrl;

architecture vga_ctrl_arch of vga_ctrl is

	signal rgb_reg: std_logic_vector(2 downto 0);
	signal pixel_x, pixel_y: std_logic_vector(9 downto 0);
	signal video_on: std_logic;
	signal rgb_aux: std_logic_vector(2 downto 0);

begin

	-- instanciacion del controlador VGA
	vga_sync_unit: entity work.vga_sync
		port map(
			clk 	=> clk,
			rst 	=> rst,
			hsync 	=> hsync,
			vsync 	=> vsync,
			vidon	=> video_on,
			p_tick 	=> open,
			pixel_x => pixel_x,
			pixel_y => pixel_y
		);

	pixeles: entity work.gen_pixels
		port map(
			clk		=> clk,
			reset	=> rst,
			sw		=> sw,
			pixel_x	=> pixel_x,
			pixel_y	=> pixel_y,
			ena		=> video_on,
			rgb		=> rgb_aux		-- 101	-->  111 000 11
		);
		
	rgb <= (0 to 2 => rgb_aux(2)) & (0 to 2 => rgb_aux(1)) & (0 to 1 => rgb_aux(0));

end vga_ctrl_arch;