#Starting with Machine Learning in Spark Readings

<!--- tags: ml scala -->

Apache [Spark](http://spark.apache.org/) is an open framework to manipulate big data - data that does not fit in the memory of a single machine. I was mostly interested in machine learning with Spark. Spark MLLib [helps](https://www.youtube.com/watch?v=HG2Yd-3r4-M&list=PLTPXxbhUt-YWGNTaDj6HSjnHMxiTD1HCR) processing distributed large set of samples and do parallel parametric model evaluation. The number of features for a single data sample has to fit in the memory. Below is a list of resources I used to get familiar with Spark.

##Learning Spark (2015)

[![@left@](blog/images/book-ls.png)](http://shop.oreilly.com/product/0636920028512.do) *Learning Spark* This is the main book to start learning Spark. The book introduces the concept of the directed graph of transformations over RDDs and has enough examples to get you started. Spark is a fast moving ecosystem and no book can keep up with that, but you get an idea of the basics and then refer to Spark [documentation](http://spark.apache.org/documentation.html). It is easy to run Spark locally (your `/tmp` folder needs to be executable) and I run several python examples to get my self used to the details. I found it useful to create a script to start `ipython`:

```bash
#!/bin/bash

IPYTHON=1 IPYTHON_OPTS="--matplotlib" $HOME/opt/spark/bin/pyspark
```

I [updated](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-jupyter-notebook-to-run-ipython-on-ubuntu-16-04) `pip` using `sudo -H pip install --upgrade pip`. and to get latest [version](http://blog.jupyter.org/2016/07/08/ipython-5-0-released/) of `ipython` with `prompt_toolkit` I used `pip install ipython --upgrade` (use `pip3` for `ipython3`). I also added `$HOME/opt/spark` where I installed spark (`$SPARK_HOME`) to my `$PATH` variable.

<br clear="all">

##Machine Learning with Spark (2015)

[![@left@](blog/images/book-mls.png)](https://www.amazon.com/Machine-Learning-Spark-Powerful-Algorithms-ebook/dp/B00TXBLFB0) *Machine Learning with Spark* This was the book I wanted to read, so the rest of books were mostly preparation. You will not learn machine learning in depth from this book, but if you know of bit of machine learning the book is a great introduction to Spark `ml` library. I learned enough from the book to be able to follow Spark [documentation](http://spark.apache.org/docs/latest/ml-guide.html) on my own. As I was reading the book, Spark 2.0.0 come out and MLlib was updated with new functionality. The official [documentation](http://spark.apache.org/docs/latest/ml-guide.html) is the definitive guide, especially to learn the pipeline API the book does not show. The book has also some good [one hot encoding](https://en.wikipedia.org/wiki/Categorical_distribution) samples, which coming for R models, I used to take for granted. 

<br clear="all">

##Programming Scala (2014)

[![@left@](blog/images/book-lsc.png)](http://shop.oreilly.com/product/0636920030287.do) *Learning Scala* This is somehow a bad book, partly because Scala itself is a too evolved language with a lot of corner cases (not as bad as Haskel thought :), and partly that while the authors do knows Scala they do a bad job of systematically introducing stuff. After I read first five chapters and the introduction was not finished, I decided to find another book and only skipped later on though the rest of this book content. [Learning Scala](http://shop.oreilly.com/product/0636920030287.do) is a better book, if you want to go with O'Reilly.

<br clear="all">

##Programming in Scala (2016)

[![@left@](blog/images/book-ps.png)](http://www.artima.com/shop/programming_in_scala_3ed) *Programming in Scala* I found this a very good book to learn Scala in a structured way. There is lot in Scala to be able to efficiently remember by reading a book once. While Scala has to many corner cases that make it harder to use if efficiently without spending a lot of time in documentation, knowing some of Scala will make you a better programmer. I know now enough to read most Scala code and to follow Spark documentation. The knowledge proved useful to be able to understand compile and run [MLlib](http://spark.apache.org/docs/latest/ml-guide.html) examples.

<br clear="all">

##SciPy Lecture Notes

[Scipy Lecture Notes](http://www.scipy-lectures.org/) - is an open on-line book to get started with [SciPy](https://www.scipy.org/). Though I have used some of SciPy, I found it useful to remind myself of some of the main features. SciPy and the associated Python toolset and libraries are useful if you code for Spark using Python, as some local data manipulation can be done with SciPy.

<br clear="all">

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2016/2016-08-02-Lubuntu-Closing-Chrome-Downloads-Bar.md'>Lubuntu Closing Chrome Downloads Bar</a> <a rel='next' id='fnext' href='#blog/2016/2016-07-30-Upgrading-to-Lubuntu-16.04.1.md'>Upgrading to Lubuntu 16.04.1</a></ins>
