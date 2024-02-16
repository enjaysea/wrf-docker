FROM rockylinux:9

RUN mkdir -p /wrf/wrf
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
RUN dnf -y install gcc-gfortran

ENV BUILD_DIR /wrf/wrf
ENV HDFDIR $BUILD_DIR/opt
ENV HDF5 $BUILD_DIR/opt
ENV NETCDF $BUILD_DIR/opt

# Download and extract HDF5 source code
RUN curl -SLk https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.14/hdf5-1.14.0/src/hdf5-1.14.0.tar.gz -o hdf5-1.14.0.tar.gz \
&& tar xvzf hdf5-1.14.0.tar.gz \
&& cd hdf5-1.14.0 
#&& ./configure --prefix=$HDFDIR --enable-fortran --enable-parallel \
#&& make -j \
#&& make install

# Download and extract HDF5 source code
#RUN curl -L https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.9.0.tar.gz | tar xvzf -
#WORKDIR netcdf-c-4.9.0
#RUN ./configure --prefix=$NETCDF
#RUN make -j && make install
#WORKDIR $BUILD_DIR

#
# Finished root tasks
#

USER wrfuser
WORKDIR /wrf

# Download WRF
#RUN curl -L https://github.com/wrf-model/WRF/releases/download/v4.5.2/v4.5.2.tar.gz | tar xvzf -
#RUN mv /wrf/WRFV4.5.2 /wrf/wrf

# Set shell environment
RUN echo export 'PS1="\e[0;92m\u\e[0;95m \$PWD \e[m"' > /wrf/.bashrc \
 && echo export PATH=.:$PATH >> /wrf/.bashrc \
 && echo 'alias l="ls -l"' >> /wrf/.bashrc \
 && echo 'alias em="emacs -nw"' >> /wrf/.bashrc \
 && echo 'alias cls="clear"' >> /wrf/.bashrc \
 && echo 'alias nobak="rm -rf *~"' >> /wrf/.bashrc \
 && echo export 'LD_LIBRARY_PATH="/usr/lib64/openmpi/lib"' >> /wrf/.bashrc \
 && echo export 'PATH=".:/usr/lib64/openmpi/bin:$PATH"' >> /wrf/.bashrc \
 && echo export 'LDFLAGS="-lm"' >> /wrf/.bashrc \
 && echo export "PKG_CONFIG_PATH=/usr/lib64/openmpi/lib/pkgconfig" >> /wrf/.bashrc \
 && echo export 'NETCDF=/wrf/netcdf_links' >> /wrf/.bashrc \
 && echo export 'JASPERINC=/wrf/wps/external/jasper-1.900.29/src/libjasper/include/jasper/' >> /wrf/.bashrc \
 && echo export 'JASPERLIB=/usr/lib64/' >> /wrf/.bashrc 
 
CMD ["/bin/bash"]
