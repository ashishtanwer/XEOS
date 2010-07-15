/*******************************************************************************
 * XEOS - x86 Experimental Operating System
 * 
 * Copyright (C) 2010 Jean-David Gadina (macmade@eosgarden.com)
 * All rights reserved
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *  -   Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *  -   Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *  -   Neither the name of 'Jean-David Gadina' nor the names of its
 *      contributors may be used to endorse or promote products derived from
 *      this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************/

/* $Id$ */

#ifndef __LIBC_STDIO_H__
#define __LIBC_STDIO_H__
#pragma once

#include <private/__null.h>
#include <private/__size_t.h>
#include <stdarg.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Size of buffer used by setbuf.
 */
#define BUFSIZ          1024

/**
 * Value used to indicate end-of-stream or to report an error.
 */
#define EOF             -1

/**
 * Maximum length required for array of characters to hold a filename.
 */
#define FILENAME_MAX    1024

/**
 * Maximum number of files which may be open simultaneously.
 */
#define FOPEN_MAX       20

/**
 * Number of characters required for temporary filename generated by tmpnam.
 */
#define L_tmpnam        ( sizeof( "/tmp/" ) + FILENAME_MAX )

/**
 * Value for origin argument to fseek specifying current file position.
 */
#define SEEK_CUR        0x01

/**
 * Value for origin argument to fseek specifying end of file.
 */
#define SEEK_END        0x02

/**
 * Value for origin argument to fseek specifying beginning of file.
 */
#define SEEK_SET        0x00

/**
 * Minimum number of unique filenames generated by calls to tmpnam.
 */
#define TMP_MAX         20

/**
 * Value for mode argument to setvbuf specifying full buffering.
 */
#define _IOFBF          0x01

/**
 * Value for mode argument to setvbuf specifying line buffering.
 */
#define _IOLBF          0x02

/**
 * Value for mode argument to setvbuf specifying no buffering.
 */
#define _IONBF          0x03

/**
 * Type of object holding information necessary to control a stream.
 */
typedef struct
{
    int desc;               /* File descriptor */
    unsigned long pos;      /* Current stream position */
    int eof;                /* End-of-file indicator */
    int error;              /* Error indicator */
    char * buf;             /* Pointer to the stream's buffer, if applicable */
    int std;                /* Whether is stdin, stdout or stderr */
    int open;               /* Whether the file is open or not */
    int mode;               /* Open mode */
    char modeStr[ 4 ];      /* 2nd parameter to fopen */
}
FILE;

/**
 * File pointer for standard input stream. Automatically opened when program
 * execution begins.
 */
extern FILE * stdin;

/**
 * File pointer for standard output stream. Automatically opened when program
 * execution begins.
 */
extern FILE * stdout;

/**
 * File pointer for standard error stream. Automatically opened when program
 * execution begins.
 */
extern FILE * stderr;

/**
 * Type for objects declared to store file position information.
 */
typedef unsigned long int fpos_t;


/**
 * 
 */
FILE * fopen( const char * filename, const char * mode );

/**
 * 
 */
FILE * freopen( const char * filename, const char * mode, FILE * stream );

/**
 * 
 */
int fflush( FILE * stream );

/**
 * 
 */
int fclose( FILE * stream );

/**
 * 
 */
int remove( const char * filename );

/**
 * 
 */
int rename( const char * oldname, const char * newname );

/**
 * 
 */
FILE * tmpfile( void );

/**
 * 
 */
char * tmpnam( char s[ L_tmpnam ] );

/**
 * 
 */
int setvbuf( FILE * stream, char * buf, int mode, size_t size );

/**
 * 
 */
void setbuf( FILE * stream, char * buf );

/**
 * Converts (according to format format) and writes output to stream stream.
 * Number of characters written, or negative value on error, is returned.
 * Conversion specifications consist of:
 *      
 *      -   %
 *      -   (optional) flag:
 *          
 *          -       left adjust
 *          +       always sign
 *          space   space if no sign
 *          0       zero pad
 *          #       Alternate form: for conversion character o, first digit will
 *                  be zero, for [xX], prefix 0x or 0X to non-zero value, for
 *                  [eEfgG], always decimal point, for [gG] trailing zeros not
 *                  removed.
 *          
 *      -   (optional) minimum width: if specified as *, value taken from next
 *          argument (which must be int).
 *      -   (optional) . (separating width from precision):
 *      -   (optional) precision: for conversion character s, maximum characters
 *          to be printed from the string, for [eEf], digits after decimal
 *          point, for [gG], significant digits, for an integer, minimum number
 *          of digits to be printed. If specified as *, value taken from next
 *          argument (which must be int).
 *      -   (optional) length modifier:
 *              
 *          h       short or unsigned short
 *          l       long or unsigned long
 *          L       long double
 *          
 *      conversion character:
 *          
 *          d,i     int argument, printed in signed decimal notation
 *          o       int argument, printed in unsigned octal notation
 *          x,X     int argument, printed in unsigned hexadecimal notation
 *          u       int argument, printed in unsigned decimal notation
 *          c       int argument, printed as single character
 *          s       char* argument
 *          f       double argument, printed with format [-]mmm.ddd
 *          e,E     double argument, printed with format [-]m.dddddd(e|E)(+|-)xx
 *          g,G     double argument
 *          p       void * argument, printed as pointer
 *          n       int * argument : the number of characters written to this
 *                  point is written into argument
 *          %       no argument; prints %  
 */
