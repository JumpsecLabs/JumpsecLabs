---
title: "Ligolo: Quality of Life on Red Team Engagements"
date: "2023-06-09"
categories: 
  - "jumpsec"
  - "network-tools"
tags: 
  - "bringyourownc2"
  - "proxy"
  - "red-teaming"
  - "tunneling"
author: "francescoiulio"
---

**![ligolo bugsbunny 2023 06 09 12 50](images/ligolo-bugsbunny-2023-06-09_12-50-300x267.png "ligolo bugsbunny 2023 06 09 12 50")**In recent months we, JUMPSEC’s red team, have been using a nifty little tool that we would like to share with you in this blog post. Ligolo-ng is a versatile tool that has been aiding our covert, and slightly-less-covert, engagements with regards to tunnelling, exfiltration, persistence, and widely improving the operators’ “quality of life” when carrying out assessments involving beaconing from within an internal network.

This highly-useful tool is developed by Nicolas Chatelain and can be found on Github at [https://github.com/nicocha30/ligolo-ng](https://github.com/nicocha30/ligolo-ng). Ligolo can be described as a modern tunnelling tool, similar to the likes of chisel, sshuttle or SSH, with the advantage of being written in GO and behaving just like a VPN. That is to say, when setup correctly operators can enjoy connections to a target network of up to 100 Mbits/sec, utilising various protocols such as ICMP (ping), UDP scans, SYN stealth scan, OS detection and DNS Resolution, which are commonly not allowed through proxychains or “standard” tunnelling tooling.

The tool uses agents on the compromised machine which connect to a publicly-facing proxy server to route traffic through a tun interface that is created on the host. In simple terms, Ligolo offers red teamers an alternative C2 channel that supports far more than traditional SSH or SOCKS proxies, allowing you to run a wider variety of tooling, much faster, and with what feels like too-good-to-be-true quality of life.

The gif below shows how quick it is to setup the proxy server on a linux host machine after downloading the proxy executable from the releases’ page on Github.

![latest ligolo demo setup5](images/latest_ligolo_demo_setup5.gif "latest ligolo demo setup5")

More and more, when using this tool, we discover features applicable to new use-cases. For example, beside its ease of use, things like using ping and private domain name resolution during a red team engagement are invaluable and can definitely improve the turnaround time and efficiency of an assessment. Once the necessary steps have been taken, as detailed below, operators can enjoy their entire suite of red team tooling on their linux server, with full name resolution, and speeds that are incomparable with that of traditional tunnelling on red team engagements. We have jokingly referred to Ligolo as allowing you to move your C2 into the target network!

Furthermore, it is possible to set up listeners on deployed agents to welcome connections coming from agents deployed somewhere else in the target environment. Crucially, the agents do not require any privileged permissions to be executed on the compromised hosts, because of its “gvisor” implementation, which works by virtualising sandboxed containers that translate traffic reaching the central proxy server deployed on our host.

As previously mentioned, GO makes it highly versatile and flexible, allowing operators to customise the proxy as well as the agents, and compile them to bypass defences or implement additional capabilities that are not there by default.

For example, we found ourselves able to bypass common endpoint detection and response (EDR) mechanisms employed in a Windows environment by simply either packing the agent executable (something like Nimcrypt will do), removing unimportant pieces of code, restructuring the source-code, or by compiling the agents beforehand and adding extra flags to the syntax, such as the following:

`GOOS=windows GOARCH=amd64 go build -ldflags="-s -w"`

Researchers at JUMPSEC have also recently determined that, in at least several mature client environments, the creation of new network interfaces is not monitored. Therefore, should you find yourself wanting to deploy a Ligolo proxy server on a compromised machine (remember you don’t need admin permissions to deploy an agent but you do need it to deploy a proxy server!), and that it does not appear that monitoring is in place for tunnelling tools such as Ligolo by default, which makes it an attractive target when compared to existing C2 payloads. A note of caution however, EDRs may flag the “tunnelling” functionality when traffic is exchanged between the agent and the proxy.

![fry takemymoney](images/fry-takemymoney-300x300.png "fry takemymoney")

Once a successful connection has been established packets will be automatically (read automagically) routed to the intended target network, making it a seamless experience, and one that compares with the ease of which you would carry out operations in your own local network.

The agents can be easily modified and trivially executed by a Scheduled Task or a Cron Job for backdoor purposes or to establish persistence. When trying to achieve domain dominance on an engagement we found we were having to spend far less time in fixing or maintaining our foothold when compared to the usual routines of dealing with beacons, port forwarding and SSH tunnelling. Furthermore, we found that generally there are less restrictions in regards to the traffic we are allowed to generate and forward through.

As previously mentioned, another interesting capability of this tool is the possibility to create listeners on the agent themselves to chain connections as shown in the code block below.

```
[Agent : domain\Administrator@VICTIM] >> listener_add --addr <agent_ip>:11601 --to <proxyserver_ip>:11601
INFO[0326] Listener created on remote agent!
```

This behaviour is particularly useful when the proxy server’s IP address is out of reach for the last deployed agent, but connection can be established from the final pivoted box to the adjacent network running a previously deployed ligolo’s agent, allowing a pass-through connection back to our proxy server leveraged by the agent listener/forwarder.

Finally, some caveats to keep in consideration…Ligolo does not automatically recognise the subnets where traffic needs to be redirected to, therefore you will need to add your routes as you discover or need them, using something like “sudo ip route add 192.168.0.0/24 dev ligolo” on the proxy server’s host, and target’s nameservers to /etc/resolv.conf to use DNS instead of IP addresses in an internal network. Furthermore, do not expect your agents to automatically establish a tunnel when reconnecting to the proxy…an auto-connect feature needs to be developed in-house or wait for the feature to be released by the author. Finally, remember that when using it for client networks, you will need a publicly facing box reachable by the agents to listen for connections and execute commands from.

All in all, Ligolo enabled us to speed up our engagements, made our shells more stable and reliable, allowed for a larger and more comprehensive gathering of our targets data, and helped us spend less time maintaining an important part of our persistent operational infrastructure. Most importantly, it avoids the use of tooling on-disk or even in memory, as only the raw traffic leaves the compromised machine.

To conclude this blogpost, I just want to say (write) that we love Ligolo and we are very grateful to Nicolas Chatelain for creating this amazing instrument that we are proud to have in our day-to-day operational tool suite.

References

● The Cyber Plumber's Handbook - https://github.com/opsdisk/the\_cyber\_plumbers\_handbook

● Ligolo-ng - https://github.com/nicocha30/ligolo-ng

● Gvisor - https://gvisor.dev/

Alternatives to Ligolo-ng:

● Proxychains - https://github.com/haad/proxychains

● Proxychains-ng - https://github.com/rofl0r/proxychains-ng

● Chisel - https://github.com/jpillora/chisel

● SSHuttle - https://github.com/sshuttle/sshuttle
