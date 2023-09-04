use Mojo::Base -strict, -signatures;
use 5.010;

use Test::More;
use Test::Mojo;
use Data::Printer;

my $t = Test::Mojo->new('BiodiverseR');
$t->get_ok('/calculations_metadata')->status_is(200);

#  pretty basic
$t->json_has ('/result/calc_phylo_rpe2/description');
$t->json_has ('/result/calc_endemism_whole/indices/ENDW_CWE');
$t->json_has ('/result/calc_phylo_rpd2/required_args');
$t->json_has ('/result/calc_phylo_rpe2/indices/PHYLO_RPE_DIFF2/description');

# use Data::Printer;
# p $t->tx->res->json;

done_testing();
