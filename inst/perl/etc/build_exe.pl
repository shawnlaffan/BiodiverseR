#  Build a Biodiverse related executable

use 5.010;
use strict;
use warnings;
use English qw { -no_match_vars };

#  make sure we get all the Strawberry libs
#  and pack Gtk2 libs
use PAR::Packer 1.036;    
use Module::ScanDeps 1.23;
BEGIN {
    eval 'use Win32::Exe' if $OSNAME eq 'MSWin32';
}

use App::PP::Autolink 2.04;

use Config;
use File::Copy;
use Path::Class;
use Cwd;
use File::Basename;
use File::Find::Rule;

use FindBin qw /$Bin/;

use 5.020;
use warnings;
use strict;
use Carp;

use Data::Dump       qw/ dd /;
use File::Which      qw( which );
use Capture::Tiny    qw/ capture /;
use List::Util       qw( uniq );
use File::Find::Rule qw/ rule find /;
use Path::Tiny       qw/ path /;
use Module::ScanDeps;

use Getopt::Long::Descriptive;

my ($opt, $usage) = describe_options(
  '%c <arguments>',
  [ 'script|s=s',             'The input script', { required => 1 } ],
  [ 'out_folder|out_dir|o=s', 'The output directory where the binary will be written'],
  [ 'verbose|v!',             'Verbose building?', ],
  [ 'execute|x!',             'Execute the script to find dependencies?', {default => 1} ],
  #[ 'gd!',                    'We are packing GD, get the relevant dlls'],
  [ '-', 'Any arguments after this will be passed through to pp'],
  [],
  [ 'help|?',       "print usage message and exit" ],
);

if ($opt->help) {
    print($usage->text);
    exit;
}

my $script     = $opt->script;
my $out_folder = $opt->out_folder // cwd();
my $verbose    = $opt->verbose ? $opt->verbose : q{};
my $execute    = $opt->execute ? '-x' : q{};
my @rest_of_pp_args = @ARGV;
my @script_args = qw |get /index|;
@script_args = ();

die "Script file $script does not exist or is unreadable" if !-r $script;

my $RE_DLL_EXT = qr/\.dll/i;

my $root_dir = Path::Class::file ($script)->dir->parent;

#  assume bin folder is at parent folder level
my $bin_folder = Path::Class::dir ($root_dir, 'script');
say $bin_folder;

my $perlpath     = $EXECUTABLE_NAME;
my $bits         = $Config{archname} =~ /x(86_64|64)/ ? 64 : 32;
my $using_64_bit = $bits == 64;

my $script_fullname = Path::Class::file($script)->absolute;

my $output_binary = basename ($script_fullname, '.pl', qr/\.[^.]*$/);
#$output_binary .= "_x$bits";


if (!-d $out_folder) {
    die "$out_folder does not exist or is not a directory";
}


my @links;

if ($OSNAME eq 'MSWin32') {
    $output_binary .= '.exe';
}


#  make sure we get the aliens
#  last two might not actually be needed
my @aliens = qw /
    Alien::gdal       Alien::geos::af
    Alien::proj       Alien::sqlite
    Alien::libtiff    Alien::curl
    Alien::spatialite Alien::freexl
/;
push @rest_of_pp_args, map {; '-M' => $_."::"} @aliens;
#push @rest_of_pp_args, map {; '-M' => $_."::"} ('Math::Random::MT::Auto');
push @rest_of_pp_args, map {; '-M' => $_."::"} ('Object::InsideOut');


my $output_binary_fullpath = Path::Class::file ($out_folder, $output_binary)->absolute;

$ENV{BDV_PP_BUILDING}              = 1;
$ENV{BIODIVERSE_EXTENSIONS_IGNORE} = 1;

my @cmd = (
    'pp_autolink',
    ($verbose ? '-v' : ()),
    '-u',
    '-B',
    '-z',
    9,
    $execute,
    @rest_of_pp_args,
    '-o',
    $output_binary_fullpath,
    $script_fullname,
    #@script_args,
);


say "\nCOMMAND TO RUN:\n" . join ' ', @cmd;

system @cmd;
