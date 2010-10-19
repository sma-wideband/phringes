library IEEE;
use IEEE.std_logic_1164.all;

entity vsi_fmt_core is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    freqsel: in std_logic_vector(2 downto 0); 
    outsel: in std_logic_vector(1 downto 0); 
    pol0_interp: in std_logic_vector(3 downto 0); 
    pol0_real: in std_logic_vector(3 downto 0); 
    pol1_interp: in std_logic_vector(3 downto 0); 
    pol1_real: in std_logic_vector(3 downto 0); 
    sync_in: in std_logic; 
    vsi0_bs: out std_logic_vector(31 downto 0); 
    vsi1_bs: out std_logic_vector(31 downto 0); 
    vsi_1pps: out std_logic; 
    vsi_clk: out std_logic
  );
end vsi_fmt_core;
