
.origin 0
.entrypoint MEMACCESS_DDR_PRUSHAREDRAM

#include "PRU_memAccess_DDR_PRUsharedRAM.hp"

MEMACCESS_DDR_PRUSHAREDRAM:

    // Enable OCP master port
    lbco      r0, CONST_PRUCFG, 4, 4
    clr     r0, r0, 4         // Clear SYSCFG[STANDBY_INIT] to enable OCP master port
    sbco      r0, CONST_PRUCFG, 4, 4

    // Enable 16 bit parallel capture mode
    mov     r0, 0x01
    sbco    r0, CONST_PRUCFG, 0x0c, 4

    // Configure the programmable pointer register for PRU0 by setting c28_pointer[15:0]
    // field to 0x0120.  This will make C28 point to 0x00012000 (PRU shared RAM).
    mov     r0, 0x00000120
    mov       r1, PRU1_CTPPR_0
    st32      r0, r1

    // Configure the programmable pointer register for PRU0 by setting c31_pointer[15:0]
    // field to 0x0010.  This will make C31 point to 0x80001000 (DDR memory).
    mov     r0, 0x00100000
    mov       r1, PRU1_CTPPR_1
    st32      r0, r1

    //Load values from external DDR Memory into Registers R0/R1/R2
    lbco      r0, CONST_DDR, 0, 12

.enter Scope
.struct Stats
    .u32 pixels
    .u32 lines
.ends
.assign Stats, r3, *, stats

    zero &stats, SIZE(stats)

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

    add stats.lines, stats.lines, 1 // start of a line
    add stats.pixels, stats.pixels, 1 // got a pixel
read_line:
    wbs r31, 16
    qbbc done, r31, 11 // if fv goes to 0, then done
    qbbc wait_for_start_line, r31, 10 // if lv goes to 0, then wait for the next line

    add stats.pixels, stats.pixels, 1 // got a pixel
    qba read_line

done:
    sbco      &stats, CONST_PRUSHAREDRAM, 0, SIZE(stats)

.leave Scope

    // Send notification to Host for program completion
    mov       r31.b0, PRU1_ARM_INTERRUPT+16

    // Halt the processor
    halt


