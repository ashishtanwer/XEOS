;-------------------------------------------------------------------------------
; Copyright (c) 2010-2012, Jean-David Gadina <macmade@eosgarden.com>
; All rights reserved.
; 
; XEOS Software License - Version 1.0 - December 21, 2012
; 
; Permission is hereby granted, free of charge, to any person or organisation
; obtaining a copy of the software and accompanying documentation covered by
; this license (the "Software") to deal in the Software, with or without
; modification, without restriction, including without limitation the rights
; to use, execute, display, copy, reproduce, transmit, publish, distribute,
; modify, merge, prepare derivative works of the Software, and to permit
; third-parties to whom the Software is furnished to do so, all subject to the
; following conditions:
; 
;       1.  Redistributions of source code, in whole or in part, must retain the
;           above copyright notice and this entire statement, including the
;           above license grant, this restriction and the following disclaimer.
; 
;       2.  Redistributions in binary form must reproduce the above copyright
;           notice and this entire statement, including the above license grant,
;           this restriction and the following disclaimer in the documentation
;           and/or other materials provided with the distribution, unless the
;           Software is distributed by the copyright owner as a library.
;           A "library" means a collection of software functions and/or data
;           prepared so as to be conveniently linked with application programs
;           (which use some of those functions and data) to form executables.
; 
;       3.  The Software, or any substancial portion of the Software shall not
;           be combined, included, derived, or linked (statically or
;           dynamically) with software or libraries licensed under the terms
;           of any GNU software license, including, but not limited to, the GNU
;           General Public License (GNU/GPL) or the GNU Lesser General Public
;           License (GNU/LGPL).
; 
;       4.  All advertising materials mentioning features or use of this
;           software must display an acknowledgement stating that the product
;           includes software developed by the copyright owner.
; 
;       5.  Neither the name of the copyright owner nor the names of its
;           contributors may be used to endorse or promote products derived from
;           this software without specific prior written permission.
; 
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT OWNER AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
; THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
; PURPOSE, TITLE AND NON-INFRINGEMENT ARE DISCLAIMED.
; 
; IN NO EVENT SHALL THE COPYRIGHT OWNER, CONTRIBUTORS OR ANYONE DISTRIBUTING
; THE SOFTWARE BE LIABLE FOR ANY CLAIM, DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
; EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
; PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
; WHETHER IN ACTION OF CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
; NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF OR IN CONNECTION WITH
; THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE, EVEN IF ADVISED
; OF THE POSSIBILITY OF SUCH DAMAGE.
;-------------------------------------------------------------------------------

; $Id$

;-------------------------------------------------------------------------------
; Procedures for the ELF format
; 
; Those procedures and macros are intended to be used only in 16 bits real mode.
;-------------------------------------------------------------------------------
%ifndef __XEOS_ELF_INC_16_ASM__
%define __XEOS_ELF_INC_16_ASM__

;-------------------------------------------------------------------------------
; Includes
;-------------------------------------------------------------------------------
%include "XEOS.macros.inc.asm"          ; General macros
%include "XEOS.error.inc.16.asm"        ; Error management
%include "XEOS.ascii.inc.asm"           ; ASCII table

; We are in 16 bits mode
BITS    16

;-------------------------------------------------------------------------------
; Checks the ELF header to ensure it's a valid ELF binary file
; 
; The ELF header has the following structure:
;       
;       - BYTE  e_ident[ 16 ]   File identification
;       - WORD  e_type          Object file type
;       - WORD  e_machine       Required architecture
;       - DWORD e_version       Object file version
;       - DWORD e_entry         Entry point address
;       - DWORD e_phoff         Program header table's file offset
;       - DWORD e_shoff         Section header table's file offset
;       - DWORD e_flags         Processor-specific flags
;       - WORD  e_ehsize        ELF header's size
;       - WORD  e_phentsize     Size of an entry in the program header table
;                               (all entries are the same size)
;       - WORD  e_phnum         Number of entries in the program header table
;       - WORD  e_shentsize     Section header's size
;       - WORD  e_shnum         Number of entries in the section header table
;       - WORD  e_shstrndx      Section header table index of the entry
;                               associated with the section name string table
; 
; Necessary register values:
;       
;       - ax:       The memory address at which the file is loaded
;-------------------------------------------------------------------------------
XEOS.elf.checkHeader:
    
    @XEOS.reg.save
    
    mov     es,         ax
    xor     ax,         ax
    mov     di,         ax
    
    mov     si,         XEOS.elf.signature
    mov     cx,         4
    
    rep     cmpsb
    
    je      .validSignature
    
    call    XEOS.error.fatal
    
    .validSignature:
        
        push    ds
        push    si
        
        mov     ax,         es
        mov     ds,         ax
        mov     ax,         di
        mov     si,         ax
        
        lodsb
        
        cmp     al,         0x01
        
        je      .validClass
        
        pop     si
        pop     ds
        
        call    XEOS.error.fatal
        
    .validClass:
        
        lodsb
        
        cmp     al,         0x00
        
        jg      .validEncoding
        
        pop     si
        pop     ds
        
        call    XEOS.error.fatal
        
    .validEncoding:
        
        pop     si
        pop     ds
    
    @XEOS.reg.restore
    
    ret

;-------------------------------------------------------------------------------
; Gets the entry point address of an ELF file, loaded in memory
; 
; 
; Necessary register values:
;       
;       - ax:       The memory address at which the file is loaded
;-------------------------------------------------------------------------------
XEOS.elf.getEntryPointAddress:
    
    @XEOS.reg.save
    
    
    
    @XEOS.reg.restore
    
    ret
    
;-------------------------------------------------------------------------------
; Loads an ELF file into memory
; 
; Necessary register values:
;       
;       - si:       The name of the file to load
;       - ax:       The memory address at which the file will be loaded
;       - bx:       The memory address at which the buffer will be created
;                   (the buffer is used to load the FAT root directory and
;                   the file allocation table, so be sure to have enough
;                   memory available)
;-------------------------------------------------------------------------------
XEOS.elf.load:
    
    @XEOS.reg.save
    
    ; Saves some registers
    push    ax
    push    bx
    
    ; Loads the root directory into memory
    call    XEOS.io.fat12.loadRootDirectory
    
    ; Location of the data we read into memory
    pop     bx
    push    bx
    
    ; Tries to find the kernel file in the root directory
    call    XEOS.io.fat12.findFile
    
    ; Restores the needed memory registers
    pop     bx
    pop     ax
    
    ; Saves AX again
    push    ax
    
    ; Loads the kernel into memory
    call    XEOS.io.fat12.loadFile
    
    ; Checks the ELF header
    pop     ax
    push    ax
    call    XEOS.elf.checkHeader
    
    ; Restores AX
    pop    ax
    
    ; Gets the address of the entry point
    call    XEOS.elf.getEntryPointAddress
    
    @XEOS.reg.restore
    
    ret

;-------------------------------------------------------------------------------
; Variables
;-------------------------------------------------------------------------------

XEOS.elf.signature      db  0x7F, 0x45, 0x4C, 0x46
XEOS.elf.entryPoint     dd  0

%endif
