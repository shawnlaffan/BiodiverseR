package BiodiverseR;
use Mojo::Base 'Mojolicious', -signatures;

#  temporary - we need Biodiverse to be installed or in PERL5LIB
use Mojo::File qw(curfile);
use lib curfile->dirname->dirname->dirname->dirname->child('biodiverse/lib')->to_string;


use BiodiverseR::Data;
use Biodiverse::BaseData;

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
  

  $r->post ('/basedata' => sub {
    my $c = shift;
    my $hash = $c->req->json;
use Data::Printer;
p $hash;
    my $params = $hash->{params};
    my $data   = $hash->{data};
    my $bd = Biodiverse::BaseData->new(
      NAME       => ($params->{name} // 'BiodiverseR'),
      CELL_SIZES => $params->{cellsizes},
    );
    $c->data->{basedata} = $bd;
    $c->render(json => $bd);
p $bd;
    #$c->render(json => {});
    #my $description = $bd->describe;
    #Mojo::Log->log($description);
    #$c->render(json => {description => $description});
  #} => 'index');
  });

  $r->get ('/basedata' => sub {
    my $c = shift;
    my $bd = $c->data->{basedata};
    $c->render(json => $bd);
p $bd;
    #$c->render(json => {});
  #} => 'index');
  });

  
}

1;
