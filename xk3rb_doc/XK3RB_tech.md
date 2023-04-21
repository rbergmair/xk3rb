% XK3 Portfolio Project -- Technical Documentation
% Richard Bergmair
% Jan-31 2017


# Prerequisites

(1.1) First, make sure you have Perl installed.
I tested this software with perl versions 5.12.5 and 5.24.0, so it is likely
that any version within that range will work, possibly also newer versions.
If you don't already have Perl, here is an example of how to install it
with `apt-get`:
```
sudo apt-get install perl
```

(1.2) If you'd like to be able to build documentation (optional), you'll need
`pandoc`.  Here is an example of how to install it with `apt-get`:
```
sudo apt-get install pandoc
```

(1.3) Then unpack `xk3rb.tar.gz` into some working directory, e.g.
```
tar xfz xk3rb.tar.gz -C /tmp
cd /tmp/xk3rb
```
Obviously, you can use a directory other than `/tmp/xk3rb`.  Normally
this will be wherever you're used to working with code and other files
that are under version control, etc.  -- On my machine it's
`/home/rb/workspace/xk3rb`.

(1.4) Then, with that directory as your current working directory,
use the following command to install the required perl modules.
```
cat requirements.txt | xargs cpan
```

(1.5) Then, set up the directory structure that will hold the data that
you'll be working with.  In the following example I'll use `/tmp/dta/xk3rb`.
Again, you might want to use something that's more meaningful to the way
you've got your environment set up.  On my machine, it's `/dta/xk3rb`,
since I have backup strategies etc set up for `/dta`.

(1.5.a) There should be a subdirectory `filters` which will be where the
model parameters will live.
```
mkdir -p /tmp/dta/xk3rb/filters
```

(1.5.b) The contents of the `training` subdirectory of `training.zip` are
supposed to live in a subdirectory called `fetched`.
```
unzip training.zip 'training/*' -d /tmp/dta/xk3rb
mv /tmp/dta/xk3rb/training /tmp/dta/xk3rb/fetched
```


# Command Line Usage

(2.1) The following instructions need to be executed from the `xk3rb`
subdirectory of the directory that you unpacked `xk3rb.tar.gz` into.
Double-check that this is the case.  If you've set up the prerequisites as
per the example above, then `pwd` should output `/tmp/xk3rb`.

(2.2) When working with this code, the script `xk3rbspamex.pl` under
`xk3rb` will always serve as the entry point.  In addition, you need to
make sure that `xk3rb` is in the include path.  To execute the first
step, which goes by the name `s01_check_preconditions`, you need to
call it like this:
```
perl -I xk3rb ./xk3rb/xk3rbspamex.pl s01_check_preconditions /tmp/dta/xk3rb
```
So the first parameter is an identifier of the step in the processing
pipeline that you'd like to execute, the second parameter is the path
where you've set up the data files, and where additional datafiles will
be created.  It should complain about the fact that, for 558 of the domains
mentioned in `training.txt`, the corresponding files with fetched data
are not included in the archive.  Conversely, there are 85 domains for which
fetched data is present, but which do not have training labels associated
with them.  -- This can be ignored.  Further steps in the processing pipeline
will use only those domains for which both fetched data and training data
is available.

