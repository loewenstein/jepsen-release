# jepsen-release

**Work in progress**

This is a Bosh release for [Jepsen](jepsen.io), the distributed system test library written by [Kyle Kingsbury](https://github.com/aphyr).

## TODO: automate this with Bosh, currently done manually
```bash
$ bosh ssh control-node 0
$ sudo su -
$ ssh-keyscan -t rsa n{1,5} >> /home/vcap/.ssh/known_hosts # post-deploy doesn't work yet
# put private key into /home/vcap/.ssh/id_rsa, chmod 600
ssh-copy-id n1 -i
# put public key into /home/vcap/.ssh/authorized_keys, chmod 600, chmod dir 750
```

## Current test flow
```bash
$ bosh ssh control-node 0
$ sudo su - vcap
$ cd /var/vcap/packages/jepsen/galera
$ PATH=/var/vcap/packages/java-1.8.0/bin/:$PATH /var/vcap/packages/leiningen-2.6.1/bin/lein.sh test
```
