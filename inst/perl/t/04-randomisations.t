use Mojo::Base -strict, -signatures;

use Mojo::File qw(curfile);

use JSON::MaybeXS qw //;
use Test::More;
use Test::Mojo;
use Data::Printer;
use Time::HiRes qw /time/;

use Test::TempDir::Tiny;

my $data_dir = curfile->dirname->dirname->sibling('extdata')->to_string;

my $t = Test::Mojo->new('BiodiverseR');
$t->get_ok('/api_key');
my $api_key = $t->tx->res->json;
$t->get_ok('/' => {"api_key" => $api_key})->status_is(200)->content_like(qr/Mojolicious/i);

my $exp = {
    result => {
        SPATIAL_RESULTS => [
            [ qw/ELEMENT Axis_0 Axis_1 ENDC_CWE ENDC_RICHNESS ENDC_SINGLE ENDC_WE REDUNDANCY_ALL REDUNDANCY_SET1/ ],
            [ '250:250', '250', '250', '0.25', 3, '0.75', '0.75', '0.99992743983553', '0.99992743983553' ],
            [ '250:750', '250', '750', '0.25', 3, '0.75', '0.75', '0.999910222647833', '0.999910222647833' ],
            [ '750:250', '750', '250', '0.25', 3, '0.75', '0.75', '0.999909793426948', '0.999909793426948' ],
            [ '750:750', '750', '750', '0.25', 3, '0.75', '0.75', '0.999885974914481', '0.999885974914481' ],
        ]
    },
    error  => undef,
};


my %bd_setup_params = (
    name => 'blognorb',
    cellsizes => [ 500, 500 ],
);

my %analysis_args = (
    calculations => [ qw/calc_endemism_central calc_pd calc_redundancy/ ],
);

my $gp_lb = {
    '250:250' => {r1 => 13758, r2 => 13860, r3 => 13727},
    '250:750' => {r1 => 11003, r2 => 11134, r3 => 11279},
    '750:250' => {r1 => 10981, r2 => 11302, r3 => 10974},
    '750:750' => {r1 =>  8807, r2 =>  8715, r3 =>  8788},
};

my $bd_params = \%bd_setup_params;
my $data_params = {
    bd_params => {
        data => $gp_lb
    },
};

my $t_msg_suffix = "default config";
$t->post_ok('/init_basedata' => {"api_key" => $api_key} => json => $bd_params)
    ->status_is(200, "status init, $t_msg_suffix")
    ->json_is('' => {result => 1, error => undef}, "json results, $t_msg_suffix");

$t->post_ok('/bd_load_data' => {"api_key" => $api_key} => json => $data_params)
    ->status_is(200, "status load data, $t_msg_suffix")
    ->json_is('' => {result => 1, error => undef}, "json results, $t_msg_suffix");

$t->post_ok('/bd_get_group_count' => {"api_key" => $api_key})
    ->status_is(200, "status gp count, $t_msg_suffix")
    ->json_is('' => {result => 4, error => undef}, "group count, $t_msg_suffix");
$t->post_ok('/bd_get_label_count' => {"api_key" => $api_key})
    ->status_is(200, "status lb count, $t_msg_suffix")
    ->json_is('' => {result => 3, error => undef}, "label count, $t_msg_suffix");


my $sp_name = "sp_" . time();
$t->post_ok('/bd_run_spatial_analysis' => {"api_key" => $api_key} => json => {%analysis_args, name => $sp_name})
    ->status_is(200, "status run spatial, $t_msg_suffix")
    ->json_is('' => $exp, "json results, $t_msg_suffix");

#  now we actually test the randomisations
my $rand_name = "rand_" . time();
my %rand_args = (function => 'rand_structured', iterations => 9, prng_seed => 1234);
$t->post_ok('/bd_run_randomisation_analysis' => {"api_key" => $api_key} => json => {%rand_args, name => $rand_name})
    ->status_is(200, "status run randomisation, $t_msg_suffix")
    ->json_is('' => {result => 1, error => undef}, "json results, $t_msg_suffix");

$t->post_ok('/bd_get_analysis_results' => {"api_key" => $api_key} => json => {name => $sp_name})
    ->status_is(200, "status get_analysis_results from already run sp analysis");

my $sp_res = $t->tx->res->json;
my @keys = sort keys %{$sp_res->{result}};
my @expected = (
    'SPATIAL_RESULTS',
    "$rand_name>>SPATIAL_RESULTS",
    "$rand_name>>p_rank>>SPATIAL_RESULTS",
    "$rand_name>>z_scores>>SPATIAL_RESULTS"
);
is_deeply \@keys, \@expected, "SP result has rand results";

done_testing();
