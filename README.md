# jepsen-release

**Work in progress**

This is a Bosh release for [Jepsen](jepsen.io), the distributed system test library written by [Kyle Kingsbury](https://github.com/aphyr).

## TODO: automate this with Bosh, currently done manually
```bash
$ bosh ssh control-node 0
$ sudo su -
$ vim /etc/hosts
# enter mappings for the 5 db hosts to symbolic names 'n1' to 'n5'
$ ssh-keyscan -t rsa n{1,5} >> /home/vcap/.ssh/known_hosts
```

## Current test flow
```bash
$ bosh ssh control-node 0
$ sudo su - vcap
$ cd /var/vcap/packages/jepsen/galera
$ PATH=/var/vcap/packages/java-1.8.0/bin/:$PATH /var/vcap/packages/leiningen-2.6.1/bin/lein.sh test
```
