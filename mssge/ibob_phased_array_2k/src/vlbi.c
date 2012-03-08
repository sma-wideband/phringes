#include "xbasic_types.h"
#include "xexception_l.h"
#include "xparameters.h"
#include "xuartlite_l.h"
#include "xtime_l.h"
#include "math.h"
#include "fifo.h"
#include "core_util.h"

#include "vlbi.h"

#define PI 3.14159265
#define SID_PER_SEC (1 / 0.997270)
#define HA_RAD_PER_SID (PI / 43200)
#define HA_RAD_PER_SEC (SID_PER_SEC * HA_RAD_PER_SID)
#define HA_RAD_PER_SEC_6 (HA_RAD_PER_SEC / 1000000)
#define CLOCKS_PER_SEC XPAR_CPU_PPC405_CORE_CLOCK_FREQ_HZ

// Used for tracking source hour angle
Xfloat32 del_sec = 0;
Xfloat32 ha0 = 0;
Xfloat32 cur_ha = 0;
Xfloat32 avg_per = 0;
XTime    tbr0 = 0;
XTime    cur_tbr = 0;

// Used to store delay triplets per input
Xfloat32 deltrip[4][3] = { {0, 0, 0},
			   {0, 0, 0},
			   {0, 0, 0},
			   {0, 0, 0} };
Xfloat32 delay[4] = {0, 0, 0, 0};
Xfloat32 phase[4] = {0, 0, 0, 0};

// Used for phasing up inputs
Xfloat32 phaseoff[4] = {0, 0, 0, 0};
Xfloat32 delayoff[4] = {0, 0, 0, 0};

// Fringe stopping frequency for 
// calculating geometric phases
Xfloat32 fstop = 0;

// Misc. fringe stopping info
int total_cycles = 0;
int stop_fringes_flag = 0;

// Defined in lwipinit.c, used in bramload_cmd.
extern fifo_p input_fifo;

// Defined in Software/main.c, used in vlbi_getc.
void process_inputs(int feed_tinysh);

void arm1pps_cmd(int argc, char** argv)
/* command = "arm1pps" */
/* help    = "arm 1pps" */
/* params  = "" */
{
    Xuint32 arm;
    Xuint32 ack;

    // Get current values
    arm = sif_reg_read(XPAR_IBOB_PHASED_ARRAY_2K_ONEPPS_SYNC_ARM1PPS_BASEADDR);
    ack = sif_reg_read(XPAR_IBOB_PHASED_ARRAY_2K_ONEPPS_SYNC_ARM1PPS_ACK_BASEADDR);

    if(arm) {
      sleep(1);
      usleep(1000);
      sif_reg_write(XPAR_IBOB_PHASED_ARRAY_2K_ONEPPS_SYNC_ARM1PPS_BASEADDR, 0);
    } else if (ack) {
      /* Arm is low if we get here, so raise it */
      sif_reg_write(XPAR_IBOB_PHASED_ARRAY_2K_ONEPPS_SYNC_ARM1PPS_BASEADDR, 1);
      sleep(1);
      usleep(1000);
      sif_reg_write(XPAR_IBOB_PHASED_ARRAY_2K_ONEPPS_SYNC_ARM1PPS_BASEADDR, 0);
    }

    // arm and ack should both be low now

    // Raise arm
    sif_reg_write(XPAR_IBOB_PHASED_ARRAY_2K_ONEPPS_SYNC_ARM1PPS_BASEADDR, 1);

    xil_printf("Synchronizing internal 1PPS to external 1PPS...\n\r");

    sleep(1);

    // Check ack
    ack = sif_reg_read(XPAR_IBOB_PHASED_ARRAY_2K_ONEPPS_SYNC_ARM1PPS_ACK_BASEADDR);
    xil_printf("%sInternal 1PPS %ssynchronized to external 1PPS.\n\r",
        ack ? "" : "ERROR: ",
        ack ? "" : "NOT ");

    // Lower arm (clears ack)
    sif_reg_write(XPAR_IBOB_PHASED_ARRAY_2K_ONEPPS_SYNC_ARM1PPS_BASEADDR, 0);
}

