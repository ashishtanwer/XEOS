#!/usr/bin/perl
#
# Format the documentation as PostScript
#

use Env;
use lib $srcdir;

require 'psfonts.ph';		# The fonts we want to use
require 'pswidth.ph';		# PostScript string width

use Fcntl;

#
# PostScript configurables; these values are also available to the
# PostScript code itself
#
%psconf = (
	   pagewidth => 595,    # Page width in PostScript points
	   pageheight => 792,	# Page height in PostScript points
	   lmarg => 100,	# Left margin in PostScript points
	   rmarg => 50,		# Right margin in PostScript points
	   topmarg => 100,	# Top margin in PostScript points
	   botmarg => 100,	# Bottom margin in PostScript points
	   plmarg => 50,	# Page number position relative to left margin
	   prmarg => 0,		# Page number position relative to right margin
	   pymarg => 50,	# Page number position relative to bot margin
	   startcopyright => 75, # How much above the bottom margin is the
	                         # copyright notice stuff
	   bulladj => 12,	# How much to indent a bullet paragraph
	   tocind => 12,	# TOC indentation per level
	   tocpnz => 24,	# Width of TOC page number only zone
	   tocdots => 8,	# Spacing between TOC dots
	   idxspace => 24,	# Minimum space between index title and pg#
	   idxindent => 24,	# How much to indent a subindex entry
	   idxgutter => 24,	# Space between index columns
	   idxcolumns => 2,	# Number of index columns
	   );

%psbool = (
	   colorlinks => 0,	# Set links in blue rather than black
	   );

# Known paper sizes
%papersizes = (
	       'a5'     => [421, 595], # ISO half paper size
	       'b5'     => [501, 709], # ISO small paper size
	       'a4'     => [595, 842], # ISO standard paper size
	       'letter' => [612, 792], # US common paper size
	       'pa4'    => [595, 792], # Compromise ("portable a4")
	       'b4'     => [709,1002], # ISO intermediate paper size
	       'legal'  => [612,1008], # US intermediate paper size
	       'a3'     => [842,1190], # ISO double paper size
	       '11x17'  => [792,1224], # US double paper size
	       );

#
# Parse the command line
#
undef $input;
while ( $arg = shift(@ARGV) ) {
    if ( $arg =~ /^\-(|no\-)(.*)$/ ) {
	$parm = $2;
	$true = ($1 eq '') ? 1 : 0;
	if ( $true && defined($papersizes{$parm}) ) {
	    $psconf{pagewidth}  = $papersizes{$parm}->[0];
	    $psconf{pageheight} = $papersizes{$parm}->[1];
	} elsif ( defined($psbool{$parm}) ) {
	    $psbool{$parm} = $true;
	} elsif ( $true && defined($psconf{$parm}) ) {
	    $psconf{$parm} = shift(@ARGV);
	} elsif ( $parm =~ /^(title|subtitle|year|author|license)$/ ) {
	    $metadata{$parm} = shift(@ARGV);
	} else {
	    die "$0: Unknown option: $arg\n";
	}
    } else {
	$input = $arg;
    }
}

#
# Document formatting parameters
#
$paraskip = 6;			# Space between paragraphs
$chapstart = 30;		# Space before a chapter heading
$chapskip = 24;			# Space after a chapter heading
$tocskip = 6;			# Space between TOC entries

# Configure post-paragraph skips for each kind of paragraph
%skiparray = ('chap' => $chapskip, 'appn' => $chapstart,
	      'head' => $paraskip, 'subh' => $paraskip,
	      'norm' => $paraskip, 'bull' => $paraskip,
	      'code' => $paraskip, 'toc0' => $tocskip,
	      'toc1' => $tocskip,  'toc2' => $tocskip);

# Custom encoding vector.  This is basically the same as
# ISOLatin1Encoding (a level 2 feature, so we dont want to use it),
# but with the "naked" accents at \200-\237 moved to the \000-\037
# range (ASCII control characters), and a few extra characters thrown
# in.  It is basically a modified Windows 1252 codepage, minus, for
# now, the euro sign (\200 is reserved for euro.)

