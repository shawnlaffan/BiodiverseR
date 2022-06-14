package BiodiverseR;
use Mojo::Base 'Mojolicious', -signatures;

#  temporary - we need Biodiverse to be installed or in PERL5LIB
use Mojo::File qw(curfile);
use lib curfile->dirname->dirname->dirname->dirname->child('biodiverse/lib')->to_string;


use BiodiverseR::Data;
use Biodiverse::BaseData;
use Biodiverse::ReadNexus;
use Biodiverse::Spatial;

local $| = 1;

#use JSON::Validator 5.08 ();

#has 'foo';

#has 'biodiverse_object' => sub {
#  Biodiverse::BaseData->new(NAME => 'some name');
#};


# This method will run once at server start
sub startup ($self) {

  # Load configuration from config file
  #my $config = $self->plugin('NotYAMLConfig');

  $self->helper(data => sub {state $data = BiodiverseR::Data->new});

  # Configure the application
  #$self->secrets($config->{secrets});
  $self->secrets(rand());

  # Router
  my $r = $self->routes;

  #$self->renderer->default_format('json');

  # Normal route to controller
  $r->get('/')->to('Example#welcome');

  #  pass some data, get a result.  Or the broken pieces. 
  $r->post ('/analysis_spatial_oneshot' => sub {
        my $c = shift;
    my $analysis_params = $c->req->json;
use Data::Printer;
p $analysis_params;
    my $bd_params = $analysis_params->{bd}{params};
    my $bd_data   = $analysis_params->{bd}{data};
    my $bd = Biodiverse::BaseData->new(
      NAME       => ($bd_params->{name} // 'BiodiverseR'),
      CELL_SIZES => $bd_params->{cellsizes},
    );
#p $bd;
    #  needs to be a more general call
    my $csv_object = $bd->get_csv_object(
      quote_char => $bd->get_param('QUOTES'),
      sep_char   => $bd->get_param('JOIN_CHAR')
    );
p $bd_data;
    eval {
      $bd->add_elements_collated_simple_aa($bd_data, $csv_object, 1);
    };
    croak $@ if $@;
say STDERR 'aaaargh';
#p $bd;
    my $tree;
    if ($analysis_params->{tree}) {
      my $readnex = Biodiverse::ReadNexus->new;
      $readnex->import_data(data => $analysis_params->{tree});
      my @results = $readnex->get_tree_array;
      $tree = shift @results;
    }
      
    $c->data->{basedata} = $bd;
    $c->data->{tree}     = $tree;
#p $bd->get_groups_ref;
#p $tree;

    #  need to be params
    my $spatial_conditions = ['sp_self_only()'];  
    my $calculations = ['calc_endemism_central'];
    my $result_list  = 'SPATIAL_RESULTS';
    
    my $sp = $bd->add_spatial_output(name => 'ooyah');
    $sp->run_analysis (
      spatial_conditions => $spatial_conditions,
      calculations => $calculations,
    );
    my $table = $sp->to_table (list => $result_list);
    $c->render(text => $table);
    p $table;
  });

#  $r->post ('/basedata' => sub {
#    my $c = shift;
#    my $hash = $c->req->json;
#use Data::Printer;
#p $hash;
#    my $params = $hash->{params};
#    my $data   = $hash->{data};
#    my $bd = Biodiverse::BaseData->new(
#      NAME       => ($params->{name} // 'BiodiverseR'),
#      CELL_SIZES => $params->{cellsizes},
#    );
#    $c->data->{basedata} = $bd;
#    $c->render(json => $bd);
#p $bd;
#    #$c->render(json => {});
#    #my $description = $bd->describe;
#    #Mojo::Log->log($description);
#    #$c->render(json => {description => $description});
#  #} => 'index');
#  });

#  $r->get ('/basedata' => sub {
#    my $c = shift;
#    my $bd = $c->data->{basedata};
#    $c->render(json => $bd);
#p $bd;
#    #$c->render(json => {});
#  #} => 'index');
#  });

  
}

1;
