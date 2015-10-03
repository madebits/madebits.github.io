#Integrating GO.CD with Nexus

2017-02-21

<!--- tags: agile deployment -->

[GO.CD](https://www.gocd.io/) is continuous a delivery platform organized around value streams modeled as delivery pipelines. GO.CD is a generic tool and one can invoke any build or deployment commands of choice. GO.CD can store build artifacts from GO.CD build agents in GO.CD server and make them accessible via its web interface or via its REST API. GO.CD artifact management is limited in options and not structured and works best for limited amounts of value streams data.

[Nexus](http://www.sonatype.org/nexus/) is a controlled central repository server to store and retrieve artifacts. Nexus can transparently proxy combined public and local repositories and supports a wide range of repository types from Maven, Npm, Nuget, Docker and Python. Developers uses heterogeneous technologies and Nexus is one repository server to manage them all. This makes Nexus a tool of choice for both temporary and long term artifact storage.

To have the best of both worlds one can combine continuous delivery guided by GO.CD with artifact storage in Nexus. 

##Nexus Central Repository

Several types of build artifacts, such as Nuget or Npm packages, are naturally and directly handled by Nexus. During GO.CD builds, one can publish Nuget and Npm packaged components directly in Nexus repositories and consume them from there. Not all build artifact are so structured to fit in any of the existing Nexus repositories. Binaries, documentation, and build artifacts of several technologies, such as Microsoft .NET, do not fit directly in Nexus structure. 

##Maven as a Binary Repository

Nexus support RAW repositories, but they are a collection of files without direct controlling structure. The next best generic purpose repository type that can be re-purposed to handle arbitrary data is [Maven](https://maven.apache.org/). Maven is interesting because apart of handling Java JAR components, it can be used as a generic repository to store any other type of versioned artifacts. Maven basically stores binary data (in forms of JAR or whatever) that can be associated with meta-data in form of XML POM files. The idea is to misuse a Maven repository to store non-Java build artifacts.

##Uploading GO.CD Artifacts in Nexus

GO.CD caries pipeline actions in agent machines and then uploads any defined artifacts in GO.CD server once the jobs are finished. One can hook at the job tasks and run own code to upload artifacts in Nexus, and store minimal information about them in GO.CD own artifacts. While Maven supports any binary types, Maven plugin in combination with POM files, works best with JAR types. To [upload](https://support.sonatype.com/hc/en-us/articles/213465818-How-can-I-programatically-upload-an-artifact-into-Nexus-
) an arbitrary file packed as JAR (JAR files for our purpose here are renamed ZIP files, with no further required structure) the following command can be used:

```bat
%MAVEN_HOME%\bin\mvn deploy:deploy-file -DgroupId=com.test -DartifactId=app -Dversion=1.0.0-20170105.074730-3 -DgeneratePom=false
-Dpackaging=jar -DrepositoryId=snapshots -Durl=http://cd.nexus/content/repositories/snapshots -Dfile=app-1.0.zip -DpomFile=pom.xml
```

It is possible to [upload](https://support.sonatype.com/hc/en-us/articles/213465818-How-can-I-programatically-upload-an-artifact-into-Nexus-
) without using Maven plugin, but using the Maven plugin protects us from any API changes. 

GO.CD agent UTC timestamp is used in version. The last part of version after the timestamp (`-3`), is auto-incremented locally by Maven. As GO.CD runs its stages on different agents, this feature of Maven plugin can be problematic as every agent has its own increment. Using the above command one can fully control the version string and we can use GO_PIPELINE_COUNTER (build number) for the last part.

##Adding Custom Metadata

Using a POM file when uploading artifacts in Maven repository is not required as it can be auto-generated as needed. POM files are useful if we want to store our own custom meta-data. Maven has its own minimal housekeeping data in POM files, but we can add our own data as *properties*:

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
<modelVersion>4.0.0</modelVersion>
<groupId>com.test</groupId>
<artifactId>app</artifactId>
<version>1.0.0-20170105.074730-3</version>
<packaging>jar</packaging>
<properties>
  <custom-data><![CDATA[JSON]]></custom-data>
</properties>
</project>
```

In this example, we store custom data as JSON within the XML. Any number of such custom properties can be added. Custom meta-data enable keeping track of  various build and deploy related data, such as Git commit revision used, GO.CD pipeline name and stage counters, and so on - the exact data will depend on your build and deploy logic.

##Grouping Artifacts

In GO.CD, binary artifacts are generated by different build pipelines and we many need to combine them together, to act as a logical package in order to move further down in the stream of processing pipelines. 

Maven is also good at this. We can use POM dependencies to group several generated artifacts in a [fan-in](https://docs.gocd.io/16.9.0/advanced_usage/fan_in.html) pipeline to be treated a single package for further processing. In a *fan-in* pipeline, we fetch information about the single artifacts put in Maven and create a 'package' POM that contains them as dependencies:

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
<modelVersion>4.0.0</modelVersion>
<groupId>com.test</groupId>
<artifactId>package1</artifactId>
<version>1.0.0</version>
<packaging>jar</packaging>
  <repositories>
    <repository>
      <id>nexus</id>
      <name>Nexus Public Repositories</name>
      <url>http://cd.nexus/content/groups/public/</url>
    </repository>
  </repositories>
  <dependencies>
    <dependency>
      <groupId>com.test</groupId>
      <artifactId>app1</artifactId>
      <version>1.0.0-20170125.064730-3</version>
    </dependency>
    <dependency>
      <groupId>com.test</groupId>
      <artifactId>app2</artifactId>
      <version>1.0.0-20170125.064730-3</version>
    </dependency>
  </dependencies>
<properties>
  <custom-data><![CDATA[JSON]]></custom-data>
</properties>
</project>
```

New custom meta-data added to the package POM at this stage, may include the Git commit revision of the configuration repository used to deploy the package.

##Downloading Packaged Artifacts

The nice thing about packing artifacts together as package dependencies is that we can fetch them together at once in a GO.CD agent using Maven plugin:

```bat
%MAVEN_HOME%\bin\mvn dependency:copy-dependencies -f pom.xml
```

For this to work, one has to inject in the POM XML the repository by referring names used in the Maven `conf/settings.xml` file:

```xml
<repositories>
  <repository>
    <id>nexus</id>
    <name>Nexus Public Repository</name>
    <url>http://cd.nexus/content/groups/public/</url>
  </repository>
</repositories>
``` 

Maven by design (given it has to deliver JARs to Java projects, and those JARs has to be local for CLASSPATH to work) will keep a copy of the artifact locally. If disk space is not an issue, move `<localRepository>/path/to/local/repo</localRepository>` in `conf/settings.xml` to a shared storage location, where the local repository can be placed.

In my case, this was not an option as builds generate a lot of data. I wrote some custom Node.js code to parse the POM and download the files without using Maven plugin. The main benefit of the custom code is that it can download from Nexus directly and does not need to keep local copies for longer than needed in GO.CD agents, as Maven would do.

##Artifact Promotion

Our builds produce a lot of artifacts and most of them are not intended to live forever. When we build, we store the artifacts in a Nexus Maven SNAPSHOTS repository. We clean SNAPSHOTS repository periodically to claim the space. 

At some place in our pipelines, the artifacts are deployed, tested, and can be manually selected for promotion to releases, for further staging. Promotion to release means moving artifacts from a SNAPSHOTS repository to a RELEASES one. 

The brute-force way to do this works nicely for our binary artifacts. We download package data from the SNAPSHOTS in one GO.CD agent, and after updating the version format to match the RELEASES one, we re-publish all JARs and POMs in the RELEASES repository. Additional custom meta-data are added to package POM to mark the promotion event.

RELEASES artifacts are persevered for a longer time. While we allow artifact overwrite in our Nexus, the timestamps in release artifacts allow us to have globally uniquely identifiable binaries.

##Complete GO.CD Workflow

![](blog/images/cd.png)

##Summary

GO.CD is a great tool to manage continuous delivery pipelines. Templates guide creation and combination of pipelines and in our case invoke custom Node.js code that manages builds and deployments. Node.js code is parameterized via files found in Git repositories, so that builds and configurations are fully versioned and controlled. As part of the Node.js code actions, we store and consume binary artifact to and from Nexus, using each tool for what it does best. 

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2017/2017-03-08-Checkpoint-Security-On-Ubuntu.md'>Checkpoint Security On Ubuntu</a> <a rel='next' id='fnext' href='#blog/2017/2017-01-19-Embracing-Team-Practices-Variability.md'>Embracing Team Practices Variability</a></ins>