@NASMEncoding =
(
 undef, undef, undef, undef, undef, undef, undef, undef, undef, undef,
 undef, undef, undef, undef, undef, undef, 'dotlessi', 'grave',
 'acute', 'circumflex', 'tilde', 'macron', 'breve', 'dotaccent',
 'dieresis', undef, 'ring', 'cedilla', undef, 'hungarumlaut',
 'ogonek', 'caron', 'space', 'exclam', 'quotedbl', 'numbersign',
 'dollar', 'percent', 'ampersand', 'quoteright', 'parenleft',
 'parenright', 'asterisk', 'plus', 'comma', 'minus', 'period',
 'slash', 'zero', 'one', 'two', 'three', 'four', 'five', 'six',
 'seven', 'eight', 'nine', 'colon', 'semicolon', 'less', 'equal',
 'greater', 'question', 'at', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V',
 'W', 'X', 'Y', 'Z', 'bracketleft', 'backslash', 'bracketright',
 'asciicircum', 'underscore', 'quoteleft', 'a', 'b', 'c', 'd', 'e',
 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
 't', 'u', 'v', 'w', 'x', 'y', 'z', 'braceleft', 'bar', 'braceright',
 'asciitilde', undef, undef, undef, 'quotesinglbase', 'florin',
 'quotedblbase', 'ellipsis', 'dagger', 'dbldagger', 'circumflex',
 'perthousand', 'Scaron', 'guilsinglleft', 'OE', undef, 'Zcaron',
 undef, undef, 'grave', 'quotesingle', 'quotedblleft',
 'quotedblright', 'bullet', 'endash', 'emdash', 'tilde', 'trademark',
 'scaron', 'guilsignlright', 'oe', undef, 'zcaron', 'Ydieresis',
 'space', 'exclamdown', 'cent', 'sterling', 'currency', 'yen',
 'brokenbar', 'section', 'dieresis', 'copyright', 'ordfeminine',
 'guillemotleft', 'logicalnot', 'hyphen', 'registered', 'macron',
 'degree', 'plusminus', 'twosuperior', 'threesuperior', 'acute', 'mu',
 'paragraph', 'periodcentered', 'cedilla', 'onesuperior',
 'ordmasculine', 'guillemotright', 'onequarter', 'onehalf',
 'threequarters', 'questiondown', 'Agrave', 'Aacute', 'Acircumflex',
 'Atilde', 'Adieresis', 'Aring', 'AE', 'Ccedilla', 'Egrave', 'Eacute',
 'Ecircumflex', 'Edieresis', 'Igrave', 'Iacute', 'Icircumflex',
 'Idieresis', 'Eth', 'Ntilde', 'Ograve', 'Oacute', 'Ocircumflex',
 'Otilde', 'Odieresis', 'multiply', 'Oslash', 'Ugrave', 'Uacute',
 'Ucircumflex', 'Udieresis', 'Yacute', 'Thorn', 'germandbls',
 'agrave', 'aacute', 'acircumflex', 'atilde', 'adieresis', 'aring',
 'ae', 'ccedilla', 'egrave', 'eacute', 'ecircumflex', 'edieresis',
 'igrave', 'iacute', 'icircumflex', 'idieresis', 'eth', 'ntilde',
 'ograve', 'oacute', 'ocircumflex', 'otilde', 'odieresis', 'divide',
 'oslash', 'ugrave', 'uacute', 'ucircumflex', 'udieresis', 'yacute',
 'thorn', 'ydieresis'
);

# Name-to-byte lookup hash
%charcode = ();
for ( $i = 0 ; $i < 256 ; $i++ ) {
    $charcode{$NASMEncoding[$i]} = chr($i);
}

#
# First, format the stuff coming from the front end into
# a cleaner representation
#
if ( defined($input) ) {
    sysopen(PARAS, $input, O_RDONLY) or
	die "$0: cannot open $input: $!\n";
} else {
    open(PARAS, "<&STDIN") or die "$0: $!\n";
}
while ( defined($line = <PARAS>) ) {
    chomp $line;
    $data = <PARAS>;
    chomp $data;
    if ( $line =~ /^meta :(.*)$/ ) {
	$metakey = $1;
	$metadata{$metakey} = $data;
    } elsif ( $line =~ /^indx :(.*)$/ ) {
	$ixentry = $1;
	push(@ixentries, $ixentry);
	$ixterms{$ixentry} = [split(/\037/, $data)];
	# Look for commas.  This is easier done on the string
	# representation, so do it now.
	if ( $data =~ /^(.*)\,\037sp\037/ ) {
	    $ixprefix = $1;
	    $ixprefix =~ s/\037n $//; # Discard possible font change at end
	    $ixhasprefix{$ixentry} = $ixprefix;
	    if ( !$ixprefixes{$ixprefix} ) {
		$ixcommafirst{$ixentry}++;
	    }
	    $ixprefixes{$ixprefix}++;
	} else {
	    # A complete term can also be used as a prefix
	    $ixprefixes{$data}++;
	}
    } else {
	push(@ptypes, $line);
	push(@paras, [split(/\037/, $data)]);
    }
}
close(PARAS);

#
# Convert an integer to a chosen base
#
sub int2base($$) {
    my($i,$b) = @_;
    my($s) = '';
    my($n) = '';
    my($z) = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return '0' if ($i == 0);
    if ( $i < 0 ) { $n = '-'; $i = -$i; }
    while ( $i ) {
	$s = substr($z,$i%$b,1) . $s;
	$i = int($i/$b);
    }
    return $n.$s;
}

#
# Convert a string to a rendering array
#
sub string2array($)
{
    my($s) = @_;
    my(@a) = ();

    $s =~ s/ \- / $charcode{'endash'} /g;	# Replace " - " with en dash

    while ( $s =~ /^(\s+|\S+)(.*)$/ ) {
	push(@a, [0,$1]);
	$s = $2;
    }

    return @a;
}

#
# Take a crossreference name and generate the PostScript name for it.
#
# This hack produces a somewhat smaller PDF...
#%ps_xref_list = ();
#$ps_xref_next = 0;
#sub ps_xref($) {
#    my($s) = @_;
#    my $q = $ps_xref_list{$s};
#    return $q if ( defined($ps_xref_list{$s}) );
#    $q = 'X'.int2base($ps_xref_next++, 52);
#    $ps_xref_list{$s} = $q;
#    return $q;
#}

# Somewhat bigger PDF, but one which obeys # URLs
sub ps_xref($) {
    return @_[0];
}

