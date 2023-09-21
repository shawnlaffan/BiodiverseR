package BiodiverseR;
use Mojo::Base 'Mojolicious', -signatures;

#  temporary - we need Biodiverse to be installed or in PERL5LIB
#use Mojo::File qw(curfile);
#use lib curfile->dirname->dirname->dirname->dirname->child('biodiverse/lib')->to_string;

use Ref::Util qw /is_ref is_arrayref is_hashref/;
use Carp qw /croak/;

use BiodiverseR::SpatialAnalysisOneShot;
use BiodiverseR::Data;
use BiodiverseR::IndicesMetadata;
use BiodiverseR::BaseData;

use Biodiverse::BaseData;
use Biodiverse::ReadNexus;
use Biodiverse::Spatial;

#  should use Mojo::File
use Path::Tiny qw /path/;
use Data::Printer qw /p np/;

local $| = 1;

#  maybe should save mac logs to ~/Library/BiodiverseR
my $logdir  = path (($^O eq 'MSWin32' ? $ENV{APPDATA} : $ENV{HOME}), "BiodiverseR/logs")->mkdir;
my $logname = path (sprintf ("$logdir/BiodiverseR_log_%s_%s.txt", time(), $$))->absolute;
while (-e $logname) {
    $logname =~ s/.txt$//;
    $logname .= 'x.txt';
}
say STDERR "log file is $logname";
my $log = Mojo::Log->new(path => $logname, level => 'trace');

#use JSON::Validator 5.08 ();

#has 'foo';

#has 'biodiverse_object' => sub {
#  Biodiverse::BaseData->new(NAME => 'some name');
#};


