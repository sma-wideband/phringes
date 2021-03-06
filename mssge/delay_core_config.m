
function delay_core_config(this_block)

  % Revision History:
  %
  %   12-Jan-2011  (12:21 hours):
  %     Original code was machine generated by Xilinx's System Generator after parsing
  %     G:\CASPER\projects\carma\vlbi\phringes\mssge\delay_core.vhd
  %
  %

  this_block.setTopLevelLanguage('VHDL');

  this_block.setEntityName('delay_core');

  this_block.addSimulinkInport('in0');
  this_block.addSimulinkInport('in1');
  this_block.addSimulinkInport('in2');
  this_block.addSimulinkInport('in3');
  this_block.addSimulinkInport('delay');
  this_block.addSimulinkInport('sb_sel');

  this_block.addSimulinkOutport('z0_re');
  this_block.addSimulinkOutport('z0_im');
  this_block.addSimulinkOutport('z2_re');
  this_block.addSimulinkOutport('z2_im');
  this_block.addSimulinkOutport('ph_comp');

  z0_re_port = this_block.port('z0_re');
  z0_re_port.setType('Fix_25_22');
  z0_im_port = this_block.port('z0_im');
  z0_im_port.setType('Fix_25_22');
  z2_re_port = this_block.port('z2_re');
  z2_re_port.setType('Fix_25_22');
  z2_im_port = this_block.port('z2_im');
  z2_im_port.setType('Fix_25_22');
  ph_comp_port = this_block.port('ph_comp');
  ph_comp_port.setType('UFix_2_0');

  % -----------------------------
  if (this_block.inputTypesKnown)
    % do input type checking, dynamic output type and generic setup in this code block.

    if (this_block.port('delay').width ~= 17);
      this_block.setError('Input data type for port "delay" must have width=17.');
    end

    if (this_block.port('in0').width ~= 8);
      this_block.setError('Input data type for port "in0" must have width=8.');
    end

    if (this_block.port('in1').width ~= 8);
      this_block.setError('Input data type for port "in1" must have width=8.');
    end

    if (this_block.port('in2').width ~= 8);
      this_block.setError('Input data type for port "in2" must have width=8.');
    end

    if (this_block.port('in3').width ~= 8);
      this_block.setError('Input data type for port "in3" must have width=8.');
    end

    if (this_block.port('sb_sel').width ~= 1);
      this_block.setError('Input data type for port "sb_sel" must have width=1.');
    end

    this_block.port('sb_sel').useHDLVector(false);

  end  % if(inputTypesKnown)
  % -----------------------------

  % -----------------------------
   if (this_block.inputRatesKnown)
     setup_as_single_rate(this_block,'clk_1','ce_1')
   end  % if(inputRatesKnown)
  % -----------------------------

    % (!) Set the inout port rate to be the same as the first input 
    %     rate. Change the following code if this is untrue.
    uniqueInputRates = unique(this_block.getInputRates);


  % Add addtional source files as needed.
  %  |-------------
  %  | Add files in the order in which they should be compiled.
  %  | If two files "a.vhd" and "b.vhd" contain the entities
  %  | entity_a and entity_b, and entity_a contains a
  %  | component of type entity_b, the correct sequence of
  %  | addFile() calls would be:
  %  |    this_block.addFile('b.vhd');
  %  |    this_block.addFile('a.vhd');
  %  |-------------

  %    this_block.addFile('');
  %    this_block.addFile('');
  this_block.addFile('delay_core.vhd');

return;


% ------------------------------------------------------------

function setup_as_single_rate(block,clkname,cename) 
  inputRates = block.inputRates; 
  uniqueInputRates = unique(inputRates); 
  if (length(uniqueInputRates)==1 & uniqueInputRates(1)==Inf) 
    block.addError('The inputs to this block cannot all be constant.'); 
    return; 
  end 
  if (uniqueInputRates(end) == Inf) 
     hasConstantInput = true; 
     uniqueInputRates = uniqueInputRates(1:end-1); 
  end 
  if (length(uniqueInputRates) ~= 1) 
    block.addError('The inputs to this block must run at a single rate.'); 
    return; 
  end 
  theInputRate = uniqueInputRates(1); 
  for i = 1:block.numSimulinkOutports 
     block.outport(i).setRate(theInputRate); 
  end 
  block.addClkCEPair(clkname,cename,theInputRate); 
  return; 

% ------------------------------------------------------------