int fprintf( FILE * stream, const char * format, ... );

/**
 * printf( f, ... ) is equivalent to fprintf( stdout, f, ... )
 */
int printf( const char * format, ... );

/**
 * Like fprintf, but output written into string s, which must be large enough
 * to hold the output, rather than to a stream. Output is NUL-terminated.
 * Returns length (excluding the terminating NUL).
 */
int sprintf( char * s, const char * format, ... );

/**
 * Equivalent to fprintf with variable argument list replaced by arg, which must
 * have been initialised by the va_start macro (and may have been used in calls
 * to va_arg).
 */
int vfprintf( FILE * stream, const char * format, va_list arg );

/**
 * Equivalent to printf with variable argument list replaced by arg, which must
 * have been initialised by the va_start macro (and may have been used in calls
 * to va_arg).
 */
int vprintf( const char * format, va_list arg );

/**
 * Equivalent to sprintf with variable argument list replaced by arg, which must
 * have been initialised by the va_start macro (and may have been used in calls
 * to va_arg).
 */
int vsprintf( char * s, const char * format, va_list arg );

/**
 * 
 */
int fscanf( FILE * stream, const char * format, ... );

/**
 * 
 */
int scanf( const char * format, ... );

/**
 * 
 */
int sscanf( char * s, const char * format, ... );

/**
 * 
 */
int fgetc( FILE * stream );

/**
 * 
 */
char * fgets( char * s, int n, FILE * stream );

/**
 * Writes c, to stream stream. Returns c, or EOF on error.
 */
int fputc( int c, FILE * stream );

/**
 * Writes s, to (output) stream stream. Returns non-negative on success or EOF
 * on error.
 */
int fputs( const char * s, FILE * stream );

/**
 * 
 */
int getc( FILE * stream );

/**
 * 
 */
int getchar( void );

/**
 * 
 */
char * gets( char * s );

/**
 * Equivalent to fputc except that it may be a macro.
 */
#define putc( c, stream ) fputc( c, stream )

/**
 * 
 */
int putchar( int c );

/**
 * Writes s (excluding terminating NUL) and a newline to stdout. Returns
 * non-negative on success, EOF on error.
 */
int puts( const char * s );

/**
 * 
 */
int ungetc( int c, FILE * stream );

/**
 * 
 */
size_t fread( void * ptr, size_t size, size_t nobj, FILE * stream );

/**
 * Writes to stream stream, nobj objects of size size from array ptr.
 * Returns number of objects written.
 */
size_t fwrite( const void * ptr, size_t size, size_t nobj, FILE * stream );

/**
 * Sets file position for stream stream and clears end-of-file indicator.
 * For a binary stream, file position is set to offset bytes from the position
 * indicated by origin: beginning of file for SEEK_SET, current position for
 * SEEK_CUR, or end of file for SEEK_END. Behaviour is similar for a text
 * stream, but offset must be zero or, for SEEK_SET only, a value returned by
 * ftell.
 * Returns non-zero on error.
 */
int fseek( FILE * stream, long offset, int origin );

/**
 * Returns current file position for stream stream, or -1 on error.
 */
long ftell( FILE * stream );

/**
 * Equivalent to fseek(stream, 0L, SEEK_SET); clearerr(stream).
 */
void rewind( FILE * stream );

/**
 * Stores current file position for stream stream in * ptr.
 * Returns non-zero on error.
 */
int fgetpos( FILE * stream, fpos_t * ptr );

/**
 * Sets current position of stream stream to * ptr. Returns non-zero on error.
 */
int fsetpos( FILE * stream, const fpos_t * ptr );

/**
 * Clears end-of-file and error indicators for stream stream.
 */
void clearerr( FILE * stream );

/**
 * Returns non-zero if end-of-file indicator is set for stream stream.
 */
int feof( FILE * stream );

/**
 * Returns non-zero if error indicator is set for stream stream.
 */
int ferror( FILE * stream );

/**
 * Prints s (if non-null) and strerror(errno) to standard error as would:
 * fprintf( stderr, "%s: %s\n", ( s != NULL ? s : "" ), strerror( errno ) )
 */
void perror( const char * s );

#ifdef __cplusplus
}
#endif

#endif /* __LIBC_STDIO_H__ */