(2.2) The next step is concerned with assigning the domains that we have
data available for into folds for
[crossvalidation](https://en.wikipedia.org/wiki/Cross-validation_(statistics)).
```
perl -I xk3rb ./xk3rb/xk3rbspamex.pl s02_generate_folds /tmp/dta/xk3rb
```
It will say that it found folds data in `xk3rb_dta/folds.txt` and will
validate it against training labels and fetched data in `/tmp/dta/xk3rb`.
If this validation fails try this
```
rm xk3rb_dta/folds.txt
perl -I xk3rb ./xk3rb/xk3rbspamex.pl s02_generate_folds /tmp/dta/xk3rb
```
This will generate fresh folds data by assigning a fold which is an integer
in the range 1 through 10 inclusive to each domain.  The folds data lives
in `xk3rb_dta` rather than `/tmp/dta/xk3rb`.  This was laid out like this
intentionally.  Once generated, the file cannot be reliably reproduced
(e.g. across different versions of the random number generator), but the
contents are needed for statistics to be comparable with statistics quoted
in this documentation, and the file is small enough so as not to cause
trouble for the version control system.  Recommended practice would be that,
if changes are made to this file, then the documentation needs to be updated
in line with the evaluation stats derived from the folds assignment, and
both should be checked into version control.

(2.3.a) The next step is to use the data as training data to fit a model.
The calling pattern is like this:
```
perl -I xk3rb ./xk3rb/xk3rbspamex.pl s11_fit_model /tmp/dta/xk3rb 1
```
The last parameter is the fold to be omitted for model fitting.  So by
calling the model fitting like this, all domains, except for the domains
that are assigned to fold number one are used for training.  The resulting
model parameters are stored under `/tmp/dta/xk3rb` and should never be
checked into version control, as they can be reliably reproduced from the
code, the input data, and the folds data.

(2.3.b) This part of the processing pipeline will throw an exception if it's
asked to generate model parameters that already exist in a model parameters
file.  So if you rerun it the same way a second time
```
perl -I xk3rb ./xk3rb/xk3rbspamex.pl s11_fit_model /tmp/dta/xk3rb 1
```
then you should get a perl exception pointing to a failed assertion that
will make it very obvious that there is a file here that exists that
shouldn't exist.  To run a second time, you need to manually delete the file:
```
rm /tmp/dta/xk3rb/filters/filter_for_spamex_1.txt
perl -I xk3rb ./xk3rb/xk3rbspamex.pl s11_fit_model /tmp/dta/xk3rb 1
```
It can also be useful for regression testing to rename the file, then
diff it with a newly generated file, or take an md5sum before deleting
and after regenerating to verify that model parameters don't change
when you don't expect them to, e.g. as part of refactoring work.

(2.3.c.) So, you should generate model parameters for all 10 folds.
```
perl -I xk3rb ./xk3rb/xk3rbspamex.pl s11_fit_model /tmp/dta/xk3rb 2
...
perl -I xk3rb ./xk3rb/xk3rbspamex.pl s11_fit_model /tmp/dta/xk3rb 10
```
There is an obvious opportunity here for parallelization.
More information about the way the modelling works can be found in the
document on
[evaluation & methodology](XK3RB_sci.md).

(2.4) The final step will be evaluation.  The calling pattern is like this:
```
perl -I xk3rb ./xk3rb/xk3rbspamex.pl s12_evaluate_model /tmp/dta/xk3rb 1
```
By calling it like this, with a value of `1` for the last parameter, it
will use the model that was fitted by omitting the domains assigned to
fold number `1`, and use them for testing.  In other words, having never
seen the data pertaining to those domains, the model will be used to make
a decision about whether or not each domain is spam, and that model
decision will be compared to the decision recorded in the data.  The results
of those comparisions are summarized using a battery of standard statistics.
For fold number one we get the number `0.7600` for the accuracy measure.
This means that the model decision matched the decision recorded in the data
in 80.67% of the cases.  We can then rerun this on fold number 10.
```
perl -I xk3rb ./xk3rb/xk3rbspamex.pl s12_evaluate_model /tmp/dta/xk3rb 10
```
For this fold we get a number of `0.8067`.  The fact that there is a 4%
difference tells us something about the sensitivity of the model fitting
and evaluation to sampling error.  In other words, the better value of
80.67% needs to be, to some extent, attributed to the fact that we got
"lucky" in the way the training and testing sample was picked, or conversely
the worse value of 76.00% can be, to some extent, excused by the fact that
we were "unlucky" in the way the sample was picked.
More evaluation numbers and discussions thereof can be found in the
document on
[evaluation & methodology](XK3RB_sci.md).


# Top-Level API

These same steps can also be called as an API through Perl.

### Example: Running the Pipeline

```
use Xk3RbSpamex::S01CheckPreconditions;
use Xk3RbSpamex::S02GenerateFolds;
use Xk3RbSpamex::S11FitModel;
use Xk3RbSpamex::S12EvaluateModel;

s01_check_preconditions( '/tmp/dta/xk3rb' );
s02_generate_folds( '/tmp/dta/xk3rb' );
s11_fit_model( '/tmp/dta/xk3rb', '1' );
s12_evaluate_model( '/tmp/dta/xk3rb', '1' );
```


# Core API


## Xk3RbSpamex::FilterFun::FilterForSpamex


This is the lower-level API that you'd use for example when training a model
from a differently structured data source or a live realtime datasource, etc.
You'd also use this lower-level API for getting model predictions in a
context other than for collecting evaluation statistics.  So this is the API
that would be used to implement this into the search engine proper.


### Example: Training & Dumping

```
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
```


### Example: Loading & Applying

```
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
```


### Reference

**`new`()**
takes no arguments;
returns the object reference as usual for a constructor.

**`init`()**
should be called immediately after construction;
for use in connection with implementation internals.

**`ingest_for_training`( *`$domain`*, *`$content`*, *`$spamlabel`* )**
ingests data for training purposes.
Here *`$content`* is the html content of the page to be used for training.
A value needs to be passed in for *`$domain`* for link resolution as every
page is implicitly considered to link to its own domain.  Also, this domain
is used to resolve relative links.  The value of *`$spamlabel`* needs to be
either zero or one and indicates whether this is an example of a data that's
to be considered spam, or an example of data that's to be considered nonspam.

**`dump_to_file`( *`$fn`* )**
dumps the model parameters to the file named *\$fn*.

**`dump_to_file`( *`$fn`* )**
loads the model parameters from the file named *\$fn*.

***`$spamlabel`* = `apply_filter`( *`$domain`*, *`$content`* )**
outputs the model decision for a given page.
The parameters are the same as for `ingest_for_training`, except that
*`$spamlabel`* is returned rather than passed in.


## Xk3RbSpamex::FilterFun::Preprocessor


This is a reusable component that factors out the aspects having to do with
the preprocessing that forms the model's perception of the data.  Essentially
a web document is perceived as a set of keywords, plus a set of domains that
the page links to.


### Example: Retrieving Keywords and Links From a Web Document


```
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
```

### Reference

**`new`()**
takes no arguments;
returns the object reference as usual for a constructor.

**`init`( *`$domain`*, *`$content`* )**
should be called immediately after construction.
Here *`$content`* is the html content of the page to be preprocessed.
A value needs to be passed in for *`$domain`* for link resolution as every
page is implicitly considered to link to its own domain.  Also, this domain
is used to resolve relative links.

***`@links`* = `get_outgoing_links`()**
returns in list context a uniqued list of host-part of outgoing links
appearing in the data.

***`@words`* = `get_words`()**
returns in list context a uniqued list of keywords appearing in the data.



## Xk3RbSpamex::FilterFun::Evaluator


This is a reusable component that factors out the aspects having to do with
collecting data about model-assigned labels and gold-standard labels and
comparing them through a battery of standard statistics.


### Example: Calculating Some Evaluation Stats


```
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
```


### Reference

**`new`()**
takes no arguments;
returns the object reference as usual for a constructor.

**`init`()**
should be called immediately after construction;
for use in connection with implementation internals.

**`ingest_for_evaluation`( *`$goldstandard_label`*, *`$model_label`* )**
is to be called on each decision pair, where *`$goldstandard_label`* is the
class label associated with a testing instance as per the data provided, i.e.
the ground truth or "gold standard", and *`$model_label`* is the class label
representing the model decision of a model to be evaluated.  These labels can
be either one of 0 or 1, where 1 is considered to be the "positive" class
for purposes of the below evaluation measures, and 0 is the "negative" class.

**`total`**
is the total number of decision pairs ingested for testing.

**`true_positives`**
is the raw number of decision pairs which the model identified as positives
and which actually were positives as per the gold standard.

**`false_positives`**
is the raw number of decision pairs which the model identified as positives
and which actually were negatives as per the gold standard.

**`true_negatives`**
is the raw number of decision pairs which the model identified as negatives
and which actually were negatives as per the gold standard.

**`false_negatives`**
is the raw number of decision pairs which the model identified as negatives
but which actually were positives as per the gold standard.

**`dataset_bias`**
is the proportion of decision pairs which were positives as per the gold
standard.

**`model_bias`**
is the proportion of decision pairs which were positives as per the model
decisions.

**`accuracy`**
is the proportion of decision pairs wherein the model decision coincided with
the gold standard.

**`precision`**
is the proportion of true positives among all decision pairs which were
positives as per the model decisions.

**`recall`**
is the proportion of true positives among all decision pairs which were
positives as per the gold standard.

**`fmeasure`**
is a harmonic mean of precision and recall.

**`say_report()`**
prints all of the above in human-readable YAML format.


#### See Also

See also
[here](https://en.wikipedia.org/wiki/F1_score).


# Generating Documentation

To generate documentation, the following instructions need to be executed
from the `xk3rb` subdirectory of the directory that you unpacked
`xk3rb.tar.gz` into.
```
cd xk3rb_doc
make
```


# Notes On Implementation Details


## Unit Tests

Normally, I like to have unit test in place for all code that I'm responsible
for.  Due to the stringent time limit of 20 hours which applied to this
exercise, I did not have time to implement any, so this would be my immediate
next step, if I were to work on something like this in a realistic setting.


## Assertive Programming

I like to use lots of `assert` statements throughout my code.  This is a
practice I got into as a python developer.  I work very hard to make my
programs fail with a big bang as close as possible to the point where an
error condition first becomes detectable.  It seems to me that, with Perl,
it's even more important to do this, as the interpreter/compiler does less
checking of its own accord and follows a philosophy of trying to be
"forgiving" w.r.t. errors, which will often have the effect that an error
will still happen eventually, but later on throughout the execution path,
making it difficult to trace the root cause of an error.


## Error Messages

In this code, you will notice that I did not invest a lot of effort into
creating human readable error messages.  If you get into the habit of using
asserts, you will find that asserts are a pretty good excuse for laziness
on that front.  If a program trips up due to an assert, then by looking up
the line of code identified in the exception trace, one will know which
assert failed, which, in self-documenting code will make it immediately
obvious what's wrong, thus eliminating the need to to create pretty error
messages.  -- Obviously, it would still be a good idea to do so, but with
the time pressures faced by this project (and any project for that matter)
it seems to me an acceptable compromise.


## Comments

Whenever I feel the need to put a comment into a piece of code to describe
what's going on, it's usually better to do one of three things:  (a) Refactor
the code so it becomes more obvious what's going on.  (b) Put in a log
statement to tell the user what you're up to.  This will serve just as well
as a comment to the reader of the code, plus you've got logs now!
(c) Put the comment into the documentation instead of the code, which I find
preferable as I like to keep the code "dense", rather than having the actual
logic scattered throughout a sea of comments and docstrings.


## Documentation

I apply the same philosophy to documentation.  As I like to keep my code
dense, I prefer not to use tools that generate documenation from docstrings
in code.  I'd rather have the documenation in separate files.


## Flexibility

I like to keep my obsessive-range personality traits in check.  So if you
disagree with any of the above, I can happily yield to what's common
practice in a codebase that I work with.

