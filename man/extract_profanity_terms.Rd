% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extract_profanity_terms.R
\name{extract_profanity_terms}
\alias{extract_profanity_terms}
\title{Extract Profanity Words}
\usage{
extract_profanity_terms(
  text.var,
  profanity_list = unique(tolower(lexicon::profanity_alvarez)),
  ...
)
}
\arguments{
\item{text.var}{The text variable.  Can be a \code{get_sentences} object or
a raw character vector though \code{get_sentences} is preferred as it avoids
the repeated cost of doing sentence boundary disambiguation every time
\code{profanity} is run.}

\item{profanity_list}{A atomic character vector of profane words.  The 
\pkg{lexicon} package has lists that can be used, including: 
\itemize{
  \item \code{lexicon::profanity_alvarez}
  \item \code{lexicon::profanity_arr_bad}
  \item \code{lexicon::profanity_banned}
  \item \code{lexicon::profanity_zac_anger}
}}

\item{\ldots}{Ignored.}
}
\value{
Returns a \pkg{data.table} with a columns of profane terms.
}
\description{
Extract the profanity words from a text.
}
\examples{
\dontrun{
bw <- sample(lexicon::profanity_alvarez, 4)
mytext <- c(
   sprintf('do you \%s like this \%s?  It is \%s. But I hate really bad dogs', bw[1], bw[2], bw[3]),
   'I am the best friend.',
   NA,
   sprintf('I \%s hate this \%s', bw[3], bw[4]),
   "Do you really like it?  I'm not happy"
)


x <- get_sentences(mytext)
profanity(x)

prof_words <- extract_profanity_terms(x)
prof_words
prof_words$sentence
prof_words$neutral
prof_words$profanity
data.table::as.data.table(prof_words)

attributes(extract_profanity_terms(x))$counts
attributes(extract_profanity_terms(x))$elements


brady <- get_sentences(crowdflower_deflategate)
brady_swears <- extract_profanity_terms(brady)

attributes(extract_profanity_terms(brady))$counts
attributes(extract_profanity_terms(brady))$elements
}
}
