package BiodiverseR::SpatialAnalysisOneShot;

use 5.026;
use strict;
use warnings;

use Mojo::Base 'Mojolicious', -signatures;

use Ref::Util qw /is_ref is_arrayref/;
use Carp qw /croak/;

use Biodiverse::BaseData;
use Biodiverse::ReadNexus;
use Biodiverse::Spatial;

use Path::Tiny qw /path/;
use Data::Printer qw /p np/;

#  almost a dummy run
sub new {
    my $class = shift;
    my $self = {};
    return bless $self, $class;
}

sub run_analysis ($self, $analysis_params) {
    my $a_cfg = $analysis_params->{analysis_config} // {};

    #  rjson converts single item vectors to scalars
    #  so need to handle both scalars and arrays
    my $spatial_conditions
      = $analysis_params->{analysis_config}{spatial_conditions} // ['sp_self_only()'];
    if (is_ref($spatial_conditions) && !is_arrayref($spatial_conditions)) {
      croak 'reftype of spatial_conditions must be array';
    }
    elsif (!is_ref($spatial_conditions)) {
      $spatial_conditions = [$spatial_conditions];
    }

    my $calculations
      = $analysis_params->{analysis_config}{calculations} // ['calc_richness'];
    if (is_ref($calculations) && !is_arrayref($calculations)) {
      croak 'reftype of spatial_conditions must be array';
    }
    elsif (!is_ref($calculations)) {
      $calculations = [$calculations];
    }

    my $result_lists
      = $analysis_params->{analysis_config}{result_lists} // ['SPATIAL_RESULTS'];
    croak 'result_lists must be an array reference'
      if !is_arrayref($result_lists);
    #  should objectify this stuff so the args are checked automatically
    croak 'result_list is no longer a valid argument - use result_lists instead'
      if defined $analysis_params->{analysis_config}{result_list};
    croak 'results_list is not a valid argument - use result_lists instead'
      if defined $analysis_params->{analysis_config}{results_list};

    my $bd_params = $analysis_params->{bd}{params};
    my $bd_data   = $analysis_params->{bd}{data};
    my $bd = Biodiverse::BaseData->new(
      NAME       => ($bd_params->{name} // 'BiodiverseR'),
      CELL_SIZES => $bd_params->{cellsizes},
    );

    if ($bd_data) {
        #  needs to be a more general call
        my $csv_object = $bd->get_csv_object(
          quote_char => $bd->get_param('QUOTES'),
          sep_char   => $bd->get_param('JOIN_CHAR')
        );
        eval {
          $bd->add_elements_collated_simple_aa($bd_data, $csv_object, 1);
        };
        croak $@ if $@;
    }
    my $raster_files = $analysis_params->{bd}{raster_files};
    if ($raster_files) {  #  need to import some rasters
        if (!is_ref($raster_files)) {
            $raster_files = [$raster_files];
        }
        my %in_options_hash = (
            labels_as_bands   => 1,
            raster_origin_e   => ($bd_params->{cellorigins}[0] // 0),
            raster_origin_n   => ($bd_params->{cellorigins}[1] // 0),
            raster_cellsize_e => $bd_params->{cellsizes}[0],
            raster_cellsize_n => $bd_params->{cellsizes}[1],
        );
        my $success = eval {
            $bd->import_data_raster (
                input_files => $raster_files,
                %in_options_hash,
                labels_as_bands => ($bd_params->{labels_as_bands} // 1),
            );
        };
        croak $@ if $@;
    }

    my $tree;
    if ($analysis_params->{tree}) {
      my $readnex = Biodiverse::ReadNexus->new;
      $readnex->import_data(data => $analysis_params->{tree});
      my @results = $readnex->get_tree_array;
      $tree = shift @results;
    }
#p $bd->{LABELS};
#p $analysis_params->{tree};
#p $tree->{TREE_BY_NAME};
    my $sp = $bd->add_spatial_output(name => 'ooyah');
    $sp->run_analysis (
      spatial_conditions => $spatial_conditions,
      calculations => $calculations,
      tree_ref => $tree,
    );
#p $sp;
    my @list_names = $sp->get_hash_list_names_across_elements(no_private => 1);
#p @list_names;
    my %results;
    foreach my $listname (@list_names) {
        my $table = $sp->to_table (list => $listname, symmetric => 1);
        $results{$listname} = $table;
    }
#p %results;
    return \%results;
}


1;

