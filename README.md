# sptables

Pure Iptables firewall for servers

sptables is a basic pure Iptables firewall for servers that also comes with Docker compatibility. sptables includes example pure Iptables rules and patterns against some known attacks. 
Actually, sptables consists of Iptables, Ipset, Sysctl configuration files and start, stop, reload, save scripts with a Systemd unit file.

Standalone mode properties:

* Well-commented pure Iptables rules
* Build a basic but powerful firewall
* Pre-defined protection patterns and examples included
* DoS/DDoS mitigation, connection limiting, port scanning protection, ping limitation, port knocking patterns implemented in pure Iptables
* Iptables rules utilising IPset denylist with timeout
* Bare Iptables with no daemons continuously running
* A basic sysctl hardening configuration is also included

Docker mode properties:

* Utilise the documented DOCKER-USER chain for Docker compatibility
* Let Docker continue managing iptables
* Same filters apply for host and Docker containers

## Requirements

* Iptables
* IPset
* Systemd
* Root permissions

Tested on Debian Stretch (Requirements are already present)
Installation file tested on Debian Stretch, Ubuntu 17, CentOS 7
With manual installation, sptables can be used even without Systemd.

## Optional

* Docker 17.06 or later

## Installation

* Now, the installation script builds a basic but powerful firewall out of the box, but please read instructions before enabling the firewall.

* Previous versions are not compatible with version 4. Please uninstall older version before installing version 4. (See the Uninstallation section below)

* Installation requires root permission. (You can use sudo)

* Clone from github and run the installation script.

```
	$ git clone https://github.com/vkucukcakar/sptables.git	
	$ cd sptables
	$ ./install.sh
```
		
* Edit configuration files at "/etc/sptables/conf/*". 
  
  Edit "/etc/sptables/conf/iptables.conf" and "/etc/sptables/conf/iptables.conf" according to your server configuration before starting or enabling sptables.
  
  The installation script will try to find out default network interface name and replace "eth0" with default network interface name in Iptables configuration files mentioned above.
  
  The default rules will allow any outgoing packets and disallow any incoming packets except for ports 22,80,443 (SSH, HTTP, HTTPS).
    
  There are various connection limits implemented for the ports allowed.
  
  Please see the well-commented iptables configuration files mentioned above.
  
* Start the service for testing. The service will not survive after reboot.

  Note that, with default settings, the firewall will immediately lock you out if you are connected to ssh with a different port instead of port 22. Just reboot if something goes wrong.
```
	$ systemctl start sptables
```
* You can add your ssh IP address to allowlist to bypass rules and not lock yourself out of your own server in the fuuture.
```  
	$ ipset add allowlist 192.168.1.2
```
* Test the firewall for a while. After making sure everything is okay, you can permanently enable the service (See usage below)
```
	$ systemctl enable sptables
```
	
## Manual Installation

If ./install.sh does not work out of the box, please check if requiremets are installed successfully. You can optionally check command paths in ./install.sh.

