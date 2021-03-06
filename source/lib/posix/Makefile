#-------------------------------------------------------------------------------
# Copyright (c) 2010-2013, Jean-David Gadina - www.xs-labs.com
# All rights reserved.
# 
# XEOS Software License - Version 1.0 - December 21, 2012
# 
# Permission is hereby granted, free of charge, to any person or organisation
# obtaining a copy of the software and accompanying documentation covered by
# this license (the "Software") to deal in the Software, with or without
# modification, without restriction, including without limitation the rights
# to use, execute, display, copy, reproduce, transmit, publish, distribute,
# modify, merge, prepare derivative works of the Software, and to permit
# third-parties to whom the Software is furnished to do so, all subject to the
# following conditions:
# 
#       1.  Redistributions of source code, in whole or in part, must retain the
#           above copyright notice and this entire statement, including the
#           above license grant, this restriction and the following disclaimer.
# 
#       2.  Redistributions in binary form must reproduce the above copyright
#           notice and this entire statement, including the above license grant,
#           this restriction and the following disclaimer in the documentation
#           and/or other materials provided with the distribution, unless the
#           Software is distributed by the copyright owner as a library.
#           A "library" means a collection of software functions and/or data
#           prepared so as to be conveniently linked with application programs
#           (which use some of those functions and data) to form executables.
# 
#       3.  The Software, or any substancial portion of the Software shall not
#           be combined, included, derived, or linked (statically or
#           dynamically) with software or libraries licensed under the terms
#           of any GNU software license, including, but not limited to, the GNU
#           General Public License (GNU/GPL) or the GNU Lesser General Public
#           License (GNU/LGPL).
# 
#       4.  All advertising materials mentioning features or use of this
#           software must display an acknowledgement stating that the product
#           includes software developed by the copyright owner.
# 
#       5.  Neither the name of the copyright owner nor the names of its
#           contributors may be used to endorse or promote products derived from
#           this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT OWNER AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE, TITLE AND NON-INFRINGEMENT ARE DISCLAIMED.
# 
# IN NO EVENT SHALL THE COPYRIGHT OWNER, CONTRIBUTORS OR ANYONE DISTRIBUTING
# THE SOFTWARE BE LIABLE FOR ANY CLAIM, DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN ACTION OF CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF OR IN CONNECTION WITH
# THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
#-------------------------------------------------------------------------------

# $Id$

include ../../../Makefile-Config.mk

#-------------------------------------------------------------------------------
# Display
#-------------------------------------------------------------------------------

PROMPT              := "    ["$(COLOR_GREEN)" XEOS "$(COLOR_NONE)"]> ["$(COLOR_GREEN)" SRC  "$(COLOR_NONE)"]> ["$(COLOR_GREEN)" LIB  "$(COLOR_NONE)"]> ["$(COLOR_GREEN)" POSX "$(COLOR_NONE)"]> *** "

#-------------------------------------------------------------------------------
# Paths
#-------------------------------------------------------------------------------

DIR_SRC_SYS_MMAN    = $(PATH_SRC_LIB_POSIX)sys_mman/
DIR_SRC_UNISTD      = $(PATH_SRC_LIB_POSIX)unistd/
DIR_SRC_SCHED       = $(PATH_SRC_LIB_POSIX)sched/
DIR_SRC_TIME        = $(PATH_SRC_LIB_POSIX)time/
DIR_SRC_SIGNAL      = $(PATH_SRC_LIB_POSIX)signal/
DIR_SRC_AIO         = $(PATH_SRC_LIB_POSIX)aio/
DIR_SRC_NETINET_IN  = $(PATH_SRC_LIB_POSIX)netinet_in/
DIR_SRC_ARPA_INET   = $(PATH_SRC_LIB_POSIX)arpa_inet/
DIR_SRC_CTYPE       = $(PATH_SRC_LIB_POSIX)ctype/

#-------------------------------------------------------------------------------
# Search paths
#-------------------------------------------------------------------------------

# Define the search paths for source files
vpath %$(EXT_C)         $(PATH_SRC_LIB_POSIX)
vpath %$(EXT_C)         $(DIR_SRC_SYS_MMAN)
vpath %$(EXT_C)         $(DIR_SRC_UNISTD)
vpath %$(EXT_C)         $(DIR_SRC_SCHED)
vpath %$(EXT_C)         $(DIR_SRC_TIME)
vpath %$(EXT_C)         $(DIR_SRC_SIGNAL)
vpath %$(EXT_C)         $(DIR_SRC_AIO)
vpath %$(EXT_C)         $(DIR_SRC_NETINET_IN)
vpath %$(EXT_C)         $(DIR_SRC_ARPA_INET)
vpath %$(EXT_C)         $(DIR_SRC_CTYPE)

#-------------------------------------------------------------------------------
# File suffixes
#-------------------------------------------------------------------------------

# Adds the suffixes used in this file
.SUFFIXES:  $(EXT_ASM_32)   \
            $(EXT_ASM_64)   \
            $(EXT_C)        \
            $(EXT_H)        \
            $(EXT_OBJ)      \
            $(EXT_BIN)

#-------------------------------------------------------------------------------
# Files
#-------------------------------------------------------------------------------

