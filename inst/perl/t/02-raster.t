use Mojo::Base -strict, -signatures;

use Mojo::File qw(curfile);

use Test::More;
use Test::Mojo;
use Data::Printer;

my $data_dir = curfile->dirname->child('data')->to_string;

my $t = Test::Mojo->new('BiodiverseR');
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);

#  plenty repetition below - could do with a refactor

my $oneshot_data = {
  bd => {
    params => {name => 'blognorb', cellsizes => [500,500]},
    raster_files => ["$data_dir/r1.tif", "$data_dir/r2.tif", "$data_dir/r3.tif"],
  },
  analysis_config => {
    calculations => ['calc_endemism_central'],
  },
};

my $exp = {
  SPATIAL_RESULTS => [
    [qw /ELEMENT Axis_0 Axis_1 ENDC_CWE ENDC_RICHNESS ENDC_SINGLE ENDC_WE/],
    ['250:-250', '250', '-250', '0.25', 3, '0.75', '0.75'],
    ['250:250',  '250',  '250', '0.25', 3, '0.75', '0.75'],
    ['750:-250', '750', '-250', '0.25', 3, '0.75', '0.75'],
    ['750:250',  '750',  '250', '0.25', 3, '0.75', '0.75'],
  ]
};
my $t_msg_suffix = 'default config';
$t->post_ok ('/analysis_spatial_oneshot' => json => $oneshot_data)
  ->status_is(200, "status, $t_msg_suffix")
  ->json_is ('' => $exp, "json results, $t_msg_suffix");

done_testing();
