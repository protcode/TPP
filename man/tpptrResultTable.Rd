% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/tpptrResultTable.R
\name{tpptrResultTable}
\alias{tpptrResultTable}
\title{Statistical analysis of melting curve parameters.}
\usage{
tpptrResultTable(data, binWidth = 300)
}
\arguments{
\item{data}{list of ExpressionSets containing fold changes and metadata. It's
featureData contains the fitted melting curve parameters}

\item{binWidth}{bin width used for p-value computation}
}
\description{
Summarizes the output of a TPP-TR experiment and performs statistical
comparisons of conditions, if appropriate.
}
\details{
If a TPP-TR experiment was performed with the conditions "Vehicle" and "Treatment",
the melting points between these conditions will be compared statistically, producing
p-values for each protein and replicate.
}

