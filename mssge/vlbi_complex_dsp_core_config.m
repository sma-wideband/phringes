
function vlbi_complex_dsp_core_config(this_block)

  % Revision History:
  %
  %   20-Jan-2011  (15:47 hours):
  %     Original code was machine generated by Xilinx's System Generator after parsing
  %     G:\CASPER\projects\carma\vlbi\phringes\mssge\vlbi_complex_dsp_core.vhd
  %
  %

  this_block.setTopLevelLanguage('VHDL');

  this_block.setEntityName('vlbi_complex_dsp_core');

  this_block.addSimulinkInport('shift_ctrl');
  this_block.addSimulinkInport('re0');
  this_block.addSimulinkInport('im0');
  this_block.addSimulinkInport('re1');
  this_block.addSimulinkInport('im1');
  this_block.addSimulinkInport('sync_in');
  this_block.addSimulinkInport('gain0');
  this_block.addSimulinkInport('gain1');

  this_block.addSimulinkOutport('sync_out');
  this_block.addSimulinkOutport('real_out');
  this_block.addSimulinkOutport('interp_out');
  this_block.addSimulinkOutport('gain_sync');

  sync_out_port = this_block.port('sync_out');
  sync_out_port.setType('Bool');
  sync_out_port.useHDLVector(false);
  real_out_port = this_block.port('real_out');
  real_out_port.setType('UFix_4_0');
  interp_out_port = this_block.port('interp_out');
  interp_out_port.setType('UFix_4_0');
  gain_sync_port = this_block.port('gain_sync');
  gain_sync_port.setType('Bool');
  gain_sync_port.useHDLVector(false);

  % -----------------------------
  if (this_block.inputTypesKnown)
    % do input type checking, dynamic output type and generic setup in this code block.

    if (this_block.port('gain0').width ~= 32);
      this_block.setError('Input data type for port "gain0" must have width=32.');
    end

    if (this_block.port('gain1').width ~= 32);
      this_block.setError('Input data type for port "gain1" must have width=32.');
    end

    if (this_block.port('im0').width ~= 8);
      this_block.setError('Input data type for port "im0" must have width=8.');
    end

    if (this_block.port('im1').width ~= 8);
      this_block.setError('Input data type for port "im1" must have width=8.');
    end

    if (this_block.port('re0').width ~= 8);
      this_block.setError('Input data type for port "re0" must have width=8.');
    end

    if (this_block.port('re1').width ~= 8);
      this_block.setError('Input data type for port "re1" must have width=8.');
    end

    if (this_block.port('shift_ctrl').width ~= 32);
      this_block.setError('Input data type for port "shift_ctrl" must have width=32.');
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
  this_block.addFile('vlbi_complex_dsp_core.vhd');

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

