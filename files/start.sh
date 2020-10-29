#!/usr/bin/env bash

###
# sptables - Pure Iptables firewall for servers
#
# Copyright (c) 2018, Volkan Kucukcakar
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###

###
# This file is a part of sptables - Pure Iptables firewall for servers
# Filename		: start.sh
# Path			: /etc/sptables/start.sh
# Description	: sptables service start file executed by Systemd
###


# sysctl command
SYSCTL="sysctl"

# ipset command
IPSET="ipset"

# iptables command
IPTABLES="iptables"

# iptables-restore command
IPTABLESRESTORE="iptables-restore"

# Abort script on error
set -e

# Make sysctl read all configuration files again
echo "Making sysctl read all configuration files again"
$SYSCTL --quiet --system

# Restore default ipset configurations
echo "Restoring default ipset configurations"
$IPSET restore -! -f /etc/sptables/conf/ipset.conf

# Restore the saved sets (-! parameter will prevent ipset failing on multiple create statements)
echo "Restoring the saved sets"
[ -e /etc/sptables/data/allowlist.save ] && $IPSET restore -! -f /etc/sptables/data/allowlist.save
[ -e /etc/sptables/data/denylist.save ] && $IPSET restore -! -f /etc/sptables/data/denylist.save
[ -e /etc/sptables/data/proxylist.save ] && $IPSET restore -! -f /etc/sptables/data/proxylist.save
[ -e /etc/sptables/data/seclist.save ] && $IPSET restore -! -f /etc/sptables/data/seclist.save
[ -e /etc/sptables/data/bogonlist.save ] && $IPSET restore -! -f /etc/sptables/data/bogonlist.save
[ -e /etc/sptables/data/banlist.save ] && $IPSET restore -! -f /etc/sptables/data/banlist.save

# Switch running mode before restoring iptables
if docker --version >/dev/null 2>&1 && $IPTABLES -L DOCKER-USER >/dev/null 2>&1 ; then
	# Docker mode
	echo "Initializing Iptables in Docker mode."

	# Restore default configuration (Common part) without flushing previous content
	$IPTABLESRESTORE -n /etc/sptables/conf/iptables.conf

	# Restore default configuration (Docker mode part) without flushing previous content
	$IPTABLESRESTORE -n /etc/sptables/conf/iptables.docker.conf
else
	# Standalone mode (Docker not installed or DOCKER-USER chain not found)
	echo "Initializing Iptables in standalone mode."

	# Restore default configuration (Common part) without flushing previous content
	$IPTABLESRESTORE -n /etc/sptables/conf/iptables.conf
fi

echo "Start script executed"
