use Mojo::Base -strict, -signatures;

use Test::More;
use Test::Mojo;
use Data::Printer;

my $t = Test::Mojo->new('BiodiverseR');
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);

#  plenty repetition below - could do with a refactor

my $gp_lb = {
  '50:50'   => {label1 => 1, label2 => 1},
  '150:150' => {label1 => 1, label2 => 1},
};
my $oneshot_data = {
  bd => {
    params => {name => 'blognorb', cellsizes => [100,100]},
    data   => $gp_lb,
  },
};

my $exp = {
  SPATIAL_RESULTS =>  [
    [qw /ELEMENT Axis_0 Axis_1 ENDC_CWE ENDC_RICHNESS ENDC_SINGLE ENDC_WE/],
    ['150:150', 150, 150, 0.5, 2, 1.0, 1],
    ['50:50', 50, 50, 0.5, 2, 1.0, 1],
  ],
};
my $t_msg_suffix = 'default config';
$t->post_ok ('/analysis_spatial_oneshot' => json => $oneshot_data)
  ->status_is(200, "status, $t_msg_suffix")
  ->json_is ('' => $exp, "json results, $t_msg_suffix");

$oneshot_data->{analysis_config}{spatial_conditions}
  = ['sp_self_only()'];
$t_msg_suffix = 'spatial conditions set';
$t->post_ok ('/analysis_spatial_oneshot' => json => $oneshot_data)
  ->status_is(200, "status, $t_msg_suffix")
  ->json_is ('' => $exp, "json results, $t_msg_suffix");

$oneshot_data->{analysis_config}{calculations}
  = ['calc_richness'];
$exp = {
  SPATIAL_RESULTS => [
    [qw /ELEMENT Axis_0 Axis_1 RICHNESS_ALL RICHNESS_SET1/],
    ['150:150', 150, 150, 2, 2],
    ['50:50', 50, 50, 2, 2],
  ]
};
$t_msg_suffix = 'calculation set';
$t->post_ok ('/analysis_spatial_oneshot' => json => $oneshot_data)
  ->status_is(200, "status, $t_msg_suffix")
  ->json_is ('' => $exp, "json results, $t_msg_suffix");


$oneshot_data->{analysis_config}{calculations}
  = ['calc_elements_used'];
$oneshot_data->{analysis_config}{results_list}
  = ['SPATIAL_RESULTS'];
$exp = {
  SPATIAL_RESULTS => [
    [qw /ELEMENT Axis_0 Axis_1 EL_COUNT_ALL EL_COUNT_SET1/],
    ["150:150", 150, 150, 1, 1],
    ["50:50", 50, 50, 1, 1],
  ]
};
$t_msg_suffix = 'results_list=SPATIAL_RESULTS, calculations=calc_elements_used';
$t->post_ok ('/analysis_spatial_oneshot' => json => $oneshot_data)
  ->status_is(200, "status, $t_msg_suffix")
  ->json_is ('' => $exp, "json results, $t_msg_suffix");


#### EXPECTED FAILURES

$oneshot_data->{analysis_config}{calculations}
  = {'calc_elements_used' => 0};
$t_msg_suffix = 'calculations not an array ref';
$t->post_ok ('/analysis_spatial_oneshot' => json => $oneshot_data)
  ->status_is(500, "status 500, $t_msg_suffix");
  
$oneshot_data->{analysis_config}{calculations}
  = ['calc_elements_used'];
$oneshot_data->{analysis_config}{result_lists}
  = 'SPATIAL_RESULTS';
$t_msg_suffix = 'result_lists is not a ref';
$t->post_ok ('/analysis_spatial_oneshot' => json => $oneshot_data)
  ->status_is(500, "status 500, $t_msg_suffix");

$oneshot_data->{analysis_config}{calculations}
  = ['calc_elements_used'];
$oneshot_data->{analysis_config}{result_lists}
  = 'EL_COUNT_ALL';
$oneshot_data->{analysis_config}{spatial_conditions}
  = {'sp_self_only()' => ''};
$t_msg_suffix = 'spatial_conditions ref is not an array';
$t->post_ok ('/analysis_spatial_oneshot' => json => $oneshot_data)
  ->status_is(500, "status 500, $t_msg_suffix");

#p $c;

#  this needs a server to be running

#diag 'Running Mojo UA code';
#
#my $ua = Mojo::UserAgent->new;
#my $tx = $ua->post(
#  'http://127.0.0.1:3000/analysis_spatial_oneshot'
#  => json
#  => $oneshot_data
#);
##p $tx->result->body;
#diag 'Finished Mojo UA code';
#
##diag $tx->result;
#
##  not the best test - fix later
#is $tx->result->body,
#  '[["ELEMENT","Axis_0","Axis_1","ENDC_CWE","ENDC_RICHNESS","ENDC_SINGLE","ENDC_WE"],["150:150","150","150",0.5,2,1.0,1],["50:50","50","50",0.5,2,1.0,1]]',
#  'got expected table back';
#

done_testing();
