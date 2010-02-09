;-------------------------------------------------------------------------------
; XEOS - x86 Experimental Operating System
; 
; Copyright (C) 2010 Jean-David Gadina (macmade@eosgarden.com)
; All rights reserved
; 
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
; 
;  -   Redistributions of source code must retain the above copyright notice,
;      this list of conditions and the following disclaimer.
;  -   Redistributions in binary form must reproduce the above copyright
;      notice, this list of conditions and the following disclaimer in the
;      documentation and/or other materials provided with the distribution.
;  -   Neither the name of 'Jean-David Gadina' nor the names of its
;      contributors may be used to endorse or promote products derived from
;      this software without specific prior written permission.
; 
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
; POSSIBILITY OF SUCH DAMAGE.
;-------------------------------------------------------------------------------

; $Id$

;-------------------------------------------------------------------------------
; XEOS kernel
; 
; Note about compiling:
;
; This file has to be compiled as a flat-form binary file.
; 
; The following compilers have been successfully tested:
; 
;       - NASM - The Netwide Assembler
;       - YASM - The Yasm Modular Assembler
; 
; Other compilers have not been tested.
; 
; Examples:
; 
;       - nasm -f bin -o [boot.flp] [boot.asm]
;       - yasm -f bin -o [boot.flp] [boot.asm]
;-------------------------------------------------------------------------------

; Location at which we were loaded by the second stage bootloader (1MB)
ORG     0x100000

; We are in 32 bits mode
BITS    32

; Jumps to the effective code section
jmp     XEOS.kernel

;-------------------------------------------------------------------------------
; Includes
;-------------------------------------------------------------------------------
%include "XEOS.video.inc.32.asm"        ; XEOS video services
%include "XEOS.ascii.inc.asm"           ; ASCII table
%include "XEOS.gdt.inc.asm"             ; GDT - Global Descriptor Table
%include "XEOS.error.inc.32.asm"        ; Error management
%include "XEOS.smbios.inc.32.asm"       ; SMBIOS

; Prints a new line with a message, prefixed by the prompt
%macro @XEOS.kernel.print 1
    
    @XEOS.video.print    XEOS.kernel.prompt
    @XEOS.video.print    %1
    @XEOS.video.print    XEOS.kernel.nl
    
%endmacro

;-------------------------------------------------------------------------------
; XEOS kernel
;-------------------------------------------------------------------------------
XEOS.kernel:
    
    ; Sets the data segments
    mov     ax,         $XEOS.gdt.descriptors.data
    mov     ds,         ax
    mov     es,         ax
    
    ; Sets up the stack space
    mov     ss,         ax
    mov     esp,        0x90000
    
    ; Clears the screen
    call    XEOS.video.clear
    
    ; Kernel logo
    @XEOS.video.print   XEOS.kernel.logo
    
    ; Kernel message
    @XEOS.kernel.print  XEOS.kernel.greet
    @XEOS.kernel.print  XEOS.kernel.revision
    @XEOS.kernel.print  XEOS.kernel.date
    @XEOS.kernel.print  XEOS.kernel.smbios.search
    
    ; Tries to find the SMBIOS entry point
    call    XEOS.smbios.find
    
    ; Checks the result stored in EAX
    cmp     eax,        0
    
    ; If 0, the SMBIOS entry point was found
    je     .smbiosChecksum
    
    ; SMBIOS not found - Issues a fatal error
    @XEOS.error.fatal XEOS.kernel.smbios.error.notFound
    
    ; Verifies the SMBIOS entry point checksum
    .smbiosChecksum:
    
    ; Status message
    @XEOS.kernel.print  XEOS.kernel.smbios.checksum
    
    ; Verifies the SMBIOS entry point checksum
    call    XEOS.smbios.verifyChecksum
    
    ; Checks the result stored in EAX
    cmp     eax,        0
    
    ; If 0, the SMBIOS entry point is valid
    je     .smbiosValid
    
    ; Invalid SMBIOS entry point - Issues a fatal error
    @XEOS.error.fatal XEOS.kernel.smbios.error.checksum
    
    ; The SMBIOS entry point is valid
    .smbiosValid:
    
    ; Status message
    @XEOS.kernel.print  XEOS.kernel.smbios.valid
    
    ; Infinite loop
    jmp     $

;-------------------------------------------------------------------------------
; Variables definition
;-------------------------------------------------------------------------------

XEOS.kernel.nl                      db   $ASCII.NL,  $ASCII.NUL         
XEOS.kernel.prompt                  db  '<XEOS>: ', $ASCII.NUL
XEOS.kernel.smbios.search           db  'Locating the SMBIOS entry point...', $ASCII.NUL
XEOS.kernel.smbios.checksum         db  'Checksumming the SMBIOS entry point...', $ASCII.NUL
XEOS.kernel.smbios.valid            db  'Found a valid SMBIOS entry point...', $ASCII.NUL
XEOS.kernel.smbios.error.notFound   db  'Unable to locate the SMBIOS table.', $ASCII.NUL
XEOS.kernel.smbios.error.checksum   db  'Invalid SMBIOS table checksum.', $ASCII.NUL
XEOS.kernel.greet                   db  'Entering the XEOS kernel...', $ASCII.NUL
XEOS.kernel.revision                db  '$Revision$', $ASCII.NUL
XEOS.kernel.date                    db  '$Date$', $ASCII.NUL
XEOS.kernel.logo                    db  $ASCII.NL,\
                                        '    ------------------------------------------------------------------------   ', $ASCII.NL,\
                                        '   |                                                                        |  ', $ASCII.NL,\
                                        '   |       00000     00000  00000000000  0000000000000  0000000000000       |  ', $ASCII.NL,\
                                        '   |        00000   00000   00000000000  0000000000000  0000000000000       |  ', $ASCII.NL,\
                                        '   |          000000000     000          000       000  000                 |  ', $ASCII.NL,\
                                        '   |           0000000      00000000000  000       000  0000000000000       |  ', $ASCII.NL,\
                                        '   |          000000000     000          000       000            000       |  ', $ASCII.NL,\
                                        '   |        00000   00000   00000000000  0000000000000  0000000000000       |  ', $ASCII.NL,\
                                        '   |       00000     00000  00000000000  0000000000000  0000000000000       |  ', $ASCII.NL,\
                                        '   |                                                                        |  ', $ASCII.NL,\
                                        '   |                XEOS - x86 Experimental Operating System                |  ', $ASCII.NL,\
                                        '   |                                                                        |  ', $ASCII.NL,\
                                        '   |      Copyright (C) 2010 Jean-David Gadina (macmade@eosgarden.com)      |  ', $ASCII.NL,\
                                        '   |                     All rights (& wrongs) reserved                     |  ', $ASCII.NL,\
                                        '   |                                                                        |  ', $ASCII.NL,\
                                        '    ------------------------------------------------------------------------   ', $ASCII.NL,\
                                        $ASCII.NL, $ASCII.NUL