void armsowf_cmd(int argc, char** argv)
/* command = "armsowf" */
/* help    = "arm SOWF" */
/* params  = "" */
{
    Xuint32 arm;
    Xuint32 ack;

    // Get current values
    arm = sif_reg_read(XPAR_IBOB_PHASED_ARRAY_2K_HB_SYNC_ARM_SOWF_BASEADDR);
    ack = sif_reg_read(XPAR_IBOB_PHASED_ARRAY_2K_HB_SYNC_ARMSOWF_ACK_BASEADDR);

    if(arm) {
      sleep(1);
      usleep(1000);
      sif_reg_write(XPAR_IBOB_PHASED_ARRAY_2K_HB_SYNC_ARM_SOWF_BASEADDR, 0);
    } else if (ack) {
      /* Arm is low if we get here, so raise it */
      sif_reg_write(XPAR_IBOB_PHASED_ARRAY_2K_HB_SYNC_ARM_SOWF_BASEADDR, 1);
      sleep(1);
      usleep(1000);
      sif_reg_write(XPAR_IBOB_PHASED_ARRAY_2K_HB_SYNC_ARM_SOWF_BASEADDR, 0);
    }

    // arm and ack should both be low now

    // Raise arm
    sif_reg_write(XPAR_IBOB_PHASED_ARRAY_2K_HB_SYNC_ARM_SOWF_BASEADDR, 1);

    xil_printf("Synchronizing internal SOWF to external SOWF...\n\r");

    sleep(1);

    // Check ack
    ack = sif_reg_read(XPAR_IBOB_PHASED_ARRAY_2K_HB_SYNC_ARMSOWF_ACK_BASEADDR);
    xil_printf("%sInternal SOWF %ssynchronized to external SOWF.\n\r",
        ack ? "" : "ERROR: ",
        ack ? "" : "NOT ");

    // Lower arm (clears ack)
    sif_reg_write(XPAR_IBOB_PHASED_ARRAY_2K_HB_SYNC_ARM_SOWF_BASEADDR, 0);
}

// Gets a character from tcp stream or uart.  Returns -1 if no character
// available within timeout period (30 seconds)
int vlbi_getc()
{
  int timeout = 30*1000; // 30 seconds
  unsigned char c;

  // While not timed out
  while(timeout > 0) {

    // Process input (without feeding tinysh!)
    process_inputs(0);
    
    // Check lwip fifo
    if(fifo_get(input_fifo, &c, 1)) {
      return c;
    }
    // Check uart fifo 
    if(!XUartLite_mIsReceiveEmpty(XPAR_RS232_UART_1_BASEADDR)) {     
      c = (Xuint8)XIo_In32(XPAR_RS232_UART_1_BASEADDR + XUL_RX_FIFO_OFFSET);
      return c;
    }

    // Sleep 1 ms == 1,000 us
    usleep(1000);
    // Decrement timeout
    timeout--;
  }

  // Timed out!
  return -1;
}

