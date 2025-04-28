---
title: "Red Teaming the Cloud: A Shift in Perspective"
date: "2023-12-19"
categories: 
  - "jumpsec"
author: "Max Corbridge"
excerpt: "Having delivered entirely cloud red teams, JUMPSEC experts discuss the shifts in perspective necessary for red teamers when targeting cloud environments."
---

**Introduction**

Cloud adoption is exploding, and rightfully so. Businesses are seeing the value of improved agility and efficiency when leveraging public cloud, resulting in 60% of all corporate data globally being stored in the cloud in 2022. As such, securing the cloud is becoming an increasingly important skill for defensive security teams, ergo red teaming the cloud is becoming increasingly important for us offensive security teams too.

Whilst on-premise red teaming is a rich, documented and well-understood topic, cloud red teaming is still in its infancy. This blog post will highlight some of the biggest differences between on-premise and cloud red teaming, and how red teamers must shift their perspective in the newest security frontier: the cloud. 

**Initial Compromise**

One element that remains the same from on-premise to the cloud is that almost all attack paths start with the initial compromise of ‘something’ in the target environment. In fact, that ‘something’ remains largely unchanged: staff members, externally facing assets and exposed data. The first major difference is the end-goal after having achieved this initial compromise: whilst traditional red teaming would see you introduce malware, such as a C2 implant in most cases, cloud red teaming often focuses on obtaining a target’s access tokens or credentials. 

Access ‘tokens’ in Azure or ‘keys’ in AWS both serve the purpose of allowing remote attackers to begin interacting with the cloud estate via portals or APIs, which is where much of the battle will be fought. Whilst this can indeed be obtained through remote code execution (RCE) on a machine in most cases, there are alternative (usually easier) methods such as google dorking for leaked keys or social engineering targeting authentication flows.

**Getting to your goal**

In traditional on-premise environments, attackers seek to obtain credentials and exploit vulnerabilities to move laterally and escalate privileges within the local network. Lateral movement and privilege escalation often involves techniques like credential dumping, exploiting misconfigurations and taking control of increasingly privileged machines and user accounts. Persistence often involves the deployment of malware and mechanisms to keep them alive. 

In cloud environments, the focus shifts towards the compromise of identities, which means attackers primarily aim to compromise user accounts or service principal identities in the target tenant. Many traditional on-premise attack vectors that rely on local network access are not applicable in cloud red teaming scenarios.

In this case, privilege escalation and persistence can be achieved by compromising other cloud-based identities and their associated permissions. In our experience, whilst many traditional on-premise attack paths require obtaining ‘superuser’ (namely domain administrator) permissions, this is not as often the case in the cloud. We believe this is due to the complexity of, and thereby lack of familiarity with, cloud-based access control permissions leading to access control gaps arising more often. With vendors rightfully advertising least privilege and zero-trust architectures, roles can be assigned with far more granularity. However, with granularity comes greater complexity and administrators sometimes (often) refrain from diving into the documentation to truly understand the permissions needed, resulting in overly permissive accounts.

Crucially, one of the biggest differences between on-premise and cloud here is that we are typically looking to abuse default configurations or ‘abuse primitives’, as opposed to finding exploits in the cloud platform. The many reasons why this is the case is beyond the scope of this blog post, but an incredibly interesting topic for discussion. Finally, internal phishing using cloud services is often used to gain elevated privileges and, in our experience, used much more often than in on-premise engagements.

**Mining for Data**

Data gathering is crucial and still prevalent in both on-premise and cloud engagements. However, the places and the means change substantially. File storage and database servers that were previously secured behind a corporate firewall may now be left exposed due to misconfigurations, resulting in an accidental reliance on ‘security through obscurity’ for business-critical assets and data. Attackers who have phished the right user account may end up connecting to cloud resources from anywhere in the world. Gone are the days when a VPN connection was necessary to reach critical internal resources, as cloud platforms expose their logins and APIs publicly. With a single authentication to cloud platforms an adversary has a foothold in the target cloud environment and all its offerings.

In response to the evolving landscape of data storage, exchange and security, new methods for extracting sensitive data are emerging. Attackers are increasingly abusing vendor APIs for reconnaissance purposes, as exemplified by the Microsoft Graph API. Only recently we were made aware of a technique using text-to-speech immersive reading features to retrieve and ‘read out’ credential material you should not have access to! Yet again this shows how common features can be exploited, and underscores the need for heightened vigilance in this space. Additionally, we have seen Artificial Intelligence (AI) being trained on the target’s internal blueprints, documents, email exchanges and instant messaging logs to make informed decisions about potential targets within an organisation, whether they are humans, or machines. This raises concerns about the evolving sophistication of cyberattacks and the need to stay ahead as red teamers.

**Conclusion**

The cloud’s shared responsibility model has changed the security landscape, as customers cannot assess the security of the systems hosting their data from the ground-up anymore. In many cases, cloud providers leave them to develop the knowledge required to be able to securely administer cloud services, and by doing so open the door for myriad cloud misconfigurations.

As we at JUMPSEC gain more experience with cloud red teaming we have come to appreciate the major, and minor, shifts in perspective that are necessary when targeting cloud environments. Gone are the days of being highly exploit-centric red teamers, when the success in cloud environments can, in large part, come down to the understanding and abuse of cloud configurations and functionality. Whilst ‘popping shells’ will never lose its novelty, it is often less impactful than going after key identities within the cloud environment. However, what really excites us is the knowledge that there remains so much to explore and evolve in cloud red teaming. It is for this reason that we are dedicating so much time and energy to stay ahead in this burgeoning area of offensive security.
