FROM wrf_base:latest

# 
# This Dockerfile compiles WRF from source during "docker build" step
ENV WRF_VERSION 4.3
ENV WPS_VERSION 4.3

#
# Download original sources
#
RUN umask 0002 \
 && curl -SL https://github.com/wrf-model/WRF/archive/v${WRF_VERSION}.tar.gz | tar zxC /wrf \
 && mv ./WRF-${WRF_VERSION} ./wrf \
 && curl -SL https://github.com/wrf-model/WPS/archive/v${WPS_VERSION}.tar.gz | tar zxC /wrf \
 && mv ./WPS-${WPS_VERSION} ./wps

RUN echo export 'PS1="\e[0;92m\u\e[0;95m \$PWD \e[m"' > /wrf/.bashrc \
 && echo export PATH=.:$PATH >> /wrf/.bashrc \
 && echo export 'LD_LIBRARY_PATH="/usr/lib64/openmpi/lib"' >> /wrf/.bashrc \
 && echo export 'PATH=".:/usr/lib64/openmpi/bin:$PATH"' >> /wrf/.bashrc \
 && echo export 'LDFLAGS="-lm"' >> /wrf/.bashrc \
 && echo export 'NETCDF=/wrf/netcdf_links' >> /wrf/.bashrc \
 && echo export 'JASPERINC=/usr/include/jasper/' >> /wrf/.bashrc \
 && echo export 'JASPERLIB=/usr/lib64/' >> /wrf/.bashrc \
 && echo export 'J="-j 4"' >> /wrf/.bashrc \
 && echo 'alias l="ls -l"' >> /wrf/.bashrc \
 && echo 'alias em="emacs -nw"' >> /wrf/.bashrc \
 && echo 'alias cls="clear"' >> /wrf/.bashrc \
 && echo 'alias nobak="rm -rf *~"' >> /wrf/.bashrc

#
# Build WRF first
# input 1 and 1 to configure script alternative line = && echo -e "34\r1\r" | ./configure
#
RUN umask 0002 \
 && cd ./wrf \
 && echo export "LD_LIBRARY_PATH=/usr/lib64/openmpi/lib" >> ./build_real \
 && echo export "PATH=.:/usr/lib64/openmpi/bin:$PATH" >> ./build_real \
 && echo export "LDFLAGS=-lm" >> ./build_real \
 && echo export "NETCDF=/wrf/netcdf_links" >> ./build_real \
 && echo export "JASPERINC=/usr/include/jasper/" >> ./build_real \
 && echo export "JASPERLIB=/usr/lib64/" >> ./build_real \
 && echo export "J='-j 4'" >> ./build_real \
 && echo "./configure <<< $'1\r1\r'" >> ./build_real \
 && echo "sed -i -e '/^DM_CC/ s/$/ -DMPI2_SUPPORT/' ./configure.wrf'" >> ./build_real \
 && echo "sed -i '/BUILD_RRTMG_FAST/d' ./configure.wrf" >> ./build_real \
 && echo "/bin/csh ./compile em_real > compile.log 2>&1" >> ./build_real \
 && chmod +x ./build_real

#
# Build WPS second
#
# input 1 to configure script (gfortran serial build)
#RUN umask 0002 \
# && ln -sf WRF-${WRF_VERSION} WRF \
# && cd ./WPS-${WPS_VERSION} \
# && ./configure <<< $'1\r' \
# && sed -i -e 's/-L$(NETCDF)\/lib/-L$(NETCDF)\/lib -lnetcdff /' ./configure.wps \
# && /bin/csh ./compile > compile_wps.log 2>&1

CMD ["/bin/bash"]