void bramload_cmd(int argc, char** argv)
/* command = "bramload" */
/* help    = "load multiple values into a bram" */
/* params  = "<bram name> <address> <num values>" */
{
	Xuint32 value = 0;
	char *name;
	int i, j;
	unsigned int address, address_start, loaded=0, word_count, word_size=0;
	core * corep = NULL;
  // str holds number read in from fifo.
  // Max len is 10 (0x????????).
  char str[11];
  int c;

	if(argc != 4) {
		xil_printf("Wrong number of arguments\n\r");
		return;
	}

  name = argv[1];
	address = tinysh_atoxi(argv[2]);
	word_count = tinysh_atoxi(argv[3]);
  address_start = address;

	switch(find_core(name,xps_bram,&corep)) {
		case CORE_WRONG_TYPE:
			xil_printf("Core '%s' is not a bram\n\r",name);
			return;
		case CORE_NOT_FOUND:
			xil_printf("Core '%s' not found\n\r",name);
			return;
		case CORE_OK:
			word_size = tinysh_atoxi(corep->params);

			if (address >= word_size) {
				xil_printf("The specified address is outside of the BRAM\n\r");
        return;
			}
	}

  // Read in word_count values
  for(i=0; i<word_count; i++) {

    // Skip leading white space and nuls
    do {
      c = vlbi_getc();
      // Bail out if vlbi_getc timed out
      if(c == -1) return;
    } while(isspace(c) || !c);

    // Store first character in str
    str[0] = (char)c;

    // Read in upto 9 more characters
    for(j=1; j<10; j++) {
      c = vlbi_getc();
      // Bail out if vlbi_getc timed out
      if(c == -1) return;
      // Store c in str
      str[j] = (char)c;
      // Done if whitespace or nul character
      if(isspace(str[j]) || !str[j]) break;
    }
    // Either j is 10 because we read 10 non-whitespace characters
    // or j is index of first whitespace character in str.  In either
    // case, we nul terminate str at j.
    str[j] = '\0';

    // If address is in range
    if(address < word_size) {
      // Parse number at str
      value = tinysh_atoxi(str);
      // Write value to BRAM
      sif_bram_write(corep->address, address, value);
      // Advance address
      address++;
      // Advance loaded counter
      loaded++;
    }
  }

  // If last character was '\r', read in one more character
  if(c == '\r') {
    c = vlbi_getc();
  }

  xil_printf("Loaded %d values at %d (0x%08x)\n\r", loaded, address_start, address_start);
}

void loadlut_cmd(int argc, char** argv)
/* command = "loadlut" */
/* help    = "load linear values into a LUT" */
/* params  = "<bram name> <address> <value> <step> <count> <shift>" */
{
	char *name;
	core * corep = NULL;
	Xuint32 address;
	Xuint32 value;
	Xuint32 step;
	Xuint32 count;
  Xuint32 shift;
	Xuint32 size;

	if(argc != 7) {
		xil_printf("Wrong number of arguments\n\r");
		return;
	}

  name = argv[1];
	address = tinysh_atoxi(argv[2]);
	value = tinysh_atoxi(argv[3]);
	step = tinysh_atoxi(argv[4]);
	count = tinysh_atoxi(argv[5]);
	shift = tinysh_atoxi(argv[6]);

  // Find core
	switch(find_core(name,xps_bram,&corep)) {
		case CORE_WRONG_TYPE:
			xil_printf("Core '%s' is not a bram\n\r",name);
			return;
		case CORE_NOT_FOUND:
			xil_printf("Core '%s' not found\n\r",name);
			return;
	}

  // Get size
  size = tinysh_atoxi(corep->params);

  // Limit count to size of core
  if(count > size) {
			count = size;
  }

  // Ensure address starts out in range
  address %= size;

  for(; count > 0; count--)
  {
    // Write value to BRAM
    sif_bram_write(corep->address, address, value >> shift);

    address++;
    if(address >= size) {
      address = 0;
    }
    value += step;
  }
}


void sync_hour_angle_cmd(int argc, char** argv)
/* command = "sync_hour_angle" */
/* help    = "Synchronize the time base register with current source HA" */
/* params  = "<current HA> <RT correction>" */
{
  Xfloat32 rt_time;

  // Store the current TBR value
  XTime_GetTime(&tbr0);

  // Make sure we have all arguments
  if(argc != 3) {
    xil_printf("Wrong number of arguments\n\r");
    return;
  }

  // Store the hour angle (convert to float)
  ha0 = ((Xfloat32)tinysh_atoxi(argv[1])) * pow(10, -5);
  
  // Adjust for RT time (if available)
  rt_time = ((Xfloat32)tinysh_atoxi(argv[2])) * pow(10, -5);

  // Correct the RT time
  ha0 += rt_time;

}

