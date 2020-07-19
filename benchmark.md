Benchmark `match_name()` in development vs. on CRAN
================

Some users
[reported](https://github.com/2DegreesInvesting/r2dii.match/issues/214)
that the
[`match_name()`](https://2degreesinvesting.github.io/r2dii.match/)
crashed with large files. However efficient, `match_name()` – and any
function – will always have a limit to how much data you can feed it
before your computer crashes. Although your data maybe too big to work
with in your computer, you can still work with it in two ways: (1) Pick
a smaller subset: For example, you may pick all rows from a specific
sector (see
[`filter()`](https://dplyr.tidyverse.org/reference/filter.html)), or you
may pick a representative sample from all sectors (see
[`slice_sample()`](https://dplyr.tidyverse.org/reference/slice.html));
(2) Compute not on your local computer but on a more powerful server.
For more details, watch RStudio’s webinar on [Working with Big Data in
R](https://dplyr.tidyverse.org/reference/filter.html).

However you use it, we want `match_name()` to take as little time and
memory as it is reasonably possible. Here we compare two versions of
`match_name()`: The version on CRAN versus the version in-development.
Compared to the version on CRAN, the version in-development is now
several times faster, and uses several times less memory. This document
shows the details.

-----

Use some packages.

``` r
library(bench)
library(devtools)
library(dplyr)
library(fs)
library(r2dii.data)
```

Let’s use different names to refer to each of the two versions of
`match_name()` – the version in development (`devel`), and the one on
CRAN (`cran`).

``` r
# The older version on CRAN
packageVersion("r2dii.match")
#> [1] '0.0.3'

# Copy of match_name on CRAN
cran <- r2dii.match::match_name

# The newer version on the PR "profile"
suppressMessages(devtools::load_all(fs::path_home("git", "r2dii.match")))
# The newer version in development
packageVersion("r2dii.match")
#> [1] '0.0.3.9000'

# Copy of match_name in development
devel <- r2dii.match::match_name
```

Both versions have different source code.

``` r
# Confirm the two versions of `match_name` are different
identical(devel, cran)
#> [1] FALSE
```

The version in development uses less memory and runs faster.

``` r
benchmark <- bench::mark(
  # Don't check that the output is identical; rows-order is different^[1]
  check = FALSE,
  iterations = 5,
  out_devel = out_devel <- devel(loanbook_demo, ald_demo),
  out_cran  = out_cran  <-  cran(loanbook_demo, ald_demo)
)
#> Warning: Some expressions had a GC in every iteration; so filtering is disabled.

benchmark
#> # A tibble: 2 x 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 out_devel  165.09ms 170.65ms     4.66         NA    14.0 
#> 2 out_cran      1.04s    1.21s     0.801        NA     8.17

benchmark %>%
  summarise(
    # How many times less memory is allocating the version in development?^[2]
    times_less_memory  = as.double(mem_alloc)[[2]]  / as.double(mem_alloc)[[1]],
    # How many times faster is the version in development?
    times_less_time    = as.double(total_time)[[2]] / as.double(total_time)[[1]]
  )
#> # A tibble: 1 x 2
#>   times_less_memory times_less_time
#>               <dbl>           <dbl>
#> 1                NA            5.82
```

-----

`[1]`: If we reorder the rows in the same way, both outputs are
equivalent.

``` r
# No output means that the two expressions are indeed equivalent
testthat::expect_equivalent(
  out_devel %>% arrange(across(names(.))),
  out_cran  %>% arrange(across(names(.)))
)
```

`[2]`: In Rmarkdown I fail to get a result for `times_less_memory`; in
the console I get `times_less_memory` of up to 5.5; and
`times_less_time` of up to 9.