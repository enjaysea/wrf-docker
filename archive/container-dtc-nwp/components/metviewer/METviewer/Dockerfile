FROM dtcenter/base_image:simple

MAINTAINER Tatiana Burek <tatiana@ucar.edu>

#
# This Dockerfile checks out METviewer from GitHub and builds the specified branch or tag.
#
ENV METVIEWER_GIT_NAME v4.1.0
ENV METCALCPY_GIT_NAME v1.1.0
ENV METPLOTPY_GIT_NAME v1.1.0
ENV METDATADB_GIT_NAME v1.1.0

#
# Constants
#
ENV TOMCAT_MINOR_VERSION 5.61
ENV TOMCAT_MAJOR_VERSION 8
ENV TOMCAT_VERSION ${TOMCAT_MAJOR_VERSION}.${TOMCAT_MINOR_VERSION}

ENV METVIEWER_GIT_URL  https://github.com/dtcenter/METviewer
ENV METCALCPY_GIT_URL  https://github.com/dtcenter/METcalcpy
ENV METPLOTPY_GIT_URL  https://github.com/dtcenter/METplotpy
ENV METDATADB_GIT_URL  https://github.com/dtcenter/METdataio


ENV UMASK 002

#
# METVIEWER_GIT_NAME is required.
#
RUN if [ "x${METVIEWER_GIT_NAME}" = "x" ]; then \
      echo "ERROR: METVIEWER_GIT_NAME undefined! Rebuild with \"--build-arg METVIEWER_GIT_NAME={branch, tag, or hash}\""; \
      exit 1; \
    else \
      echo "Build Argument METVIEWER_GIT_NAME=${METVIEWER_GIT_NAME}"; \
    fi

#
# METCALCPY_GIT_NAME is required.
#
RUN if [ "x${METCALCPY_GIT_NAME}" = "x" ]; then \
      echo "ERROR: METCALCPY_GIT_NAME undefined! Rebuild with \"--build-arg METCALCPY_GIT_NAME={branch, tag, or hash}\""; \
      exit 1; \
    else \
      echo "Build Argument METCALCPY_GIT_NAME=${METCALCPY_GIT_NAME}"; \
    fi

#
# METPLOTPY_GIT_NAME is required.
#
RUN if [ "x${METPLOTPY_GIT_NAME}" = "x" ]; then \
      echo "ERROR: METPLOTPY_GIT_NAME undefined! Rebuild with \"--build-arg METPLOTPY_GIT_NAME={branch, tag, or hash}\""; \
      exit 1; \
    else \
      echo "Build Argument METPLOTPY_GIT_NAME=${METPLOTPY_GIT_NAME}"; \
    fi

#
# METDATADB_GIT_NAME is required.
#
RUN if [ "x${METDATADB_GIT_NAME}" = "x" ]; then \
      echo "ERROR: METDATADB_GIT_NAME undefined! Rebuild with \"--build-arg METDATADB_GIT_NAME={branch, tag, or hash}\""; \
      exit 1; \
    else \
      echo "Build Argument METDATADB_GIT_NAME=${METDATADB_GIT_NAME}"; \
    fi

#
# Install system updates
#
RUN yum -y update \
 && yum -y install 'dnf-command(config-manager)' \
 && yum-config-manager --enable PowerTools

RUN yum -y install --setopt=tsflags=nodocs epel-release && \
    yum -y erase vim-minimal && \
    yum -y update && yum clean all