#
# Flow lines according to a particular font set and width
#
# A "font set" is represented as an array containing
# arrays of pairs: [<size>, <metricref>]
#
# Each line is represented as:
# [ [type,first|last,aux,fontset,page,ypos,optional col],
#   [rendering array] ]
#
# A space character may be "squeezed" by up to this much
# (as a fraction of the normal width of a space.)
#
$ps_space_squeeze = 0.00;	# Min space width 100%
sub ps_flow_lines($$$@) {
    my($wid, $fontset, $type, @data) = @_;
    my($fonts) = $$fontset{fonts};
    my($e);
    my($w)  = 0;		# Width of current line
    my($sw) = 0;		# Width of current line due to spaces
    my(@l)  = ();		# Current line
    my(@ls) = ();		# Accumulated output lines
    my(@xd) = ();		# Metadata that goes with subsequent text
    my $hasmarker = 0;		# Line has -6 marker
    my $pastmarker = 0;		# -6 marker found

    # If there is a -6 marker anywhere in the paragraph,
    # *each line* output needs to have a -6 marker
    foreach $e ( @data ) {
	$hasmarker = 1 if ( $$e[0] == -6 );
    }

    $w = 0;
    foreach $e ( @data ) {
	if ( $$e[0] < 0 ) {
	    # Type is metadata.  Zero width.
	    if ( $$e[0] == -6 ) {
		$pastmarker = 1;
	    }
	    if ( $$e[0] == -1 || $$e[0] == -6 ) {
		# -1 (end anchor) or -6 (marker) goes with the preceeding
		# text, otherwise with the subsequent text
		push(@l, $e);
	    } else {
		push(@xd, $e);
	    }
	} else {
	    my $ew = ps_width($$e[1], $fontset->{fonts}->[$$e[0]][1],
			      \@NASMEncoding) *
		($fontset->{fonts}->[$$e[0]][0]/1000);
	    my $sp = $$e[1];
	    $sp =~ tr/[^ ]//d;	# Delete nonspaces
	    my $esw = ps_width($sp, $fontset->{fonts}->[$$e[0]][1],
			       \@NASMEncoding) *
		($fontset->{fonts}->[$$e[0]][0]/1000);

	    if ( ($w+$ew) - $ps_space_squeeze*($sw+$esw) > $wid ) {
		# Begin new line
		# Search backwards for previous space chunk
		my $lx = scalar(@l)-1;
		my @rm = ();
		while ( $lx >= 0 ) {
		    while ( $lx >= 0 && $l[$lx]->[0] < 0 ) {
			# Skip metadata
			$pastmarker = 0 if ( $l[$lx]->[0] == -6 );
			$lx--;
		    };
		    if ( $lx >= 0 ) {
			if ( $l[$lx]->[1] eq ' ' ) {
			    splice(@l, $lx, 1);
			    @rm = splice(@l, $lx);
			    last; # Found place to break
			} else {
			    $lx--;
			}
		    }
		}

		# Now @l contains the stuff to remain on the old line
		# If we broke the line inside a link, then split the link
		# into two.
		my $lkref = undef;
		foreach my $lc ( @l ) {
		    if ( $$lc[0] == -2 || $$lc[0] == -3 || $lc[0] == -7 ) {
			$lkref = $lc;
		    } elsif ( $$lc[0] == -1 ) {
			undef $lkref;
		    }
		}

		if ( defined($lkref) ) {
		    push(@l, [-1,undef]); # Terminate old reference
		    unshift(@rm, $lkref); # Duplicate reference on new line
		}

		if ( $hasmarker ) {
		    if ( $pastmarker ) {
			unshift(@rm,[-6,undef]); # New line starts with marker
		    } else {
			push(@l,[-6,undef]); # Old line ends with marker
		    }
		}

		push(@ls, [[$type,0,undef,$fontset,0,0],[@l]]);
		@l = @rm;

		$w = $sw = 0;
		# Compute the width of the remainder array
		for my $le ( @l ) {
		    if ( $$le[0] >= 0 ) {
			my $xew = ps_width($$le[1],
					   $fontset->{fonts}->[$$le[0]][1],
					   \@NASMEncoding) *
			    ($fontset->{fonts}->[$$le[0]][0]/1000);
			my $xsp = $$le[1];
			$xsp =~ tr/[^ ]//d;	# Delete nonspaces
			my $xsw = ps_width($xsp,
					   $fontset->{fonts}->[$$le[0]][1],
					   \@NASMEncoding) *
			    ($fontset->{fonts}->[$$le[0]][0]/1000);
			$w += $xew;  $sw += $xsw;
		    }
		}
	    }
	    push(@l, @xd);	# Accumulated metadata
	    @xd = ();
	    if ( $$e[1] ne '' ) {
		push(@l, $e);
		$w += $ew; $sw += $esw;
	    }
	}
    }
    push(@l,@xd);
    if ( scalar(@l) ) {
	push(@ls, [[$type,0,undef,$fontset,0,0],[@l]]);	# Final line
    }

    # Mark the first line as first and the last line as last
    if ( scalar(@ls) ) {
	$ls[0]->[0]->[1] |= 1;	   # First in para
	$ls[-1]->[0]->[1] |= 2;    # Last in para
    }
    return @ls;
}

#
# Once we have broken things into lines, having multiple chunks
# with the same font index is no longer meaningful.  Merge
# adjacent chunks to keep down the size of the whole file.
#
sub ps_merge_chunks(@) {
    my(@ci) = @_;
    my($c, $lc);
    my(@co, $eco);

    undef $lc;
    @co = ();
    $eco = -1;			# Index of the last entry in @co
    foreach $c ( @ci ) {
	if ( defined($lc) && $$c[0] == $lc && $$c[0] >= 0 ) {
	    $co[$eco]->[1] .= $$c[1];
	} else {
	    push(@co, $c);  $eco++;
	    $lc = $$c[0];
	}
    }
    return @co;
}

#
# Convert paragraphs to rendering arrays.  Each
# element in the array contains (font, string),
# where font can be one of:
# -1 end link
# -2 begin crossref
# -3 begin weblink
# -4 index item anchor
# -5 crossref anchor
# -6 left/right marker (used in the index)
# -7 page link (used in the index)
#  0 normal
#  1 empatic (italic)
#  2 code (fixed spacing)
#

