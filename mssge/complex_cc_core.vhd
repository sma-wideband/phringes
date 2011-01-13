library IEEE;
use IEEE.std_logic_1164.all;

entity complex_cc_core is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    i_i0: in std_logic_vector(1 downto 0); 
    i_i1: in std_logic_vector(1 downto 0); 
    i_r0: in std_logic_vector(1 downto 0); 
    i_r1: in std_logic_vector(1 downto 0); 
    integ_time: in std_logic_vector(31 downto 0); 
    q_i0: in std_logic_vector(1 downto 0); 
    q_i1: in std_logic_vector(1 downto 0); 
    q_r0: in std_logic_vector(1 downto 0); 
    q_r1: in std_logic_vector(1 downto 0); 
    sync_in: in std_logic; 
    addr: out std_logic_vector(3 downto 0); 
    imag_data: out std_logic_vector(31 downto 0); 
    integs: out std_logic_vector(31 downto 0); 
    real_data: out std_logic_vector(31 downto 0); 
    we: out std_logic
  );
end complex_cc_core;
