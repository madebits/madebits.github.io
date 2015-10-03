2004

#Group Manager

<!--- tags: cpp -->

This is an improved and updated version of a CodeProject [article](http://www.codeproject.com/menu/gmanager.asp).

##Introduction

Many programming related actions are repetitive across different modules in a program. Cross cutting actions can be handled with generic static meta-programming tools such as aspect oriented engines. Some tasks can be simplified easier without the need for a meta-programming step, by adding run-time support specialized for them in software.

Activation of groups of related interface controls is a repetitive cross-cutting task that can be automated with appropriate programming support. For example, in graphical user interface (GUI) applications, it is often necessary to prevent the user from being able to carry some of the actions that the interface offers. This is (often) done by disabling (deactivating) temporarily at run-time groups of controls, for example, menus.

Run-time menu management is usually done manually in code, in every place such a feature is needed. The enable/disable code spread around the code routines that need to do some from of synchronization between the different menu groups. This means that the cost of making a change in such an application, when a new menu, or to define a new logical menu group needs to be added is high. This situation happens often during development phase and more rarely during maintenance.

Below an automated system is represented which tries to facilitate this kind of task in a GUI application. The logic behind this system is transparent to the programmer. The discussion that follows can easily apply to any type of control, but the example code will focus on the management of menu groups.

##Automated Deduction of Groups

Most of the knowledge about the exclusive groups of menus can be deduced from simple logic statements made about each menu element that is present, or is added in a program. For every newly added menu item, the group of menus where it belongs could be specified indirectly based on the relation of the new menu item and another known related menu item.

For example, let suppose that the first defined menu item is named m1. There are no other menu items before m1, thus m1 forms a group by itself, denoted as: {m1}. Later on a new menu item m2 is added. The m2 can be in the same group as m1 or in a new one. If m2 is in the same group as m1 then there is still only one group {m1, m2}. Otherwise, m2 is in a new group and there are now two groups {m1} and {m2}.

In general, for every two menu items only one of two relations may stand. They are 'friends', that is they belong to the same group, or they are 'enemies' and belong to two different groups.

Usually there is no need to specify the relation for every pair of menus, since this knowledge can be deduced from the group's state. For example, consider the case when there are three menu items named m1, m2, and m3. If we say that m1 'is friend of' m2, and m2 'is enemy of' m3, then these three items would group in two 'action' groups: {m1, m2} and {m3}. Thus, there is no need to say explicitly that m1 'is enemy of' m3.

This knowledge can be used to build a system for managing the action groups, where the menu relations are deduced based on the relations specified. In such a system the groups are created automatically and transparently, by examining all of 'friend' and 'enemy' relations defined by the user. The system should then offer the possibility to de/activate the implicit groups, based only on a given menu item, which belongs to one or more of the implicit groups. The implementation is almost transparent to the end-programmer.

##Group Operations

In practice, the friend and enemy relations can be projected in four operations (relations):

* The friend `<+>` operation declares a friendship. If m1<+>m2, then after this, a group {m1,m2} will exist. For a new item m3, either m1<+>m3, or m2<+>m3, will add m3 to the above group {m1, m2, m3}.
The friend operation can also merge the groups. For the groups {m1, m2} and {m3,m4}, ANY of such declarations: m1<+>m3 OR/AND m1<+>m4 OR/AND m2<+>m3 OR/AND m3<+>m1 OR/AND m3<+>m2 OR/AND m4<+>m1 OR/AND m4<+>m2, will result in a group merge: {m1,m2,m3,m4}. The <+> relations is reflective (m1<+>m1), symmetrical (m1<+>m2 == m2<+>m1), and transitive (m1<+>m2 AND m2<+>m3 => m1<+>m3). It is also associative, but this property is not needed in the implementation. 
By definition m1<+>m1 will create group {m1} if and only if m1 is not already a member of any group.

* The enemy `<->` operation declares a contradiction (negative condition). If m1<->m2, then after the groups {m1} and {m2} will be created. In contrary to the 'friend' relation, the '<->' operation is NOT symmetrical. Thus, given {m1,m2,m3} and m1<->m2, then the following groups are created {m1} and {m2,m3}. This is different from m2<->m1, which would have resulted in {m2} and {m1,m3} being created. The '<->' operation results in a group split. By definition m1<->m1 will create group {m1} if this group does not exist.

* The mutual friend operation `<*>` declares what a directed friendship. It is the same as the friend operation as it also declares a 'friend' relation, but in difference from the friend operation, the mutual friend operation does NOT result in a group merge. This is required in those cases when one wants to declare that a given menu item belongs to more than one action group in a given time. Given groups {m1,m2} and {m3,m4}, and m1`<*>`m3 OR/AND m1`<*>`m4, then this would result in {m1,m2} and {m1,m3,m4}. Thus both groups contain m1 as mutual friend, hence the name of this operation. This operation is not symmetrical. By definition, the operation m1<*>m1 will create group {m1} if this group does not exist.

* The anti-enemy operation `<%>` declares an enemy-like relation, but changes from operation '<->' in that it does not create a new group for the first operand. Given {m1,m2,m3}, then m1<%>m2 results in {m2,m3} and no group is created for m1. Given {m1,m2} and {m3,m4}, then m1<%>m3 OR/AND m1<%>m4 does nothing.
By definition m1<%>m1 removes the group {m1} if it exists. This is the main reason for the existence of this operation: given that the enemy operation <-> introduces new groups, there should be then a way to remove them. By definition m1<%>m2 should create the group {m2} if it does not exist.

The four operations above can be used to change the state of groups (clusters) in any time and a new successive declaration can change the state set by the previous declarations. The order in which the operations are defined is not important.

The system can create and maintain the action groups implicitly from these operations. This process is transparent. Some mean for debugging the state of the manager (the groups formed in a moment of time) would be useful during development, so that it could be implemented and exposed to the developers.

##Example

```
// Legend:
// <+> - declareFriend
// <-> - declareEnemy
// <*> - declareMutualFriend
// <%> - declareAntiEnemy
```

```
m1<+>m2 # this forms group: {m1,m2}
m2<+>m1 # this is the same: {m1,m2}
m2<->m3 # then: {m1,m2};{m3}
m1<+>m3 # this here causes the group merge
              # of {m1,m2} and {m3} so {m1, m2, m3}
m4<+>m2 # {m1,m2,m3,m4};
m4<->m1 # {m1,m2,m3};{m4}
m1<+>m1 # m1 creates a new group if not already a member
              # of another: {m1,m2,m3};{m4}
m1<->m1 # m1 creates a new group if {m1} does not
              # exists: {m1};{m1,m2,m3};{m4}
m5<->m1 # {m1};{m1,m2,m3};{m4};{m5}
m6<->m1 # {m1};{m1,m2,m3};{m4};{m5};{m6}
m6<+>m5 # {m1};{m1,m2,m3};{m4};{m5,m6}
m1<*>m5 # {m1};{m1,m2,m3};{m4};{m1,m5,m6} - mutual
              # friends: m1 belong to two groups.
m1<%>m2 # {m1};{m2,m3};{m4};{m1,m5,m6}
m1<%>m1 # {m2,m3};{m4};{m1,m5,m6}
m1<+>m3 # {m1,m2,m3,m5,m6};{m4}
```

##Implementation and Demo

`Member<T>` (files: member.h) is a wrapper class around the specific GUI components `T` to be synchronized. The `T` class is required to have these two methods:

```cpp
 *  Each member object of class T must have these methods:
 *  string (T::*pf)();  // eg. string Menu::getName();
 *  void (T::*pf)(bool); // eg. Void Menu::setState(bool newState);
 *
 *  Also operator << must be defined for
 *  specific member objects T.
```

They will be used like this:

```cpp
// this is the first thing we must do before
// we use any of other gmanager objects !!!
Member<Menu>::setNameMethod(&Menu::getName);
Member<Menu>::setStateMethod(&Menu::setState);
```

A trivial class `Menu` (files: menu.h, menu.cpp) is used as a type `T` in demo.

`Group<T>` (files: group.h) - We save objects not pointers here. This may not be always preferable. The implementation can be changed to make use of pointers, that is to store types of `Member<T>*`, instead of `Member<T>` as it does now. Since a member item can not be in a group more than once, than a group is just a set. `Group<T>` class should NOT be accessed directly in code.

`GroupManager<T>` (files: groupmanager.h, groupmanager.cpp) implements the required logic for clustering the groups of components based on their `<+>` (friend) and `<->` (enemy), `<*>` (mutual friend) and `<%>` (anti-enemy) operations. The operations can be specified by calling its methods `declareFriend()`, `declareEnemy()`, `declareMutualFriend()`, and `declareAntiEnemy()` directly in code, or by using an external action file which is the preferred way. Various `*activate()` methods of this class are used to de/activate groups.

`ParseClusters` (files: parseclusters.h, parseclusters.cpp) allows us to initialize a `GroupManager<T>` object based on an external action file, not calling thus `declareFriend()`, `declareEnemy()`, `declareMutualFriend()`, and `declareAntiEnemy()` directly. Only the names of `T` objects need to be in this file along with their relations.

The method: 

```cpp
void parseAction(GroupManager<T>&, map<string, Member<T> >&, char *) 
```

is used to initialize a `GroupManager<T>` from a action file `char *`. The pairs of components (name, `Member<T>`) should be provided in a map object.

The format of the actions file is:

```
# The grammar:
#
# associationsfile := (association_line)*;
# association_line := comment | operation | operation comment | empty;
# comment := '#' + (alfanumeric)*
# operation := name operator name;
# name := (alfanumeric)+;
# operator := '<+>' | '<->' | '<*>' | '<%>'
# alfanumeric := all keyboard chars
# empty := an empty line
#
# Spaces may separate tokens.
```

To use this feature in code 'parseclusters.h' should be included and 'parseclusters.cpp' code should be included in the list of to be compiled files.

`MemberCollection<T>` (files: membercollection.h, membercollection.cpp) a utility class for using the gmanager system. The 'gmanager-demo.cpp' uses this class. For more details manual operations see 'manager.cpp'. This is the recommended way to use the code functionality.

Various other files are used:

* gmanager-demo.cpp - the main demo of gmanager usage in an application. See also 'manager.cpp' for other details.
* vutils.h, vutils.cpp - various numeric and string routines used here.

To use gmananger system in another application, you do not need the 'gmanager-demo.cpp' file.

To compile the demo use:

```
CC gmanager-demo.cpp menu.cpp vutils.cpp parseclusters.cpp membercollection.cpp
```

Where CC is any C++ compiler. The code makes use of C++ exceptions and may not be compiled by all compilers (BCC32 5.5.1 was used to compile it). The exceptions may be omitted, by editing the code.

The demo code is not thread safe. The code needs some critical-session wrapper code to be used in multi-thread applications, that enable/disable controls from many threads.

##Implications and Future Work

While this article focused on group management for GUI controls in general and menu items in particular, group management is a generic property of many systems. For example, the same operations as defined here could be used to enable users of mobile devices (cellular phones) to manage lousy friend lists. The idea is enable each mobile phone user to enter a relation such as those defined above for every contact the user likes. The deduced groups can then be stored and managed in a central server location (a distributed event-based system is also possible) and be used to propagate the events.

For example, user A decides to send a message to user B (SMS for example). The software could enable the user A to send the message optionally to the group of friends where B belongs, so all can share it. The enemies of A will not receive the message. This way, the system could model the semantics of natural relations that exists between people in real life. In the real life if A tells something to his/her friend B, and C is a friend of B, then there is very high chance that B will tell it to C. Some propagation depth could also be defined so the signal gets lost automatically after the allowed level of propagation is reached. Investigating such a system for mobile device users, or peer to peer software users could be future work.
