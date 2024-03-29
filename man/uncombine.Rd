% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/uncombine.R
\name{uncombine}
\alias{uncombine}
\title{Ungroup a \code{sentiment_by} Object to the Sentence Level}
\usage{
uncombine(x, ...)
}
\arguments{
\item{x}{A \code{sentiment_by} object.}

\item{\ldots}{Ignored.}
}
\value{
Returns a \pkg{data.table} with grouping variables plus:
\itemize{
  \item  element_id - The id number of the original vector passed to \code{sentiment}
  \item  word_count - Word count \code{\link[base]{sum}}med by grouping variable
  \item  sd - Standard deviation (\code{\link[stats]{sd}}) of the sentiment/polarity score by grouping variable
  \item  ave_sentiment - Sentiment/polarity score \code{\link[base]{mean}} average by grouping variable
}
}
\description{
Ungroup a \code{sentiment_by} object, stretching to the \code{element_id} and
\code{sentence_id} levels.
}
\examples{
mytext <- c(
   'do you like it?  But I hate really bad dogs',
   'I am the best friend.',
   "Do you really like it?  I'm not happy"
)

mytext <- get_sentences(mytext)
(x <- sentiment_by(mytext))
uncombine(x)

\dontrun{
(y <- with(
    presidential_debates_2012, 
    sentiment_by(
        text.var = get_sentences(dialogue), 
        by = list(person, time)
    )
))
uncombine(y)
}
}
