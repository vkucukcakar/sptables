#!/usr/bin/env bash

###
# dtables - Docker compatible Iptables firewall
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
# This file is a part of dtables - Docker compatible Iptables firewall
# Filename		: dtables.start.sh
# Description	: DCIF service start file
###


### Reload sysctl ###


# sysctl command
SYSCTL="sysctl"

# Make sysctl read all configuration files again
$SYSCTL --quiet --system


### Start IPset ###


# ipset command
IPSET="ipset"

# Restore default configuration
$IPSET restore -! -f /etc/dtables/conf/ipset.conf

# Restore the saved sets (-! parameter will prevent ipset failing on multiple create statements)
[ -e /etc/dtables/data/whitelist.save ] && $IPSET restore -! -f /etc/dtables/data/whitelist.save
[ -e /etc/dtables/data/blacklist.save ] && $IPSET restore -! -f /etc/dtables/data/blacklist.save
[ -e /etc/dtables/data/banlist.save ] && $IPSET restore -! -f /etc/dtables/data/banlist.save
[ -e /etc/dtables/data/bogonlist.save ] && $IPSET restore -! -f /etc/dtables/data/bogonlist.save


### Start Iptables ###


# iptables-restore command
IPTABLESRESTORE="iptables-restore"

# Restore default configuration
$IPTABLESRESTORE -n /etc/dtables/conf/iptables.conf