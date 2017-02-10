use Xk3RbSpamex::FilterFun::FilterForSpamex;

my $SPAMMY = <<'END_EX';
<!DOCTYPE html>
<html> <body>
   <p>Click me!</p>
   <p>Click me!</p>
   <p>Click me!</p>
</body> </html>
END_EX

my $GOOD = <<'END_EX';
<!DOCTYPE html>
<html> <body>
   <p>This is some great content right here.</p>
</body> </html>
END_EX

my $filter_for_spamex
  = Xk3RbSpamex::FilterFun::FilterForSpamex->new();
$filter_for_spamex->init();

$filter_for_spamex->ingest_for_training( "spam.com", $SPAMMY, 1 );
$filter_for_spamex->ingest_for_training( "superspam.com", $SPAMMY, 1 );
$filter_for_spamex->ingest_for_training( "garbage.com", $SPAMMY, 1 );
$filter_for_spamex->ingest_for_training( "greatcontent.com", $GOOD, 0 );
$filter_for_spamex->dump_to_file( "/tmp/examplemodel.txt" );
