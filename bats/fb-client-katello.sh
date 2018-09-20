#!/usr/bin/env bats
# vim: ft=sh:sw=2:et

set -o pipefail

load os_helper
load foreman_helper
load fixtures/content

setup() {
  tSetOSVersion
}

# The intent for this file is to be run on the client side. This means that it will be run not in the Katello environment
