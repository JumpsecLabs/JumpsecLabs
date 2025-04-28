---
title: "API Hooking Framework"
date: "2020-06-07"
categories: 
  - "jumpsec"
author: "ndt"
---

An API hooking framework, composed by a Windows driver component for library injection, a DLL file for function hooking and reporting, and a web service presenting a user interface and managing the communications between the user and the other components.  
The framework is aimed towards desktop application testing and vulnerability research: allows a granular monitoring of one or more processes at runtime, giving the ability to transparently change the behaviour of the application, and performs various automated vulnerability checks, reporting whenever a potential weakness is found.  
Logs sent by the framework can be filtered and searched for in the web UI, and the library injection can be selectively turned on or off based on different criteria, such as process path, username, or privilege level.
