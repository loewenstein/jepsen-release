# jepsen-release

**Work in progress**

This is a Bosh release for [Jepsen](http://jepsen.io), the distributed system test library written by [Kyle Kingsbury](https://github.com/aphyr).

## Prerequisites
```bash
$ bosh upload release jepsen-release
$ bosh upload release https://bosh.io/d/github.com/cloudfoundry/cf-mysql-release?v=26
```

## TODO: automate this with Bosh, currently done manually

## Current test flow
```bash
$ bosh ssh control-node 0
$ sudo su -
$ cd /var/vcap/packages/jepsen/galera
$ export LEIN_ROOT=yes # currently the whole thing runs as root
$ PATH=/var/vcap/packages/java-1.8.0/bin/:$PATH /var/vcap/packages/leiningen-2.6.1/bin/lein.sh test
```