void set_delay_triplet_cmd(int argc, char** argv)
/* command = "set_delay_triplet" */
/* help    = "Store the delay triplet associated with an input." */
/* params  = "<input> <A> <B> <C>" */
{
  int input;

  // Make sure we have all arguments
  if(argc != 5) {
    xil_printf("Wrong number of arguments\n\r");
    return;
  }

  // Store all values
  input = tinysh_atoxi(argv[1]);
  deltrip[input][0] = ((Xfloat32)tinysh_atoxi(argv[2])) * pow(10, -5);
  deltrip[input][1] = ((Xfloat32)tinysh_atoxi(argv[3])) * pow(10, -5);
  deltrip[input][2] = ((Xfloat32)tinysh_atoxi(argv[4])) * pow(10, -5);

}

void set_fstop_cmd(int argc, char** argv)
/* command = "set_fstop" */
/* help    = "Store the fringe stopping frequency and start/stop tracking." */
/* params  = "<fstop> <flag>" */
{

  // Make sure we have all arguments
  if(argc != 3) {
    xil_printf("Wrong number of arguments\n\r");
    return;
  }

  // Store all values
  fstop = tinysh_atoxi(argv[1]) * pow(10, -5);
  stop_fringes_flag = tinysh_atoxi(argv[2]);

}

void get_phase_offset_cmd(int argc, char** argv)
/* command = "get_phase_offset" */
/* help    = "Return the phase offset for one input." */
/* params  = "<input>" */
{
  int input;
  Xfloat32 phaseval;

  // Make sure we have all arguments
  if(argc != 2) {
    xil_printf("Wrong number of arguments\n\r");
    return;
  }

  // Grab and print the value
  input = tinysh_atoxi(argv[1]);
  phaseval = phaseoff[input];
  xil_printf("PO%d=%d.%05d\n\r", input, (int)phaseval, (int)((phaseval-(int)phaseval)*pow(10, 5)));
}

void set_phase_offset_cmd(int argc, char** argv)
/* command = "set_phase_offset" */
/* help    = "Set phase offset for one input." */
/* params  = "<input> <phase_offset>" */
{
  int input;

  // Make sure we have all arguments
  if(argc != 3) {
    xil_printf("Wrong number of arguments\n\r");
    return;
  }

  // Store all values
  input = tinysh_atoxi(argv[1]);
  phaseoff[input] = ((Xfloat32)tinysh_atoxi(argv[2])) * pow(10, -5);

}

void get_delay_offset_cmd(int argc, char** argv)
/* command = "get_delay_offset" */
/* help    = "Return the delay offset for one input." */
/* params  = "<input>" */
{
  int input;
  Xfloat32 delayval;

  // Make sure we have all arguments
  if(argc != 2) {
    xil_printf("Wrong number of arguments\n\r");
    return;
  }

  // Grab and print the value
  input = tinysh_atoxi(argv[1]);
  delayval = delayoff[input];
  xil_printf("DO%d=%d.%05d\n\r", input, (int)delayval, (int)((delayval-(int)delayval)*pow(10, 5)));
}

void set_delay_offset_cmd(int argc, char** argv)
/* command = "set_delay_offset" */
/* help    = "Set delay offset for one input." */
/* params  = "<input> <delay_offset>" */
{
  int input;

  // Make sure we have all arguments
  if(argc != 3) {
    xil_printf("Wrong number of arguments\n\r");
    return;
  }

  // Store all values
  input = tinysh_atoxi(argv[1]);
  delayoff[input] = ((Xfloat32)tinysh_atoxi(argv[2])) * pow(10, -5);

}

