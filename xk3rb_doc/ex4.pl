use Xk3RbSpamex::FilterFun::Evaluator;


my $evaluator
  = Xk3RbSpamex::FilterFun::Evaluator->new();
$evaluator->init();

$evaluator->ingest_for_evaluation( 0, 1 );
$evaluator->ingest_for_evaluation( 0, 0 );
$evaluator->ingest_for_evaluation( 1, 0 );
$evaluator->ingest_for_evaluation( 1, 1 );
$evaluator->ingest_for_evaluation( 1, 1 );
$evaluator->ingest_for_evaluation( 1, 1 );
$evaluator->ingest_for_evaluation( 0, 0 );
$evaluator->ingest_for_evaluation( 0, 1 );
$evaluator->ingest_for_evaluation( 0, 1 );

print scalar $evaluator->total, "\n";

$evaluator->say_report();
