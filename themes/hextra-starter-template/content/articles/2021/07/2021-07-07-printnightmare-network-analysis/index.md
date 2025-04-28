---
title: "PRINTNIGHTMARE NETWORK ANALYSIS"
date: "2021-07-07"
categories: 
  - "detection"
author: "dray"
---

By [Dray Agha](https://twitter.com/Purp1eW0lf)

The infosec community has been busy dissecting the **PrintNightmare exploit**. There are now **variations of the exploit** that can have **various impacts** on a target machine.

When we at JUMPSEC saw that [Lares](https://github.com/LaresLLC/CVE-2021-1675/blob/main/zeek/PrintNightmare.pcap) had captured some network traffic of the PrintNightmare exploit in action, I wondered if there was an opportunity **to gather network-level IoCs and processes** that could offer defenders **unique but consistent methods of detection across the various exploits.**

In this blog, I leverage **Tshark** and see if it can reveal anything about the **networking side** of the **PrintNightmare** exploit. Our goal is purely exploratory, investigating the general workings and network activity of this exploit under the hood. **[Read More...](https://labs.jumpsec.com/printnightmare-network-analysis/)**

Written by: Dray Agha, Security Researcher
