#include "xuartlite_l.h"
#include "fifo.h"
#include "core_util.h"

#include "vlbi.h"

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
