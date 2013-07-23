
.origin 0
.entrypoint MEMACCESS_DDR_PRUSHAREDRAM

#include "PRU_memAccess_DDR_PRUsharedRAM.hp"

MEMACCESS_DDR_PRUSHAREDRAM:

    // Enable OCP master port
    LBCO      r0, CONST_PRUCFG, 4, 4
    CLR     r0, r0, 4         // Clear SYSCFG[STANDBY_INIT] to enable OCP master port
    SBCO      r0, CONST_PRUCFG, 4, 4

    // Enable 16 bit parallel capture mode
    MOV     r0, 0x01
    SBCO    r0, CONST_PRUCFG, 0x0c, 4

    // Configure the programmable pointer register for PRU0 by setting c28_pointer[15:0]
    // field to 0x0120.  This will make C28 point to 0x00012000 (PRU shared RAM).
    MOV     r0, 0x00000120
    MOV       r1, PRU1_CTPPR_0
    ST32      r0, r1

    // Configure the programmable pointer register for PRU0 by setting c31_pointer[15:0]
    // field to 0x0010.  This will make C31 point to 0x80001000 (DDR memory).
    MOV     r0, 0x00100000
    MOV       r1, PRU1_CTPPR_1
    ST32      r0, r1

    //Load values from external DDR Memory into Registers R0/R1/R2
    LBCO      r0, CONST_DDR, 0, 12

    //Store values from read from the DDR memory into PRU shared RAM
    SBCO      r0, CONST_PRUSHAREDRAM, 0, 12

    mov r3, 0
    mov r4, 0
    sbco      r3, CONST_PRUSHAREDRAM, 0, 8

    // Wait for vsync
vsync_loop:
    // Wait for pixel clock
    wbs  r31, 16
    qbbs vsync_loop, r31, 11 // branch if fv is set

    // Wait for frame
wait_for_start_loop:
    wbs r31, 16
    qbbc wait_for_start_loop, r31, 11

wait_for_start_line:
    wbs r31, 16
    qbbc done, r31, 11 // if fv goes to 0, then done
    qbbc wait_for_start_line, r31, 10

    add r4, r4, 1 // start of a line
    add r3, r3, 1 // got a pixel
read_line:
    wbs r31, 16
    qbbc done, r31, 11 // if fv goes to 0, then done
    qbbc wait_for_start_line, r31, 10 // if lv goes to 0, then wait for the next line

    add r3, r3, 1 // got a pixel
    qba read_line


done:
    sbco      r3, CONST_PRUSHAREDRAM, 0, 8

    // Send notification to Host for program completion
    mov       r31.b0, PRU1_ARM_INTERRUPT+16

    // Halt the processor
    halt


