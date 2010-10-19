
function vsi_fmt_core_config(this_block)

  % Revision History:
  %
  %   19-Oct-2010  (01:32 hours):
  %     Original code was machine generated by Xilinx's System Generator after parsing
  %     G:\CASPER\projects\carma\vlbi\phringes\mssge\vsi_fmt_core.vhd
  %
  %

  this_block.setTopLevelLanguage('VHDL');

  this_block.setEntityName('vsi_fmt_core');

  % System Generator has to assume that your entity  has a combinational feed through; 
  %   if it  doesn't, then comment out the following line:
  %this_block.tagAsCombinational;

  this_block.addSimulinkInport('sync_in');
  this_block.addSimulinkInport('pol0_real');
  this_block.addSimulinkInport('pol0_interp');
  this_block.addSimulinkInport('pol1_real');
  this_block.addSimulinkInport('pol1_interp');
  this_block.addSimulinkInport('outsel');
  this_block.addSimulinkInport('freqsel');

  this_block.addSimulinkOutport('vsi0_bs');
  this_block.addSimulinkOutport('vsi1_bs');
  this_block.addSimulinkOutport('vsi_clk');
  this_block.addSimulinkOutport('vsi_1pps');

  vsi0_bs_port = this_block.port('vsi0_bs');
  vsi0_bs_port.setType('UFix_32_0');
  vsi1_bs_port = this_block.port('vsi1_bs');
  vsi1_bs_port.setType('UFix_32_0');
  vsi_clk_port = this_block.port('vsi_clk');
  vsi_clk_port.setType('UFix_1_0');
  vsi_clk_port.useHDLVector(false);
  vsi_1pps_port = this_block.port('vsi_1pps');
  vsi_1pps_port.setType('Bool');
  vsi_1pps_port.useHDLVector(false);

  % -----------------------------
  if (this_block.inputTypesKnown)
    % do input type checking, dynamic output type and generic setup in this code block.

    if (this_block.port('freqsel').width ~= 3);
      this_block.setError('Input data type for port "freqsel" must have width=3.');
    end

    if (this_block.port('outsel').width ~= 2);
      this_block.setError('Input data type for port "outsel" must have width=2.');
    end

    if (this_block.port('pol0_interp').width ~= 4);
      this_block.setError('Input data type for port "pol0_interp" must have width=4.');
    end

    if (this_block.port('pol0_real').width ~= 4);
      this_block.setError('Input data type for port "pol0_real" must have width=4.');
    end

    if (this_block.port('pol1_interp').width ~= 4);
      this_block.setError('Input data type for port "pol1_interp" must have width=4.');
    end

    if (this_block.port('pol1_real').width ~= 4);
      this_block.setError('Input data type for port "pol1_real" must have width=4.');
    end

    if (this_block.port('sync_in').width ~= 1);
      this_block.setError('Input data type for port "sync_in" must have width=1.');
    end

    this_block.port('sync_in').useHDLVector(false);

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
  this_block.addFile('vsi_fmt_core.vhd');

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