sub mkparaarray($@) {
    my($ptype, @chunks) = @_;

    my @para = ();
    my $in_e = 0;
    my $chunk;

    if ( $ptype =~ /^code/ ) {
	foreach $chunk ( @chunks ) {
	    push(@para, [2, $chunk]);
	}
    } else {
	foreach $chunk ( @chunks ) {
	    my $type = substr($chunk,0,2);
	    my $text = substr($chunk,2);

	    if ( $type eq 'sp' ) {
		push(@para, [$in_e?1:0, ' ']);
	    } elsif ( $type eq 'da' ) {
		push(@para, [$in_e?1:0, $charcode{'endash'}]);
	    } elsif ( $type eq 'n ' ) {
		push(@para, [0, $text]);
		$in_e = 0;
	    } elsif ( $type =~ '^e' ) {
		push(@para, [1, $text]);
		$in_e = ($type eq 'es' || $type eq 'e ');
	    } elsif ( $type eq 'c ' ) {
		push(@para, [2, $text]);
		$in_e = 0;
	    } elsif ( $type eq 'x ' ) {
		push(@para, [-2, ps_xref($text)]);
	    } elsif ( $type eq 'xe' ) {
		push(@para, [-1, undef]);
	    } elsif ( $type eq 'wc' || $type eq 'w ' ) {
		$text =~ /\<(.*)\>(.*)$/;
		my $link = $1; $text = $2;
		push(@para, [-3, $link]);
		push(@para, [($type eq 'wc') ? 2:0, $text]);
		push(@para, [-1, undef]);
		$in_e = 0;
	    } elsif ( $type eq 'i ' ) {
		push(@para, [-4, $text]);
	    } else {
		die "Unexpected paragraph chunk: $chunk";
	    }
	}
    }
    return @para;
}

$npara = scalar(@paras);
for ( $i = 0 ; $i < $npara ; $i++ ) {
    $paras[$i] = [mkparaarray($ptypes[$i], @{$paras[$i]})];
}

#
# This converts a rendering array to a simple string
#
sub ps_arraytostr(@) {
    my $s = '';
    my $c;
    foreach $c ( @_ ) {
	$s .= $$c[1] if ( $$c[0] >= 0 );
    }
    return $s;
}

#
# This generates a duplicate of a paragraph
#
sub ps_dup_para(@) {
    my(@i) = @_;
    my(@o) = ();
    my($c);

    foreach $c ( @i ) {
	my @cc = @{$c};
	push(@o, [@cc]);
    }
    return @o;
}

#
# This generates a duplicate of a paragraph, stripping anchor
# tags (-4 and -5)
#
sub ps_dup_para_noanchor(@) {
    my(@i) = @_;
    my(@o) = ();
    my($c);

    foreach $c ( @i ) {
	my @cc = @{$c};
	push(@o, [@cc]) unless ( $cc[0] == -4 || $cc[0] == -5 );
    }
    return @o;
}

#
# Scan for header paragraphs and fix up their contents;
# also generate table of contents and PDF bookmarks.
#
@tocparas = ([[-5, 'contents'], [0,'Contents']]);
@tocptypes = ('chap');
@bookmarks = (['title', 0, 'Title'], ['contents', 0, 'Contents']);
%bookref = ();
for ( $i = 0 ; $i < $npara ; $i++ ) {
    my $xtype = $ptypes[$i];
    my $ptype = substr($xtype,0,4);
    my $str;
    my $book;

    if ( $ptype eq 'chap' || $ptype eq 'appn' ) {
	unless ( $xtype =~ /^\S+ (\S+) :(.*)$/ ) {
	    die "Bad para";
	}
	my $secn = $1;
	my $sech = $2;
	my $xref = ps_xref($sech);
	my $chap = ($ptype eq 'chap')?'Chapter':'Appendix';

	$book = [$xref, 0, ps_arraytostr(@{$paras[$i]})];
	push(@bookmarks, $book);
	$bookref{$secn} = $book;

	push(@tocparas, [ps_dup_para_noanchor(@{$paras[$i]})]);
	push(@tocptypes, 'toc0'.' :'.$sech.':'.$chap.' '.$secn.':');

	unshift(@{$paras[$i]},
		[-5, $xref], [0,$chap.' '.$secn.':'], [0, ' ']);
    } elsif ( $ptype eq 'head' || $ptype eq 'subh' ) {
	unless ( $xtype =~ /^\S+ (\S+) :(.*)$/ ) {
	    die "Bad para";
	}
	my $secn = $1;
	my $sech = $2;
	my $xref = ps_xref($sech);
	my $pref;
	$pref = $secn; $pref =~ s/\.[^\.]+$//; # Find parent node

	$book = [$xref, 0, ps_arraytostr(@{$paras[$i]})];
	push(@bookmarks, $book);
	$bookref{$secn} = $book;
	$bookref{$pref}->[1]--;	# Adjust count for parent node

	push(@tocparas, [ps_dup_para_noanchor(@{$paras[$i]})]);
	push(@tocptypes,
	     (($ptype eq 'subh') ? 'toc2':'toc1').' :'.$sech.':'.$secn);

	unshift(@{$paras[$i]}, [-5, $xref]);
    }
}

#
# Add TOC to beginning of paragraph list
#
unshift(@paras,  @tocparas);  undef @tocparas;
unshift(@ptypes, @tocptypes); undef @tocptypes;

#
# Add copyright notice to the beginning
#
unshift(@paras,
	[[0, $charcode{'copyright'}], [0, ' '], [0,$metadata{'year'}],
	 [0, ' '], string2array($metadata{'author'})],
	[string2array($metadata{'license'})]);
