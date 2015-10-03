2003

Multi-Client Multi-Thread HTTP Web Spider Demo (.NET C# Remoting)
=====

<!--- tags: csharp -->

A web spider (or a crawler) is a program that scans HTML pages recursively starting with one given page and collects the links found. This program is not a complete web spider, rather a demo. Its spider capabilities are restricted, but otherwise it contains the complete architecture of a broadband web spider service. It is implemented in .NET using remoting in C# (.NET 1.0 compatible).

##Description

Spider tasks are run in a dedicated spider server that has all the required bandwidth required for this type task. Various clients can specify spider tasks and get the results back from the server as a file consisting of a list of the found URLs. When a client is connected to the spider server, the server assigns a unique ID to the client. A client can start new spider tasks, or ask for the status of existing tasks. To be able ask for the status of the existing tasks, the client must logging with a previous given ID (assigned by the server). If the client is still connected to the web server, when one of its spider related tasks ends, the server sends the data black to the client asynchronously. Otherwise, after a task has finished, the client can re-connect and get back the results. The client could also ask explicitly at any time about the status of a spider tasks associated with its ID. The tasks name space is unique for each client.

![](r/msnet-remoting-webspider/spider.gif)

The spider server handles each client in a new thread, and assigns a number of threads to each spider task. To limit the search the spider has a limited URL search depth of 5 levels (can be customized). The clients can also specify other parameters to fine-grain the search, such as, searching within a given web site only. A search starts always with a given start URL. The server sends the results of the spider task back to the client immediately as soon as the task ends, if the client is still connected at that moment of time. Otherwise, the server stores the data temporarily for a given amount of time (a few hours). If the client is not re-connected to receive the data back within this amount of time, the data are automatically deleted. Once a client gets the data, the server deletes its copy of the data.

##Implementation

The code demonstrates some common design issues when dealing with .NET remoting. It demonstrates the use of interfaces to decouple the remote object usage from the implementation. The web server and the client need to refer to each other (the clients register callbacks on the server). The code demonstrates how to properly decouple such callbacks, in order to keep the amount of the shared code between the client and the server at a minimum. Because of the serialization and problems related to versioning and code sharing, the demo optimizes the shared code to contain a minimum of shared types that serve only as data placeholders. The demo clearly separates the business logic in server and client from the shared code. This ensures that no unintended code goes to the client, and that the server logic is kept outside of the shared data types which are accessible to the client. These properties are important for using .NET remoting securely for real applications. The demo demonstrates also some other minor points, such as, the use of configuration files, web server deployment, etc., and serves as a non-so-trivial .NET remoting use case. The code is written in C# for .NET 1.0.
