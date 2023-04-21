use Xk3RbSpamex::FilterFun::Preprocessor;


my $SPAMMY = <<'END_EX';
<!DOCTYPE html>
<html> <body>
   <p>Click <a href="http://www.clickbait1.com/">me!</a></p>
   <p>Click <a href="http://www.clickbait2.com/">me!</a></p>
</body> </html>
END_EX


my $pp
  = Xk3RbSpamex::FilterFun::Preprocessor->new();
$pp->init( "spammy.com", $SPAMMY );

for my $lnk ( $pp->get_outgoing_links() ) {
    print $lnk, "\n";
};

for my $wrd ( $pp->get_words() ) {
    print $wrd, "\n";
};
