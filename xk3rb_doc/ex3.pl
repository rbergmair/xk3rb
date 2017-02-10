use Xk3RbSpamex::FilterFun::FilterForSpamex;

my $BRITISH_SPAMMY = <<'END_EX';
<!DOCTYPE html>
<html> <body>
   <p>Might I trouble you to click here?</p>
</body> </html>
END_EX

my $ALSO_GOOD = <<'END_EX';
<!DOCTYPE html>
<html> <body>
   <p>There is always a well-known solution to every human problem...</p>
</body> </html>
END_EX

my $filter_for_spamex
  = Xk3RbSpamex::FilterFun::FilterForSpamex->new();
$filter_for_spamex->init();

$filter_for_spamex->load_from_file( "/tmp/examplemodel.txt" );

my $decision1
  = $filter_for_spamex->apply_filter( "britishspam.com", $BRITISH_SPAMMY );

my $decision2
  = $filter_for_spamex->apply_filter( "alsogood.com", $ALSO_GOOD );

print "britishspam.com has spamlabel $decision1\n";
print "alsogood.com has spamlabel $decision2\n";
