FROM centos:7 as static-node-builder
RUN yum update -y &&\
    curl -sL https://rpm.nodesource.com/setup_14.x | bash - &&\
    yum install -y nodejs
COPY app/ /app/
WORKDIR /app
RUN npm i && npm run-script prod


FROM --platform=amd64 centos:7 as python-builder
RUN yum update -y &&\
    yum-builddep -y python3 &&\
    yum install -y wget make && \
    wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tgz && \
    tar -xzf Python-3.7.0.tgz 
RUN cd Python-3.7.0 && ./configure --enable-optimizations --enable-shared && \
    make install && ldconfig /usr/local/lib
COPY requirements.txt /
RUN pip3 install --upgrade pip && pip3 install -r /requirements.txt

FROM centos:7 as datagerry-builder
WORKDIR /app
COPY --from=static-node-builder /app/dist/datagerry-app /app/cmdb/interface/net_app/datagerry-app
COPY --from=python-builder /usr/local/bin/pip3 /usr/local/bin/pip
COPY --from=python-builder /usr/local/bin/pyinstaller /usr/local/bin/pyinstaller
COPY --from=python-builder /usr/local/bin/python3.7 /usr/local/bin/python3.7
COPY --from=python-builder /usr/local/lib/  /usr/local/lib/
COPY cmdb/ /app/cmdb
RUN ldconfig /usr/local/lib &&\
    pyinstaller --name datagerry --onefile \
    --hidden-import cmdb.updater.versions.updater_20200214 \
		--hidden-import cmdb.updater.versions.updater_20200226 \
		--hidden-import cmdb.updater.versions.updater_20200408 \
		--hidden-import cmdb.updater.versions.updater_20200512 \
		--hidden-import cmdb.exportd \
		--hidden-import cmdb.exportd.service \
		--hidden-import cmdb.exportd.externals \
		--hidden-import cmdb.exportd.externals.external_systems \
		--hidden-import cmdb.exporter \
		--hidden-import cmdb.exporter.exporter_base \
		--hidden-import cmdb.interface.gunicorn \
		--hidden-import gunicorn.glogging \
		--hidden-import gunicorn.workers.sync \
		--hidden-import reportlab.graphics.barcode.common \
		--hidden-import reportlab.graphics.barcode.code128 \
		--hidden-import reportlab.graphics.barcode.code93 \
		--hidden-import reportlab.graphics.barcode.code39 \
		--hidden-import reportlab.graphics.barcode.usps \
		--hidden-import reportlab.graphics.barcode.usps4s \
		--hidden-import reportlab.graphics.barcode.ecc200datamatrix \
		--add-data cmdb/interface/docs/static:cmdb/interface/docs/static \
		--add-data cmdb/interface/net_app/datagerry-app:cmdb/interface/net_app/datagerry-app \
		cmdb/__main__.py


FROM centos:7
COPY --from=datagerry-builder /app/dist/datagerry /app/datagerry
COPY cmdb.default.conf /app/cmdb.default.conf
CMD ["/app/datagerry","-s","-c","/app/cmdb.default.conf"]