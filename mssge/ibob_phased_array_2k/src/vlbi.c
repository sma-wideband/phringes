#include "vlbi.h"

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
