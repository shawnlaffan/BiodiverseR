#  this exists solely for the purposes of building an executable using PAR::Packer
#  Much of it is duplicated from Biodiverse::Config which should also be picked up.
package BiodiverseR::PPDeps;
use 5.020;
use strict;
use warnings;

use Carp;

use utf8;
#say 'Building pp file';
#say "using $0";

#  File::BOM stuff still needed?
use File::BOM qw / :subs /;          #  we need File::BOM.
open my $fh, '<:via(File::BOM)', $0  #  just read ourselves
  or croak "Cannot open $0 via File::BOM\n";
$fh->close;

#  more File::BOM issues
require encoding;

#  exercise the unicode regexp matching - needed for the spatial conditions
use 5.016;
use feature 'unicode_strings';
my $string = "sp_self_only () and \N{WHITE SMILING FACE}";
$string =~ /\bsp_self_only\b/;

#  load extra encode pages, except the extended ones (for now)
#  https://metacpan.org/pod/distribution/Encode/lib/Encode/Supported.pod#CJK:-Chinese-Japanese-Korean-Multibyte
use Encode::CN;
use Encode::JP;
use Encode::KR;
use Encode::TW;

#  Big stuff needs loading (poss not any more with PAR>1.08)
use Math::BigInt;

use Alien::gdal ();
use Alien::geos::af ();
use Alien::proj ();
use Alien::sqlite ();
#eval 'use Alien::spatialite';  #  might not have this one
#eval 'use Alien::freexl';      #  might not have this one

#  these are here for PAR purposes to ensure they get packed
#  Spreadsheet::Read calls them as needed
#  (not sure we need all of them, though)
use Spreadsheet::ParseODS 0.27;
use Spreadsheet::ReadSXC;
use Spreadsheet::ParseExcel;
use Spreadsheet::ParseXLSX;
use PerlIO::gzip;  #  used by ParseODS

#  GUI needs this for help,
#  so don't trigger for engine-only
eval 'use IO::Socket::SSL';

use FFI::Platypus;

1;
