#Installing R and RStudio in Ubuntu 14.04

2015-03-22

<!--- tags: r -->

**R** is in Ubuntu repositories, but in order to install the latest version remove any old version (`sudo apt-get remove r-base`) and then follow the steps in [cran readme](http://cran.r-project.org/bin/linux/ubuntu/README):

Edit `/etc/apt/sources.list` to add: 

```
deb http://cran.rstudio.com/bin/linux/ubuntu trusty/
```

Add signature keys and update package sources and install R:

```
gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9
gpg -a --export E084DAB9 | sudo apt-key add -
sudo apt-get update
sudo apt-get install r-base
```

At this time, you need also RStudio [v0.99.335](http://www.rstudio.com/products/rstudio/download/preview/) for the latest R version.

The following libraries are also needed:

```
sudo apt-get install libcurl4-openssl-dev libxml2-dev
```

To [search](http://stackoverflow.com/questions/25721884/how-should-i-deal-with-package-xxx-is-not-available-warning) for available R [packages](http://mazamascience.com/WorkingWithData/?p=1185) containing *"AB"* in registered repositories one could use:

```r
ap <- available.packages()
rownames(ap)[grep("AB", rownames(ap))]
```

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2015/2015-03-24-Encrypted-Swap-File-in-Linux.md'>Encrypted Swap File in Linux</a> <a rel='next' id='fnext' href='#blog/2015/2015-02-26-Useful-Browser-Extensions.md'>Useful Browser Extensions</a></ins>
