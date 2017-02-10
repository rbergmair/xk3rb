use Xk3RbSpamex::S01CheckPreconditions;
use Xk3RbSpamex::S02GenerateFolds;
use Xk3RbSpamex::S11FitModel;
use Xk3RbSpamex::S12EvaluateModel;

s01_check_preconditions( '/tmp/dta/xk3rb' );
s02_generate_folds( '/tmp/dta/xk3rb' );
s11_fit_model( '/tmp/dta/xk3rb', '1' );
s12_evaluate_model( '/tmp/dta/xk3rb', '1' );

