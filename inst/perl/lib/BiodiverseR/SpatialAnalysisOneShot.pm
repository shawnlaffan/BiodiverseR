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
    my $spatial_conditions
      = $analysis_params->{analysis_config}{spatial_conditions} // ['sp_self_only()'];
    if (is_ref($spatial_conditions) && !is_arrayref($spatial_conditions)) {
      croak 'reftype of spatial_conditions must be array';
    }
    elsif (!is_ref($spatial_conditions)) {
      $spatial_conditions = [$spatial_conditions];
    }
    my $calculations = $analysis_params->{analysis_config}{calculations} // ['calc_endemism_central'];
    if (is_ref($calculations) && !is_arrayref($calculations)) {
      croak 'reftype of spatial_conditions must be array';
    }
    elsif (!is_ref($calculations)) {
      $spatial_conditions = [$spatial_conditions];
    }
    my $result_list  = $analysis_params->{analysis_config}{result_list} // 'SPATIAL_RESULTS';
    croak 'result_list cannot be a reference'
      if is_ref($result_list);

    my $bd_params = $analysis_params->{bd}{params};
    my $bd_data   = $analysis_params->{bd}{data};
    my $bd = Biodiverse::BaseData->new(
      NAME       => ($bd_params->{name} // 'BiodiverseR'),
      CELL_SIZES => $bd_params->{cellsizes},
    );

    #  needs to be a more general call
    my $csv_object = $bd->get_csv_object(
      quote_char => $bd->get_param('QUOTES'),
      sep_char   => $bd->get_param('JOIN_CHAR')
    );

    eval {
      $bd->add_elements_collated_simple_aa($bd_data, $csv_object, 1);
    };
    croak $@ if $@;

    my $tree;
    if ($analysis_params->{tree}) {
      my $readnex = Biodiverse::ReadNexus->new;
      $readnex->import_data(data => $analysis_params->{tree});
      my @results = $readnex->get_tree_array;
      $tree = shift @results;
    }
    
    my $sp = $bd->add_spatial_output(name => 'ooyah');
    $sp->run_analysis (
      spatial_conditions => $spatial_conditions,
      calculations => $calculations,
    );
    my $table = $sp->to_table (list => $result_list);
    
    #  need to transpose the table for json that is closer to what R wants as a list
    return $table;
}


1;

