use MIME::Parser;
use Data::Dumper;
 
### Create parser, and set some parsing options:
my $parser = new MIME::Parser;
 
### Parse input:
my $entity = $parser->parse(\*STDIN) or die "parse failed\n";
my $head     = $entity->head();
print "WTF: ", $head->get('Subject'), "\n";

### Take a look at the top-level entity (and any parts it has):
$entity->dump_skeleton;
