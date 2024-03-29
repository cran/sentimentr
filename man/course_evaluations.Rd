% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sentimentr-package.R
\docType{data}
\name{course_evaluations}
\alias{course_evaluations}
\title{Student Course Evaluation Comments}
\format{
A data frame with 566 rows and 2 variables
}
\usage{
data(course_evaluations)
}
\description{
A dataset containing a subset of comments and rating from Welch & Mihalcea's 
(2017) data set filtered to include comments with a one or more unambiguous 
sentiment rating.
}
\details{
\itemize{ 
  \item sentiment. A numeric sentiment score
  \item text. The text from the evaluation
}
}
\references{
Welch, C. and Mihalcea, R. (2017). Targeted sentiment to 
understand student comments. In Proceedings of the International Conference 
on Computational Linguistics (COLING 2016). \cr \cr
Original URL: http://web.eecs.umich.edu/~mihalcea/downloads.html#GroundedEmotions
}
\keyword{datasets}
