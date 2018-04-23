# dtables

Docker compatible Iptables firewall

* Compatible with Docker, let Docker continue managing iptables
* Well commented bare Iptables rules 
* Simple structure with a few chains 
* Utilise the documented DOCKER-USER chain for Docker compatibility
* Same filters apply for host and Docker containers
* Dos/DDoS protection, connection limiting, port scanning protection, ping limitation, port knocking patterns implemented in pure Iptables
* Iptables rules utilising IPset Blacklist with timeout
* Bare Iptables with no daemons continuously running
* A basic sysctl hardening configuration is included


## Requirements

* Docker 17.06 or later
* Iptables
* IPset
* Systemd
* Root permissions

Tested on Debian Stretch (Requirements except Docker is already present)
Installation file tested on Debian Stretch, Ubuntu 17, CentOS 7


## Installation

* Installation also requires root permissions. (You can try sudo)

* Clone from github and run installation script.

	$ git clone https://github.com/vkucukcakar/dtables.git	

	$ cd dtables
	
	$ ./install.sh
		
* Give execute permission if not cloned from github

	$ chmod +x ./install.sh
	
* Edit configuration files at "/etc/dtables/conf/*". 
  
  At least edit "/etc/dtables/conf/iptables.conf" according to your server configuration before starting or enabling dtables.  
  
  Add your ssh IP address to whitelist to not lock yourself out of your server.
  
	$ ipset add whitelist 192.168.1.2
	
* Start to test and enable if everything works fine (See usage below)


## Usage

* Start service
	$ systemctl start dtables

* Restart service
	$ systemctl restart dtables

* Get service status
	$ systemctl status dtables
	
* Stop service
	$ systemctl stop dtables

* Enable service start on boot
	$ systemctl enable dtables

* Disable service start on boot
	$ systemctl disable dtables

 
## Details

### Configuration Files

Configuration files are at copied at location /etc/dtables/conf/* on installation and symbolic links are created on system folders.

* /etc/dtables/conf/iptables.conf			: Well commented Iptables configuration file. 
  You must edit this file to tune it for your server before starting or enabling dtables. (Open ports, define limits etc...)
* /etc/dtables/conf/iptables.stop.conf		: Iptables stop configuration file.
* /etc/dtables/conf/sysctl.hardening.conf	: Sysctl hardening file.
  You can edit this file according to your needs. Some options directly affect iptables modules like conntrack etc...
* /etc/dtables/conf/ipset.conf				: IPset configuration file that creates the four pre-defined sets explained below. You usually have nothing to do with this file unless you need to create other custom sets.

### Iptables Rules

By default, two filter chains are available INPUT-FILTERS and OUTPUT-FILTERS in iptables configuration which filter both host and container packets. 
There are example rules well-commented and mostly self explanatory which you can edit according to your needs.
Basically you just need to check up or edit "INPUT FILTERS" and "OUTPUT FILTERS" sections in the file unless you do not want to change the structure.

### Pre-defined IP Sets

dtables have 4 pre-defined IP sets:
* "whitelist"	: Manually filled whitelist to bypass connection limits by default. (You should add your ssh IP address here to not lock yourself out of your server.)
* "blacklist"	: Temporary blacklist with timeout, used automatically for DDOS protection.
* "banlist"		: Manually filled IP ban list
* "bogonlist"	: Manually filled bogon IP list (Intended to be filled manually or automatically with bogon IP addresses)

### Blacklist Examples

With default rules, there is a blacklist with a timeout which can be configured by editing "/etc/dtables/conf/iptables.conf". 
The blacklist is also used for DoS/DDoS mitigiation.

Example use cases:

* e.g.: Any IP trying to connect with ssh with more than 10 new connections per 1 minute and a total of 5 connections (SSH brute-force attempt), is blacklisted for 1 hour.
* e.g.: Any IP trying to connect with HTTP/HTTPS with more than 100 new connections per 1 minute and a total of 100 connections, is blacklisted for 1 hour.
* e.g.: Any IP trying to open more than a total of 100 connections, is blacklisted for 1 hour.
* e.g.: Any IP trying to connect more than 8 different ports in 1 minute (a port scanning attempt), is blacklisted for 1 hour.

If you want to manually block an IP, use banlist. See ipset examples below.

### IPset Examples:

IP addresses can be added to and deleted from manulally working IP sets with ipset command.

	$ ipset add whitelist 192.168.1.1
	
	$ ipset del whitelist 192.168.1.1

	$ ipset add banlist 1.2.3.4
	
	$ ipset del banlist 1.2.3.4

	
## Caveats

* Add your ssh IP address to whitelist to not lock yourself out of your server. 
* Any Iptables rules, connection limits for DDOS mitigiation and Sysctl options are not advisory. 
  You should set you own connection limits depending on conditions and the services running on your server.

