# Kali_Setup_Script
This script can be used to configure Kali Linux to be production ready for ITHC use. On first launch, the script will update the system via apt, and therein on each use if the last update was over 7 days prior. Next, you can use the menu system to install packages, clone git repositories, and configure useful services such an a Pure-FTPd server.

## Packages
The following packages will be installed by default:

* atftp
* bloodhound
* cherrytree
* crackmapexec
* crowbar
* exploitdb
* gedit
* gobuster
* htop
* httptunnel
* ipcalc
* kerberoast
* metasploit-framework
* mingw-w64
* nishang
* odat
* powercat
* powershell-empire
* pure-ftpd
* rinetd
* rsh-client
* rusers
* screenfetch
* seclists
* shellter
* veil
* wine
* xsltproc

To add more packages, add them to the *packages* file.

## Git Repositories
The following repositories will be cloned locally on your system:

* nmapAutomator: https://github.com/21y4d/nmapAutomator.git
* nosqlmap: https://github.com/codingo/NoSQLMap.git
* Reconnoitre: https://github.com/codingo/Reconnoitre.git
* baron_samedit_ubuntu_debian https://github.com/blasty/CVE-2021-3156.git
* baron_samedit_redhat_centos https://github.com/worawit/CVE-2021-3156
* juicy_potato: https://github.com/ohpe/juicy-potato.git
* libssh-0.8.3_Authentication_Bypass: https://github.com/hackerhouse-opensource/cve-2018-10933.git
* lovely_potato_(automating_juicy_potato): https://github.com/TsukiCTF/Lovely-Potato.git
* ms08-067: https://github.com/andyacer/ms08_067.git
* ms17-010_Eternal_Exploits: https://github.com/worawit/MS17-010.git
* ssh_badkeys: https://github.com/rapid7/ssh-badkeys.git
* ssh_debian: https://github.com/g0tmi1k/debian-ssh.git
* x11_remote_desktop: https://github.com/sensepost/xrdp.git
* linEnum: https://github.com/rebootuser/LinEnum.git
* linux_exploit_suggestor: https://github.com/mzet-/linux-exploit-suggester.git
* linux_exploit_suggestor_2: https://github.com/jondonas/linux-exploit-suggester-2.git
* linux_priv_checker: https://github.com/sleventyeleven/linuxprivchecker.git
* linux_smart_enumeration: https://github.com/diego-treitos/linux-smart-enumeration.git
* mimipenguin: https://github.com/huntergregal/mimipenguin.git
* powershell_script_encoder: https://github.com/darkoperator/powershell_scripts.git
* privilege_escalation_awesome_scripts_suite: https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite.git
* pspy: https://github.com/DominicBreuker/pspy.git
* windows_privesc_check: https://github.com/pentestmonkey/windows-privesc-check.git
* windows_sysinternals: https://github.com/Sysinternals/sysinternals.git

If you read the repositories file, you will note that in the middle of each line there is a category. This is to assist with sorting the repositories on your local file system when you clone them. The categories by default are:

* 1.OSINT
* 2.Scanning
* 3.Exploitation
* 4.Post_Exploitation
* 5.Exploit_Development
* 6.Custom_Tools

You can edit the repositories as required, but ensure that you adhere to the following syntax:

```
repo_name category url
```

In all sections ensure that there are no spaces, as the spaces between them act as a delimiter within the script itself. Adding additional spaces in any individual section of your entry will result in failure to clone.

## WIP
This script is still being actively worked on. Whilst some modest debugging has taken place, there are likely to be a few snags here and there - if you find any, let me know!
