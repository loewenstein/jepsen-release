# jepsen-release

**Work in progress**

This is a Bosh release for [Jepsen](jepsen.io), the distributed system test library written by [Kyle Kingsbury](https://github.com/aphyr).

## Current test flow
```bash
$ bosh ssh control-node 0
$ sudo su - vcap
$ cd /var/vcap/packages/jepsen/galera
$ PATH=/var/vcap/packages/java-1.8.0/bin/:$PATH /var/vcap/packages/leiningen-2.6.1/bin/lein.sh deps
$ PATH=/var/vcap/packages/java-1.8.0/bin/:$PATH /var/vcap/packages/leiningen-2.6.1/bin/lein.sh test
```
