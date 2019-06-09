# sptables

Pure Iptables firewall for servers

sptables is a basic pure Iptables firewall for servers that also comes with Docker compatibility. sptables includes example pure Iptables rules and patterns against some known attacks. 
Actually, sptables consists of Iptables, Ipset, Sysctl configuration files and start, stop, reload, save scripts with a Systemd unit file.

Standalone mode properties:

* Well commented pure Iptables rules
* Simple structure with a few chains
* Pre-defined protection patterns and examples included
* DoS/DDoS mitigation, connection limiting, port scanning protection, ping limitation, port knocking patterns implemented in pure Iptables
* Iptables rules utilising IPset Blacklist with timeout
* Bare Iptables with no daemons continuously running
* A basic sysctl hardening configuration is included

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

* Version 2 and before are not compatible with version 3. Please uninstall version 2 before installing version 3. (See the Uninstallation section below)

* Installation also requires root permissions. (You can try sudo)

* Clone from github and run installation script.

	$ git clone https://github.com/vkucukcakar/sptables.git	

	$ cd sptables
	
	$ ./install.sh
		
* Give execute permission if not cloned from github

	$ chmod +x ./install.sh
	
* Edit configuration files at "/etc/sptables/conf/*". 
  
  At least edit "/etc/sptables/conf/iptables.conf" according to your server configuration before starting or enabling sptables.  
  
	
* Start the service (See usage below) and add your ssh IP address to whitelist to not lock yourself out of your server.
  
	$ ipset add whitelist 192.168.1.2

* Test and enable the service if everything works fine (See usage below)

	
## Manual Installation

If ./install.sh does not work for you, please check if requiremets are installed successfully and check command paths in ./install.sh.

If you do not have Systemd and you want to use sptables without Systemd, you can try manual installation.
To manually install sptables, copy the files under files/* to /etc/sptables/*, give /etc/sptables/*.sh execute permission, and call these scripts after editing configurations.

## Uninstallation

	# Stop and disable the service
	$ systemctl stop sptables
	$ systemctl disable sptables
	
	# You can try manually stopping if Systemd is not used
	$ /etc/sptables/stop.sh
	
	# Rename old sptables directory (You can delete all settings and IP sets later with "rm -r" if you wish)
	$ mv /etc/sptables /etc/sptables.backup

## Usage

* Start service

	$ systemctl start sptables

* Restart service

	$ systemctl restart sptables

* Reload service (Reload just restores IP sets and sysctl configuration. Use restart to apply new Iptables configuration)

	$ systemctl reload sptables

* Get service status

	$ systemctl status sptables
	
* Stop service

	$ systemctl stop sptables

* Enable service start on boot

	$ systemctl enable sptables

* Disable service start on boot

	$ systemctl disable sptables

* Manually save current sets without restarting service

	$ /etc/sptables/save.sh
 
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
* "whitelist"	: Manually filled whitelist to bypass filters by default. (You should add your ssh IP address here to not lock yourself out of your server.)
* "blacklist"	: Manually filled IP blacklist
* "proxylist"	: Trusted proxylist to bypass filters for certain ports. (Intended to be filled manually or automatically with trusted reverse proxy / CDN IP addresses)
* "crawlerlist"	: Crawler list to bypass filters for certain ports. (Intended to be filled manually or automatically with trusted crawler/search engine IP addresses)
* "bogonlist"	: Bogon IP list (Intended to be filled manually or automatically with bogon IP addresses)
* "banlist"		: Internally used temporary list with timeout, used automatically for DoS/DDoS mitigation

You can use scripts like [ip-list-updater](https://github.com/vkucukcakar/ip-list-updater) (or a custom bash script) to periodically update proxylist and bogonlist.

### DoS/DDoS mitigation Examples

With default rules, there is a blacklist with a timeout which can be configured by editing "/etc/sptables/conf/iptables.conf". 
The blacklist is also used for DoS/DDoS mitigation.
IP set named "banlist" is internally used by Iptables to block attackers temporarily.

Example use cases implemented in default rules:

* e.g.: Any IP trying to connect with ssh with more than 10 new connections per 1 minute and a total of 5 connections (SSH brute-force attempt), is blacklisted for 1 hour.
* e.g.: Any IP trying to connect with HTTP/HTTPS with more than 600 new connections per 1 minute is blacklisted for 1 hour.
* e.g.: Any IP trying to open more than a total of 100 parallel HTTP/HTTPS connections, is blacklisted for 1 hour.
* e.g.: Any IP trying to connect more than 8 different ports in 1 minute (possibly a port scanning attempt), is blacklisted for 1 hour.

If you want to manually block an IP, use blacklist. See ipset examples below.

### Manual whitelist/blacklist with IPset Examples:

IP addresses can be added to and deleted from manulally working IP sets with ipset command.

	# Add IP to whitelist with default timeout 
	$ ipset add whitelist 1.2.3.4

	# Add IP to whitelist for 1 day, update timeout if IP already exists
	$ ipset -exist add whitelist 1.2.3.4 timeout 86400
	
	# Add IP to whitelist permanently
	$ ipset add whitelist 1.2.3.4 timeout 0
	
	# Remove IP from whitelist
	$ ipset del whitelist 1.2.3.4

	# Add IP to blacklist with default timeout
	$ ipset add blacklist 1.2.3.4
	
	# Add IP to blacklist for 1 day, update timeout if IP already exists
	$ ipset -exist add blacklist 1.2.3.4 timeout 86400
	
	# Add IP to blacklist permanently
	$ ipset add blacklist 1.2.3.4 timeout 0
	
	# Remove IP from blacklist
	$ ipset del blacklist 1.2.3.4

### Allowing reverse proxies (Cloudflare etc...)

IP set named "proxylist" can be filled up with trusted proxy IP addresses which bypass filters for certain ports.
The set can be filled either manually or automatically with the help of an IP updater script like [ip-list-updater](https://github.com/vkucukcakar/ip-list-updater)

### Allowing crawlers/search engines

IP set named "crawlerlist" can be filled up with crawlers' IP addresses which bypass filters for certain ports.
Many crawlers (like Googlebot) may not have known static IP list.
You can use a custom script to detect crawler IP and add it to the list.

### Blocking bogon IP range

IP set named "bogonlist" can be filled up with bogon IP addresses which will be blocked.
The set can be filled either manually or automatically with the help of an IP updater script like [ip-list-updater](https://github.com/vkucukcakar/ip-list-updater)

## Caveats

* Add your ssh IP address to whitelist to not lock yourself out of your server. 
* Example rules are mostly given to prevent incoming attack patterns.
* For DDoS mitigation, you may wish to limit a full Class C network with /24 netmask at least. Please read the comments in /etc/sptables/conf/iptables.conf
* Any Iptables rules, connection limits for DoS/DDoS mitigation and Sysctl options are not advisory. 
  You should set you own connection limits depending on conditions and the services running on your server.
