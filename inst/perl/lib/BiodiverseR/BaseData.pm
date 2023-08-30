package BiodiverseR::BaseData;

use 5.026;
use strict;
use warnings;
use Carp;
use Ref::Util qw/is_ref is_arrayref is_hashref/;

use Data::Printer;

use Biodiverse::BaseData;

#  A bare bones class to handle a single basedata.
#  Implemented as a singleton class - maybe not such a good idea but we'll see.

sub get_instance {
    my $class = shift;
    state $instance = bless {basedata => undef}, $class;
    return $instance;
}

sub init_basedata {
    my ($class, %args) = @_;
    my $self = $class->get_instance;
    my %params = (
        NAME         => ($args{name} // 'BiodiverseR'),
        CELL_SIZES   => $args{cellsizes},
        CELL_ORIGINS => $args{cellorigins},
    );

    my $bd = Biodiverse::BaseData->new (%params);
    $self->{basedata} = $bd;
    return defined $self->{basedata};
}

sub get_basedata_ref {
    my $self = get_instance();
    $self->{basedata};
}


sub load_data {
    my ($class, %args) = @_;
    my $bd = get_basedata_ref();

    if (my $bd_data = $args{bd_params}) {
        my $data = $bd_data->{data};
        # say STDERR "Loading bd_data";
        # p $bd_data;
        #  needs to be a more general call
        my $csv_object = $bd->get_csv_object(
            quote_char => $bd->get_param('QUOTES'),
            sep_char   => $bd->get_param('JOIN_CHAR')
        );
        eval {
            $bd->add_elements_collated_simple_aa($data, $csv_object, 1);
        };
        my $e = $@;
        # say STDERR "Error is '$e'";
        # my $lb = $bd->get_labels_ref;
        # p $lb;
        croak $e if $e;
        # # say STDERR "LOADED GPLB DATA";
        # _dump_sample_counts ($bd);
    }

    #need to check if files in the raster exist
    if ($args{raster_params}{files}) {
        my $params = $args{raster_params};
        my $files = $params->{files} // croak 'raster_params must include an array of files';
        if (!is_ref($files)) {
            $files = [$files];
        }
        my %in_options_hash = (
            labels_as_bands   => 1,
            #  these should already be set
            # raster_origin_e   => ($bd_params->{cellorigins}[0] // 0),
            # raster_origin_n   => ($bd_params->{cellorigins}[1] // 0),
            # raster_cellsize_e => $bd_params->{cellsizes}[0],
            # raster_cellsize_n => $bd_params->{cellsizes}[1],
        );
        my $success = eval {
            $bd->import_data_raster (
                input_files => $files,
                %in_options_hash,
                labels_as_bands => ($params->{labels_as_bands} // 1),
            );
        };
        croak $@ if $@;
        say STDERR "LOADED RASTER DATA";
        #_dump_sample_counts ($bd);
    }

    #  some shapefiles
    if ($args{shapefile_params}{files}) {
        my $params = $args{shapefile_params};
        # p $params;
        my $files = $params->{files} // croak 'shapefile_params must include an array of files';
        if (!is_ref($files)) {
            $files = [$files];
        }
        # p $bd_params;
        my %in_options_hash
            = map {$_ => $params->{$_}}
            (qw /group_field_names label_field_names sample_count_col_names/);
        #  add croaks for missing field names groups and labels
        # p %in_options_hash;
        my $success = eval {
            $bd->import_data_shapefile (
                input_files => $files,
                %in_options_hash,
            );
        };
        my $e = $@;
        croak $e if $e;
        # say STDERR "LOADED SHAPEFILE DATA";
        # _dump_sample_counts ($bd);
    }
    #  some delimited text files
    # p $analysis_params;
    if ($args{delimited_text_params}{files}) {
        # say STDERR "LOADING CSV DATA";
        my $params = $args{delimited_text_params};
        # p $params;
        my $files = $params->{files} // croak 'delimited_text_params must include an array of files';
        if (!is_ref($files)) {
            $files = [$files];
        }
        my %in_options_hash
            = map {$_ => $params->{$_}}
            (qw /group_columns label_columns sample_count_columns/);

        #  add croaks for missing field names groups and labels
        my $success = eval {
            $bd->import_data (
                input_files => $files,
                %in_options_hash,
            );
        };
        my $e = $@;
        say STDERR $e if $e;
        croak $e if $e;
        # say STDERR "LOADED CSV DATA";
        # _dump_sample_counts ($bd);
    }
    #  some spreadsheets
    if ($args{spreadsheet_params}{files}) {
        my $params = $args{spreadsheet_params};
        # p $files;
        my $files = $params->{files} // croak 'spreadsheet_params must include an array of files';
        if (!is_ref($files)) {
            $files = [$files];
        }
        # p $bd_params;
        my %in_options_hash
            = map {$_ => $params->{$_}}
            (qw /group_field_names label_field_names sample_count_col_names/);

        #  add croaks for missing field names groups and labels
        # p %in_options_hash;
        my $success = eval {
            $bd->import_data_spreadsheet (
                input_files => $files,
                %in_options_hash,
            );
        };
        my $e = $@;
        # p $e;
        croak $e if $e;
        # say STDERR "LOADED SPREADSHEET DATA";
        # _dump_sample_counts ($bd);
    }

    return 1;
}

1;