_FILES_C_OBJ_BUILD              = $(call XEOS_FUNC_C_OBJ,$(PATH_BUILD_32_LIB_OBJ_POSIX),$(PATH_SRC_LIB_POSIX))
_FILES_C_OBJ_BUILD_SYS_MMAN     = $(call XEOS_FUNC_C_OBJ,$(PATH_BUILD_32_LIB_OBJ_POSIX),$(DIR_SRC_SYS_MMAN))
_FILES_C_OBJ_BUILD_UNISTD       = $(call XEOS_FUNC_C_OBJ,$(PATH_BUILD_32_LIB_OBJ_POSIX),$(DIR_SRC_UNISTD))
_FILES_C_OBJ_BUILD_SCHED        = $(call XEOS_FUNC_C_OBJ,$(PATH_BUILD_32_LIB_OBJ_POSIX),$(DIR_SRC_SCHED))
_FILES_C_OBJ_BUILD_TIME         = $(call XEOS_FUNC_C_OBJ,$(PATH_BUILD_32_LIB_OBJ_POSIX),$(DIR_SRC_TIME))
_FILES_C_OBJ_BUILD_SIGNAL       = $(call XEOS_FUNC_C_OBJ,$(PATH_BUILD_32_LIB_OBJ_POSIX),$(DIR_SRC_SIGNAL))
_FILES_C_OBJ_BUILD_AIO          = $(call XEOS_FUNC_C_OBJ,$(PATH_BUILD_32_LIB_OBJ_POSIX),$(DIR_SRC_AIO))
_FILES_C_OBJ_BUILD_NETINET_IN   = $(call XEOS_FUNC_C_OBJ,$(PATH_BUILD_32_LIB_OBJ_POSIX),$(DIR_SRC_NETINET_IN))
_FILES_C_OBJ_BUILD_ARPA_INET    = $(call XEOS_FUNC_C_OBJ,$(PATH_BUILD_32_LIB_OBJ_POSIX),$(DIR_SRC_ARPA_INET))
_FILES_C_OBJ_BUILD_CTYPE        = $(call XEOS_FUNC_C_OBJ,$(PATH_BUILD_32_LIB_OBJ_POSIX),$(DIR_SRC_CTYPE))

#-------------------------------------------------------------------------------
# Built-in targets
#-------------------------------------------------------------------------------

# Declaration for phony targets, to avoid problems with local files
.PHONY: all     \
        clean

#-------------------------------------------------------------------------------
# Phony targets
#-------------------------------------------------------------------------------

# Build the full project
all:    $(_FILES_C_OBJ_BUILD)               \
        $(_FILES_C_OBJ_BUILD_SYS_MMAN)      \
        $(_FILES_C_OBJ_BUILD_SYSCALL)       \
        $(_FILES_C_OBJ_BUILD_UNISTD)        \
        $(_FILES_C_OBJ_BUILD_SCHED)         \
        $(_FILES_C_OBJ_BUILD_TIME)          \
        $(_FILES_C_OBJ_BUILD_SIGNAL)        \
        $(_FILES_C_OBJ_BUILD_AIO)           \
        $(_FILES_C_OBJ_BUILD_NETINET_IN)    \
        $(_FILES_C_OBJ_BUILD_ARPA_INET)     \
        $(_FILES_C_OBJ_BUILD_CTYPE)
	
	@$(PRINT) $(PROMPT)$(COLOR_CYAN)"Generating the library archive"$(COLOR_NONE)" [ 32 bits ]: "$(COLOR_GRAY)"libposix.a"$(COLOR_NONE)
	@$(AR_32) $(ARGS_AR_32) $(PATH_BUILD_32_LIB_BIN)libposix.a $(PATH_BUILD_32_LIB_OBJ_POSIX)*$(EXT_OBJ)
	@$(RANLIB_32) $(PATH_BUILD_32_LIB_BIN)libposix.a
	
	@$(PRINT) $(PROMPT)$(COLOR_CYAN)"Generating the library archive"$(COLOR_NONE)" [ 64 bits ]: "$(COLOR_GRAY)"libposix.a"$(COLOR_NONE)
	@$(AR_64) $(ARGS_AR_64) $(PATH_BUILD_64_LIB_BIN)libposix.a $(PATH_BUILD_64_LIB_OBJ_POSIX)*$(EXT_OBJ)
	@$(RANLIB_64) $(PATH_BUILD_64_LIB_BIN)libposix.a
	
	@$(PRINT) $(PROMPT)$(COLOR_CYAN)"Generating the dynamic library"$(COLOR_NONE)" [ 32 bits ]: "$(COLOR_GRAY)"libposix.so"$(COLOR_NONE)
	@$(LD_32) $(ARGS_LD_SHARED_32) -o $(PATH_BUILD_32_LIB_BIN)libposix.so $(PATH_BUILD_32_LIB_OBJ_POSIX)*$(EXT_OBJ_PIC)
	
	@$(PRINT) $(PROMPT)$(COLOR_CYAN)"Generating the dynamic library"$(COLOR_NONE)" [ 64 bits ]: "$(COLOR_GRAY)"libposix.so"$(COLOR_NONE)
	@$(LD_64) $(ARGS_LD_SHARED_64) -o $(PATH_BUILD_64_LIB_BIN)libposix.so $(PATH_BUILD_64_LIB_OBJ_POSIX)*$(EXT_OBJ_PIC)

# Cleans the build files
clean:
	
	@$(PRINT) $(PROMPT)"Cleaning all build files"
	@$(RM) $(ARGS_RM) $(PATH_BUILD_32_LIB_OBJ_POSIX)*
	@$(RM) $(ARGS_RM) $(PATH_BUILD_64_LIB_OBJ_POSIX)*
	@$(RM) $(ARGS_RM) $(PATH_BUILD_32_LIB_BIN)libposix.*
	@$(RM) $(ARGS_RM) $(PATH_BUILD_64_LIB_BIN)libposix.*
