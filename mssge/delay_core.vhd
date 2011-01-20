library IEEE;
use IEEE.std_logic_1164.all;

entity delay_core is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    delay: in std_logic_vector(16 downto 0); 
    in0: in std_logic_vector(7 downto 0); 
    in1: in std_logic_vector(7 downto 0); 
    in2: in std_logic_vector(7 downto 0); 
    in3: in std_logic_vector(7 downto 0); 
    sb_sel: in std_logic; 
    ph_comp: out std_logic_vector(1 downto 0); 
    z0_im: out std_logic_vector(24 downto 0); 
    z0_re: out std_logic_vector(24 downto 0); 
    z2_im: out std_logic_vector(24 downto 0); 
    z2_re: out std_logic_vector(24 downto 0)
  );
end delay_core;
