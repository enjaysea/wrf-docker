FROM rockylinux:9

RUN mkdir /wrf
RUN groupadd wrf -g 9999
RUN useradd -u 9999 -g wrf -M -d /wrf wrfuser
RUN chown -R wrfuser:wrf /wrf && chmod 6755 /wrf

COPY README.md /wrf/README.md

RUN dnf -y update
RUN dnf -y install file 
RUN dnf -y install m4
RUN dnf -y install time
RUN dnf -y install emacs
RUN dnf -y install make
RUN dnf -y install git
RUN dnf -y install tar
RUN dnf -y install gcc 
RUN dnf -y install gfortran gcc-gfortran libgfortran
RUN dnf -y install zlib zlib-devel
RUN dnf -y install libpng-devel
RUN dnf -y install perl bash tcsh csh
RUN dnf -y install openmpi
RUN dnf -y install openmpi-devel
RUN dnf -y install jasper jasper-libs
RUN dnf -y install epel-release
RUN dnf -y install hdf5 hdf5-devel 
RUN dnf -y install hdf5-openmpi hdf5-openmpi-devel
RUN dnf -y install netcdf netcdf-devel
RUN dnf -y install netcdf-fortran netcdf-fortran-devel

# Set shell environments
RUN echo export 'PS1="\e[0;92m\u\e[0;95m \$PWD \e[m"' > /wrf/.bashrc \
 && echo 'alias l="ls -l"' >> /wrf/.bashrc \
 && echo 'alias em="emacs -nw"' >> /wrf/.bashrc \
 && echo 'alias cls="clear"' >> /wrf/.bashrc \
 && echo 'alias nobak="rm -rf *~"' >> /wrf/.bashrc \
 && echo 'export BASE=/usr' >> /wrf/.bashrc \
 && echo 'export NETCDF=$BASE' >> /wrf/.bashrc \
 && echo 'export LIB=$BASE/lib64' >> /wrf/.bashrc \
 && echo 'export CPPFLAGS=-I$BASE/INCLUDE' >> /wrf/.bashrc \ 
 && echo 'export CFLAGS=-I$BASE/include' >> /wrf/.bashrc \ 
 && echo 'export FFLAGS=-I$BASE/include' >> /wrf/.bashrc \
 && echo 'export LDFLAGS="-L$LIB -lhdf5_hl -lhdf5 -lm -lz"' >> /wrf/.bashrc \
 && echo 'export LD_LIBRARY_PATH=$LIB:LD_LIBRARY_PATH' >> /wrf/.bashrc \
 && echo 'export PATH=.:$BASE/bin:$LIB/openmpi/bin:$PATH' >> /wrf/.bashrc 

RUN cp /wrf/.bashrc /root && chown root:root /root/.bashrc

# 
# Finished root tasks
#

USER wrfuser
WORKDIR /wrf

# Download WRF
RUN curl -L https://github.com/wrf-model/WRF/releases/download/v4.5.2/v4.5.2.tar.gz -o wrf.tar.gz \
 && tar xvzf wrf.tar.gz \
 && mv WRFV4.5.2 wrf \
 && rm wrf.tar.gz

# Compile WRF
WORKDIR /wrf/wrf
ENV BASE /usr
ENV NETCDF $BASE
ENV LIB $BASE/lib64
ENV CPPFLAGS -I$BASE/INCLUDE
ENV CFLAGS -I$BASE/include
ENV FFLAGS -I$BASE/include
ENV LDFLAGS "-L$LIB -lhdf5_hl -lhdf5 -lm -lz"
ENV LD_LIBRARY_PATH $LIB:LD_LIBRARY_PATH
ENV PATH .:$BASE/bin:$LIB/openmpi/bin:$PATH
RUN configure <<< $'15\r1\r' && compile em_real

# Download WPS
WORKDIR /wrf
ENV WRF_DIR /wrf/wrf
RUN curl -L https://github.com/wrf-model/WPS/archive/refs/tags/v4.5.tar.gz -o wps.tar.gz \
 && tar xvzf wps.tar.gz \
 && mv WPS-4.5 wps \
 && rm wps.tar.gz

ENV JASPERINC /usr/include/jasper/
ENV JASPERLIB /usr/lib64

CMD ["/bin/bash"]

