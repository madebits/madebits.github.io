#Bootstrapping Intercorrelated Data

2016-02-03

<!--- tags: ml r -->

<a href="https://en.wikipedia.org/wiki/Bootstrapping_(statistics)">Bootstrapping</a> cannot be used directly with series that have intercorrelated samples. Plain bootstrap does not know how to re-sample data in such cases. The `boot` library in **R** works best for data whose samples are not correlated. In case of intercorrelated samples, an adaptation of bootstrap is to use series windowing - by re-sampling based on intervals, assuming the correlation between window intervals can be ignored. 

We can bootstrap manually in this case, but it would be preferable to reuse the `boot` library. The trick to use `boot` library with window re-sampling is not to give the original data series to `boot`, but the index of the windows, so that we do not use `data` in the boot function, only the `index`. Let our data be:

```r
X1 <- sin(1:1000)
X2 <- cos(1:1000)
Y <- 2 * X1 + X2 + rnorm(1000);
data <- data.frame(X1, X2, Y)
```

These data are definitively intercorrelated (as we can see if do some plots). To bootstrap linear regression standard error for such data, we can split them in intervals having `1/10` of data each. We define also a function `indexToRange` to map the window index to the data index:

```r
(windows <- seq(1:10))

indexToRange <- function(index) {
  unlist(sapply(index, function(b){
    ((b - 1) * 100 + 1):(b * 100)  
  }, simplify = FALSE))
}
```

Now we can use `boot` library, to re-sample windows:

```r
library(boot)

bf <- function(dummy, index) {
  rows <- indexToRange(index)
  d <- data[rows, ] #data is global
  return(coef(lm(Y ~ X1 + X2, data=d)))
}

boot(windows, bf, 1000)
```

Obtaining the needed results:

```
Bootstrap Statistics :
      original        bias    std. error
t1* 0.08037169 -0.0005199964  0.02894703
t2* 2.05123115  0.0007082852  0.03296834
t3* 0.99092124 -0.0018817800  0.04644636
```

<ins class='nfooter'><a id='fnext' href='#blog/2015/2015-12-10-WebEx-On-Ubuntu.md'>WebEx On Ubuntu</a></ins>
