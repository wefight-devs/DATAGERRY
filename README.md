![Image](app/src/assets/img/datagerry_logo.svg)
DATAGERRY is an OpenSource CMDB & Asset Management Tool, which completely leaves the definition of a data model to the user.

Key Functions:
* Define your own object types (e.g. router, server, location) in a simple webfrontend
* Add objects manually or import them from a CSV, Excel, XML, JSON file
* Define automated exports to external systems (e.g. Monitoring Systems, Config Management, Backup, Ticket Systems, DNS, ...)
* Use one of our APIs to integrate your systems
* ...and many many more features on the roadmap - we just started

Key Facts:
* Define your own data model
* Automate your IT with exporting assets to external systems
* OpenSource (AGPLv3)

See [DATAGERRY website](https://www.datagerry.com) for more details!


## Getting Started
|Useful Links |
|-----|
|[Getting Started](https://www.datagerry.com) |
|[Documentation](https://docs.datagerry.com)|
|[Issue Tracker](https://issues.datagerry.com)|
|[Community Support](https://community.datagerry.com)|

This repository is a fork of the official one. To build a new version make sure you are up to date or pull the latest version in this repo and adapt it.
 - requirements.txt must have pymongo[srv]==3.11.2
 - Dockerfile must be:
 ```
FROM --platform=amd64 centos:7 as build
COPY . /build/
WORKDIR /build/
RUN yum update -y && \
curl -sL https://rpm.nodesource.com/setup_14.x | bash - && \
yum install -y epel-release make python3 nodejs rpm-build
RUN make rpm

FROM --platform=amd64 centos:7
COPY --from=build /build/target/rpm/RPMS/x86_64 ./
RUN rpm -ivh DATAGERRY-undefined-1.el7.x86_64.rpm && systemctl enabledatagerry
COPY cmdb.conf /etc/datagerry/
CMD [ "/usr/bin/datagerry", "-c", "/etc/datagerry/cmdb.conf", "-s" ]
 ```

- you must have a file named cmdb.conf : 
```
[Database]
host = <uri>
port = 27017
database_name = datagerry
username = <user>
password = <pass>


[WebServer]
host = 0.0.0.0
port = 4000

[MessageQueueing]
host = 127.0.0.1
port = 5672
username = guest
password = guest
exchange = datagerry.eventbus
connection_attempts = 2
retry_delay = 6
use_tls = False
```
 - Then to build the image run: ```docker build -t wefight/datagerry:1.7.2 .```