#Getting Started With Spark ML

2016-07-26

<!--- tags: ml scala -->

`spark.ml` [examples](http://spark.apache.org/docs/latest/ml-guide.html#example-estimator-transformer-and-param) are intended to be run in the `spark-shell`. It is often more convenient to run them as stand-alone programs. We need to wrap them in same way `scala` tool wrap scripts.

##Installing Scala

Assuming Java SDK is installed, one can [download](http://www.scala-lang.org/download/) Scala and unpack it to a local folder, such `~/opt/scala` and make sure `$HOME/opt/scala/bin` it is added to the `$PATH`. Additionally, scala build tool, [sbt](http://www.scala-sbt.org/0.13/docs/Manual-Installation.html) tool JAR can be placed in `$HOME/opt/scala/bin` and a `sbt` bash script to invoke `sbt` can be created in same folder.

##Sbt Project

The [minimal](http://stackoverflow.com/questions/27438353/mllib-dependency-error) build.sbt file to run Spark Ml examples is:

```
name := "example-app"

version := "1.0"

scalaVersion := "2.11.8"

libraryDependencies ++= Seq(
  "org.apache.spark"  %% "spark-core"              % "1.6.2" % "provided",
  "org.apache.spark"  %% "spark-mllib"             % "1.6.2"
  )
```

Scala and Spark versions used may be changed as needed.

Project folder and file structure is simple:

```
.
├── build.sbt
└── src
    └── main
        └── scala
            └── ExampleApp.scala
```

To build the project use `sbt clean compile`, to run it use `sbt run` and to package it as JAR for usage with `spark-submit` use `sbt package`.

##Wrapper Object

`ExampleApp.scala` need to wrap the example in a Scala object with a main method:

```scala
import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._

object ScalaApp {

    def main(args: Array[String]) {
        val sc = new SparkContext("local[2]", "App")
        sc.setLogLevel("WARN")
        println("SparkVersion: " + sc.version)
        val sqlContext = new org.apache.spark.sql.SQLContext(sc)
        import sqlContext.implicits._

        // paste Ml example here:
        ...

        sc.stop()
    }
}
```

I have set some of the sc context configuration parameters explicitly. You may choose to set no parameters here, if you want to set them later via `spark-submit`.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2016/2016-07-27-Using-keynav-to-move-mouse-pointer-on-Lubuntu.md'>Using keynav to move mouse pointer on Lubuntu</a> <a rel='next' id='fnext' href='#blog/2016/2016-07-14-Agile-Iterations-As-Path-Search.md'>Agile Iterations As Path Search</a></ins>