# This method will run once at server start
sub startup ($self) {

$log->debug("Called startup");

  # Load configuration from config file
  #my $config = $self->plugin('NotYAMLConfig');

  $self->helper(data => sub {state $data = BiodiverseR::Data->new});

  my $renderer = Mojolicious::Renderer->new;
  if ($ENV{PAR_INC}) {
    push @{$renderer->paths}, path ($ENV{PAR_INC}, 'templates');
  }
  
  # Configure the application
  #$self->secrets($config->{secrets});
  $self->secrets(rand());

  # Router
  my $r = $self->routes;

  #$self->renderer->default_format('json');

  # Normal route to controller
  $r->get('/')->to('Example#welcome');

    $r->get('/calculations_metadata' => sub ($c) {
        my $metadata;
        my $success = eval {
            $metadata = BiodiverseR::IndicesMetadata->get_indices_metadata();
            1;
        };
        my $e = $@;
        return error_as_json($c, $e)
            if $e;
        return success_as_json($c, $metadata);
    });

    $r->get('/valid_cluster_indices' => sub ($c) {
        my $metadata;
        my $success = eval {
            $metadata = BiodiverseR::IndicesMetadata->get_valid_cluster_indices();
            1;
        };
        my $e = $@;
        return error_as_json($c, $e)
            if $e;
        return success_as_json($c, $metadata);
    });

    $r->get('/valid_cluster_tie_breaker_indices' => sub ($c) {
        my $metadata;
        my $success = eval {
            $metadata = BiodiverseR::IndicesMetadata->get_valid_cluster_tie_breaker_indices();
            1;
        };
        my $e = $@;
        return error_as_json($c, $e)
            if $e;
        return success_as_json($c, $metadata);
    });

    $r->get('/valid_cluster_linkage_functions' => sub ($c) {
        my $metadata;
        use Biodiverse::Cluster;
        my $success = eval {
            $metadata = 'Biodiverse::Cluster'->get_linkage_functions();
            1;
        };
        my $e = $@;
        return error_as_json($c, $e)
            if $e;
        return success_as_json($c, $metadata);
    });

    #  pass some data, get a result.  Or the broken pieces.
    $r->post ('/analysis_spatial_oneshot' => sub ($c) {
        my $analysis_params = $c->req->json;

        $log->debug("parameters are:");
        $log->debug(np ($analysis_params));

        my $oneshot = BiodiverseR::SpatialAnalysisOneShot->new;
        my $results = $oneshot->run_analysis($analysis_params);

        $log->debug("Table is:");
        $log->debug(np ($results));

        return $c->render(json => $results);
    });

    #  initialise a basedata.
    $r->post ('/init_basedata' => sub ($c) {
        my $analysis_params = $c->req->json;

        $log->debug("parameters are:");
        $log->debug(np ($analysis_params));

        my $result = eval {
            BiodiverseR::BaseData->init_basedata ($analysis_params);
            1;
        };
        my $e = $@;
        return error_as_json ($c,  "Cannot initialise basedata, $e")
            if $e;

        return success_as_json ($c, $result);
    });

    $r->post ('/bd_delete_analysis' => sub ($c) {
        my $analysis_params = $c->req->json;

        my $result = eval {
            BiodiverseR::BaseData->delete_output ($analysis_params);
            1;
        };
        my $e = $@;
        return error_as_json ($c,  "Cannot delete $analysis_params->{name} from basedata, $e")
            if $e;

        return success_as_json ($c, $result);
    });

    $r->post ('/bd_delete_all_analyses' => sub ($c) {
        my $analysis_params = $c->req->json;

        my $result = eval {
            BiodiverseR::BaseData->delete_all_outputs;
            1;
        };
        my $e = $@;
        return error_as_json ($c,  "Cannot delete all analyses from basedata, $e")
            if $e;

        return success_as_json ($c, $result);
    });


    $r->post ('/bd_load_data' => sub ($c) {
        my $analysis_params = $c->req->json;

        $log->debug("parameters are:");
        $log->debug(np ($analysis_params));
        $log->debug("About to call load_data");

        my $result = eval {
            BiodiverseR::BaseData->load_data ($analysis_params);
            1;
        };
        my $e = $@;
        $log->debug ($e) if $e;
        return error_as_json ($c, "Cannot load data into basedata, $e")
          if $e;
        # my $bd = BiodiverseR::BaseData->get_basedata_ref;
        # say STDERR "LOADED, result is $result, group count is " . $bd->get_group_count;
        #  should just return success or failure
        return success_as_json ($c, $result);
    });

    $r->post ('/bd_get_group_count' => sub ($c) {
        my $bd = BiodiverseR::BaseData->get_basedata_ref;
        my $result = $bd ? $bd->get_group_count : undef;
        return success_as_json ($c, $result);
    });

    $r->post ('/bd_get_label_count' => sub ($c) {
        my $bd = BiodiverseR::BaseData->get_basedata_ref;
        my $result = $bd ? $bd->get_label_count : undef;
        return success_as_json ($c, $result);
    });

    $r->post ('/bd_get_analysis_count' => sub ($c) {
        my $result = BiodiverseR::BaseData->get_output_count;
        return success_as_json ($c, $result);
    });

    $r->post ('/bd_run_spatial_analysis' => sub ($c) {
        return analysis_call ($c, 'run_spatial_analysis');
    });

    #  refactor needed - mostly the same as spatial variant
    $r->post ('/bd_run_cluster_analysis' => sub ($c) {
        return analysis_call ($c, 'run_cluster_analysis');
    });

    #  duplicates much from above - needs refactoring
    $r->post ('/bd_get_analysis_results' => sub ($c) {
        my $analysis_params = $c->req->json;

        $log->debug("parameters are:");
        $log->debug(np ($analysis_params));
        $log->debug("About to call get_analysis_results");

        return error_as_json($c,
            ('analysis_params must be a hash structure, got '
                . reftype($analysis_params)))
            if !is_hashref ($analysis_params);

        my $result = eval {
            BiodiverseR::BaseData->get_analysis_results ($analysis_params->{name});
        };
        my $e = $@;
        return error_as_json($c, "Failed to get analysis results\n$e")
            if $e;

        return success_as_json($c, $result);
    });

    $r->post ('/bd_save_to_bds' => sub ($c) {
        my $args = $c->req->json;
        my $filename = $args->{filename};
        my $result = eval {
            my $bd = BiodiverseR::BaseData->get_basedata_ref;
            return $c->render(json => undef)
                if !$bd || !defined $filename;
            $bd->save(filename => $filename);
        };
        my $e = $@;
        return $c->render(json => {error => $e, result => defined $result});
    });

    sub success_as_json ($c, $result) {
        return $c->render(
            json => {
                error  => undef,
                result => $result,
            }
        );
    }

    sub error_as_json ($c, $error) {
        return $c->render(
            json => {
                error  => $error,
                result => undef
            }
        );
    }

    sub analysis_call ($c, $method){
        my $analysis_params = $c->req->json;

        $log->debug("parameters are:");
        $log->debug(np ($analysis_params));
        $log->debug("About to call $method");

        return error_as_json($c,
            ('analysis_params must be a hash structure, got '
                . reftype($analysis_params)))
            if !is_hashref ($analysis_params);

        my $result = eval {
            BiodiverseR::BaseData->$method ($analysis_params);
        };
        my $e = $@;
        return error_as_json($c, "Failed to get analysis results\n$e")
            if $e;

        return success_as_json($c, $result);
    }

}


1;
