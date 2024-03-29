% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sentimentr-package.R
\docType{data}
\name{hu_liu_cannon_reviews}
\alias{hu_liu_cannon_reviews}
\title{Cannon G3 Camera Product Reviews From Amazon}
\format{
A data frame with 597 rows and 3 variables
}
\usage{
data(hu_liu_cannon_reviews)
}
\description{
A dataset containing Amazon product reviews for the Cannon G3 Camera.  This
data set was compiled by Hu and Liu (2004).  Where a sentence contains more
than one opinion score and average of all scores is used.
}
\details{
\itemize{
  \item sentiment. Hu and Liu (2004)'s average opinion rating for a
  sentence.  Negative and positive reflects direction, a negative or positive
  sentiment.  Opinion strength varies between 3 (strongest), and 1 (weakest).
  number.  The review number.
  \item text. The text from the review.
  \item review_id. The review number.
}
}
\references{
Minqing Hu and Bing Liu. (2004). Mining and summarizing customer reviews.
   Proceedings of the ACM SIGKDD International Conference on
   Knowledge Discovery & Data Mining (KDD-04).

Minqing Hu and Bing Liu. (2004)."Mining Opinion Features in Customer
   Reviews. Proceedings of Nineteeth National Conference on
   Artificial Intelligence (AAAI-2004).

Original URL:  \file{https://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html}
}
\keyword{datasets}
