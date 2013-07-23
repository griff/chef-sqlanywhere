#!/bin/sh
set -o errexit
cd `dirname $0`
. bin32/sa_config.sh
ruby driver.rb "$1" "$2"