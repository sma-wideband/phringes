
function complex_cc_core_config(this_block)

  % Revision History:
  %
  %   See Git logs.
  %
  %

  this_block.setTopLevelLanguage('VHDL');

  this_block.setEntityName('complex_cc_core');

  % System Generator has to assume that your entity  has a combinational feed through; 
  %   if it  doesn't, then comment out the following line:
  %this_block.tagAsCombinational;

  this_block.addSimulinkInport('sync_in');
  this_block.addSimulinkInport('in0_r0'); % input 0, sample 0, real
  this_block.addSimulinkInport('in0_i0'); % input 0, sample 0, imag
  this_block.addSimulinkInport('in0_r1'); % input 0, sample 1, real
  this_block.addSimulinkInport('in0_i1'); % input 0, sample 1, imag
  this_block.addSimulinkInport('in0_w');  % input 0, walsh state (0=I; 1=Q)
  this_block.addSimulinkInport('in1_r0'); % input 1, sample 0, real
  this_block.addSimulinkInport('in1_i0'); % input 1, sample 0, imag
  this_block.addSimulinkInport('in1_r1'); % input 1, sample 1, real
  this_block.addSimulinkInport('in1_i1'); % input 1, sample 1, imag
  this_block.addSimulinkInport('in1_w');  % input 1, walsh state (0=I; 1=Q)
  this_block.addSimulinkInport('integ_time');
  this_block.addSimulinkInport('wdelay');

  this_block.addSimulinkOutport('addr');
  this_block.addSimulinkOutport('usb_data_re');
  this_block.addSimulinkOutport('usb_data_im');
  this_block.addSimulinkOutport('lsb_data_re');
  this_block.addSimulinkOutport('lsb_data_im');
  this_block.addSimulinkOutport('we');
  this_block.addSimulinkOutport('integs');
  this_block.addSimulinkOutport('sample_cnt');
  this_block.addSimulinkOutport('subint_cnt');
  this_block.addSimulinkOutport('phsw_bal');

  addr_port = this_block.port('addr');
  addr_port.setType('UFix_4_0');
  real_data_port = this_block.port('usb_data_re');
  real_data_port.setType('UFix_32_0');
  imag_data_port = this_block.port('usb_data_im');
  imag_data_port.setType('UFix_32_0');
  real_data_port = this_block.port('lsb_data_re');
  real_data_port.setType('UFix_32_0');
  imag_data_port = this_block.port('lsb_data_im');
  imag_data_port.setType('UFix_32_0');
  we_port = this_block.port('we');
  we_port.setType('Bool');
  we_port.useHDLVector(false);
  integs_port = this_block.port('integs');
  integs_port.setType('UFix_32_0');
  sample_cnt_port = this_block.port('sample_cnt');
  sample_cnt_port.setType('UFix_32_0');
  subint_cnt_port = this_block.port('subint_cnt');
  subint_cnt_port.setType('UFix_32_0');
  phsw_bal_port = this_block.port('phsw_bal');
  phsw_bal_port.setType('Fix_32_0');

  % -----------------------------
  if (this_block.inputTypesKnown)
    % do input type checking, dynamic output type and generic setup in this code block.

    if (this_block.port('in0_i0').width ~= 2);
      this_block.setError('Input data type for port "in0_i0" must have width=2.');
    end

    if (this_block.port('in0_i1').width ~= 2);
      this_block.setError('Input data type for port "in0_i1" must have width=2.');
    end

    if (this_block.port('in0_r0').width ~= 2);
      this_block.setError('Input data type for port "in0_r0" must have width=2.');
    end

    if (this_block.port('in0_r1').width ~= 2);
      this_block.setError('Input data type for port "in0_r1" must have width=2.');
    end

    if (this_block.port('integ_time').width ~= 32);
      this_block.setError('Input data type for port "integ_time" must have width=32.');
    end

    if (this_block.port('in1_i0').width ~= 2);
      this_block.setError('Input data type for port "in1_i0" must have width=2.');
    end

    if (this_block.port('in1_i1').width ~= 2);
      this_block.setError('Input data type for port "in1_i1" must have width=2.');
    end

    if (this_block.port('in1_r0').width ~= 2);
      this_block.setError('Input data type for port "in1_r0" must have width=2.');
    end

    if (this_block.port('in1_r1').width ~= 2);
      this_block.setError('Input data type for port "in1_r1" must have width=2.');
    end

    if (this_block.port('sync_in').width ~= 1);
      this_block.setError('Input data type for port "sync_in" must have width=1.');
    end

    if (this_block.port('in0_w').width ~= 1);
      this_block.setError('Input data type for port "in0_w" must have width=1.');
    end

    if (this_block.port('in1_w').width ~= 1);
      this_block.setError('Input data type for port "in1_w" must have width=1.');
    end

    if (this_block.port('wdelay').width ~= 6);
      this_block.setError('Input data type for port "wdelay" must have width=6.');
    end

    this_block.port('sync_in').useHDLVector(false);
    this_block.port('in0_w').useHDLVector(false);
    this_block.port('in1_w').useHDLVector(false);

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
  this_block.addFile('complex_cc_core.vhd');

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

