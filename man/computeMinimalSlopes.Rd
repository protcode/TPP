% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/computeMinimalSlopes.R
\name{computeMinimalSlopes}
\alias{computeMinimalSlopes}
\title{Minimal slopes per protein and replicate}
\usage{
computeMinimalSlopes(slV, slT)
}
\arguments{
\item{slV}{numeric vector with slope estimates of Vehicle group.}

\item{slT}{numeric vector with slope estimates of Treatment group.}
}
\value{
Vector numeric vector with minimal slope.
}
\description{
Determine the minimum of the melting curve slopes estimated for Vehicle and Treatment
group for each protein.
}

