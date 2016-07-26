#!/bin/bash

# *******
# This is a script to get katello installed with puppet 4. It is only meant to
# be a POC and should not be used in production scenarios.
#
# This script is temporary and should go away and be replaced with something
# better.
# *******

yum -y localinstall http://yum.theforeman.org/releases/1.12/el7/x86_64/foreman-release.rpm
yum -y localinstall http://fedorapeople.org/groups/katello/releases/yum/3.1/katello/el7/x86_64/katello-repos-latest.rpm
yum -y localinstall https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm # puppet 4!!!
yum -y localinstall http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install foreman-release-scl
yum -y install katello
yum -y install puppet-agent #this upgrades puppet

yum install -y haveged; service haveged start # saves some time on tomcat startup, worth it:)

# XXX: please fix this second
setenforce 0  # uggggh! stopdisablingselinux.com :-P

# we need "puppet help strings" to work so kafo_parsers picks up the parser
/opt/puppetlabs/bin/puppet module install puppetlabs-strings
/opt/puppetlabs/puppet/bin/gem install yard

# at this point, "foreman-installer -v --noop --scenario katello" will run (not clean, but runs)

service mongod start # to get around error related to master selection in mongo puppet module

# XXX: this will go away on its own after we are using nightlies instead of 3.1
mkdir /usr/share/katello-installer-base/modules/OLD
for r in certs katello pulp qpid crane capsule candlepin common service_wait; do
  mv /usr/share/katello-installer-base/modules/$r /usr/share/katello-installer-base/modules/OLD/
  git clone https://github.com/Katello/puppet-$r /usr/share/katello-installer-base/modules/$r
done

# XXX: please fix this first
cd /;
curl http://paste.fedoraproject.org/395853/95484231/raw/ | patch -p0 # hack candlepin param ref error
curl http://paste.fedoraproject.org/397071/35937146/raw/ | patch -p0 # hack passenger module issue
curl http://paste.fedoraproject.org/397340/46980677/raw/ | patch -p0 # hack env dir override

# remove once nightlies are back
cd /usr/share/katello-installer-base/
curl https://patch-diff.githubusercontent.com/raw/Katello/katello-installer/pull/380.patch | patch -p1
curl https://patch-diff.githubusercontent.com/raw/Katello/katello-installer/pull/381.patch | patch -p1
