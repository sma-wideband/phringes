library IEEE;
use IEEE.std_logic_1164.all;

entity vlbi_dsp_core is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    din0: in std_logic_vector(7 downto 0); 
    din1: in std_logic_vector(7 downto 0); 
    din2: in std_logic_vector(7 downto 0); 
    din3: in std_logic_vector(7 downto 0); 
    gain0: in std_logic_vector(31 downto 0); 
    gain1: in std_logic_vector(31 downto 0); 
    shift_ctrl: in std_logic_vector(31 downto 0); 
    sync_in: in std_logic; 
    gain_sync: out std_logic; 
    interp_out: out std_logic_vector(3 downto 0); 
    real_out: out std_logic_vector(3 downto 0); 
    sync_out: out std_logic
  );
end vlbi_dsp_core;
