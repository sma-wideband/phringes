#include "vlbi.h"

void vlbi_init ()
/* init */
{
    sif_reg_write(XPAR_DBE_ADC_SINGLE_SHIFTCTRL_REG_BASEADDR, 0xffffffff);
	//new stuff to check rs-232
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL0_GAINCTRL0_BASEADDR, 0, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL0_GAINCTRL0_BASEADDR, 1, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL0_GAINCTRL0_BASEADDR, 2, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL0_GAINCTRL0_BASEADDR, 3, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL0_GAINCTRL0_BASEADDR, 4, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL0_GAINCTRL0_BASEADDR, 5, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL0_GAINCTRL0_BASEADDR, 6, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL0_GAINCTRL0_BASEADDR, 7, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL0_GAINCTRL1_BASEADDR, 0, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL0_GAINCTRL1_BASEADDR, 1, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL0_GAINCTRL1_BASEADDR, 2, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL0_GAINCTRL1_BASEADDR, 3, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL0_GAINCTRL1_BASEADDR, 4, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL0_GAINCTRL1_BASEADDR, 5, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL0_GAINCTRL1_BASEADDR, 6, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL0_GAINCTRL1_BASEADDR, 7, 200);
	
/*	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL1_GAINCTRL0_BASEADDR, 0, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL1_GAINCTRL0_BASEADDR, 1, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL1_GAINCTRL0_BASEADDR, 2, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL1_GAINCTRL0_BASEADDR, 3, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL1_GAINCTRL0_BASEADDR, 4, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL1_GAINCTRL0_BASEADDR, 5, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL1_GAINCTRL0_BASEADDR, 6, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL1_GAINCTRL0_BASEADDR, 7, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL1_GAINCTRL1_BASEADDR, 0, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL1_GAINCTRL1_BASEADDR, 1, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL1_GAINCTRL1_BASEADDR, 2, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL1_GAINCTRL1_BASEADDR, 3, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL1_GAINCTRL1_BASEADDR, 4, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL1_GAINCTRL1_BASEADDR, 5, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL1_GAINCTRL1_BASEADDR, 6, 200);
	sif_bram_write(XPAR_DBE_ADC_SINGLE_POL1_GAINCTRL1_BASEADDR, 7, 200);
*/	//end new stuff

    sif_reg_write(XPAR_DBE_ADC_SINGLE_OUTSEL_BASEADDR, 3);






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

    sif_reg_write(XPAR_DBE_ADC_SINGLE_OUTSEL_BASEADDR, muxsel);
}

void arm1pps_cmd(int argc, char** argv)
/* command = "arm1pps" */
/* help    = "arm 1pps" */
/* params  = "" */
{
    // XIo_Out32(XPAR_VSITVG_ONEPPS_SYNC_ARM1PPS_BASEADDR, 1);
    sif_reg_write(XPAR_DBE_ADC_SINGLE_ONEPPS_SYNC_ARM1PPS_BASEADDR, 1);

    xil_printf("Synchronizing internal 1PPS to external 1PPS...\n\r");

    // Wait for ack to go low
    while (sif_reg_read(XPAR_DBE_ADC_SINGLE_ONEPPS_SYNC_ARM1PPS_ACK_BASEADDR));

    // XIo_Out32(XPAR_VSITVG_ONEPPS_SYNC_ARM1PPS_BASEADDR, 0);
    sif_reg_write(XPAR_DBE_ADC_SINGLE_ONEPPS_SYNC_ARM1PPS_BASEADDR, 0);

    // Wait for ack to go high
    while (!sif_reg_read(XPAR_DBE_ADC_SINGLE_ONEPPS_SYNC_ARM1PPS_ACK_BASEADDR));

    xil_printf("Internal 1PPS synchronized to external 1PPS.\n\r");
}
