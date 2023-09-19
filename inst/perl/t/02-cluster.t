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
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);

#  really need to change this hard coding
my $expected_cluster_indices = {
    error => undef,
    result => {
        BETA_2 => 'The other beta',
        BRAY_CURTIS => 'Bray Curtis dissimilarity',
        BRAY_CURTIS_NORM => 'Bray Curtis dissimilarity normalised by groups',
        HIER_ASUMRAT1_0 =>
            '1 - Ratio of shared label sample counts, (HIER_ASUM1 / HIER_ASUM0)',
        JACCARD => 'Jaccard value, 0 is identical, 1 is completely dissimilar',
        KULCZYNSKI2 => 'Kulczynski 2 index',
        MXD_MEAN => 'Mean dissimilarity of labels in set 1 to those in set 2.',
        MXD_VARIANCE => 'Variance of the dissimilarity values, set 1 vs set 2.',
        NEST_RESULTANT => 'Nestedness-resultant index',
        NUMD_ABSMEAN =>
            'Mean absolute dissimilarity of labels in set 1 to those in set 2.',
        NUMD_VARIANCE =>
            'Variance of the dissimilarity values (mean squared deviation), set 1 '
                .'vs set 2.',
        PHYLO_JACCARD => 'Phylo Jaccard score',
        PHYLO_RW_TURNOVER => 'Range weighted turnover',
        PHYLO_S2 => 'Phylo S2 score',
        PHYLO_SORENSON => 'Phylo Sorenson score',
        RW_TURNOVER => 'Range weighted turnover',
        S2 => 'S2 dissimilarity index',
        SORENSON => 'Sorenson index',
    },
};

$t->get_ok('/valid_cluster_indices')
    ->status_is(200, "status valid cluster indices")
    ->json_is('' => $expected_cluster_indices, "json results");


my $exp_linkages = {
    error => undef,
    result => [
        'link_average', 'link_average_unweighted', 'link_maximum',
        'link_minimum', 'link_recalculate',
    ],
};
$t->get_ok('/valid_cluster_linkage_functions')
    ->status_is(200, "status valid cluster linkage functions")
    ->json_is('' => $exp_linkages, "json results");
# use Data::Dumper::Compact qw/ddc/;
# print STDERR ddc $t->tx->res->json;



my $json_tree = '{"edge":[4,5,5,4,5,1,2,3],"edge.length":["NaN",1,1,2],"Nnode":2,"tip.label":["r1","r2","r3"]}';
my $tree = JSON::MaybeXS::decode_json ($json_tree);
# p $tree;
my %bd_setup_params = (
    name => 'blognorb',
    cellsizes => [ 500, 500 ],
);

my %analysis_args = (
    linkage_function     => undef,
    spatial_conditions   => undef,
    definition_query     => undef,
    spatial_calculations =>  [ qw/calc_endemism_central calc_pd calc_redundancy/ ],
    tree                 => $tree,
    cluster_tie_breaker  => undef,  #  support
);

my $gp_lb = {
    '250:250' => {r1 => 13, r2 => 13, r3 => 13},
    '250:750' => {r2 => 11, r3 => 11, r4 => 10},
    '750:250' => {r3 => 10},
    '750:750' => {r1 =>  8, r3 =>  8},
};

my %data_params = (
    bd_params => {
        data => $gp_lb
    },
);

my $t_msg_suffix = "";
$t->post_ok('/init_basedata' => json => \%bd_setup_params)
    ->status_is(200, "status init, $t_msg_suffix")
    ->json_is('' => {result => 1, error => undef}, "json results, $t_msg_suffix");

$t->post_ok('/bd_load_data' => json => \%data_params)
    ->status_is(200, "status load data, $t_msg_suffix")
    ->json_is('' => {result => 1, error => undef}, "json results, $t_msg_suffix");

$t->post_ok('/bd_get_group_count')
    ->status_is(200, "status gp count, $t_msg_suffix")
    ->json_is('' => {result => 4, error => undef}, "group count, $t_msg_suffix");
$t->post_ok('/bd_get_label_count')
    ->status_is(200, "status lb count, $t_msg_suffix")
    ->json_is('' => {result => 4, error => undef}, "label count, $t_msg_suffix");

my $exp = {
    error => undef,
    result => {
        NODE_VALUES => [
            [
                'ELEMENT', 'Axis_0', 'COLOUR', 'LENGTHTOPARENT', 'NAME',
                'NODE_NUMBER', 'PARENTNODE', 'TREENAME',
            ],
            [ 1, 1, undef, 0, '2___', 1, 0, 'TREE' ],
            [ 2, 2, undef, '0.0611111111111111', '1___', 2, 1, 'TREE' ],
            [ 3, 3, undef, '0.216666666666667', '0___', 3, 2, 'TREE' ],
            [ 4, 4, undef, '0.2', '250:250', 4, 3, 'TREE' ],
            [ 5, 5, undef, '0.2', '750:750', 5, 3, 'TREE' ],
            [ 6, 6, undef, '0.416666666666667', '750:250', 6, 2, 'TREE' ],
            [ 7, 7, undef, '0.477777777777778', '250:750', 7, 1, 'TREE' ],
        ],
        dendrogram  => {
            Nnode         => 3,
            edge          => [ 5, 6, 7, 7, 5, 6, 1, 2, 3, 4, 6, 7 ],
            'edge.length' => [
                '0.477777777777778', '0.416666666666667', '0.2', '0.2',
                '0.0611111111111111', '0.216666666666667',
            ],
            'node.label'  => [ '1___', '0___' ],
            'root.edge'   => 0,
            'tip.label'   => [ '250:750', '750:250', '250:250', '750:750' ],
        },
        lists       => {},
    },
};

my $cl_name = "cl_" . time();
$t->post_ok('/bd_run_cluster_analysis' => json => {%analysis_args, name => $cl_name})
    ->status_is(200, "status run cluster, $t_msg_suffix")
    ->json_is('' => $exp, "json results, $t_msg_suffix");

$t->post_ok('/bd_get_analysis_results' => json => {%analysis_args, name => $cl_name})
    ->status_is(200, "status get cluster results, $t_msg_suffix")
    ->json_is('' => $exp, "json results, $t_msg_suffix");



# use Data::Printer;
# p $t->tx->res->json;
# use Data::Dumper::Compact qw/ddc/;
# print STDERR ddc $t->tx->res->json;

done_testing();