unshift(@ptypes, 'norm', 'norm');

$npara = scalar(@paras);

#
# No lines generated, yet.
#
@pslines    = ();

#
# Line Auxilliary Information Types
#
$AuxStr	    = 1;		# String
$AuxPage    = 2;		# Page number (from xref)
$AuxPageStr = 3;		# Page number as a PostScript string
$AuxXRef    = 4;		# Cross reference as a name
$AuxNum     = 5;		# Number

#
# Break or convert paragraphs into lines, and push them
# onto the @pslines array.
#
sub ps_break_lines($$) {
    my ($paras,$ptypes) = @_;

    my $linewidth  = $psconf{pagewidth}-$psconf{lmarg}-$psconf{rmarg};
    my $bullwidth  = $linewidth-$psconf{bulladj};
    my $indxwidth  = ($linewidth-$psconf{idxgutter})/$psconf{idxcolumns}
                     -$psconf{idxspace};

    my $npara = scalar(@{$paras});
    my $i;

    for ( $i = 0 ; $i < $npara ; $i++ ) {
	my $xtype = $ptypes->[$i];
	my $ptype = substr($xtype,0,4);
	my @data = @{$paras->[$i]};
	my @ls = ();
	if ( $ptype eq 'code' ) {
	    my $p;
	    # Code paragraph; each chunk is a line
	    foreach $p ( @data ) {
		push(@ls, [[$ptype,0,undef,\%BodyFont,0,0],[$p]]);
	    }
	    $ls[0]->[0]->[1] |= 1;	     # First in para
	    $ls[-1]->[0]->[1] |= 2;      # Last in para
	} elsif ( $ptype eq 'chap' || $ptype eq 'appn' ) {
	    # Chapters are flowed normally, but in an unusual font
	    @ls = ps_flow_lines($linewidth, \%ChapFont, $ptype, @data);
	} elsif ( $ptype eq 'head' || $ptype eq 'subh' ) {
	    unless ( $xtype =~ /^\S+ (\S+) :(.*)$/ ) {
		die "Bad para";
	    }
	    my $secn = $1;
	    my $sech = $2;
	    my $font = ($ptype eq 'head') ? \%HeadFont : \%SubhFont;
	    @ls = ps_flow_lines($linewidth, $font, $ptype, @data);
	    # We need the heading number as auxillary data
	    $ls[0]->[0]->[2] = [[$AuxStr,$secn]];
	} elsif ( $ptype eq 'norm' ) {
	    @ls = ps_flow_lines($linewidth, \%BodyFont, $ptype, @data);
	} elsif ( $ptype eq 'bull' ) {
	    @ls = ps_flow_lines($bullwidth, \%BodyFont, $ptype, @data);
	} elsif ( $ptype =~ /^toc/ ) {
	    unless ( $xtype =~/^\S+ :([^:]*):(.*)$/ ) {
		die "Bad para";
	    }
	    my $xref = $1;
	    my $refname = $2.' ';
	    my $ntoc = substr($ptype,3,1)+0;
	    my $refwidth = ps_width($refname, $BodyFont{fonts}->[0][1],
				    \@NASMEncoding) *
		($BodyFont{fonts}->[0][0]/1000);

	    @ls = ps_flow_lines($linewidth-$ntoc*$psconf{tocind}-
				$psconf{tocpnz}-$refwidth,
				\%BodyFont, $ptype, @data);

	    # Auxilliary data: for the first line, the cross reference symbol
	    # and the reference name; for all lines but the first, the
	    # reference width; and for the last line, the page number
	    # as a string.
	    my $nl = scalar(@ls);
	    $ls[0]->[0]->[2] = [[$AuxStr,$refname], [$AuxXRef,$xref]];
	    for ( $j = 1 ; $j < $nl ; $j++ ) {
		$ls[$j]->[0]->[2] = [[$AuxNum,$refwidth]];
	    }
	    push(@{$ls[$nl-1]->[0]->[2]}, [$AuxPageStr,$xref]);
	} elsif ( $ptype =~ /^idx/ ) {
	    my $lvl = substr($ptype,3,1)+0;

	    @ls = ps_flow_lines($indxwidth-$lvl*$psconf{idxindent},
				\%BodyFont, $ptype, @data);
	} else {
	    die "Unknown para type: $ptype";
	}
	# Merge adjacent identical chunks
	foreach $l ( @ls ) {
	    @{$$l[1]} = ps_merge_chunks(@{$$l[1]});
	}
	push(@pslines,@ls);
    }
}

# Break the main body text into lines.
ps_break_lines(\@paras, \@ptypes);

#
# Break lines in to pages
#

# Where to start on page 2, the copyright page
$curpage = 2;			# Start on page 2
$curypos = $psconf{pageheight}-$psconf{topmarg}-$psconf{botmarg}-
    $psconf{startcopyright};
undef $columnstart;		# Not outputting columnar text
undef $curcolumn;		# Current column
$nlines = scalar(@pslines);

