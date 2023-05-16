use Mojo::Base -strict, -signatures;

use Mojo::File qw(curfile);

use JSON::MaybeXS qw //;
use Test::More;
use Test::Mojo;
use Data::Printer;

my $data_dir = curfile->dirname->dirname->sibling('extdata')->to_string;

my $t = Test::Mojo->new('BiodiverseR');
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);

my $exp = {
    SPATIAL_RESULTS => [
        [qw /ELEMENT Axis_0 Axis_1 ENDC_CWE ENDC_RICHNESS ENDC_SINGLE ENDC_WE PD PD_P PD_P_per_taxon PD_per_taxon REDUNDANCY_ALL REDUNDANCY_SET1/],
        ['250:250', '250', '250', '0.25', 3, '0.75', '0.75', 4, 1, '0.333333333333333', '1.33333333333333', '0.99992743983553', '0.99992743983553'],
        ['250:750', '250', '750', '0.25', 3, '0.75', '0.75', 4, 1, '0.333333333333333', '1.33333333333333', '0.999910222647833', '0.999910222647833'],
        ['750:250', '750', '250', '0.25', 3, '0.75', '0.75', 4, 1, '0.333333333333333', '1.33333333333333', '0.999909793426948', '0.999909793426948'],
        ['750:750', '750', '750', '0.25', 3, '0.75', '0.75', 4, 1, '0.333333333333333', '1.33333333333333', '0.999885974914481', '0.999885974914481'],
    ]
};

my $json_tree = '{"edge":[4,5,5,4,5,1,2,3],"edge.length":["NaN",1,1,2],"Nnode":2,"tip.label":["r1","r2","r3"]}';
my $tree = JSON::MaybeXS::decode_json ($json_tree);

my %common_args = (
    bd => {
        params       => { name => 'blognorb', cellsizes => [ 500, 500 ] },
    },
    analysis_config => {
        calculations => [qw /calc_endemism_central calc_pd calc_redundancy/],
    },
    tree => $tree,
);

{
    my $oneshot_data_raster = {
        raster_params => {
            files => [ "$data_dir/r1.tif", "$data_dir/r2.tif", "$data_dir/r3.tif" ]
        },

        shapefile_params => {
            files => [ "$data_dir/r1.shp", "$data_dir/r2.shp", "$data_dir/r3.shp" ],
            group_field_names      => [ qw/:shape_x :shape_y/ ],
            label_field_names      => [ 'label' ],
            sample_count_col_names => [ 'count' ]
        },
        delimited_text_params => {
            files => [ "$data_dir/r1.csv", "$data_dir/r2.csv", "$data_dir/r3.csv" ],
            group_columns        => [ 1, 2 ],
            label_columns        => [ 4 ],
            sample_count_columns => [ 3 ],
        },
        spreadsheet_params => {
            files                  => [ "$data_dir/r1.xlsx", "$data_dir/r2.xlsx", "$data_dir/r3.xlsx" ],
            group_field_names      => [ qw/X Y/ ],
            label_field_names      => [ 'label' ],
            sample_count_col_names => [ 'count' ]
        },
        %common_args,
    };

    my $t_msg_suffix = 'default config, raster files';
    $t->post_ok('/analysis_spatial_oneshot' => json => $oneshot_data_raster)
        ->status_is(200, "status, $t_msg_suffix");
}

done_testing();
