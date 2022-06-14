use Mojo::Base -strict, -signatures;

use Test::More;
use Test::Mojo;
use Data::Printer;

my $t = Test::Mojo->new('BiodiverseR');
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);


my $gp_lb = {
  '50:50'   => {label1 => 1, label2 => 1},
  '150:150' => {label1 => 1, label2 => 1},
};
my $oneshot_data = {
  bd => {
    params => {name => 'blognorb', cellsizes => [100,100]},
    data   => $gp_lb,
  },
}; 
$t->post_ok ('/analysis_spatial_oneshot' => json => $oneshot_data)
  ->status_is(200);

my $ua = Mojo::UserAgent->new;
my $tx = $ua->post(
  'http://127.0.0.1:3000/analysis_spatial_oneshot'
  => json
  => $oneshot_data
);
#p $tx->result->body;

#  not the best test - fix later
is $tx->result->body,
  '[["ELEMENT","Axis_0","Axis_1","ENDC_CWE","ENDC_RICHNESS","ENDC_SINGLE","ENDC_WE"],["150:150","150","150",0.5,2,1.0,1],["50:50","50","50",0.5,2,1.0,1]]',
  'got expected table back';

done_testing();