void show_params_cmd(int argc, char** argv)
/* command = "show_params" */
/* help    = "Show the parameters used for stopping fringes." */
/* params  = "" */
{
  int i;
  int ha_hr;
  int ha_min;
  float ha_sec;
  float ha_24h;

  // Convert radian HA into H:M:S
  ha_24h = cur_ha * (12/PI);
  ha_hr = (int)(ha_24h);
  ha_min = (int)((ha_24h-ha_hr)*60.0);
  ha_sec = ((ha_24h-ha_hr-((float)ha_min/60.0)))*3600.0;

  // Print important parameters
  if (stop_fringes_flag) {
    xil_printf("Fringe stop    -- on\n\r");
  } else {
    xil_printf("Fringe stop    -- off\n\r");
  }
  xil_printf(  "Fstop (MHz)    -- %d\n\r", (int)(fstop*pow(10, 3)));
  xil_printf(  "Total cycles   -- %d\n\r", total_cycles);
  xil_printf(  "HA/SEC * 10^6  -- %d.%05d\n\r", 
	       (int)HA_RAD_PER_SEC_6, (int)((HA_RAD_PER_SEC_6 - (int)HA_RAD_PER_SEC_6)*pow(10, 5)));
  xil_printf(  "Sec since sync -- %d.%05d\n\r", (int)del_sec, (int)((del_sec-(int)del_sec)*pow(10, 5)));
  xil_printf(  "Hour angle (r) -- %d.%05d\n\r", (int)cur_ha, (int)((cur_ha-(int)cur_ha)*pow(10, 5)));
  xil_printf(  "Hour angle (d) -- %d:%02d:%02d\n\r", ha_hr, ha_min, (int)ha_sec);
  for (i = 0; i<4; i++) {
    xil_printf("Delay %d (ns)   -- %d.%05d\n\r", i, (int)delay[i], (int)((delay[i]-(int)delay[i])*pow(10, 5)));
  }
  for (i = 0; i<4; i++) {
    xil_printf("Phase %d (deg)  -- %d.%05d\n\r", i, (int)phase[i], (int)fabs((phase[i]-(int)phase[i])*pow(10, 5)));
  }

}

// Return -1 if negative, 1 if positive or zero
Xfloat32 sign(Xfloat32 n) {
  return (n<0) ? -1 : 1;
}

// Modulo returning a float
Xfloat32 mod(Xfloat32 a, int n) {
  return  a - (Xfloat32)(n*((int)a / n));
}

void stop_fringes()
/* repeat */
{

  int i;
  float per;
  float deg_per_step;
  float ns_per_step;
  int delay_step[4] = {0, 0, 0, 0};
  int phase_step[4] = {0, 0, 0, 0};

  if (stop_fringes_flag) {
    total_cycles++;

    // Store the current TBR value
    XTime_GetTime(&cur_tbr);
    del_sec = ((Xfloat32)(cur_tbr-tbr0)) / CLOCKS_PER_SEC;
  
    // Find time since last sync and
    // calculate the current hour angle
    cur_ha = ha0 + del_sec * HA_RAD_PER_SEC;

    // constants for converstion
    deg_per_step = 360 / pow(2, 12);

    // Calculate delays and phases for all inputs
    for (i = 0; i<4; i++) {
      // delays...
      delay[i] = delayoff[i] + deltrip[i][0] + 
	cos(cur_ha)*deltrip[i][1] + 
	sin(cur_ha)*deltrip[i][2];
      delay_step[i] = (int)mod(round(16*1.024*delay[i]) + 64, pow(2, 17));
      // and phases...
      phase[i] = phaseoff[i] + sign(fstop) * mod(360*delay[i]*fabs(fstop), 360);
      phase_step[i] = (int)mod(round(phase[i]/deg_per_step), pow(2, 12));
    }

    // Finally write to registers
    sif_reg_write(XPAR_IBOB_PHASED_ARRAY_2K_DELAY0_BASEADDR, delay_step[0]);
    sif_reg_write(XPAR_IBOB_PHASED_ARRAY_2K_DELAY1_BASEADDR, delay_step[1]);
    sif_reg_write(XPAR_IBOB_PHASED_ARRAY_2K_DELAY2_BASEADDR, delay_step[2]);
    sif_reg_write(XPAR_IBOB_PHASED_ARRAY_2K_DELAY3_BASEADDR, delay_step[3]);
    sif_reg_write(XPAR_IBOB_PHASED_ARRAY_2K_PHASE0_BASEADDR, phase_step[0]);
    sif_reg_write(XPAR_IBOB_PHASED_ARRAY_2K_PHASE1_BASEADDR, phase_step[1]);
    sif_reg_write(XPAR_IBOB_PHASED_ARRAY_2K_PHASE2_BASEADDR, phase_step[2]);
    sif_reg_write(XPAR_IBOB_PHASED_ARRAY_2K_PHASE3_BASEADDR, phase_step[3]);

  }

}

