sentimentr   [![Follow](https://img.shields.io/twitter/follow/tylerrinker.svg?style=social)](https://twitter.com/intent/follow?screen_name=tylerrinker)
============


[![Project Status: Active - The project has reached a stable, usable
state and is being actively
developed.](http://www.repostatus.org/badges/0.1.0/active.svg)](http://www.repostatus.org/#active)
[![Build
Status](https://travis-ci.org/trinker/sentimentr.svg?branch=master)](https://travis-ci.org/trinker/sentimentr)
[![Coverage
Status](https://coveralls.io/repos/trinker/sentimentr/badge.svg?branch=master)](https://coveralls.io/r/trinker/sentimentr?branch=master)
[![DOI](https://zenodo.org/badge/5398/trinker/sentimentr.svg)](https://zenodo.org/badge/latestdoi/5398/trinker/sentimentr)
<a href="https://img.shields.io/badge/Version-0.4.0-orange.svg"><img src="https://img.shields.io/badge/Version-0.4.0-orange.svg" alt="Version"/></a>
</p>
[![](http://cranlogs.r-pkg.org/badges/sentimentr)](https://cran.r-project.org/package=sentimentr)

<img src="inst/sentimentr_logo/r_sentimentr.png" width="150" alt="readability Logo">

**sentimentr** is designed to quickly calculate text polarity sentiment
at the sentence level and optionally aggregate by rows or grouping
variable(s).

**sentimentr** is a response to my own needs with sentiment detection
that were not addressed by the current **R** tools. My own `polarity`
function in the **qdap** package is slower on larger data sets. It is a
dictionary lookup approach that tries to incorporate weighting for
valence shifters (negation and amplifiers/deamplifiers). Matthew
Jocker's created the
[**syuzhet**](http://www.matthewjockers.net/2015/02/02/syuzhet/) package
that utilizes dictionary lookups for the Bing, NRC, and Afinn methods.
He also utilizes a wrapper for the [Stanford
coreNLP](http://nlp.stanford.edu/software/corenlp.shtml) which uses much
more sophisticated analysis. Jocker's dictionary methods are fast but
are more prone to error in the case of valence shifters. Jocker's
[addressed these
critiques](http://www.matthewjockers.net/2015/03/04/some-thoughts-on-annies-thoughts-about-syuzhet/)
explaining that the method is good with regard to analyzing general
sentiment in a piece of literature. He points to the accuracy of the
Stanford detection as well. In my own work I need better accuracy than a
simple dictionary lookup; something that considers valence shifters yet
optimizes speed which the Stanford's parser does not. This leads to a
trade off of speed vs. accuracy. The equation below describes the
dictionary method of **sentimentr** that may give better results than a
dictionary approach that does not consider valence shifters but will
likely still be less accurate than Stanford's approach. Simply,
**sentimentr** attempts to balance accuracy and speed.


Table of Contents
============

-   [Functions](#functions)
-   [The Equation](#the-equation)
-   [Installation](#installation)
-   [Examples](#examples)
    -   [Plotting](#plotting)
        -   [Plotting at Aggregated Sentiment](#plotting-at-aggregated-sentiment)
        -   [Plotting at the Sentence Level](#plotting-at-the-sentence-level)
    -   [Making and Updating Dictionaries](#making-and-updating-dictionaries)
    -   [Annie Swafford's Examples](#annie-swaffords-examples)
    -   [Comparing sentimentr, syuzhet, RSentiment, and Stanford](#comparing-sentimentr-syuzhet-rsentiment-and-stanford)
    -   [Text Highlighting](#text-highlighting)
-   [Contact](#contact)

Functions
============


There are two main functions (top 2 in table below) in **sentimentr**
with several helper functions summarized in the table below:

<table style="width:104%;">
<colgroup>
<col width="26%" />
<col width="77%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Function</th>
<th align="left">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left"><code>sentiment</code></td>
<td align="left">Sentiment at the sentence level</td>
</tr>
<tr class="even">
<td align="left"><code>sentiment_by</code></td>
<td align="left">Aggregated sentiment by group(s)</td>
</tr>
<tr class="odd">
<td align="left"><code>uncombine</code></td>
<td align="left">Extract sentence level sentiment from <code>sentiment_by</code></td>
</tr>
<tr class="even">
<td align="left"><code>get_sentences</code></td>
<td align="left">Regex based string to sentence parser (or get sentences from <code>sentiment</code>/<code>sentiment_by</code>)</td>
</tr>
<tr class="odd">
<td align="left"><code>replace_emoticon</code></td>
<td align="left">Replace emoticons with word equivalent</td>
</tr>
<tr class="even">
<td align="left"><code>replace_grade</code></td>
<td align="left">Replace gradess (e.g., &quot;A+&quot;) with word equivalent</td>
</tr>
<tr class="odd">
<td align="left"><code>replace_rating</code></td>
<td align="left">Replace ratings (e.g., &quot;10 out of 10&quot;, &quot;3 stars&quot;) with word equivalent</td>
</tr>
<tr class="even">
<td align="left"><code>as_key</code></td>
<td align="left">Coerce a <code>data.frame</code> lexicon to a polarity hash key</td>
</tr>
<tr class="odd">
<td align="left"><code>is_key</code></td>
<td align="left">Check if an object is a hash key</td>
</tr>
<tr class="even">
<td align="left"><code>update_key</code></td>
<td align="left">Add/remove terms to/from a hash key</td>
</tr>
<tr class="odd">
<td align="left"><code>highlight</code></td>
<td align="left">Highlight positive/negative sentences as an HTML document</td>
</tr>
</tbody>
</table>

The Equation
============

The equation used by the algorithm to assign value to polarity of each
sentence fist utilizes the sentiment dictionary (Hu and Liu,
[2004](http://www.cs.uic.edu/~liub/publications/kdd04-revSummary.pdf))
to tag polarized words. Each paragraph
(*p*<sub>*i*</sub> = {*s*<sub>1</sub>, *s*<sub>2</sub>, ..., *s*<sub>*n*</sub>})
composed of sentences, is broken into element sentences
(*s*<sub>*i*</sub>, *j* = {*w*<sub>1</sub>, *w*<sub>2</sub>, ..., *w*<sub>*n*</sub>})
where *w* are the words within sentences. Each sentence
(*s*<sub>*j*</sub>) is broken into a an ordered bag of words.
Punctuation is removed with the exception of pause punctuations (commas,
colons, semicolons) which are considered a word within the sentence. I
will denote pause words as *c**w* (comma words) for convenience. We can
represent these words as an i,j,k notation as
*w*<sub>*i*, *j*, *k*</sub>. For example *w*<sub>3, 2, 5</sub> would be
the fifth word of the second sentence of the third paragraph. While I
use the term paragraph this merely represent a complete turn of talk.
For example it may be a cell level response in a questionnaire composed
of sentences.

The words in each sentence (*w*<sub>*i*, *j*, *k*</sub>) are searched
and compared to a modified version of Hu, M., & Liu, B.'s (2004)
dictionary of polarized words. Positive
(*w*<sub>*i*, *j*, *k*</sub><sup>+</sup>) and negative
(*w*<sub>*i*, *j*, *k*</sub><sup>−</sup>) words are tagged with a +1 and
−1 respectively (or other positive/negative weighting if the user
provides the sentiment dictionary). I will denote polarized words as
*p**w* for convenience. These will form a polar cluster
(*c*<sub>*i*, *j*, *l*</sub>) which is a subset of the a sentence
(*c*<sub>*i*, *j*, *l*</sub> ⊆ *s*<sub>*i*</sub>, *j*).

The polarized context cluster (*c*<sub>*i*, *j*, *l*</sub>) of words is
pulled from around the polarized word (*p**w*) and defaults to 4 words
before and two words after *p**w* to be considered as valence shifters.
The cluster can be represented as
(*c*<sub>*i*, *j*, *l*</sub> = {*p**w*<sub>*i*, *j*, *k* − *n**b*</sub>, ..., *p**w*<sub>*i*, *j*, *k*</sub>, ..., *p**w*<sub>*i*, *j*, *k* − *n**a*</sub>}),
where *n**b* & *n**a* are the parameters `n.before` and `n.after` set by
the user. The words in this polarized context cluster are tagged as
neutral (*w*<sub>*i*, *j*, *k*</sub><sup>0</sup>), negator
(*w*<sub>*i*, *j*, *k*</sub><sup>*n*</sup>), amplifier
(*w*<sub>*i*, *j*, *k*</sub><sup>*a*</sup>), or de-amplifier
(*w*<sub>*i*, *j*, *k*</sub><sup>*d*</sup>). Neutral words hold no value
in the equation but do affect word count (*n*). Each polarized word is
then weighted (*w*) based on the weights from the `polarity_dt` argument
and then further weighted by the function and number of the valence
shifters directly surrounding the positive or negative word (*p**w*).
Pause (*c**w*) locations (punctuation that denotes a pause including
commas, colons, and semicolons) are indexed and considered in
calculating the upper and lower bounds in the polarized context cluster.
This is because these marks indicate a change in thought and words prior
are not necessarily connected with words after these punctuation marks.
The lower bound of the polarized context cluster is constrained to
max{*p**w*<sub>*i*, *j*, *k* − *n**b*</sub>, 1, max{*c**w*<sub>*i*, *j*, *k*</sub> &lt; *p**w*<sub>*i*, *j*, *k*</sub>}}
and the upper bound is constrained to
min{*p**w*<sub>*i*, *j*, *k* + *n**a*</sub>, *w*<sub>*i*, *j**n*</sub>, min{*c**w*<sub>*i*, *j*, *k*</sub> &gt; *p**w*<sub>*i*, *j*, *k*</sub>}}
where *w*<sub>*i*, *j**n*</sub> is the number of words in the sentence.

The core value in the cluster, the polarized word is acted upon by
valence shifters. Amplifiers increase the polarity by 1.8 (.8 is the
default weight (*z*)). Amplifiers
(*w*<sub>*i*, *j*, *k*</sub><sup>*a*</sup>) become de-amplifiers if the
context cluster contains an odd number of negators
(*w*<sub>*i*, *j*, *k*</sub><sup>*n*</sup>). De-amplifiers work to
decrease the polarity. Negation
(*w*<sub>*i*, *j*, *k*</sub><sup>*n*</sup>) acts on
amplifiers/de-amplifiers as discussed but also flip the sign of the
polarized word. Negation is determined by raising −1 to the power of the
number of negators (*w*<sub>*i*, *j*, *k*</sub><sup>*n*</sup>) plus 2.
Simply, this is a result of a belief that two negatives equal a
positive, 3 negatives a negative, and so on.

The "but" conjunctions (i.e., 'but', 'however', and 'although') also
weight the context cluster. A but conjunction before the polarized word
(*w*<sub>*b**u**t* *c**o**n**j**u**n**c**t**i**o**n*</sub>, ..., *w*<sub>*i*, *j*, *k*</sub><sup>*p*</sup>)
up-weights the cluster by 1 +
*z*<sub>2</sub> \* {|*w*<sub>*b**u**t* *c**o**n**j**u**n**c**t**i**o**n*</sub>|,...,*w*<sub>*i*, *j*, *k*</sub><sup>*p*</sup>}
(.85 is the default weight (*z*<sub>2</sub>) where
|*w*<sub>*b**u**t* *c**o**n**j**u**n**c**t**i**o**n*</sub>| are the
number of but conjunctions before the polarized word). A but conjunction
after the polarized word down-weights the cluster by 1 +
{*w*<sub>*i*, *j*, *k*</sub><sup>*p*</sup>, ..., |*w*<sub>*b**u**t* *c**o**n**j**u**n**c**t**i**o**n*</sub>|\* − 1}\**z*<sub>2</sub>.
This corresponds to the belief that a but makes the next clause of
greater values while lowering the value placed on the prior clause.

The researcher may provide a weight (*z*) to be utilized with
amplifiers/de-amplifiers (default is .8; de-amplifier weight is
constrained to −1 lower bound). Last, these weighted context clusters
(*c*<sub>*i*, *j*, *l*</sub>) are summed (*c*′<sub>*i*, *j*</sub>) and
divided by the square root of the word count
(&radic;*w*<sub>*i*, *j**n*</sub>) yielding an unbounded polarity score
(*δ*<sub>*i*, *j*</sub>) for each sentence.

*δ*<sub>*i**j*</sub> =
<em>c</em>'<sub>*i**j*</sub>/&radic;*w*<sub>*i**j**n*</sub>

Where:

*c*′<sub>*i*, *j*</sub> = ∑((1 + *w*<sub>*a**m**p*</sub> + *w*<sub>*d**e**a**m**p*</sub>)⋅*w*<sub>*i*, *j*, *k*</sub><sup>*p*</sup>(−1)<sup>2 + *w*<sub>*n**e**g*</sub></sup>)

*w*<sub>*a**m**p*</sub> = ∑(*w*<sub>*n**e**g*</sub> ⋅ (*z* ⋅ *w*<sub>*i*, *j*, *k*</sub><sup>*a*</sup>))

*w*<sub>*d**e**a**m**p*</sub> = max(*w*<sub>*d**e**a**m**p*′</sub>, −1)

*w*<sub>*d**e**a**m**p*′</sub> = ∑(*z*(−*w*<sub>*n**e**g*</sub> ⋅ *w*<sub>*i*, *j*, *k*</sub><sup>*a*</sup> + *w*<sub>*i*, *j*, *k*</sub><sup>*d*</sup>))

*w*<sub>*b*</sub> = 1 + *z*<sub>2</sub> \* *w*<sub>*b*′</sub>

*w*<sub>*b*′</sub> = ∑(|*w*<sub>*b**u**t* *c**o**n**j**u**n**c**t**i**o**n*</sub>|,...,*w*<sub>*i*, *j*, *k*</sub><sup>*p*</sup>, *w*<sub>*i*, *j*, *k*</sub><sup>*p*</sup>, ..., |*w*<sub>*b**u**t* *c**o**n**j**u**n**c**t**i**o**n*</sub>|\* − 1)

*w*<sub>*n**e**g*</sub> = (∑*w*<sub>*i*, *j*, *k*</sub><sup>*n*</sup> )
mod 2

To get the mean of all sentences (*s*<sub>*i*, *j*</sub>) within a
paragraph (*p*<sub>*i*</sub>) simply take the average sentiment score
*p*<sub>*i*, *δ*<sub>*i*, *j*</sub></sub> = 1/n ⋅ ∑
*δ*<sub>*i*, *j*</sub>.

Installation
============

To download the development version of **sentimentr**:

Download the [zip
ball](https://github.com/trinker/sentimentr/zipball/master) or [tar
ball](https://github.com/trinker/sentimentr/tarball/master), decompress
and run `R CMD INSTALL` on it, or use the **pacman** package to install
the development version:

    if (!require("pacman")) install.packages("pacman")
    pacman::p_load_gh("trinker/sentimentr")

Examples
========

    if (!require("pacman")) install.packages("pacman")
    pacman::p_load(sentimentr)

    mytext <- c(
        'do you like it?  But I hate really bad dogs',
        'I am the best friend.',
        'Do you really like it?  I\'m not a fan'
    )
    sentiment(mytext)

    ##    element_id sentence_id word_count  sentiment
    ## 1:          1           1          4  0.5000000
    ## 2:          1           2          6 -2.6781088
    ## 3:          2           1          5  0.4472136
    ## 4:          3           1          5  0.8049845
    ## 5:          3           2          4  0.0000000

To aggregate by element (column cell or vector element) use
`sentiment_by` with `by = NULL`.

    mytext <- c(
        'do you like it?  But I hate really bad dogs',
        'I am the best friend.',
        'Do you really like it?  I\'m not a fan'
    )
    sentiment_by(mytext)

    ##    element_id word_count       sd ave_sentiment
    ## 1:          1         10 2.247262    -1.0890544
    ## 2:          2          5       NA     0.4472136
    ## 3:          3          9 0.569210     0.4024922

To aggregate by grouping variables use `sentiment_by` using the `by`
argument.

    (out <- with(presidential_debates_2012, sentiment_by(dialogue, list(person, time))))

    ##        person   time word_count        sd ave_sentiment
    ##  1:     OBAMA time 1       3598 0.4489512    0.10245522
    ##  2:     OBAMA time 2       7476 0.3878883    0.08730120
    ##  3:     OBAMA time 3       7241 0.4408708    0.08788677
    ##  4:    ROMNEY time 1       4085 0.3669465    0.05259171
    ##  5:    ROMNEY time 2       7534 0.3271200    0.04277505
    ##  6:    ROMNEY time 3       8302 0.3866709    0.07109706
    ##  7:   CROWLEY time 2       1672 0.2279950    0.06725135
    ##  8:    LEHRER time 1        765 0.3634981    0.13377765
    ##  9:  QUESTION time 2        583 0.3282897    0.02209842
    ## 10: SCHIEFFER time 3       1445 0.3810998    0.06892295

Plotting
--------

### Plotting at Aggregated Sentiment

    plot(out)

![](inst/figure/unnamed-chunk-7-1.png)

### Plotting at the Sentence Level

The `plot` method for the class `sentiment` uses **syuzhet**'s
`get_transformed_values` combined with **ggplot2** to make a reasonable,
smoothed plot for the duration of the text based on percentage, allowing
for comparison between plots of different texts. This plot gives the
overall shape of the text's sentiment. The user can see
`syuzhet::get_transformed_values` for more details.

    plot(uncombine(out))

![](inst/figure/unnamed-chunk-8-1.png)

Making and Updating Dictionaries
--------------------------------

It is pretty straight forward to make or update a new dictionary
(polarity or valence shifter). To create a key from scratch the user
needs to create a 2 column `data.frame`, with words on the left and
values on the right (see `?polarity_table` & `?valence_shifters_table`
for what the values mean). Note that the words need to be lower cased.
Here I show an example `data.frame` ready for key conversion:

    set.seed(10)
    key <- data.frame(
        words = sample(letters),
        polarity = rnorm(26),
        stringsAsFactors = FALSE
    )

This is not yet a key. **sentimentr** provides the `is_key` function to
test if a table is a key.

    is_key(key)

    ## [1] FALSE

It still needs to be **data.table**-ified. The `as_key` function coerces
a `data.frame` to a **data.table** with the left column named `x` and
the right column named `y`. It also checks the key against another key
to make sure there is not overlap using the `compare` argument. By
default `as_key` checks against `valence_shifters_table`, assuming the
user is creating a sentiment dictionary. If the user is creating a
valence shifter key then a sentiment key needs to be passed to `compare`
instead and set the argument `sentiment = FALSE`. Below I coerce `key`
to a dictionary that **sentimentr** can use.

    mykey <- as_key(key)

Now we can check that `mykey` is a usable dictionary:

    is_key(mykey)

    ## [1] TRUE

The key is ready for use:

    sentiment_by("I am a human.", polarity_dt = mykey)

    ##    element_id word_count sd ave_sentiment
    ## 1:          1          4 NA    -0.7594893

You can see the values of a key that correspond to a word using
**data.table** syntax:

    mykey[c("a", "b")][[2]]

    ## [1] -0.2537805 -0.1951504

Updating (adding or removing terms) a key is also useful. The
`update_key` function allows the user to add or drop terms via the `x`
(add a `data.frame`) and `drop` (drop a term) arguments. Below I drop
the "a" and "h" terms (notice there are now 24 rows rather than 26):

    mykey_dropped <- update_key(mykey, drop = c("a", "h"))
    nrow(mykey_dropped)

    ## [1] 24

    sentiment_by("I am a human.", polarity_dt = mykey_dropped)

    ##    element_id word_count sd ave_sentiment
    ## 1:          1          4 NA     -0.632599

Next I add the terms "dog" and "cat" as a `data.frame` with sentiment
values:

    mykey_added <- update_key(mykey, x = data.frame(x = c("dog", "cat"), y = c(1, -1)))

    ## Warning in as_key(x, comparison = comparison, sentiment = sentiment): Column 1 was a factor...
    ## Converting to character.

    nrow(mykey_added)

    ## [1] 28

    sentiment("I am a human. The dog.  The cat", polarity_dt = mykey_added)

    ##    element_id sentence_id word_count  sentiment
    ## 1:          1           1          4 -0.7594893
    ## 2:          1           2          2  0.7071068
    ## 3:          1           3          2 -0.7071068

Annie Swafford's Examples
-------------------------

[Annie
Swafford](https://annieswafford.wordpress.com/2015/03/02/syuzhet/)
critiqued Jocker's approach to sentiment and gave the following examples
of sentences (`ase` for Annie Swafford example). Here I test each of
Jocker's 3 dictionary approaches (Bing, NRC, Afinn), his Stanford
wrapper (note I use my own [GitHub Stanford wrapper
package](https://github.com/trinker/stansent) based off of Jocker's
approach as it works more reliably on my own Windows machine), the
[RSentiment](https://cran.r-project.org/package=RSentiment) package, and
my own algorithm with both the default Hu & Liu (2004) polarity lexicon
as well as [Baccianella, Esuli and Sebastiani's
(2010)](http://sentiwordnet.isti.cnr.it/) SentiWord lexicon.

    if (!require("pacman")) install.packages("pacman")
    pacman::p_load_gh("trinker/sentimentr", "trinker/stansent")
    pacman::p_load(syuzhet, qdap, microbenchmark, RSentiment)

    package 'microbenchmark' successfully unpacked and MD5 sums checked

    The downloaded binary packages are in
        C:\Users\Tyler\AppData\Local\Temp\RtmpwJpARf\downloaded_packages
    package 'RSentiment' successfully unpacked and MD5 sums checked

    The downloaded binary packages are in
        C:\Users\Tyler\AppData\Local\Temp\RtmpwJpARf\downloaded_packages

    ase <- c(
        "I haven't been sad in a long time.",
        "I am extremely happy today.",
        "It's a good day.",
        "But suddenly I'm only a little bit happy.",
        "Then I'm not happy at all.",
        "In fact, I am now the least happy person on the planet.",
        "There is no happiness left in me.",
        "Wait, it's returned!",
        "I don't feel so bad after all!"
    )

    syuzhet <- setNames(as.data.frame(lapply(c("bing", "afinn", "nrc"),
        function(x) get_sentiment(ase, method=x))), c("bing", "afinn", "nrc"))


    left_just(data.frame(
        stanford = sentiment_stanford(ase)[["sentiment"]],
        hu_liu = round(sentiment(ase, question.weight = 0)[["sentiment"]], 2),
        sentiword = round(sentiment(ase, sentiword, question.weight = 0)[["sentiment"]], 2),    
        RSentiment = calculate_score(ase), 
        syuzhet,
        sentences = ase,
        stringsAsFactors = FALSE
    ), "sentences")

      stanford hu_liu sentiword RSentiment bing afinn nrc
    1     -0.5   0.35      0.18         -1   -1    -2   0
    2        1    0.8      0.65          1    1     3   1
    3      0.5    0.5      0.32          1    1     3   1
    4     -0.5      0         0          0    1     3   1
    5     -0.5  -0.41     -0.56         -1    1     3   1
    6     -0.5   0.06      0.11          1    1     3   1
    7     -0.5  -0.38     -0.05          0    1     2   1
    8        0      0     -0.14          0    0     0  -1
    9     -0.5   0.38      0.24         -1   -1    -3  -1
      sentences                                              
    1 I haven't been sad in a long time.                     
    2 I am extremely happy today.                            
    3 It's a good day.                                       
    4 But suddenly I'm only a little bit happy.              
    5 Then I'm not happy at all.                             
    6 In fact, I am now the least happy person on the planet.
    7 There is no happiness left in me.                      
    8 Wait, it's returned!                                   
    9 I don't feel so bad after all!                         

Also of interest is the computational time used by each of these
methods. To demonstrate this I increased Annie's examples by 100
replications and **microbenchmark** on a few iterations (Stanford takes
so long I didn't extend to more). Note that if a text needs to be broken
into sentence parts **syuzhet** has the `get_sentences` function that
uses the **openNLP** package, this is a time expensive task.
**sentimentr** uses a much faster regex based approach that is nearly as
accurate in parsing sentences with a much lower computational time. We
see that Stanford takes the longest time while **sentimentr** and
**syuzhet** are comparable depending upon lexicon used. **RSentiment**
is a bit slower than the fastest versions of either **sentimentr** or
**syuzhet**.

    ase_100 <- rep(ase, 100)

    stanford <- function() {sentiment_stanford(ase_100)}

    sentimentr_hu_liu <- function() sentiment(ase_100)
    sentimentr_sentiword <- function() sentiment(ase_100, sentiword) 
        
    RSentiment <- function() calculate_score(ase_100) 
        
    syuzhet_binn <- function() get_sentiment(ase_100, method="bing")
    syuzhet_nrc <- function() get_sentiment(ase_100, method="nrc")
    syuzhet_afinn <- function() get_sentiment(ase_100, method="afinn")
         
    microbenchmark(
        stanford(),
        sentimentr_hu_liu(),
        sentimentr_sentiword(),
        RSentiment(), 
        syuzhet_binn(), 
        syuzhet_nrc(),
        syuzhet_afinn(),
        times = 3
    )

    Unit: milliseconds
                       expr         min          lq        mean      median
                 stanford()  27555.9649  29336.0280  30124.1588  31116.0911
        sentimentr_hu_liu()    262.6678    267.3538    272.7080    272.0398
     sentimentr_sentiword()   1057.2413   1087.2625   1102.4927   1117.2838
               RSentiment() 145682.8551 148026.6238 151587.5462 150370.3924
             syuzhet_binn()    394.5227    439.8974    462.2086    485.2720
              syuzhet_nrc()    980.6292   1003.1331   1024.1288   1025.6370
            syuzhet_afinn()    169.6761    173.3827    181.3841    177.0894
              uq         max neval
      31408.2557  31700.4203     3
        277.7281    283.4165     3
       1125.1184   1132.9531     3
     154539.8918 158709.3912     3
        496.0516    506.8311     3
       1045.8786   1066.1202     3
        187.2381    197.3868     3

Comparing sentimentr, syuzhet, RSentiment, and Stanford
-------------------------------------------------------

The accuracy of an algorithm weighs heavily into the decision as to what
approach to take in sentiment detection. Both **syuzhet** and
**sentimentr** provide multiple dictionaries with a general algorithm to
compute sentiment scores. **syuzhet** provides 3 approaches while
**sentimentr** provides 2, but can be extended easily using the 3
dictionaries from the **syuzhet** package. The follow visualization
provides the accuracy of these approaches in comparison to Stanford's
**Java** based implementation of sentiment detection. The visualization
is generated from testing on three reviews data sets from Kotzias,
Denil, De Freitas, & Smyth (2015). These authors utilized the three 1000
element data sets from:

-   amazon.com
-   imdb.com
-   yelp.com

The data sets are hand scored as either positive or negative. The
testing here merely matches the sign of the algorithm to the human coded
output to determine accuracy rates.

-   Kotzias, D., Denil, M., De Freitas, N., & Smyth,P. (2015). *From
    group to individual labels using deep features*. Proceedings of the
    21th ACM SIGKDD International Conference on Knowledge Discovery and
    Data Mining. 597-606.
    <http://mdenil.com/media/papers/2015-deep-multi-instance-learning.pdf>

<img src="inst/figure/comparisons_between_sentiment_detectors_b.png" width="100%" alt="sent comp">

The bar graph on the left shows the accuracy rates for the various
sentiment set-ups in the three review contexts. The rank plot on the
right shows how the rankings for the methods varied across the three
review contexts.

The take away here seems that, unsurprisingly, Stanford's algorithm
consistently outscores **sentimentr**, **syuzhet**, and **RSentiment**.
The **sentimentr** approach loaded with the `hu_lu` dictionary is a top
pick for speed and accuracy. The `bing` dictionary also performs well
within both the **syuzhet** and **sentimentr** algorithms. Generally,
the **sentimentr** algorithm out performs **syuzhet** when their
dictonaries are comparable.

It is important to point out that this is a small sample data set that
covers a narrow range of uses for sentiment detection. Jocker's
**syuzhet** was designed to be applied across book chunks and it is, to
some extent, unfair to test it out of this context. Still this initial
analysis provides a guide that may be of use for selecting the sentiment
detection set up most applicable to the reader's needs.

The reader may access the R script used to generate this visual via:

    testing <- system.file("sentiment_testing/sentiment_testing.R", package = "sentimentr")
    file.copy(testing, getwd())

In the figure below we compare raw table counts as a heat map, plotting
the predicted values from the various algorithms on the x axis versus
the human scored values on the y axis.

<img src="inst/figure/comparisons_between_sentiment_detectors2.png" width = "80%" alt="sent comp">

Across all three contexts, notice that the Stanford coreNLP algorithm is
better at:

-   Detecting negative sentiment as negative
-   Discrimination (i.e., reducing neutral assignments)

The Bing, Hu & Lu, and Afinn dictionaries all do well with regard to not
assigning negative scores to positive statements, but perform less well
in the reverse, often assigning positive scores to negative statements.
We can now see that the reason for the NRC's poorer performance in
accuracy rate above is its inability to discriminate. The Sentiword
dictionary does well at discriminating (like Stanford's coreNLP) but
lacks accuracy. We can deduce two things from this observation:

1.  Larger dictionaries discriminate better (Sentiword \[n =
    20,100\] vs. Hu & Lu \[n = 6,872\])
2.  The Sentiword dictionary may have words with reversed polarities

A reworking of the Sentiword dictionary may yield better results for a
dictionary lookup approach to sentiment detection, potentially,
improving on discrimination and accuracy.

The reader may access the R script used to generate this visual via:

    testing2 <- system.file("sentiment_testing/raw_results.R", package = "sentimentr")
    file.copy(testing2, getwd())

Text Highlighting
-----------------

The user may wish to see the output from `sentiment_by` line by line
with positive/negative sentences highlighted. The `highlight` function
wraps a `sentiment_by` output to produces a highlighted HTML file
(positive = green; negative = pink). Here we look at three random
reviews from Hu and Liu's (2004) Cannon G3 Camera Amazon product
reviews.

    set.seed(2)
    highlight(with(subset(cannon_reviews, number %in% sample(unique(number), 3)), sentiment_by(review, number)))

![](inst/figure/highlight.png)

Contact
=======

You are welcome to:    
- submit suggestions and bug-reports at: <https://github.com/trinker/sentimentr/issues>    
- send a pull request on: <https://github.com/trinker/sentimentr/>    
- compose a friendly e-mail to: <tyler.rinker@gmail.com>    
