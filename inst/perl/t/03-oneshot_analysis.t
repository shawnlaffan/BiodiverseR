use Mojo::Base -strict, -signatures;

use Mojo::File qw(curfile);

use JSON::MaybeXS qw //;
use Test::More;
use Test::Mojo;
use Data::Printer;

my $data_dir = curfile->dirname->dirname->sibling('extdata')->to_string;

my $t = Test::Mojo->new('BiodiverseR');
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);

my $json_tree = '{"edge":[4,5,5,4,5,1,2,3],"edge.length":["NaN",1,1,2],"Nnode":2,"tip.label":["r1","r2","r3"]}';
my $tree = JSON::MaybeXS::decode_json ($json_tree);

my $gp_lb = {
  '50:50'   => {label1 => 1, label2 => 1},
  '150:150' => {label1 => 1, label2 => 1},
};

{
my $oneshot_data = {
  raster_params => {
            files => [ "$data_dir/r1.tif", "$data_dir/r2.tif", "$data_dir/r3.tif" ]
  },
  bd => {
    params => {name => 'blognorb', cellsizes => [100,100]},
    data   => $gp_lb,
  },
  analysis_config => {
    calculations => ['calc_endemism_central'],
  },
};

my $t_msg_suffix = 'default config, raster files';
$t->post_ok('/analysis_spatial_oneshot' => json => $oneshot_data)
    ->status_is(200, "status, $t_msg_suffix");
}

my %common_args = (
    bd => {
        params       => { name => 'blognorb', cellsizes => [ 500, 500 ] },
        data        => $gp_lb,
    },
    analysis_config => {
        calculations => [qw /calc_endemism_central calc_pd calc_redundancy/],
    },
    tree => $tree,
);

{
my $oneshot_data = {
    shapefile_params => {
            files => [ "$data_dir/r1.shp", "$data_dir/r2.shp", "$data_dir/r3.shp" ],
            group_field_names      => [ qw/:shape_x :shape_y/ ],
            label_field_names      => [ 'label' ],
            sample_count_col_names => [ 'count' ]
    },
    %common_args,
};

my $t_msg_suffix = 'default config, raster files';
$t->post_ok('/analysis_spatial_oneshot' => json => $oneshot_data)
    ->status_is(200, "status, $t_msg_suffix");
}

{
my $oneshot_data = {
    delimited_text_params => {
            files => [ "$data_dir/r1.csv", "$data_dir/r2.csv", "$data_dir/r3.csv" ],
            group_columns        => [ 1, 2 ],
            label_columns        => [ 4 ],
            sample_count_columns => [ 3 ],
        },
    %common_args,
};

my $t_msg_suffix = 'default config, raster files';
$t->post_ok('/analysis_spatial_oneshot' => json => $oneshot_data)
    ->status_is(200, "status, $t_msg_suffix");
}

