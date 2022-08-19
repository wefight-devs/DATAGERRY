FROM --platform=amd64 centos:7 as build
COPY . /build/
WORKDIR /build/
RUN yum update -y && \
curl -sL https://rpm.nodesource.com/setup_14.x | bash - && \
yum install -y epel-release make python3 nodejs rpm-build
RUN make rpm

FROM --platform=amd64 centos:7
COPY --from=build /build/target/rpm/RPMS/x86_64 ./
RUN rpm -ivh DATAGERRY-undefined-1.el7.x86_64.rpm && systemctl enable datagerry
COPY cmdb.conf /etc/datagerry/
CMD [ "/usr/bin/datagerry", "-c", "/etc/datagerry/cmdb.conf", "-s" ]