#
# This formats lines inside the global @pslines array into pages,
# updating the page and y-coordinate entries.  Start at the
# $startline position in @pslines and go to but not including
# $endline.  The global variables $curpage, $curypos, $columnstart
# and $curcolumn are updated appropriately.
#
sub ps_break_pages($$) {
    my($startline, $endline) = @_;

    # Paragraph types which should never be broken
    my $nobreakregexp = "^(chap|appn|head|subh|toc.|idx.)\$";
    # Paragraph types which are heading (meaning they should not be broken
    # immediately after)
    my $nobreakafter = "^(chap|appn|head|subh)\$";
    # Paragraph types which should never be broken *before*
    my $nobreakbefore = "^idx[1-9]\$";
    # Paragraph types which are set in columnar format
    my $columnregexp = "^idx.\$";

    my $upageheight = $psconf{pageheight}-$psconf{topmarg}-$psconf{botmarg};

    my $i;

    for ( $i = $startline ; $i < $endline ; $i++ ) {
	my $linfo = $pslines[$i]->[0];
	if ( ($$linfo[0] eq 'chap' || $$linfo[0] eq 'appn' )
	     && ($$linfo[1] & 1) ) {
	    # First line of a new chapter heading.  Start a new page.
	    undef $columnstart;
	    $curpage++ if ( $curypos > 0 || defined($columnstart) );
	    $curypos = $chapstart;
	} elsif ( defined($columnstart) && $$linfo[0] !~ /$columnregexp/o ) {
	    undef $columnstart;
	    $curpage++;
	    $curypos = 0;
	}

	if ( $$linfo[0] =~ /$columnregexp/o && !defined($columnstart) ) {
	    $columnstart = $curypos;
	    $curcolumn = 0;
	}

	# Adjust position by the appropriate leading
	$curypos += $$linfo[3]->{leading};

	# Record the page and y-position
	$$linfo[4] = $curpage;
	$$linfo[5] = $curypos;
	$$linfo[6] = $curcolumn if ( defined($columnstart) );

	if ( $curypos > $upageheight ) {
	    # We need to break the page before this line.
	    my $broken = 0;		# No place found yet
	    while ( !$broken && $pslines[$i]->[0]->[4] == $curpage ) {
		my $linfo = $pslines[$i]->[0];
		my $pinfo = $pslines[$i-1]->[0];

		if ( $$linfo[1] == 2 ) {
		    # This would be an orphan, don't break.
		} elsif ( $$linfo[1] & 1 ) {
		    # Sole line or start of paragraph.  Break unless
		    # the previous line was part of a heading.
		    $broken = 1 if ( $$pinfo[0] !~ /$nobreakafter/o &&
				     $$linfo[0] !~ /$nobreakbefore/o );
		} else {
		    # Middle of paragraph.  Break unless we're in a
		    # no-break paragraph, or the previous line would
		    # end up being a widow.
		    $broken = 1 if ( $$linfo[0] !~ /$nobreakregexp/o &&
				     $$pinfo[1] != 1 );
		}
		$i--;
	    }
	    die "Nowhere to break page $curpage\n" if ( !$broken );
	    # Now $i should point to line immediately before the break, i.e.
	    # the next paragraph should be the first on the new page
	    if ( defined($columnstart) &&
		 ++$curcolumn < $psconf{idxcolumns} ) {
		# We're actually breaking text into columns, not pages
		$curypos = $columnstart;
	    } else {
		undef $columnstart;
		$curpage++;
		$curypos = 0;
	    }
	    next;
	}

	# Add end of paragraph skip
	if ( $$linfo[1] & 2 ) {
	    $curypos += $skiparray{$$linfo[0]};
	}
    }
}

ps_break_pages(0,$nlines);	# Break the main text body into pages

#
# Find the page number of all the indices
#
%ps_xref_page   = ();		# Crossref anchor pages
%ps_index_pages = ();		# Index item pages
$nlines = scalar(@pslines);
for ( $i = 0 ; $i < $nlines ; $i++ ) {
    my $linfo = $pslines[$i]->[0];
    foreach my $c ( @{$pslines[$i]->[1]} ) {
	if ( $$c[0] == -4 ) {
	    if ( !defined($ps_index_pages{$$c[1]}) ) {
		$ps_index_pages{$$c[1]} = [];
	    } elsif ( $ps_index_pages{$$c[1]}->[-1] eq $$linfo[4] ) {
		# Pages are emitted in order; if this is a duplicated
		# entry it will be the last one
		next;		# Duplicate
	    }
	    push(@{$ps_index_pages{$$c[1]}}, $$linfo[4]);
	} elsif ( $$c[0] == -5 ) {
	    $ps_xref_page{$$c[1]} = $$linfo[4];
	}
    }
}

#
# Emit index paragraphs
#
$startofindex = scalar(@pslines);
@ixparas = ([[-5,'index'],[0,'Index']]);
@ixptypes = ('chap');

foreach $k ( @ixentries ) {
    my $n,$i;
    my $ixptype = 'idx0';
    my $prefix = $ixhasprefix{$k};
    my @ixpara = mkparaarray($ixptype,@{$ixterms{$k}});
    my $commapos = undef;

    if ( defined($prefix) && $ixprefixes{$prefix} > 1 ) {
	# This entry has a "hanging comma"
	for ( $i = 0 ; $i < scalar(@ixpara)-1 ; $i++ ) {
	    if ( substr($ixpara[$i]->[1],-1,1) eq ',' &&
		 $ixpara[$i+1]->[1] eq ' ' ) {
		$commapos = $i;
		last;
	    }
	}
    }
    if ( defined($commapos) ) {
	if ( $ixcommafirst{$k} ) {
	    # This is the first entry; generate the
	    # "hanging comma" entry
	    my @precomma = splice(@ixpara,0,$commapos);
	    if ( $ixpara[0]->[1] eq ',' ) {
		shift(@ixpara);	# Discard lone comma
	    } else {
		# Discard attached comma
		$ixpara[0]->[1] =~ s/\,$//;
		push(@precomma,shift(@ixpara));
	    }
	    push(@precomma, [-6,undef]);
	    push(@ixparas, [@precomma]);
	    push(@ixptypes, $ixptype);
	    shift(@ixpara);	# Remove space
	} else {
	    splice(@ixpara,0,$commapos+2);
	}
	$ixptype = 'idx1';
    }

    push(@ixpara, [-6,undef]);	# Left/right marker
    $i = 1;  $n = scalar(@{$ps_index_pages{$k}});
    foreach $p ( @{$ps_index_pages{$k}} ) {
	if ( $i++ == $n ) {
	    push(@ixpara,[-7,$p],[0,"$p"],[-1,undef]);
	} else {
	    push(@ixpara,[-7,$p],[0,"$p,"],[-1,undef],[0,' ']);
	}
    }

    push(@ixparas, [@ixpara]);
    push(@ixptypes, $ixptype);
}

