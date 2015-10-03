#Using SVD to Reduce Images

2015-05-12

<!--- tags: r -->

Sample image reconstructed with various SVD quality:

```r
#install.packages("jpeg")
library(jpeg)

rotate <- function(x) t(x[nrow(x):1,])
imgPlot <- function(img) image(rotate(img), axes=FALSE, col=grey(seq(0, 1, length=256)))
from.svd <- function(SVD, k) SVD$u[,1:k] %*% diag(SVD$d[1:k], k, k) %*% t(SVD$v[,1:k])

img <- readJPEG("../lenna.jpg")
red <- img[,,1]
svd <- svd(red)

#plot(1, type="n", xlim=c(0, 512), ylim=c(0, 512))
#rasterImage(red, 0, 0, 512, 512)

op <- par(mfrow = c(5, 2), mar=c(0,0,0,0))

plot(svd$d, xlim=c(0, 50))
imgPlot(red)

imgPlot(from.svd(svd, 5))
imgPlot(from.svd(svd, 10))

imgPlot(from.svd(svd, 20))
imgPlot(from.svd(svd, 30))

imgPlot(from.svd(svd, 40))
imgPlot(from.svd(svd, length(svd$d)))

imgPlot(svd$u)
imgPlot(svd$v)
par(op)
```

First row shows the first ~50 sigma values and the original image. Next three rows show SVD image reconstruction with {5, 10, 20, 30, 40, full size = 512}. Last row plots the orthonormal U, V data matrices.

![](blog/images/lenna.png)

<ins class='nfooter'><a id='fprev' href='#blog/2015/2015-06-03-Naive-Bayes-in-R.md'>Naive Bayes in R</a> <a id='fnext' href='#blog/2015/2015-04-29-Google-Apps-Tricks.md'>Google Apps Tricks</a></ins>
