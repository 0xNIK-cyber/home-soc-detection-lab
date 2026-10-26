# home-soc-detection-lab
Home SOC lab simulating a small company (NovaTech): Active Directory domain with department OUs, audit GPOs, Sysmon and Splunk Universal Forwarder feeding a Splunk SIEM on Ubuntu. Built to practice log collection, Windows event analysis and detection engineering.



# NovaTech Home SOC Lab

A home lab that simulates the IT environment of a small company, **NovaTech**: an Active Directory domain with department workstations, centralized Windows logging and a Splunk SIEM. I built it to practice the day-to-day work of a SOC analyst: collecting logs, understanding Windows events, troubleshooting a logging pipeline and writing detections.

> **Status:** in progress. The domain, audit policy and log pipeline are live. Finance and HR workstations and detection use cases are next (see [Roadmap](#roadmap)).

---

## Lab inventory

| Host | Role | IP | OS |
|---|---|---|---|
| **SPLUNK01** | SIEM (Splunk Enterprise 10.6) | 10.10.10.20 | Ubuntu Server 26.04 |
| **DC01** | Domain controller: AD DS, DNS, GPO, file shares | 10.10.10.10 | Windows Server 2022 |
| **IT-WS01** | IT department workstation | 10.10.10.101 | Windows 11 Pro |
| FIN-WS01 | Finance workstation *(planned)* | 10.10.10.102 | Windows 11 Pro |
| HR-WS01 | HR workstation *(planned)* | 10.10.10.103 | Windows 11 Pro |

- **Hypervisor:** VirtualBox on a 32 GB laptop
- **Network:** isolated NAT Network `10.10.10.0/24`, static IPs, no DHCP
- **Domain:** `novatech.local`, with a reverse lookup zone for IP-to-host resolution in investigations
- **Time:** all hosts in one time zone and synced via NTP, so events can be correlated in the SIEM

## Architecture

```
            DC01 (AD, DNS, GPO)          IT-WS01 (Windows 11)
            Security / System logs       Security / System logs
            Sysmon                       Sysmon
                 │                            │
                 └──── Splunk Universal Forwarder (TCP 9997) ────┐
                                                                 ▼
                                                    SPLUNK01 (Splunk Enterprise)
                                                    index=wineventlog
                                                    index=sysmon
```

## What is built

### Active Directory
- OU structure per department: `NovaTech → IT / Finance / HR`, each with `Users`, `Computers` and a security group `GRP-<Dept>`
- Fictional employees and a **separate admin account** for the IT administrator (daily account vs. privileged account)
- Department file shares (`\\DC01\Finance`, `\\DC01\HR`, `\\DC01\IT`) with NTFS permissions limited to the department group (least privilege)
- Synthetic data: a fake client list in Finance and an employee list in HR, generated with PowerShell
- Domain password policy: minimum 12 characters, complexity, account lockout after 5 failed attempts

### Audit policy (GPO `NovaTech-Audit-Policy`)
By default Windows logs very little. Advanced Audit Policy is enabled domain-wide:

| Subcategory | Setting | Key Event IDs |
|---|---|---|
| Logon | Success, Failure | 4624, 4625 |
| Special Logon | Success | 4672 |
| Credential Validation | Success, Failure | 4776 |
| Kerberos Authentication Service | Success, Failure | 4768, 4771 |
| Kerberos Service Ticket Operations | Success, Failure | 4769 |
| User Account Management | Success, Failure | 4720, 4722, 4724, 4738 |
| Security Group Management | Success, Failure | 4728, 4732 |
| Account Lockout | Failure | 4740 |
| Process Creation (with command line) | Success | 4688 |
| File Share / File System | Success, Failure | 5140 / 4663 |
| Audit Policy Change | Success | 4719 |

Also: "Force audit policy subcategory settings" enabled, command line logging in 4688, Security log size 512 MB, and SACL auditing on the Finance and HR folders so file access generates 4663.

### Logging pipeline
- **Sysmon** with the community config by Olaf Hartong (`sysmon-modular`), mapped to MITRE ATT&CK
- **Splunk Universal Forwarder** on every Windows host, sending Security and System logs to `index=wineventlog` and Sysmon to `index=sysmon`
- **Splunk Add-on for Microsoft Windows** and **Splunk Add-on for Sysmon** for field extraction and CIM mapping
- Splunk runs under a dedicated non-root service account

## Example searches

```spl
index=wineventlog EventCode=4624
| stats count by user, Logon_Type, src
| sort -count
```

```spl
index=sysmon EventCode=1
| table _time host User Image CommandLine ParentImage Hashes
```

```spl
index=wineventlog EventCode=7045
| table _time host Service_Name Service_File_Name
```

## Lessons learned

Real problems I hit while building the lab and how I solved them:

- **Audit GPO configured but not applied.** The settings were saved in SYSVOL (`audit.csv`), but `auditpol` showed "No Auditing". I checked layer by layer: `gpresult` (GPO applied), SYSVOL (settings present), then the GPO attribute `gPCMachineExtensionNames`. The Audit Policy client-side extension `{F3CCC681-...}` was missing because an edit was interrupted by a VM freeze. Re-saving one setting in the GPO editor registered the extension, and `gpupdate /force` applied it.
- **SIEM clock drift.** After the Splunk VM had been in saved state, its clock was ~17 hours behind, so "Last 24 hours" searches were wrong. Ubuntu 26.04 uses chrony, so I fixed it with `timedatectl` and `chronyc makestep`. Time sync matters for event correlation and for Kerberos.
- **Splunk 10 does not run as root.** I created a dedicated `splunk` service account, gave it ownership of `/opt/splunk` and configured boot-start with that user.
- **Forwarder restart failed right after a silent install** because the service was still starting. I added a short delay before the restart in the install script.
- **Noise and secrets in logs.** Most early Sysmon process events came from the Splunk forwarder itself (to be tuned), and some command lines contained passwords in plain text. Command-line logging can expose secrets.

## Lab simplifications

This is a lab, not production. Known shortcuts:
- One shared password for the fictional lab users
- The Universal Forwarder runs as Local System
- File shares are hosted on the domain controller instead of a separate file server

## Repository structure

```
scripts/       PowerShell used to build the environment (OUs, users, shares, policies, Sysmon, forwarder)
docs/          GPO report and audit policy export
screenshots/   Splunk searches, AD structure, audit policy
```

## Roadmap

- [x] SIEM server, domain controller, audit policy, log pipeline
- [x] First workstation joined to the domain and forwarding logs
- [ ] Finance and HR workstations
- [ ] Sysmon noise tuning
- [ ] Detection use cases mapped to MITRE ATT&CK, with Splunk searches and Sigma rules
- [ ] Splunk dashboards
- [ ] Short investigation write-ups for each use case

---

**Author:** Nikita Onishchuk · [LinkedIn](https://www.linkedin.com/in/nikita-onishchuk)

*All data in this lab is fictional. The lab runs in an isolated virtual network.*