#
# Flow index paragraphs into lines
#
ps_break_lines(\@ixparas, \@ixptypes);

#
# Format index into pages
#
$nlines = scalar(@pslines);
ps_break_pages($startofindex, $nlines);

#
# Push index onto bookmark list
#
push(@bookmarks, ['index', 0, 'Index']);

# Get the list of fonts used
%ps_all_fonts = ();
foreach $fset ( @AllFonts ) {
    foreach $font ( @{$fset->{fonts}} ) {
	$ps_all_fonts{$font->[1]->{name}}++;
    }
}

# Emit the PostScript DSC header
print "%!PS-Adobe-3.0\n";
print "%%Pages: $curpage\n";
print "%%BoundingBox: 0 0 ", $psconf{pagewidth}, ' ', $psconf{pageheight}, "\n";
print "%%Creator: (NASM psflow.pl)\n";
print "%%DocumentData: Clean7Bit\n";
print "%%DocumentFonts: ", join(' ', keys(%ps_all_fonts)), "\n";
print "%%DocumentNeededFonts: ", join(' ', keys(%ps_all_fonts)), "\n";
print "%%Orientation: Portrait\n";
print "%%PageOrder: Ascend\n";
print "%%EndComments\n";
print "%%BeginProlog\n";

# Emit the configurables as PostScript tokens
foreach $c ( keys(%psconf) ) {
    print "/$c ", $psconf{$c}, " def\n";
}
foreach $c ( keys(%psbool) ) {
    print "/$c ", ($psbool{$c}?'true':'false'), " def\n";
}

# Emit custom encoding vector
$zstr = '/NASMEncoding [ ';
foreach $c ( @NASMEncoding ) {
    my $z = '/'.(defined($c)?$c:'.notdef ').' ';
    if ( length($zstr)+length($z) > 72 ) {
	print $zstr,"\n";
	$zstr = ' ';
    }
    $zstr .= $z;
}
print $zstr, "] def\n";

# Font recoding routine
# newname fontname --
print "/nasmenc {\n";
print "  findfont dup length dict begin\n";
print "    { 1 index /FID ne {def}{pop pop} ifelse } forall\n";
print "    /Encoding NASMEncoding def\n";
print "    currentdict\n";
print "  end\n";
print "  definefont pop\n";
print "} def\n";

# Emit fontset definitions
foreach $font ( keys(%ps_all_fonts) ) {
    print '/',$font,'-NASM /',$font," nasmenc\n";
}

foreach $fset ( @AllFonts ) {
    my $i = 0;
    my @zfonts = ();
    foreach $font ( @{$fset->{fonts}} ) {
	print '/', $fset->{name}, $i, ' ',
	'/', $font->[1]->{name}, '-NASM findfont ',
	$font->[0], " scalefont def\n";
	push(@zfonts, $fset->{name}.$i);
	$i++;
    }
    print '/', $fset->{name}, ' [', join(' ',@zfonts), "] def\n";
}

# This is used by the bullet-paragraph PostScript methods
print "/bullet [",ps_string($charcode{'bullet'}),"] def\n";

# Emit the canned PostScript prologue
open(PSHEAD, "< head.ps");
while ( defined($line = <PSHEAD>) ) {
    print $line;
}
close(PSHEAD);
print "%%EndProlog\n";

# Generate a PostScript string
sub ps_string($) {
    my ($s) = @_;
    my ($i,$c);
    my ($o) = '(';
    my ($l) = length($s);
    for ( $i = 0 ; $i < $l ; $i++ ) {
	$c = substr($s,$i,1);
	if ( ord($c) < 32 || ord($c) > 126 ) {
	    $o .= sprintf("\\%03o", ord($c));
	} elsif ( $c eq '(' || $c eq ')' || $c eq "\\" ) {
	    $o .= "\\".$c;
	} else {
	    $o .= $c;
	}
    }
    return $o.')';
}

# Generate PDF bookmarks
print "%%BeginSetup\n";
foreach $b ( @bookmarks ) {
    print '[/Title ', ps_string($b->[2]), "\n";
    print '/Count ', $b->[1], ' ' if ( $b->[1] );
    print '/Dest /',$b->[0]," /OUT pdfmark\n";
}

# Ask the PostScript interpreter for the proper size media
print "setpagesize\n";
print "%%EndSetup\n";

# Start a PostScript page
sub ps_start_page() {
    $ps_page++;
    print "%%Page: $ps_page $ps_page\n";
    print "%%BeginPageSetup\n";
    print "save\n";
    print "%%EndPageSetup\n";
    print '/', $ps_page, " pa\n";
}

# End a PostScript page
sub ps_end_page($) {
    my($pn) = @_;
    if ( $pn ) {
	print "($ps_page)", (($ps_page & 1) ? 'pageodd' : 'pageeven'), "\n";
    }
    print "restore showpage\n";
}

$ps_page = 0;

