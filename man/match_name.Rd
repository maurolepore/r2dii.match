% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/match_name.R
\name{match_name}
\alias{match_name}
\title{Match a loanbook and asset-level datasets (ald) by the \verb{name_*} columns}
\usage{
match_name(
  loanbook,
  ald,
  by_sector = TRUE,
  min_score = 0.8,
  method = "jw",
  p = 0.1,
  overwrite = NULL
)
}
\arguments{
\item{loanbook, ald}{data frames structured like \link[r2dii.data:loanbook_demo]{r2dii.data::loanbook_demo}
and \link[r2dii.data:ald_demo]{r2dii.data::ald_demo}.}

\item{by_sector}{Should names only be compared if companies belong to the
same \code{sector}?}

\item{min_score}{A number between 0-1, to set the minimum \code{score} threshold.
A \code{score} of 1 is a perfect match.}

\item{method}{Method for distance calculation. One of \code{c("osa", "lv", "dl", "hamming", "lcs", "qgram", "cosine", "jaccard", "jw", "soundex")}. See
\link[stringdist:stringdist-metrics]{stringdist::stringdist-metrics}.}

\item{p}{Prefix factor for Jaro-Winkler distance. The valid range for 
\code{p} is \code{0 <= p <= 0.25}. If \code{p=0} (default), the
Jaro-distance is returned. Applies only to \code{method='jw'}.}

\item{overwrite}{A data frame used to overwrite the \code{sector} and/or \code{name}
columns of a particular direct loantaker or ultimate parent. To overwrite
only \code{sector}, the value in the \code{name} column should be \code{NA} and
vice-versa. This file can be used to manually match loanbook companies to
ald.}
}
\value{
A data frame with the same groups (if any) and columns as \code{loanbook},
and the additional columns:
\itemize{
\item \code{id_2dii} - an id used internally by \code{match_name()} to distinguish
companies
\item \code{level} - the level of granularity that the loan was matched at
(e.g \code{direct_loantaker} or \code{ultimate_parent})
\item \code{sector} - the sector of the \code{loanbook} company
\item \code{sector_ald} - the sector of the \code{ald} company
\item \code{name} - the name of the \code{loanbook} company
\item \code{name_ald} - the name of the \code{ald} company
\item \code{score} - the score of the match (manually set this to \code{1}
prior to calling \code{prioritize()} to validate the match)
\item \code{source} - determines the source of the match. (equal to \code{loanbook}
unless the match is from \code{overwrite}
}

The returned rows depend on the argument \code{min_value} and the result of the
column \code{score} for each loan: * If any row has \code{score} equal to 1,
\code{match_name()} returns all rows where \code{score} equals 1, dropping all other
rows. * If no row has \code{score} equal to 1,\code{match_name()} returns all rows
where \code{score} is equal to or greater than \code{min_score}. * If there is no
match the output is a 0-row tibble with the expected column names -- for
type stability.
}
\description{
\code{match_name()} scores the match between names in a loanbook dataset (columns
can be \code{name_direct_loantaker}, \verb{name_intermediate_parent*} and
\code{name_ultimate_parent}) with names in an asset-level dataset (column
\code{name_company}). The raw names are first internally transformed, and aliases
are assigned. The similarity between aliases in each of the loanbook and ald
datasets is scored using \code{\link[stringdist:stringsim]{stringdist::stringsim()}}.
}
\section{Assigning aliases}{

The transformation process used to compare names between loanbook and ald
datasets applies best practices commonly used in name matching algorithms:
\itemize{
\item Remove special characters.
\item Replace language specific characters.
\item Abbreviate certain names to reduce their importance in the matching.
\item Spell out numbers to increase their importance.
}
}

\section{Handling grouped data}{

This function ignores but preserves existing groups.
}

\examples{
library(r2dii.data)

# Small data for examples
loanbook <- head(loanbook_demo, 50)
ald <- head(ald_demo, 50)

match_name(loanbook, ald)

match_name(loanbook, ald, min_score = 0.9)
}
\seealso{
Other main functions: 
\code{\link{prioritize}()}
}
\concept{main functions}
