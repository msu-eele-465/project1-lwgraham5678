; --COPYRIGHT--,BSD_EX
;  Copyright (c) 2016, Texas Instruments Incorporated
;  All rights reserved.
;
;  Redistribution and use in source and binary forms, with or without
;  modification, are permitted provided that the following conditions
;  are met:
;
;  *  Redistributions of source code must retain the above copyright
;     notice, this list of conditions and the following disclaimer.
;
;  *  Redistributions in binary form must reproduce the above copyright
;     notice, this list of conditions and the following disclaimer in the
;     documentation and/or other materials provided with the distribution.
;
;  *  Neither the name of Texas Instruments Incorporated nor the names of
;     its contributors may be used to endorse or promote products derived
;     from this software without specific prior written permission.
;
;  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
;  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
;  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
;  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
;  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
;  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
;  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;
; ******************************************************************************
;
;                        MSP430 CODE EXAMPLE DISCLAIMER
;
;  MSP430 code examples are self-contained low-level programs that typically
;  demonstrate a single peripheral function or device feature in a highly
;  concise manner. For this the code may rely on the device's power-on default
;  register values and settings such as the clock configuration and care must
;  be taken when combining code from several examples to avoid potential side
;  effects. Also see www.ti.com/grace for a GUI- and www.ti.com/msp430ware
;  for an API functional library-approach to peripheral configuration.
;
; --/COPYRIGHT--
;******************************************************************************
;  MSP430FR235x Demo - Toggle P1.0 using software
;
;  Description: Toggle P1.0 every 0.1s using software.
;  By default, FR235x select XT1 as FLL reference.
;  If XT1 is present, the PxSEL(XIN & XOUT) needs to configure.
;  If XT1 is absent, switch to select REFO as FLL reference automatically.
;  XT1 is considered to be absent in this example.
;  ACLK = default REFO ~32768Hz, MCLK = SMCLK = default DCODIV ~1MHz.
;
;           MSP430FR2355
;         ---------------
;     /|\|               |
;      | |               |
;      --|RST            |
;        |           P1.0|-->LED
;
;   Cash Hao
;   Texas Instruments Inc.
;   November 2016
;   Built with Code Composer Studio v6.2.0
;******************************************************************************
            .cdecls C,LIST,"msp430.h"  ; Include device header file
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
            .global __STACK_END
            .sect   .stack                  ; Make stack linker segment ?known?

            .text                           ; Assemble to Flash memory
            .retain                         ; Ensure current section gets linked
            .retainrefs

RESET       mov.w   #__STACK_END,SP         ; Initialize stack pointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT

SetupTB0    bis.w	#TBCLR,&TB0CTL			; clear timers & dividers
            bis.w	#TBSSEL__ACLK,&TB0CTL	; set ACLK as source
            bis.w	#MC__CONTINUOUS,&TB0CTL ; choosing continuous counting
            bis.w	#CNTL_1,&TB0CTL 		; set 12-bit clock length
            bis.w	#ID__8,&TB0CTL			; set 8 in divider 1
            bis.w	#TBIE,&TB0CTL			; enable overflow interrupt
            bic.w	#TBIFG,&TB0CTL			; clear inturrupt flag
                                            ; calc -> (8*2^12)/32768 = 1
            NOP
            bis.w	#GIE, SR				; enabling global interrupts
            NOP

SetupP6     bic.b   #BIT6,&P6OUT            ; Clear P6.6 otput
            bis.b   #BIT6,&P6DIR            ; P6.6 output
SetupP1     bic.b   #BIT0,&P1OUT            ; Clear P1.0 output
            bis.b   #BIT0,&P1DIR            ; P1.0 output
            bic.w   #LOCKLPM5,&PM5CTL0      ; Unlock I/O pins

Mainloop    xor.b   #BIT0,&P1OUT            ; Toggle P1.0 every 1s
            call    #Delay1s                ; calling 1s delay subroutine
            jmp     Mainloop                ; Loop main program

;------------------------------------------------------------------------------
;           Delay 1 s Subroutine
;------------------------------------------------------------------------------
Delay1s:
Wait        mov.w   #71,R15                 ; Delay to R15
L1          dec.w   R15                     ; Decrement R15
            mov.w   #5000,R14               ; initialize inner delay loop
            jnz     L2                      ; Delay routine jump
            jmp     End_Delay1s             ; Jump to return


L2          dec.w   R14                     ; Decriment inner delay loop
            jnz     L2                      ; Jump to inner delay loop if R14 ≠ 0
            jmp     L1                      ; Jump to outer loop

End_Delay1s ret                             ; Return

;------------------------------------------------------------------------------
;           TB0 ISR 1s overflow timer
;------------------------------------------------------------------------------
TimerB0_1s:
		xor.b	#BIT6, &P6OUT			    ; toggle P6.6
		bic.w	#TBIFG, &TB0CTL			    ; clear inturrupt flag
		reti

;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   RESET_VECTOR            ; MSP430 RESET Vector
            .short  RESET                   ;

            .sect	".int42"                ; TB0 Interrupt Vector
            .short	TimerB0_1s              ;

            .end
