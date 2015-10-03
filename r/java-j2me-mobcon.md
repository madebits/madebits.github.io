2004

#MobCon - J2ME Generative Framework

<!--- tags: java -->

MobCon is a generative container framework for mobile applications targeting Java 2 Micro Edition Mobile Information Device Profile (MIDP) 2.0. MobCon was intended to demonstrate the practical value of the mobile container ideas and never made it to a fully usable framework. This page contains an overview of a Java prototype implementation for J2ME MIDP.

##Introduction

MobCon brings the J2EE container abstraction to mobile applications in the form of generative mobile containers. MobCon is based on the assumption that ubiquitous computing applications are inherently complex engineering tasks and this complexity can be addressed with high level software abstractions. The MobCon components use a declarative approach based on annotations. Annotations are implemented as JavaDoc tags. Users decorate the components using a predefined set of tags for Java Micro Edition MIDP.

Based on the programmer's interaction with the MobCon framework, three types of users can be identified:

* End-programmers of the MobCon framework. End-programmers use the predefined set of tags (container functionality) that comes with the MobCon framework. End-programmers use MobCon to automate routine concerns that show up while coding mobile applications. A design goal of MobCon is to easily enable the combination of the decorated code with the rest of manual application code. The decorated components are transformed into undecorated source code where the technical concerns are inserted. The developers could use the generated components, or replace them with custom implementations. The open and traceable code generation approach smoothly introduces the framework into the development work-flow of MIDP programs. Looking at the generated code is a good way to understand what is going on. The tags providers document what a tag means, and how it affects the decorated code.

* The programmers of MobCon MIDP tag plug-in providers. Any end-programmer can extend the MobCon framework to add new custom sets of tags, via one or more tag provider plug-ins, to address new technical concerns of MIDP. In order to create tag provider plug-ins successfully the types of interactions that may exist between tags must be understood. According to the dependency relation, tags can be divided into two groups:

	* Independent tags whose operation over a component is not affected by the presence of other tags.
	* Dependent tags whose operation needs to take into consideration changes done by a previous tag.

	Independent tags are the simplest to program. The preferred pattern is to have small components that are decorated with independent tags. They are then extended with custom code using either the template pattern via inheritance or by combining them using composition. 
	Dependent tags are combined similarly to functional composition and applied in sequential order. The effects of a given tag must be known to the implementer of the successive tag transformers. The co-domain of the first tag transformer is the domain of the second tag transformer. MobCon supports chaining the tag transformers by two means:

	* A way to define dependencies over tag plug-ins externally and enforce them by automatically resolving the declared dependencies, and to apply the plug-ins according to the resolved order.
	* Using internal decoration of the elements into the internal class template (CT-AST) representation that is passed between different tag plug-ins. Plug-in implementations can use internal tags to make assumptions upon the semantics of the code.
	MobCon offers a tag enabled template internal representation for generating code, and scripting language based on Apache Velocity.

* Programmers who extend MobCon framework to address new middleware. The tag plug-in libraries can come with MobCon address Java Micro Edition MIDP 2.0. The MobCon framework itself is middleware independent and is written in Java 1.4. Porting the framework to address new middleware means providing a new set of tag plug-ins for that middleware platform. This group of programmers need to determine the technical concerns that could be addressed in the new platform and provide them as tag plug-ins. For these group of programmers the MobCon tags plug-ins are further organized into:

	* Middleware specific tags. These tags and their implementations are strongly affected by the specific implementation of the addressed domain. For example, a directly dependent MIPD middleware-specific tag is a '@scr.command' that takes a piece of MIDP code as an argument.
	* Middleware independent tags. These tags are expected to be found in every common middleware, for example, the need to save data, modeled by a data persistence tag '@dp'. Independence is a relative concept. Absolute independence from all possible middleware technologies is impossible.
	* General purpose tags that are part of the framework. Tags, such as '@log', which enable method logging are so common that not only they are middleware independent, but actually they can be considered part of the MobCon framework itself.

##MobCon Examples

![HelloWorld-inline](r/java-j2me-mobcon/hellosc.jpg) ![MobRay-inline](r/java-j2me-mobcon/mobray.jpg)

'Hello World' example in MobCon:

```java
/**
 * @scr
 */
public class HelloWorld
    extends MIDlet implements CommandListener
{
    /**
     * @scr.label "Hello"
     * @scr.firstDisplay
     * @scr.exitButton
     * @scr.textField textField
     */
    private Form form;

    /**
     * @scr.label "First Application"
     * @scr.string "Hello World"
     */
    private TextField textField;
}
```

[Helloworld generated code](r/java-j2me-mobcon/AbstractMobApp.java)

A demo application based on a X-Ray medical diagnostics schenarion is used to test MobCon framework. Below is a screenshot from MobRay application and part of its execution log, obtained using the traceability concern (@log).

```
[exec] mobcon.message.MessageHandler: Getting message from server
 [exec] METHOD:  commandAction [@ses, @log]
 [exec] COMMAND:  'Select' executed in screen 'Choose a Patient'
 [exec] METHOD:  choosePatientCG_Action [@app, @log]
 [exec] METHOD:  retrieveEntry [@app, @log]
 [exec] mobcon.message.MessageHandler: Getting message from server
 [exec] METHOD:  setDbe [@dp, @log]
 [exec] METHOD:  callF_patient [@scr, @log]
 [exec] METHOD:  callSI_patientName [@scr, @log]
 [exec] METHOD:  getDbe [@dp, @log]
 [exec] METHOD:  callII_ray [@scr, @log]
 [exec] METHOD:  getDbe [@dp, @log]
 [exec] METHOD:  retrieveImage [@img, @log]
 [exec] mobcon.message.MessageHandler: Getting message from server
 [exec] METHOD:  callI_ray [@img, @log]
 ```

 MobCon has been described in details in the following paper:

*Vasian Cepa and Mira Mezini, MobCon: A Generative Middleware Framework for Java Mobile Applications, Hawaii International Conference on System Sciences (IEEE HICSS-38), 2005*

MobCon prototype has been mainly implemented by **Oliver Liemert** as part of his diploma thesis.