{
my $oneshot_data = {
    spreadsheet_params => {
            files                  => [ "$data_dir/r1.xlsx", "$data_dir/r2.xlsx", "$data_dir/r3.xlsx" ],
            group_field_names      => [ qw/X Y/ ],
            label_field_names      => [ 'label' ],
            sample_count_col_names => [ 'count' ]
        },
    %common_args,
};

my $t_msg_suffix = 'default config, raster files';
$t->post_ok('/analysis_spatial_oneshot' => json => $oneshot_data)
    ->status_is(200, "status, $t_msg_suffix");
}

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
my $oneshot_data = {
    raster_params => {
            files => [ "$data_dir/r1.tif", "$data_dir/r2.tif", "$data_dir/r3.tif" ]
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
$t->post_ok('/analysis_spatial_oneshot' => json => $oneshot_data)
    ->status_is(200, "status, $t_msg_suffix");
}

{
my $oneshot_data = {
    raster_params => {
            files => [ "$data_dir/r1.tif", "$data_dir/r2.tif", "$data_dir/r3.tif" ]
        },
    shapefile_params => {
            files => [ "$data_dir/r1.shp", "$data_dir/r2.shp", "$data_dir/r3.shp" ],
            group_field_names      => [ qw/:shape_x :shape_y/ ],
            label_field_names      => [ 'label' ],
            sample_count_col_names => [ 'count' ]
        },
    %common_args,
};

my $t_msg_suffix = 'default config, raster files';
$t->post_ok('/analysis_spatial_oneshot' => json => $oneshot_data)
    ->status_is(200, "status, $t_msg_suffix");
}

{
my $oneshot_data = {
    raster_params => {
            files => [ "$data_dir/r1.tif", "$data_dir/r2.tif", "$data_dir/r3.tif" ]
        },
    delimited_text_params => {
            files => [ "$data_dir/r1.csv", "$data_dir/r2.csv", "$data_dir/r3.csv" ],
            group_columns        => [ 1, 2 ],
            label_columns        => [ 4 ],
            sample_count_columns => [ 3 ],
        },
    %common_args,
};

my $t_msg_suffix = 'default config, raster files';
$t->post_ok('/analysis_spatial_oneshot' => json => $oneshot_data)
    ->status_is(200, "status, $t_msg_suffix");
}

{
my $oneshot_data = {
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
    %common_args,
};

my $t_msg_suffix = 'default config, raster files';
$t->post_ok('/analysis_spatial_oneshot' => json => $oneshot_data)
    ->status_is(200, "status, $t_msg_suffix");
}

{
my $oneshot_data = {
    spreadsheet_params => {
            files                  => [ "$data_dir/r1.xlsx", "$data_dir/r2.xlsx", "$data_dir/r3.xlsx" ],
            group_field_names      => [ qw/X Y/ ],
            label_field_names      => [ 'label' ],
            sample_count_col_names => [ 'count' ]
        },
    delimited_text_params => {
            files => [ "$data_dir/r1.csv", "$data_dir/r2.csv", "$data_dir/r3.csv" ],
            group_columns        => [ 1, 2 ],
            label_columns        => [ 4 ],
            sample_count_columns => [ 3 ],
        },
    %common_args,
};

my $t_msg_suffix = 'default config, raster files';
$t->post_ok('/analysis_spatial_oneshot' => json => $oneshot_data)
    ->status_is(200, "status, $t_msg_suffix");
}

{
my $oneshot_data = {
    spreadsheet_params => {
            files                  => [ "$data_dir/r1.xlsx", "$data_dir/r2.xlsx", "$data_dir/r3.xlsx" ],
            group_field_names      => [ qw/X Y/ ],
            label_field_names      => [ 'label' ],
            sample_count_col_names => [ 'count' ]
        },
    shapefile_params => {
            files => [ "$data_dir/r1.shp", "$data_dir/r2.shp", "$data_dir/r3.shp" ],
            group_field_names      => [ qw/:shape_x :shape_y/ ],
            label_field_names      => [ 'label' ],
            sample_count_col_names => [ 'count' ]
        },
    %common_args,
};

my $t_msg_suffix = 'default config, raster files';
$t->post_ok('/analysis_spatial_oneshot' => json => $oneshot_data)
    ->status_is(200, "status, $t_msg_suffix");
}

my %common_args = (
    bd => {
        params       => { name => 'blognorb', cellsizes => [ 500, 500 ] },
        data        => $gp_lb,
    },
    analysis_config => {
        calculations => [qw /calc_endemism_central calc_pd calc_redundancy/],
    },
    tree => $tree,
);

{
my $oneshot_data = {
    spreadsheet_params => {
            files                  => [ "$data_dir/r1.xlsx", "$data_dir/r2.xlsx", "$data_dir/r3.xlsx" ],
            group_field_names      => [ qw/X Y/ ],
            label_field_names      => [ 'label' ],
            sample_count_col_names => [ 'count' ]
        },
    shapefile_params => {
            files => [ "$data_dir/r1.shp", "$data_dir/r2.shp", "$data_dir/r3.shp" ],
            group_field_names      => [ qw/:shape_x :shape_y/ ],
            label_field_names      => [ 'label' ],
            sample_count_col_names => [ 'count' ]
        },
    raster_params => {
            files => [ "$data_dir/r1.tif", "$data_dir/r2.tif", "$data_dir/r3.tif" ]
        },
    %common_args,
};

my $t_msg_suffix = 'default config, raster files';
$t->post_ok('/analysis_spatial_oneshot' => json => $oneshot_data)
    ->status_is(200, "status, $t_msg_suffix");
}

{
my $oneshot_data = {
    delimited_text_params => {
            files => [ "$data_dir/r1.csv", "$data_dir/r2.csv", "$data_dir/r3.csv" ],
            group_columns        => [ 1, 2 ],
            label_columns        => [ 4 ],
            sample_count_columns => [ 3 ],
        },
    shapefile_params => {
            files => [ "$data_dir/r1.shp", "$data_dir/r2.shp", "$data_dir/r3.shp" ],
            group_field_names      => [ qw/:shape_x :shape_y/ ],
            label_field_names      => [ 'label' ],
            sample_count_col_names => [ 'count' ]
        },
    raster_params => {
            files => [ "$data_dir/r1.tif", "$data_dir/r2.tif", "$data_dir/r3.tif" ]
        },
    %common_args,
};

my $t_msg_suffix = 'default config, raster files';
$t->post_ok('/analysis_spatial_oneshot' => json => $oneshot_data)
    ->status_is(200, "status, $t_msg_suffix");
}

{
my $oneshot_data = {
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
    raster_params => {
            files => [ "$data_dir/r1.tif", "$data_dir/r2.tif", "$data_dir/r3.tif" ]
        },
    %common_args,
};

my $t_msg_suffix = 'default config, raster files';
$t->post_ok('/analysis_spatial_oneshot' => json => $oneshot_data)
    ->status_is(200, "status, $t_msg_suffix");
}

my %common_args = (
    bd => {
        params       => { name => 'blognorb', cellsizes => [ 500, 500 ] },
        data        => $gp_lb,
    },
    analysis_config => {
        calculations => [qw /calc_endemism_central calc_pd calc_redundancy/],
    },
    tree => $tree,
);

{
my $oneshot_data = {
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
$t->post_ok('/analysis_spatial_oneshot' => json => $oneshot_data)
    ->status_is(200, "status, $t_msg_suffix");
}

my %common_args = (
    bd => {
        params       => { name => 'blognorb', cellsizes => [ 500, 500 ] },
        data        => $gp_lb,
    },
    analysis_config => {
        calculations => [qw /calc_endemism_central calc_pd calc_redundancy/],
    },
    tree => $tree,
);

{
    my $oneshot_data_raster = {
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

my %common_args = (
    bd => {
        params       => { name => 'blognorb', cellsizes => [ 500, 500 ] },
        data        => $gp_lb,
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
