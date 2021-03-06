#include "vlbi.h"

void vlbi_init ()
/* init */
{
    sif_reg_write(XPAR_DBE_XAUI_CORR_SHIFTCTRL_REG_BASEADDR, 0xffffffff);
    sif_reg_write(XPAR_DBE_XAUI_CORR_DELAY_ADJ_BASEADDR, 7);
	//new stuff to check rs-232
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL0_GAINCTRL0_BASEADDR, 0, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL0_GAINCTRL0_BASEADDR, 1, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL0_GAINCTRL0_BASEADDR, 2, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL0_GAINCTRL0_BASEADDR, 3, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL0_GAINCTRL0_BASEADDR, 4, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL0_GAINCTRL0_BASEADDR, 5, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL0_GAINCTRL0_BASEADDR, 6, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL0_GAINCTRL0_BASEADDR, 7, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL0_GAINCTRL1_BASEADDR, 0, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL0_GAINCTRL1_BASEADDR, 1, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL0_GAINCTRL1_BASEADDR, 2, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL0_GAINCTRL1_BASEADDR, 3, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL0_GAINCTRL1_BASEADDR, 4, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL0_GAINCTRL1_BASEADDR, 5, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL0_GAINCTRL1_BASEADDR, 6, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL0_GAINCTRL1_BASEADDR, 7, 200);
	
/*	sif_bram_write(XPAR_DBE_XAUI_CORR_POL1_GAINCTRL0_BASEADDR, 0, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL1_GAINCTRL0_BASEADDR, 1, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL1_GAINCTRL0_BASEADDR, 2, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL1_GAINCTRL0_BASEADDR, 3, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL1_GAINCTRL0_BASEADDR, 4, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL1_GAINCTRL0_BASEADDR, 5, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL1_GAINCTRL0_BASEADDR, 6, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL1_GAINCTRL0_BASEADDR, 7, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL1_GAINCTRL1_BASEADDR, 0, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL1_GAINCTRL1_BASEADDR, 1, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL1_GAINCTRL1_BASEADDR, 2, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL1_GAINCTRL1_BASEADDR, 3, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL1_GAINCTRL1_BASEADDR, 4, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL1_GAINCTRL1_BASEADDR, 5, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL1_GAINCTRL1_BASEADDR, 6, 200);
	sif_bram_write(XPAR_DBE_XAUI_CORR_POL1_GAINCTRL1_BASEADDR, 7, 200);
*/	//end new stuff

    sif_reg_write(XPAR_DBE_XAUI_CORR_OUTSEL_BASEADDR, 3);






}

void selectoutput_cmd (int argc, char** argv)
/* command = "selectoutput" */
/* help    = "0 - all 0's | 1 - all 1's | 2 - TVG | 3 - spectrum" */
/* params  = "<source>" */
{
    Xuint32 muxsel;

    if (argc != 2)
    {
        xil_printf("Wrong number of arguments\n\r");
        return;
    }

    muxsel = tinysh_atoxi(argv[1]);

    sif_reg_write(XPAR_DBE_XAUI_CORR_OUTSEL_BASEADDR, muxsel);
}

void arm1pps_cmd(int argc, char** argv)
/* command = "arm1pps" */
/* help    = "arm 1pps" */
/* params  = "" */
{
    Xuint32 arm;
    Xuint32 ack;

    // Get current values
    arm = sif_reg_read(XPAR_DBE_XAUI_CORR_ONEPPS_SYNC_ARM1PPS_BASEADDR);
    ack = sif_reg_read(XPAR_DBE_XAUI_CORR_ONEPPS_SYNC_ARM1PPS_ACK_BASEADDR);

    if(arm) {
      sleep(1);
      usleep(1000);
      sif_reg_write(XPAR_DBE_XAUI_CORR_ONEPPS_SYNC_ARM1PPS_BASEADDR, 0);
    } else if (ack) {
      /* Arm is low if we get here, so raise it */
      sif_reg_write(XPAR_DBE_XAUI_CORR_ONEPPS_SYNC_ARM1PPS_BASEADDR, 1);
      sleep(1);
      usleep(1000);
      sif_reg_write(XPAR_DBE_XAUI_CORR_ONEPPS_SYNC_ARM1PPS_BASEADDR, 0);
    }

    // arm and ack should both be low now

    // Raise arm
    sif_reg_write(XPAR_DBE_XAUI_CORR_ONEPPS_SYNC_ARM1PPS_BASEADDR, 1);

    xil_printf("Synchronizing internal 1PPS to external 1PPS...\n\r");

    sleep(1);

    // Check ack
    ack = sif_reg_read(XPAR_DBE_XAUI_CORR_ONEPPS_SYNC_ARM1PPS_ACK_BASEADDR);
    xil_printf("%sInternal 1PPS %ssynchronized to external 1PPS.\n\r",
        ack ? "" : "ERROR: ",
        ack ? "" : "NOT ");

    // Lower arm (clears ack)
    sif_reg_write(XPAR_DBE_XAUI_CORR_ONEPPS_SYNC_ARM1PPS_BASEADDR, 0);
}
