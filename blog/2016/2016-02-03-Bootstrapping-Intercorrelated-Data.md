#Bootstrapping Intercorrelated Data

2016-02-03

<!--- tags: ml r -->

<a href="https://en.wikipedia.org/wiki/Bootstrapping_(statistics)">Bootstrapping</a> cannot be used directly with series that have intercorrelated samples. Plain bootstrap does not know how to re-sample data in such cases. In case of intercorrelated samples, an adaptation of bootstrap is to use series windowing - re-sampling based on intervals and assuming the correlation between window intervals can be ignored. 

We can bootstrap manually in this case, but it would be preferable to reuse the **R** `boot` library `boot` function. The trick to use `boot` function with window re-sampling is not to give the original data series to `boot`, but the index of the windows, so that we do not use `data` in the boot function, only the `index`. Let our data be:

```r
set.seed(1)
dataLen <- 1000
X1 <- sin(1:dataLen)
X2 <- cos(1:dataLen)
Y <- 2 * X1 + X2 + rnorm(dataLen)
data <- data.frame(X1, X2, Y)
```

These data are definitively intercorrelated (as we can see if do some plots). To bootstrap standard error of linear regression coefficients for these data, we split them in intervals having `1/10` of data each and define a function `indexToRange` to map the window index to the data index:

```r
windowsCount <- 10
(windows <- seq(1:windowsCount))
windowLen <- dataLen / windowsCount

indexToRange <- function(index) {
  unlist(sapply(index, function(b) {
    ((b - 1) * windowLen + 1):(b * windowLen)  
  }, simplify = FALSE))
}
```

Now, we can use `boot`, to re-sample windows:

```r
library(boot)

bf <- function(dummy, index) {
  rows <- indexToRange(index)
  d <- data[rows, ] #data is global
  return(coef(lm(Y ~ X1 + X2, data = d)))
}

boot(windows, bf, 1000)
```

Obtaining the needed results:

```
Bootstrap Statistics :
      original        bias    std. error
t1* -0.01165015  0.001034892  0.02490686
t2*  2.00913025 -0.002625029  0.04097508
t3*  0.98991915  0.000419581  0.04186725
```

<ins class='nfooter'><a id='fnext' href='#blog/2015/2015-12-10-WebEx-On-Ubuntu.md'>WebEx On Ubuntu</a></ins>