If you do not have Systemd and you want to use sptables without Systemd, you can try manual installation.
To manually install sptables, copy the files under files/* to /etc/sptables/*, give /etc/sptables/*.sh execute permission, and call these scripts after editing configurations.

## Uninstallation

* Stop and disable the service
```
	$ systemctl stop sptables
	$ systemctl disable sptables
```	
* You can try manually stopping if Systemd is not used
```
	$ /etc/sptables/stop.sh
```	
* Rename old sptables directory (You can delete all settings and IP sets later with "rm -r" if you wish)
```
	$ mv /etc/sptables /etc/sptables.backup
```

## Usage

* Start service
```
	$ systemctl start sptables
```
* Restart service
```
	$ systemctl restart sptables
```
* Reload service (Reload just restores IP sets and sysctl configuration. Use restart to apply new Iptables configuration)
```
	$ systemctl reload sptables
```
* Get service status
```
	$ systemctl status sptables
```	
* Stop service
```
	$ systemctl stop sptables
```
* Enable service start on boot
```
	$ systemctl enable sptables
```
* Disable service start on boot
```
	$ systemctl disable sptables
```
* Manually save current sets without restarting service
```
	$ /etc/sptables/save.sh
``` 
## Details

### Configuration Files

Configuration files are at copied at location /etc/sptables/conf/* on installation.

* /etc/sptables/conf/iptables.conf			: Well commented Iptables configuration file. 
  You must edit this file to tune it for your server before starting or enabling sptables. (Open ports, define limits etc...)
  This file is the heart of the firewall and contains example patterns, that you should edit according to your needs!
* /etc/sptables/conf/sysctl.hardening.conf	: Sysctl hardening file.
  You can edit this file according to your needs. Some options directly affect iptables modules like conntrack etc...
* /etc/sptables/conf/ipset.conf				: IPset configuration file that creates the four pre-defined sets explained below. You usually have nothing to do with this file unless you need to create other custom sets.

### Iptables Rules

By default, two filter chains are available INPUT-FILTERS and OUTPUT-FILTERS in iptables configuration which filter both host and container packets. 
There are example rules well-commented and mostly self explanatory which you can edit according to your needs.
Basically you just need to check up or edit "INPUT FILTERS" and "OUTPUT FILTERS" sections in the file unless you do not want to change the structure.

### Pre-defined IP Sets

sptables have 6 pre-defined IP sets:
* "allowlist"	: Manually filled allowlist to bypass filters by default. (You should add your ssh IP address here to not lock yourself out of your server.)
* "denylist"	: Manually filled IP denylist
* "proxylist"	: Trusted proxylist to bypass filters for certain ports. (Intended to be filled manually or automatically with trusted reverse proxy / CDN IP addresses)
* "seclist"		: Search engine crawler list to bypass filters for certain ports. (Intended to be filled manually or automatically with trusted crawler/search engine IP addresses)
* "bogonlist"	: Bogon IP list (Intended to be filled manually or automatically with bogon IP addresses)
* "banlist"		: Internally used temporary list with timeout, used automatically for DoS/DDoS mitigation

You can use scripts like [ip-list-updater](https://github.com/vkucukcakar/ip-list-updater) (or a custom bash script) to periodically update proxylist and bogonlist.

### DoS/DDoS mitigation Examples

With default rules, there is a denylist with a timeout which can be configured by editing "/etc/sptables/conf/iptables.conf". 
The denylist is also used for DoS/DDoS mitigation.
IP set named "banlist" is internally used by Iptables to block attackers temporarily.

Example use cases implemented in default rules:

* e.g.: Any IP trying to connect with ssh with more than 10 new connections per 1 minute and a total of 5 connections (SSH brute-force attempt), is denylisted for 1 hour.
* e.g.: Any IP trying to connect with HTTP/HTTPS with more than 600 new connections per 1 minute is denylisted for 1 hour.
* e.g.: Any IP trying to open more than a total of 100 parallel HTTP/HTTPS connections, is denylisted for 1 hour.
* e.g.: Any IP trying to connect more than 8 different ports in 1 minute (possibly a port scanning attempt), is denylisted for 1 hour.

If you want to manually block an IP, use denylist. See ipset examples below.

### Manually using allowlist/denylist with IPset Examples:

IP addresses can be added to and deleted from manulally working IP sets with ipset command.

* Add IP to allowlist with default timeout 
```
	$ ipset add allowlist 1.2.3.4
```
* Add IP to allowlist for 1 day, update timeout if IP already exists
```
	$ ipset -exist add allowlist 1.2.3.4 timeout 86400
```	
* Add IP to allowlist permanently
```
	$ ipset add allowlist 1.2.3.4 timeout 0
```	
* Remove IP from allowlist
```
	$ ipset del allowlist 1.2.3.4
```
* Add IP to denylist with default timeout
```
	$ ipset add denylist 1.2.3.4
```	
* Add IP to denylist for 1 day, update timeout if IP already exists
```
	$ ipset -exist add denylist 1.2.3.4 timeout 86400
```	
* Add IP to denylist permanently
```
	$ ipset add denylist 1.2.3.4 timeout 0
```	
* Remove IP from denylist
```
	$ ipset del denylist 1.2.3.4
```

### Allowing reverse proxies (Cloudflare etc...)

IP set named "proxylist" can be filled up with trusted proxy IP addresses which bypass filters for certain ports.
The set can be filled either manually or automatically with the help of an IP updater script like [ip-list-updater](https://github.com/vkucukcakar/ip-list-updater)

### Allowing search engine crawlers

IP set named "seclist" can be filled up with search engine crawlers' IP addresses which bypass filters for certain ports.
Many search engine crawlers (like Googlebot) may not have known static IP list and can be detected by DNS queries.
You can use a custom script to detect search engine crawler IP and add it to the list.

### Blocking bogon IP range

IP set named "bogonlist" can be filled up with bogon IP addresses which will be blocked.
The set can be filled either manually or automatically with the help of an IP updater script like [ip-list-updater](https://github.com/vkucukcakar/ip-list-updater)

## IPv6 support

IPv6 is not supported, you should consider disabling IPv6 from sysctl or adding your own rules with ip6tables.
You can still use sptables and IPv6 together by adding your own rules with ip6tables, sptables only handles IPv4 traffic.

sptables is tied with iptables, not ip6tables.
It is possible to use "some" of the iptables rules with ip6tables using "list:set" ipset type, but there are other incompatibilities.
i.e. An IP mask (--hashlimit-srcmask or --connlimit-mask) of /32 means 1 IPv4 address but also 4,294,967,296 IPv6 addresses.
It is possible to use two separate iptables.conf for IPv4 and IPv6, but I did not implement it currently for the sake of simplicity.
Another reason was the possibility of switching to native nftables in the future.

## nftables compatibility

Now, nftables is the default firewall framework in Debian and some other modern distros.
Luckily, the default iptables package on Debian is a wrapper for the nftables. 
So, sptables runs without any problems.

While sptables is a standalone firewall, Docker was my first starting point and Docker supports iptables.
On the other hand, sptables have some complex rules (tested well in the past) and structure.
In the future, I can consider migrating to native nftables if really necessary.

## Caveats

* Add your ssh IP address to allowlist to not lock yourself out of your server. 
* Example rules are mostly given to prevent incoming attack patterns.
* For DDoS mitigation, you may wish to limit a full Class C network with /24 netmask at least. Please read the comments in /etc/sptables/conf/iptables.conf
* Any Iptables rules, connection limits for DoS/DDoS mitigation and Sysctl options are not advisory. 
  You should set you own connection limits depending on conditions and the services running on your server.
