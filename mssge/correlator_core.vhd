library IEEE;
use IEEE.std_logic_1164.all;

entity correlator_core is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    i0: in std_logic_vector(7 downto 0); 
    i1: in std_logic_vector(7 downto 0); 
    i2: in std_logic_vector(7 downto 0); 
    i3: in std_logic_vector(7 downto 0); 
    integ_time: in std_logic_vector(31 downto 0); 
    q0: in std_logic_vector(7 downto 0); 
    q1: in std_logic_vector(7 downto 0); 
    q2: in std_logic_vector(7 downto 0); 
    q3: in std_logic_vector(7 downto 0); 
    qdelay: in std_logic_vector(10 downto 0); 
    sync_in: in std_logic; 
    addr: out std_logic_vector(4 downto 0); 
    data_in: out std_logic_vector(31 downto 0); 
    integs: out std_logic_vector(31 downto 0); 
    we: out std_logic
  );
end correlator_core;
