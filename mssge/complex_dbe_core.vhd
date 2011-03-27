library IEEE;
use IEEE.std_logic_1164.all;

entity complex_dbe_core is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in0_i0: in std_logic_vector(1 downto 0); 
    in0_i1: in std_logic_vector(1 downto 0); 
    in0_r0: in std_logic_vector(1 downto 0); 
    in0_r1: in std_logic_vector(1 downto 0); 
    in1_i0: in std_logic_vector(1 downto 0); 
    in1_i1: in std_logic_vector(1 downto 0); 
    in1_r0: in std_logic_vector(1 downto 0); 
    in1_r1: in std_logic_vector(1 downto 0); 
    integ_time: in std_logic_vector(31 downto 0); 
    sync_in: in std_logic; 
    addr: out std_logic_vector(3 downto 0); 
    data_im: out std_logic_vector(31 downto 0); 
    data_re: out std_logic_vector(31 downto 0); 
    integs: out std_logic_vector(31 downto 0); 
    sample_cnt: out std_logic_vector(31 downto 0); 
    subint_cnt: out std_logic_vector(31 downto 0); 
    we: out std_logic
  );
end complex_dbe_core;