# Title page
ps_start_page();
$title = $metadata{'title'} || '';
$title =~ s/ \- / $charcode{'emdash'} /;

$subtitle = $metadata{'subtitle'} || '';
$subtitle =~ s/ \- / $charcode{'emdash'} /;

# Print title
print "/ti ", ps_string($title), " def\n";
print "/sti ", ps_string($subtitle), " def\n";
print "lmarg pageheight 2 mul 3 div moveto\n";
print "tfont0 setfont\n";
print "/title linkdest ti show\n";
print "lmarg pageheight 2 mul 3 div 10 sub moveto\n";
print "0 setlinecap 3 setlinewidth\n";
print "pagewidth lmarg sub rmarg sub 0 rlineto currentpoint stroke moveto\n";
print "hfont1 setfont sti stringwidth pop neg ",
    -$HeadFont{leading}, " rmoveto\n";
print "sti show\n";

# Print logo, if there is one
# FIX: To be 100% correct, this should look for DocumentNeeded*
# and DocumentFonts in the header of the EPSF and add those to the
# global header.
if ( defined($metadata{epslogo}) &&
     sysopen(EPS, $metadata{epslogo}, O_RDONLY) ) {
    my @eps = ();
    my ($bbllx,$bblly,$bburx,$bbury) = (undef,undef,undef,undef);
    my $line;
    my $scale = 1;
    my $maxwidth = $psconf{pagewidth}-$psconf{lmarg}-$psconf{rmarg};
    my $maxheight = $psconf{pageheight}/3-40;
    my $width, $height;
    my $x, $y;

    while ( defined($line = <EPS>) ) {
	last if ( $line =~ /^%%EOF/ );
	if ( !defined($bbllx) &&
	     $line =~ /^\%\%BoundingBox\:\s*([0-9\.]+)\s+([0-9\.]+)\s+([0-9\.]+)\s+([0-9\.]+)/i ) {
	    $bbllx = $1+0; $bblly = $2+0;
	    $bburx = $3+0; $bbury = $4+0;
	}
	push(@eps,$line);
    }
    close(EPS);

    if ( defined($bbllx) ) {
	$width = $bburx-$bbllx;
	$height = $bbury-$bblly;

	if ( $width > $maxwidth ) {
	    $scale = $maxwidth/$width;
	}
	if ( $height*$scale > $maxheight ) {
	    $scale = $maxheight/$height;
	}

	$x = ($psconf{pagewidth}-$width*$scale)/2;
	$y = ($psconf{pageheight}-$height*$scale)/2;

	print "BeginEPSF\n";
	print $x, ' ', $y, " translate\n";
	print $scale, " dup scale\n" unless ( $scale == 1 );
	print -$bbllx, ' ', -$bblly, " translate\n";
	print "$bbllx $bblly moveto\n";
	print "$bburx $bblly lineto\n";
	print "$bburx $bbury lineto\n";
	print "$bbllx $bbury lineto\n";
	print "$bbllx $bblly lineto clip newpath\n";
	print "%%BeginDocument: ",ps_string($metadata{epslogo}),"\n";
	print @eps;
	print "%%EndDocument\n";
	print "EndEPSF\n";
    }
}
ps_end_page(0);

# Emit the rest of the document (page 2 and on)
$curpage = 2;
ps_start_page();
foreach $line ( @pslines ) {
    my $linfo = $line->[0];

    if ( $$linfo[4] != $curpage ) {
        ps_end_page($curpage > 2);
        ps_start_page();
        $curpage = $$linfo[4];
    }

    print '[';
    my $curfont = 0;
    foreach my $c ( @{$line->[1]} ) {
        if ( $$c[0] >= 0 ) {
	    if ( $curfont != $$c[0] ) {
		print ($curfont = $$c[0]);
	    }
	    print ps_string($$c[1]);
	} elsif ( $$c[0] == -1 ) {
	    print '{el}';	# End link
	} elsif ( $$c[0] == -2 ) {
	    print '{/',$$c[1],' xl}'; # xref link
	} elsif ( $$c[0] == -3 ) {
	    print '{',ps_string($$c[1]),'wl}'; # web link
	} elsif ( $$c[0] == -4 ) {
	    # Index anchor -- ignore
	} elsif ( $$c[0] == -5 ) {
	    print '{/',$$c[1],' xa}'; #xref anchor
	} elsif ( $$c[0] == -6 ) {
	    print '][';		# Start a new array
	    $curfont = 0;
	} elsif ( $$c[0] == -7 ) {
	    print '{/',$$c[1],' pl}'; # page link
	} else {
	    die "Unknown annotation";
	}
    }
    print ']';
    if ( defined($$linfo[2]) ) {
	foreach my $x ( @{$$linfo[2]} ) {
	    if ( $$x[0] == $AuxStr ) {
		print ps_string($$x[1]);
	    } elsif ( $$x[0] == $AuxPage ) {
		print $ps_xref_page{$$x[1]},' ';
	    } elsif ( $$x[0] == $AuxPageStr ) {
		print ps_string($ps_xref_page{$$x[1]});
	    } elsif ( $$x[0] == $AuxXRef ) {
		print '/',ps_xref($$x[1]),' ';
	    } elsif ( $$x[0] == $AuxNum ) {
		print $$x[1],' ';
	    } else {
		die "Unknown auxilliary data type";
	    }
	}
    }
    print ($psconf{pageheight}-$psconf{topmarg}-$$linfo[5]);
    print ' ', $$linfo[6] if ( defined($$linfo[6]) );
    print ' ', $$linfo[0].$$linfo[1], "\n";
}

ps_end_page(1);
print "%%EOF\n";