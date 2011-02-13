library IEEE;
use IEEE.std_logic_1164.all;

entity complex_cc_core is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in0_i0: in std_logic_vector(1 downto 0); 
    in0_i1: in std_logic_vector(1 downto 0); 
    in0_r0: in std_logic_vector(1 downto 0); 
    in0_r1: in std_logic_vector(1 downto 0); 
    in0_w: in std_logic; 
    in1_i0: in std_logic_vector(1 downto 0); 
    in1_i1: in std_logic_vector(1 downto 0); 
    in1_r0: in std_logic_vector(1 downto 0); 
    in1_r1: in std_logic_vector(1 downto 0); 
    in1_w: in std_logic; 
    integ_time: in std_logic_vector(31 downto 0); 
    sync_in: in std_logic; 
    wdelay: in std_logic_vector(5 downto 0); 
    addr: out std_logic_vector(3 downto 0); 
    integs: out std_logic_vector(31 downto 0); 
    lsb_data_im: out std_logic_vector(31 downto 0); 
    lsb_data_re: out std_logic_vector(31 downto 0); 
    phsw_bal: out std_logic_vector(31 downto 0); 
    sample_cnt: out std_logic_vector(31 downto 0); 
    subint_cnt: out std_logic_vector(31 downto 0); 
    usb_data_im: out std_logic_vector(31 downto 0); 
    usb_data_re: out std_logic_vector(31 downto 0); 
    we: out std_logic
  );
end complex_cc_core;
