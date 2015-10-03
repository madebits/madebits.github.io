#Naive Bayes in R

2015-06-03

<!--- tags: ml r -->

This is a didactic implementation of [Naive Bayes Classifier](https://en.wikipedia.org/wiki/Naive_Bayes_classifier) (NBC). In conditional probability, one speaks of outcome $$$O$$$ (or hypothesis) given evidence $$$E$$$ (or data):

$$
P(OE) = P(EO) = P(O) P(E|O) = P(E) P(O|E)
$$

Using simple probability rules one can demonstrate Bayes rule:

$$
P(O|E) = \frac{ P(OE) } { P(E) } = \frac{P(EO)} {P(E)} = \frac{ P(E|O) P(O) } { P(E) } = \frac{ P(E|O) P(O) } { P(E|O)  P(O) + P(E|O^c) P(O^c) }
$$

Last part's denominator can be generalized to an arbitrary disjoint partitions $$$O, O^c$$$ of the sample space. Bayes rule reverses probability calculation: $$$P(O|E)$$$ is defined in terms of $$$P(E|O)$$$. [Naive Bayes](https://stackoverflow.com/questions/10059594/a-simple-explanation-of-naive-bayes-classification) assumes that if two (or more) events $$$E_1$$$ and $$$E_2$$$ are *conditionally* independent (with regard to $$$O$$$):

$$
P(E_1E_2) = P(E_1) P(E_2) \implies P(E_1E_2 | O) = P(E_1|O) P(E_2|O)
$$

Then the posterior probability $$$P(O|E_1E_2)$$$ can be calculated fully from the prior one:

$$
P(O|E_1E_2) = \frac{ P(E_1E_2|O) P(O) } { P(E_1E_2) } = \frac{ P(E_1|O) P(E_2|O) P(O) } { P(E_1E_2) }
$$

Given $$$E_1$$$ and $$$E_2$$$ happen, then we can calculate posterior probability $$$P(O|E_1E_2)$$$ from likelihood probability $$$P(E_1E_2|O)$$$ times prior probability $$$P(O)$$$. For classification purposes, dividing by $$$P(E_1E_2)$$$ (marginal likelihood (evidence)) to normalize the probability is not needed. Naive Bayes is a supervised machine learning algorithm. We can easy estimate $$$P(E_i|O)$$$ and $$$P(O)$$$ for each output class from the training data. Then we use this prior knowledge to calculate $$$P(O|E_1E_2)$$$ for each class based on new data evidence. The class with largest $$$P(O|E_1E_2)$$$ is the winner. Code of the **R** implementation is shown next:

```r
nb.train <- function(data){
  classes <- levels(data[,1]) # Y
  total <- nrow(data)
  evidence <- lapply(2:ncol(data), function(i){ 
    table(data[, i]) / total
  })
  names(evidence) <- colnames(data)[-1]
  
  prior <- lapply(classes, function(level){
    filter <- data[,1] == level
    prior <- mean(filter)
    likelihood <- lapply(2:ncol(data), function(i){ 
      table(data[filter, i]) / total
    })
    names(likelihood) <- names(evidence)
    list(class = level, prior=prior, likelihood=likelihood)
  })
  names(prior) <- classes
  list(classes=prior, evidence=evidence)
}

nb.predict <- function(knowledge, newData, cnames=colnames(newData)){
  prediction <- apply(newData, 1, function(observation){
    classifier <- sapply(seq_along(knowledge$classes), function(classIdx){
      classData <- knowledge$classes[[classIdx]]
      prod(sapply(cnames, function(column){
        columnValue <- observation[column]
        classData$likelihood[[column]][columnValue]
      })) * classData$prior 
    })
    knowledge$classes[[which.max(classifier)]]$class
  })
  as.factor(prediction)
}
```

In `nb.train` we learn from the training data. I assume the data are in the *long-format*. Output $$$Y$$$ is is the first column and the rest of columns contains the data $$$X$$$, where $$$Y \approx f(X)$$$, for some unknown function $$$f$$$. The code also assumes all data ($$$Y$$$ and $$$X$$$) are factors (categorical). The output is list made of Y classes and the likelihood conditional probabilities. We also collect the evidence probabilities, but do not use them. `nb.predict` uses then the knowledge output from `nb.train` to classify new data. The new data must not contain $$$Y$$$, only $$$X$$$. I calculate the product of probabilities directly. In practice, this number can underflow, so a better approach would have been to use `exp(sum(...log(classData$likelihood)...))`. An example helps clarify how these functions work together:

```r
set.seed(1)
data <- data.frame(y=as.factor(sample(1:3, 20, replace=TRUE)),
                   a1=as.factor(sample(5:9, 20, replace=TRUE)),
                   a2=as.factor(sample(1:4, 20, replace=TRUE)),
                   a3=as.factor(sample(1:4, 20, replace=TRUE)))
fit <- nb.train(model.frame(y ~ a1 + a2 + a3, data=data))
pred <- nb.predict(fit, model.frame(~ a1 + a2 + a3, data=data))
table(pred, Y=data[,1])

pred
data[,1]
mean(pred != data[,1])
```

Sample `data` looks as follows:

```
  y a1 a2 a3
1 1  9  4  4
2 2  6  3  2
3 2  8  4  2
4 3  5  3  2
5 1  6  3  3
6 3  6  4  2
...
```


We have three classes in `y` and three data attributes `a1`, `a2`, `a3` in `X`. The output `fit` of `nb.train` looks as:

```
List of 2
 $ classes :List of 3
  ..$ 1:List of 3
  .. ..$ class     : chr "1"
  .. ..$ prior     : num 0.25
  .. ..$ likelihood:List of 3
  .. .. ..$ a1: table [1:5(1d)] 0 0.1 0.1 0 0.05
  .. .. .. ..- attr(*, "dimnames")=List of 1
  .. .. .. .. ..$ : chr [1:5] "5" "6" "7" "8" ...
  .. .. ..$ a2: table [1:4(1d)] 0 0.05 0.1 0.1
  .. .. .. ..- attr(*, "dimnames")=List of 1
  .. .. .. .. ..$ : chr [1:4] "1" "2" "3" "4"
  .. .. ..$ a3: table [1:4(1d)] 0 0.05 0.05 0.15
  .. .. .. ..- attr(*, "dimnames")=List of 1
  .. .. .. .. ..$ : chr [1:4] "1" "2" "3" "4"
  ..$ 2:List of 3
  .. ..$ class     : chr "2"
  .. ..$ prior     : num 0.35
  .. ..$ likelihood:List of 3
  .. .. ..$ a1: table [1:5(1d)] 0.05 0.1 0 0.15 0.05
  .. .. .. ..- attr(*, "dimnames")=List of 1
  .. .. .. .. ..$ : chr [1:5] "5" "6" "7" "8" ...
  .. .. ..$ a2: table [1:4(1d)] 0.1 0.05 0.15 0.05
  .. .. .. ..- attr(*, "dimnames")=List of 1
  .. .. .. .. ..$ : chr [1:4] "1" "2" "3" "4"
  .. .. ..$ a3: table [1:4(1d)] 0.05 0.15 0 0.15
  .. .. .. ..- attr(*, "dimnames")=List of 1
  .. .. .. .. ..$ : chr [1:4] "1" "2" "3" "4"
  ..$ 3:List of 3
  .. ..$ class     : chr "3"
  .. ..$ prior     : num 0.4
  .. ..$ likelihood:List of 3
  .. .. ..$ a1: table [1:5(1d)] 0.15 0.05 0.1 0.05 0.05
  .. .. .. ..- attr(*, "dimnames")=List of 1
  .. .. .. .. ..$ : chr [1:5] "5" "6" "7" "8" ...
  .. .. ..$ a2: table [1:4(1d)] 0.1 0.15 0.1 0.05
  .. .. .. ..- attr(*, "dimnames")=List of 1
  .. .. .. .. ..$ : chr [1:4] "1" "2" "3" "4"
  .. .. ..$ a3: table [1:4(1d)] 0 0.3 0 0.1
  .. .. .. ..- attr(*, "dimnames")=List of 1
  .. .. .. .. ..$ : chr [1:4] "1" "2" "3" "4"
 $ evidence:List of 3
  ..$ a1: table [1:5(1d)] 0.2 0.25 0.2 0.2 0.15
  .. ..- attr(*, "dimnames")=List of 1
  .. .. ..$ : chr [1:5] "5" "6" "7" "8" ...
  ..$ a2: table [1:4(1d)] 0.2 0.25 0.35 0.2
  .. ..- attr(*, "dimnames")=List of 1
  .. .. ..$ : chr [1:4] "1" "2" "3" "4"
  ..$ a3: table [1:4(1d)] 0.05 0.5 0.05 0.4
  .. ..- attr(*, "dimnames")=List of 1
  .. .. ..$ : chr [1:4] "1" "2" "3" "4"
```

We use this knowledge to predict classification for the same training data and get:

```
> pred
 [1] 1 2 2 3 1 3 3 3 2 2 3 1 3 3 3 2 2 3 2 3
> data[,1]
 [1] 1 2 2 3 1 3 3 2 2 1 1 1 3 2 3 2 3 3 2 3
> table ...
    Y
pred 1 2 3
   1 3 0 0
   2 1 5 1
   3 1 2 7
```

We see we have classified 1 correctly 3 times and incorrectly 2 times (once as 2 and once as 3) and so on, with an overall training set misclassification rate of 25% on these uniformly generated random data.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2015/2015-06-09-Encrypting-Git-Home-Folder-on-Windows.md'>Encrypting Git Home Folder on Windows</a> <a rel='next' id='fnext' href='#blog/2015/2015-05-12-Using-SVD-to-Reduce-Images.md'>Using SVD to Reduce Images</a></ins>