#
# Install required packages
#
RUN yum -y install wget tar git ant java R mysql ksh \
 && rm -rf /var/cache/yum/* \
 && yum clean all

#
# Install gsl-2.5 on which the R gsl package depends.
# The centos7 gal package is too old (version 1.5).
#
RUN echo "Compiling gsl-2.5" \
 && curl -SL http://gnu.askapache.com/gsl/gsl-2.5.tar.gz | tar zxC /lib \
 && cd /lib/gsl-2.5 \
 && ./configure --prefix=/usr --libdir=/usr/lib64 >& configure.log \
 && make >& make.log \
 && make install >& make_install.log

#
# Setup default cran repo
#
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile

#
# Install required R packages
#
RUN Rscript -e "install.packages('boot')" \
 && Rscript -e "install.packages('plotrix')" \
 && Rscript -e "install.packages('gsl')" \
 && Rscript -e "install.packages('data.table')" \
 && Rscript -e "install.packages('verification')"

#
# Install Tomcat
#
ENV CATALINA_HOME /opt/tomcat

RUN wget https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
 && tar -xvf apache-tomcat-${TOMCAT_VERSION}.tar.gz \
 && rm apache-tomcat*.tar.gz \
 && mv apache-tomcat* ${CATALINA_HOME} \
 && chmod +x ${CATALINA_HOME}/bin/*sh

EXPOSE 8080

#
# Install METplus python components
#
RUN mkdir /METviewer-python \
 && echo "Checking out METcalcpy ${METCALCPY_GIT_NAME} from ${METCALCPY_GIT_URL}" \
 && git clone ${METCALCPY_GIT_URL} /METviewer-python/METcalcpy \
 && cd /METviewer-python/METcalcpy \
 && git checkout ${METCALCPY_GIT_NAME} \
 && echo "Checking out METplotpy ${METPLOTPY_GIT_NAME} from ${METPLOTPY_GIT_URL}" \
 && git clone ${METPLOTPY_GIT_URL} /METviewer-python/METplotpy \
 && cd /METviewer-python/METplotpy \
 && git checkout ${METPLOTPY_NAME_TAG} \
 && echo "Checking out METdatadb ${METDATADB_GIT_NAME} from ${METDATADB_GIT_NAME}" \
 && git clone ${METDATADB_GIT_URL} /METviewer-python/METdatadb \
 && cd /METviewer-python/METdatadb \
 && git checkout ${METDATADB_NAME_TAG}

#
# Install METviewer
#
RUN echo "Checking out METviewer ${METVIEWER_GIT_NAME} from ${METVIEWER_GIT_URL}" \
 && git clone ${METVIEWER_GIT_URL} /METviewer \
 && cd /METviewer \
 && git checkout ${METVIEWER_GIT_NAME} \
 && echo "Configuring and building METviewer" \
 && cd /METviewer \
 && cat webapp/metviewer/WEB-INF/classes/build.properties | \
    sed -r 's%db.host=.*%db.host=mysql_mv%g' | \
    sed -r 's%db.user=.*%db.user=root%g' | \
    sed -r 's%db.password=.*%db.password=mvuser%g' | \
    sed -r 's%db.management.system=.*%db.management.system=mysql%g' | \
    sed -r 's%output.dir=.*%output.dir=/opt/tomcat/webapps/metviewer_output/%g' | \
    sed -r 's%webapps.dir=.*%webapps.dir=/opt/tomcat/webapps/metviewer/%g' | \
    sed -r 's%url.output=.*%url.output=/metviewer_output/%g' | \
    sed -r 's%python.env=.*%python.env=/usr/local/%g' | \
    sed -r 's%metcalcpy.home=.*%metcalcpy.home=/METviewer-python/METcalcpy/%g' | \
    sed -r 's%metdatadb.home=.*%metdatadb.home=/METviewer-python/METdatadb/%g' | \
    sed -r 's%metplotpy.home=.*%metplotpy.home=/METviewer-python/METplotpy/%g' \
    > build.properties \
 && ant -Dbuild.properties.file=./build.properties \
        -Ddb.management.system=mariadb \
        -Dmetcalcpy.path=/METviewer-python/METcalcpy/ \
        -Dmetdatadb.path=/METviewer-python/METdatadb/ \
        -Dmetplotpy.path=/METviewer-python/METplotpy/ \
        -Dpython.env.path=/usr/local/ war \
 && mv /METviewer/dist/*.war ${CATALINA_HOME}/webapps \
 && echo "Configuring METviewer scripts" \
 && cd /METviewer/bin \
 && cat mv_batch.sh | \
     sed -r 's%PYTHON_ENV=.*%PYTHON_ENV=/usr/local%g' | \
     sed -r 's%METCALCPY_HOME=.*%METCALCPY_HOME=/METviewer-python/METcalcpy/%g' | \
     sed -r 's%METPLOTPY_HOME=.*%METPLOTPY_HOME=/METviewer-python/METplotpy/%g'  \
     >  mv_batch.sh-DOCKER \
&& mv mv_batch.sh-DOCKER mv_batch.sh \
&& cat mv_load.sh | \
     sed -r 's%PYTHON_ENV=.*%PYTHON_ENV=/usr/local%g' | \
     sed -r 's%METDATADB_HOME=.*%METDATADB_HOME=/METviewer-python/METdatadb/%g'  \
     >  mv_load.sh-DOCKER \
&& mv mv_load.sh-DOCKER mv_load.sh \
&& cat mv_scorecard.sh | \
     sed -r 's%PYTHON_ENV=.*%PYTHON_ENV=/usr/local%g' | \
     sed -r 's%METCALCPY_HOME=.*%METCALCPY_HOME=/METviewer-python/METcalcpy/%g'  \
     >  mv_scorecard.sh-DOCKER \
&& mv mv_scorecard.sh-DOCKER mv_scorecard.sh
#
# Install Python 3.6
#
RUN yum install -y python3 python3-devel python3-pip

#
# Install Python packages
#
RUN pip-3 install kiwisolver==1.0.1 \
 && pip-3 install plotly==4.9.0 \
 && pip-3 install kaleido==0.2.1 \
 && pip-3 install pandas==1.0.1 \
 && pip-3 install numpy==1.17.0 \
 && pip-3 install scipy==1.5.1 \
 && pip-3 install PyYAML==5.3.1 \
 && pip-3 install psutil==5.7.2 \
 && pip-3 install requests \
 && pip-3 install pillow==7.2.0 \
 && pip-3 install matplotlib==3.3.0 \
 && pip-3 install lxml \
 && pip-3 install pymysql \
 && pip-3 install retrying \
 && pip-3 install cython \
 && pip-3 install statsmodels==0.11.1

#
# Create a link for python3
#
RUN ln -s /usr/bin/python3 /usr/local/bin/python

#
# set env vars
#
ENV PYTHONPATH "${PYTHONPATH}:/METviewer-python/METcalcpy/:/METviewer-python/METplotpy/metplotpy/"
ENV METPLOTPY_BASE "/METviewer-python/METplotpy/metplotpy/"

#
# Change permission on exe's
#
RUN chmod 755 /METviewer/bin/mv_batch.sh \
  && chmod 755 /METviewer/bin/mv_load.sh \
  && chmod 755 /METviewer/bin/mv_prune.sh \
  && chmod 755 /METviewer/bin/mv_scorecard.sh

ENTRYPOINT ${CATALINA_HOME}/bin/startup.sh && /bin/bash
CMD ["true"]
