---
title: "Hunting for 'Snake'"
date: "2023-05-26"
categories: 
  - "detection"
  - "jumpsec"
tags: 
  - "j"
author: "francescoiulio"
---

Following the NCSC and CISA’s detailed [joint advisory](https://www.cisa.gov/news-events/cybersecurity-advisories/aa23-129a) on the highly sophisticated ‘Snake’ cyber espionage tool, JUMPSEC threat intelligence analysts have provided a condensed blueprint for organisations to start proactively hunting for Snake within their network, contextualising key Indicators of Compromise (IoC), and providing additional methods to validate the effectiveness of Snake detections.

# Snake’s capabilities

The implant dubbed ‘Snake’ has been attributed to Centre 16 of Russia’s state sponsored FSB. The tool has been collecting intelligence in over 50 countries for up to 20 years, targeting research facilities, government networks, financial services, communications organisations, and other Critical National Infrastructure (CNI) organisations, meaning these organisations should be particularly vigilant and take precautionary steps to protect their networks.

Described by CISA as Centre 16’s “most sophisticated cyber espionage tool for long-term intelligence collection”, Snake typically targets and infects external facing infrastructure, with its ultimate aim to compromise domain controllers and administrator accounts, enabling attackers to gain widespread access and control within targeted networks.

Snake achieves these aims though a combination of several advanced technical features:

- A decentralised model - While the majority of malicious implants listen to and report back to a central node (i.e C2 or Command and Control Server) as part of a centralised infrastructure, Snake leverages a “decentralised” Peer-to-peer (P2P) network, supported by active implants residing on infected systems. As no centralised node acts as C2, commands and their output can be sent, received or retrieved all within the P2P network as nodes communicate with each other to route traffic and store information.
    
- Indistinguishable from legitimate traffic - FSB operators can ensure that all traffic to targeted machines follow the Snake custom HTTP protocol effectively blending with legitimate traffic when using a compromised HTTP server as part of the Snake P2P network.
    
- Numerous containerised tools and techniques – The implant conceals a plethora of tools, including network sniffers and keyloggers that can enable further compromise of target networks.
    
- Operating as a Kernel Driver (rootkit capabilities / kernel driver) – The aforementioned concealed techniques and tools can subsequently infect machines in Kernel Land while simultaneously leveraging active and passive operational mechanisms to achieve its aims.
    
- High degree of persistence – To achieve persistence Snake generally registers a service called "WerFaultSvc" that executes Snake's WerFault.exe located in "%windows%\\WinSxS\\", which decrypts Snake's components and loads them into memory.
    

The fact that Snake is state sponsored also adds additional resourcing capability, motivation, persistence and potential impact, making this a particularly potent threat given Russian efforts to influence political processes, conduct espionage, and disrupt critical infrastructure.

# How to detect Snake

There are numerous threat hunting techniques that can be deployed to detect Snake. However, depending on the type of infrastructure or response mechanisms your organisation has in place, certain techniques may prove more or less effective.

Here are some points to consider when prioritising how to detect Snake:

- **Host-Based Detection** - this type of detection is critical and should be performed regardless of the size of your enterprise. It is a high confidence set of rules, which are key to determining if any of Snake’s components are located on machines connected to the network.
    
- **Network based detection** – these type of detection rules could be particularly useful for large scale identification of Snake communication protocols. Ideal for enterprises using intrusion detection systems or firewalls that support Suricata rules deployment.
    
- **Memory Analysis** – Another technique to identify Snake is to investigate memory and see if it is executing at known locations. The CSA provides a useful Volatility plugin to perform this analysis. Unfortunately, this is less scalable and more time consuming, however, security researchers are developing alternatives that can help automating the process at larger scale.
    
- **Other Detection Mechanisms and Sigma Rules** – Sigma rules and Yara rules are being constantly developed as we write and will help speed up and automate the process of hunting for the FSB’s malware. These can often be integrated in SOC/SIEM as well as IR tooling.
    
- **Purple Team and Atomic Test Cases** – A highly efficient way of identifying and covering the detection gaps in your estate is to utilise a purple team approach, leveraging Atomic Red Team test cases which are being developed specifically for this implant.
    

JUMPSEC have detailed a number of implementable threat hunting detections which at risk organisations may wish to implement here at JUMPSEC Labs. We recommend using a combination of these approaches to effectively mitigate the threat and remove any reliance on a single point of failure.

**JUMPSEC have not exhaustively detailed each known technique. Additional hunting tools and techniques** **may continue to be developed and JUMPSEC is actively monitoring NCSC and CISA detections to identify** **opportunities where IoCs or TTPs can be leveraged.**

## Host-Based Detection

While effective, host-based detections are not without shortcomings within certain environments.

Host-based detections enable a high degree of confidence based on the totality of positive hits for host-based artifacts, however, many artifacts on the host are easily shifted to exist in a different location, or with a different name, as the files are fully encrypted and accurately identifying these files is difficult.

To combat these limitations JUMPSEC advises that host-based detection is integration with further manual analysis of positive hits.

Multiple Snake components can be detected running in the system using different Indicators of Compromise. For example, the Covert Store generated by the implant, can present the following hardcoded encryption key (not always, depending on the malware operator):

> A1 D2 10 B7 60 5E DA 0F A1 65 AF EF 79 C3 66 FA

And the same key can be retrieved from the following Windows Registry path when stored:

> SECURITY\\Policy\\Secrets\\n

Furthermore, the following initial 8-byte sequences are known to be used by NTFS or FAT-16 filesystems as observed:

> EB 52 90 4E 54 46 53 20
> 
> EB 5B 90 4E 54 46 53 20
> 
> EB 3C 90 4D 53 44 4F 53
> 
> EB 00 00 00 00 00 00 00

By encrypting each possible initial filesystem byte sequence with CAST-128 using the key obtained from the registry and searching for a file with a size that is an even multiple of 220, it is possible to efficiently detect Snake covert stores.

Another component is the **Registry Blob** which might appear in the Windows registry when searching for a value of at least 0x1000 bytes in size and a High entropy value of at least 7.9. However, it can typically be found using the following information when its values are left as default:

**Name:** Unknown (RegBlob)

**Registry Path:** HKLM\\SOFTWARE\\Classes\\.wav\\OpenWithProgId

**Characteristics:** High Entropy

Additionally, Snake’s Queue File can be located leveraging a file-system search with a Regular Expression together with searching for High Entropy files using the Yara Rule listed further below. Typically the Queue File can be found with the following information:

**Typical Name:** < RANDOM\_GUID >.<RANDOM\_GUID>.crmlog

**Typical Path:** %windows\\registration\\

**Unique Characteristics:** High Entropy, file attributes of hidden, system, and archive

**Role:** Snake Queue File

The following Yara rule (named 1.yar) can be used in conjunction with the subsequently listed UNIX and PowerShell commands to detect instances of the Snake Queue FIle:

1.yar

```
rule HighEntropy
{
    meta:
        description = "entropy rule"

    condition:
        math.entropy(0, filesize) >= 7.0
}

```

UNIX command:

```
find /PATH/TO/WINDOWS_DIR -type f -regextype posix-egrep -iregex \
    '.*\/registration/(\{[0-9A-F]{8}\-([0-9A-F]{4}\-){3}[0-9A-F]{12}\}\.){2}crmlog' \
     -exec yara 1.yar {} \;

```

PowerShell command:

```
Get-ChildItem -Recurse -File -Path %WINDOWS% | Where-Object {
  $_.FullName -match
  '(?i)/registration/(\{[0-9A-F]{8}\-([0-9A-F]{4}\-){3}[0-9A-F]{12}\}\.){2}crmlog$'
} | ForEach-Object {
  yara 1.yar $_.FullName
}

```

Moreover, we can use the Yara rules with the last two components that might indicate the malware running on the host machine: comadmin and werfault.

Comadmin can be detected using the following information and the previously mentioned Yara rule (1.yar):

**Name:** comadmin.dat

**Path:** %windows%\\system32\\Com

**Unique Characteristics:** High Entropy

**Role:** Houses Snake’s kernel driver and the driver’s loader

Leveraging the previously stated Yara rule (1.yar) we can use the following UNI or PowerShell commands:

UNIX

```
find /PATH/TO/WINDOWS -type f -regextype posix-egrep -iregex \
    '.*\/system32/Com/comadmin\.dat' \
     -exec yara 1.yar {} \;

```

PowerShell

```
Get-ChildItem -Recurse -File -Path %WINDOWS% | Where-Object {
    $_.FullName -match '(?i)/system32/Com/comadmin\.dat$'
} | ForEach-Object {
    yara 1.yar $_.FullName
}

```

On the other end, the Werfault executable can be retrieved due to its use of non-standard icon-size and by using the information and the Yara rule stated below:

**Name:** Werfault.exe

**Path:** %windows%\\WinSxS\\x86\_microsoft-windows-errorreportingfaults\_31bf3856ad364e35\_4.0.9600.16384\_none\_a13f7e283339a0502\\

**Unique Characteristics:** Icon is different than that of a valid Windows Werfault.exe file

**Role:** Persistence mechanism

```
rule PeIconSizes
{
    meta:
        description = "werfault rule"

    condition:
        pe.is_pe 
        and 
        for any rsrc in pe.resources:
            (rsrc.type == pe.RESOURCE_TYPE_ICON and rsrc.length == 3240)
        and
        for any rsrc in pe.resources:
            (rsrc.type == pe.RESOURCE_TYPE_ICON and rsrc.length == 1384)
        and
        for any rsrc in pe.resources:
            (rsrc.type == pe.RESOURCE_TYPE_ICON and rsrc.length == 7336)
}

```

Several tools can be used for the above-mentioned rules. Often SOC/SIEM platforms offer capabilities to automate this process once a blueprint of the hunt has been developed and integrated.

If you currently don't have any detection and response tooling, we recommend deploying one of the excellent open-source tools available online (we regularly use [Velociraptor](https://github.com/Velocidex/velociraptor)) to perform a hunt in your estate can integrate well with host-based hunting, allowing you to identify and respond to threats in conjunction with the techniques and rules mentioned above.

## Network-based Detection

Network-based detection enables high-confidence for large-scale (network-wide) detection of custom Snake communication protocols. However, there is low visibility of Snake implant operations and encrypted data in transit.  Snake http, http2, and tcp signatures also potentially produce false positives and Snake operators can easily change network-based signatures.

To counteract this, JUMPSEC recommend implementing Suricata rules to your NIDS appliances the following rules will enable you to detect http, http2 and tcp communication as leveraged by the implant. Further details can also be found within the [advisory](https://www.cisa.gov/news-events/cybersecurity-advisories/aa23-129a).

### Snake http rule

The following RegEx can be used to build rules matching the http and http2 traffic contained within the HTTP header field.

```
^[0-9A-Za-z]{10}[0-9A-Za-z/\+]{11}=
```

Which can be used in a Suricata rule as follows:

```
alert http any any -> any any (msg: "http rule (Cookie)";\
    pcre:"/[0-9A-Za-z]{10}[0-9A-Za-z\/\+]{11}=/C";\
    flow: established, to_server;\
    sid: 7; rev: 1;)
alert http any any -> any any (msg: "http rule (Other Header)";\
    pcre:"/[0-9A-Za-z]{10}[0-9A-Za-z\/\+]{11}=/H";\
    flow: established, to_server;\
    sid: 8; rev: 1;)

```

### Snake http2 rule

For http2, the implant’s header is encoded using base62 with non-extraneous characters. The following RegEx should be able to identify matches of such a header:

```
      ^[0-9A-Za-z]{22}[0-9A-Za-z/;_=]{11}
alert http any any -> any any (msg: "http2 rule (Cookie)";\
    pcre:"/[0-9A-Za-z]{22}[0-9A-Za-z\/_=\;]{11}/C";\
    flow: established, to_server;\
    sid: 9; rev: 1;)
alert http any any -> any any (msg: "http2 rule (Other Header)";\
    pcre:"/[0-9A-Za-z]{22}[0-9A-Za-z\/_=\;]{11}/H";\
    flow: established, to_server;\
    sid: 10; rev: 1;)

```

### Snake tcp rule

The following rule helps capture the signature set during the client-to-server communication for tcp, which usually starts with “ustart”, as well as subsequent data flows that match the malware’s behaviour.

```
alert tcp any any -> any any (msg: "tcp rule";\
    content: "|00 00 00 08|"; startswith; dsize: 12;\
    flow: established, to_server; flowbits: set, a8; flowbits: noalert;\
    sid: 1; rev: 1;)
alert tcp any any -> any any (msg: "tcp rule";\
    content: "|00 00 00 04|"; startswith; dsize:8;\
    flow: established, to_server; flowbits: isset, a8; flowbits: unset, a8;\
    flowbits: set, a4; flowbits: noalert;\
    sid: 2; rev: 1;)
alert tcp any any -> any any (msg: "tcp rule";\
    content: "|00 00 00 08|"; startswith; dsize: 4;\
    flow: established, to_client; flowbits: isset, a4; flowbits: unset, a4;\
    flowbits: set, b81; flowbits: noalert;\
    sid: 3; rev: 1;)
alert tcp any any -> any any (msg: "tcp rule";\
    dsize: 8; flow: established, to_client; flowbits: isset, b81;\
    flowbits: unset, b81; flowbits: set, b8; flowbits: noalert;\
    sid: 4; rev: 1;)
alert tcp any any -> any any (msg: "tcp rule";\
    content: "|00 00 00 04|"; startswith; dsize: 4;\
    flow: established, to_client; flowbits: isset, b8; flowbits: unset, b8;\
    flowbits: set, b41; flowbits: noalert;\
    sid: 5; rev: 1;)
alert tcp any any -> any any (msg: "tcp rule";\
    dsize: 4; flow: established, to_client; flowbits: isset, b41;\
    flowbits: unset, b41;\
    sid: 6; rev: 1;)

```

## Memory Analysis

Memory analysis also enables a high degree of detection confidence as memory provides the greatest level of visibility into Snake’s behaviour and artifacts. However, it has the potential to impact system stability, is difficult to scale, and can be a time-consuming process.

The joint advisory suggests the following as the most effective approach to detect the implant on an infected host and it provides a script to be used alongside Volatility and a memory dump of the target infected machine.

```
# This plugin to identify the injected usermode component of Snake is based 
# on the malfind plugin released with Volatility3
#
# This file is Copyright 2019 Volatility Foundation and licensed under the 
# Volatility Software License 1.0
# which is available at https://www.volatilityfoundation.org/license/vsl-v1.0
import logging
from typing import Iterable, Tuple
from volatility3.framework import interfaces, symbols, exceptions, renderers
from volatility3.framework.configuration import requirements
from volatility3.framework.objects import utility
from volatility3.framework.renderers import format_hints
from volatility3.plugins.windows import pslist, vadinfo
vollog = logging.getLogger(__name__)
class snake(interfaces.plugins.PluginInterface):
    _required_framework_version = (2, 4, 0)
    
    @classmethod
    def get_requirements(cls):
        return [
            requirements.ModuleRequirement(name = 'kernel', 
            description = 'Windows kernel', 
            architectures = ["Intel32", "Intel64"]),
            requirements.VersionRequirement(name = 'pslist', 
            component = pslist.PsList, version = (2, 0, 0)),
            requirements.VersionRequirement(name = 'vadinfo', 
            component = vadinfo.VadInfo, version = (2, 0, 0))]

    @classmethod
    def list_injections(
            cls, context: interfaces.context.ContextInterface, 
            kernel_layer_name: str, symbol_table: str,
            proc: interfaces.objects.ObjectInterface) -> Iterable[
            Tuple[interfaces.objects.ObjectInterface, bytes]]:
        proc_id = "Unknown"
        try:
            proc_id = proc.UniqueProcessId
            proc_layer_name = proc.add_process_layer()
        except exceptions.InvalidAddressException as excp:
            vollog.debug("Process {}: invalid address {} in layer {}".
            format(proc_id, excp.invalid_address, excp.layer_name))
            return
        proc_layer = context.layers[proc_layer_name]
        for vad in proc.get_vad_root().traverse():
            protection_string = vad.get_protection(vadinfo.VadInfo.
            protect_values(context, kernel_layer_name, symbol_table), 
            vadinfo.winnt_protections)
            if not "PAGE_EXECUTE_READWRITE" in protection_string:
                continue

            if (vad.get_private_memory() == 1
                    and vad.get_tag() == "VadS") or (vad.get_private_memory() 
                    == 0 and protection_string != 
                    "PAGE_EXECUTE_WRITECOPY"):
                data = proc_layer.read(vad.get_start(), 
                vad.get_size(), pad = True)
                if data.find(b'\x4d\x5a') != 0:
                    continue
                yield vad, data

    def _generator(self, procs):
        kernel = self.context.modules[self.config['kernel']]
        is_32bit_arch = not symbols.symbol_table_is_64bit(self.context, 
        kernel.symbol_table_name)
        for proc in procs:
            process_name = utility.array_to_string(proc.ImageFileName)
            for vad, data in self.list_injections(self.context, 
            kernel.layer_name, kernel.symbol_table_name, proc):
                strings_to_find = [b'\x25\x73\x23\x31',b'\x25\x73\x23\x32',
                b'\x25\x73\x23\x33',b'\x25\x73\x23\x34', 
                b'\x2e\x74\x6d\x70', b'\x2e\x73\x61\x76',
                b'\x2e\x75\x70\x64']
                if not all(stringToFind in data for 
                stringToFind in strings_to_find):
                    continue
                yield (0, (proc.UniqueProcessId, process_name, 
                format_hints.Hex(vad.get_start()),
                           format_hints.Hex(vad.get_size()),
                           vad.get_protection(
                               vadinfo.VadInfo.protect_values(self.context, 
                kernel.layer_name, kernel.symbol_table_name), 
                vadinfo.winnt_protections)))
                return

    def run(self):
        kernel = self.context.modules[self.config['kernel']]
        return renderers.TreeGrid([("PID", int), ("Process", str), 
        ("Address", format_hints.Hex), ("Length", format_hints.Hex), 
        ("Protection", str)], self._generator(pslist.PsList.list_processes(
        context = self.context, layer_name = kernel.layer_name,  
        symbol_table = kernel.symbol_table_name)))

```

Security researchers are currently developing detections and rules to speed up the memory analysis process. For example, Matt Suiche, Director of Incident Response R&D at Magnet Forensics (MAGT:TO), has recently developed a [YARA rule](https://gist.github.com/msuiche/8c8fd278430dda0292b4cfdfc549ca2d) based on the above Volatility plugin to look into memory and identify snake.

## Other Detection Mechanisms and Sigma Rules

Researchers at the open-source project SigmaHQ have also started developed rules that will help hunt for the malware and detect when it performs malicious operations in the network which can be found [here](https://github.com/SigmaHQ/sigma/pull/4231/files).

As of now, the rules currently developed include:

- SNAKE Malware Kernel Driver File Indicator
    
- Malware Installer Name Indicators
    
- Malware WerFault Persistence File Creation
    
- Potential SNAKE Malware Installation CLI Arguments Indicator
    
- SNAKE Malware Installation Binary Indicator
    
- Potential SNAKE Malware Persistence Service Execution
    
- SNAKE Malware Covert Store Registry Key
    
- Potential Encrypted Registry Blob Related To SNAKE Malware
    
- SNAKE Malware Service Persistence
    

Should a different set of rules be needed for your specific EDR or SOC/SIEM it is possible to utilise the extremely helpful open-source resource [Uncoder](https://uncoder.io/) to convert rules.

# Long-term prevention

If you believe your organisation is at risk, JUMPSEC recommends building an Incident Response Plan and a dedicated team to monitor and effectively respond to the threats posed by Snake, in order to meaningfully utilise and validate the detection techniques outlined above.

To ensure that implemented detections are effective JUMPSEC recommends:

- Using Atomic Red Team and Purple Team approaches to ingest and execute techniques used by Snake in your network to identify gaps in detection capabilities. For Purple Team Testing, security researchers at Red Canary have already started developing open-source Atomic Red Team test cases to simulate Snake which can be found [here](https://github.com/redcanaryco/atomic-red-team/pull/2418).
    
- Actively hunting for Snake malware using endpoint and network detection tooling. Third party security providers such as JUMPSEC can assist with deployment and integration with existing detection and response platforms to monitor and prioritise critical instances of malicious activity.
    
- Deploying Canary Tokens in your estate where possible. Canary Tokens can serve as early warning systems as part of your organisations broader security strategy.
    
- Ensuring you have an adequate incident response plan that is ready to deploy. This may include baselining or reviewing existing response processes and procedures. In the event that a Snake is identified, incident response plans can be triggered, affected hosts quarantined, back-up systems deployed, and any other steps deemed necessary to secure the environment can be taken.
    

Additionally, Snake typically achieves network intrusion by exploiting vulnerable, publicly available infrastructure via targeted phishing and social engineering campaigns, meaning that organisations should rigorously review potential vulnerabilities in externally facing assets.

## MFA and credential management

As an FSB espionage tool gathering credentials for up to 20 years, JUMPSEC would additionally echo that organisations who have not already embedded standard best practice when it comes to MFA and credential management should implement appropriate measures. For example:

- Change account credentials to values which cannot be brute forced or guessed based on old passwords, requiring minimum password strengths and unique credentials for every account.
    
- Use appropriate role separation, account permissions and separate user and privileged accounts.
    
- Implement phishing-resistant MFA or go passwordless if possible (Biometrics and FIDO2 keys).
    
- Deploy digitally signed Security.txt files to all public facing web domains which conform to the recommendations in RFC 9118.
    

As a final note, JUMPSEC recommend reporting any Indicators of Compromise (IoCs) to the relevant authorities (NCSC for UK based organisations), as well as the wider security community where appropriate.

## Helpful Links

- CISA Advisory - https://www.cisa.gov/sites/default/files/2023-05/aa23-129a\_snake\_malware\_1.pdf
- RFC 9118 - https://datatracker.ietf.org/doc/rfc9118/
- Canary Tokens - https://canarytokens.org/generate
- Guide to setup security.exe - https://securitytxt.org/
- Mitre - https://attack.mitre.org/
- SigmaHQ rules - https://github.com/SigmaHQ/sigma
