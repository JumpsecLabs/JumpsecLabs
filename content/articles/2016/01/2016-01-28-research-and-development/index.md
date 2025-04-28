---
title: "Research and Development"
date: "2016-01-28"
categories: 
  - "binary-analysis"
  - "network-tools"
  - "obfuscation"
  - "research"
---

Hello w0rld. On this post we would like to let you know our areas of research and the research projects that we are working on currently. For 2016 we are planning to develop tools that will be used in our tests. Our areas of interest can be highlighted as:

- AntiVirus Detection and Evasion techniques (sandbox detection, etc)
- Packers, anti-debugging, anti-disassembly and binary obfuscation
- Network packet capture analysis scripts looking for IoC

- **FUD Malware (maybe Veil Improvisation)**

The initial idea is to find a way to create several different templates on top of Veil. Additionally we can implement several add-ons for Virtual Machine detection or Sandbox Environment detection. This can be either logical-based such as human interaction or can be through technical means like red pills. Even 2-3 assembly instructions can be used for identifying a sandbox environment. Veil exports a .py file which is quite random. It randomizes variable names and also since it uses encryption it randomizes the key that will be used. Then it encrypts the payload and stores it in a .stub area on the binary. This area will be unfold after the execution and a routine is responsible for decrypting and launching the payload. This doesn’t offer and sandbox detection nor VM detection. It is heavily focused against AVs and specifically it is focused defeating signature-based detection systems. The idea of having different binaries but still using the same payload (meterpreter) is necessary for pentesters and for generating quickly payloads that will be used in social engineering tasks. Technically now the most important property is the large keyspace. The larger the key space the more ‘impossible’ to hit the same binary twice. Veil is providing that but still there are issues with the actual binary. My thought is to either break the exported binary and placed it under a new one OR just add several lines of code in the python script that will be used for compilation (through py2exe or pwninstaller). Another possibility is to mess around the pwninstaller and add things there. Another idea is to add randomisation on techniques defeating / escaping sandbox environments. Things that are looking promising:

1. Mess with the actual PE Header, things like .STAB areas, add more stab areas add junk data to stab areas or even add other encrypted data that might look interesting (hyperion paper also has a super cool idea…)
2. Change the file size of the exported binary dynamically. This will happen assuming the above will happen. (Can also be randomized with NOP padding
3. Change values that will not necessarily mess the execution (maybe the versioning of the PE? or the Entry point of the binary?)
4. Write a small scale packer for performance and maybe add also VM detection there
5. Employ sandbox detection and VM detection through several means (this also adds to the 2nd step)
6. Randomized routines for sandbox detection (if mouse\_right\_click = %random\_value then decrypt else break/sleep)

Implementation techniques will include ctypes for sandbox detection and adding loops or other useless things such as calculations. Also using ndisasm or pyelf for messing the binary it is suggested. Red pills can be used in several different techniques.

- **Packer**

Another idea that JUMPSEC labs have is to develop their own packer. This will have several routines for:

1. Static analysis obfuscation: Encryption
2. Dynamic analysis obfuscation: Add noise in program flow/Add randomness to data/runtime
3. Anti-debugging
4. Sandbox escape: Detect human interactions

- **Network Analysis Scripts**

We are developing several scripts for analysing pcap files. The purpose of these scripts is to parse packet captures and to identify whether there are IoC (Indicators of Compromise) by performing statistical analysis of the protocols usage and searching for potential protocol misuse (HTTP requests / responses that arent according to RFC).
