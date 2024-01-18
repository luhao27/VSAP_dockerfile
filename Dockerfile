FROM ubuntu:18.04

COPY ./sources.list /etc/apt/sources.list

RUN cat /etc/apt/sources.list

Run apt-get clean && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    cmake pkg-config build-essential wget rsync

RUN wget --no-check-certificate https://registrationcenter-download.intel.com/akdlm/irc_nas/18445/l_BaseKit_p_2022.1.1.119_offline.sh && \
    sh ./l_BaseKit_p_2022.1.1.119_offline.sh -a -s --eula accept --components intel.oneapi.lin.mkl.devel
RUN wget --no-check-certificate https://registrationcenter-download.intel.com/akdlm/irc_nas/18438/l_HPCKit_p_2022.1.1.97_offline.sh && \
    sh ./l_HPCKit_p_2022.1.1.97_offline.sh -a -s --eula accept \
         --components intel.oneapi.lin.mpi.devel:intel.oneapi.lin.ifort-compiler:intel.oneapi.lin.dpcpp-cpp-compiler-pro

RUN . /opt/intel/oneapi/setvars.sh && cd /opt/intel/oneapi/mkl/latest/interfaces/fftw3xf/ && make libintel64


COPY ./vasp.6.1.2.tar.gz .

RUN tar -zxvf vasp.6.1.2.tar.gz && cd vasp.6.1.2_patched/ && cp arch/makefile.include.linux_intel makefile.include &&\
    sed -i 's/\/path\/to\/your\/mkl\/installation//' makefile.include && \
    . /opt/intel/oneapi/setvars.sh && make std

RUN rm -rf /var/lib/apt/lists/* && cp /vasp.6.1.2_patched/bin/* /bin/ && rm -rf l_* vasp*

ENV LD_LIBRARY_PATH='/opt/intel/oneapi/mpi/2021.5.0//libfabric/lib:/opt/intel/oneapi/mpi/2021.5.0//lib/release:/opt/intel/oneapi/mpi/2021.5.0//lib:/opt/intel/oneapi/mkl/2022.0.1/lib/intel64' \
        FI_PROVIDER_PATH='/opt/intel/oneapi/mpi/2021.5.0//libfabric/lib/prov:/usr/lib64/libfabric' \
        CPATH='/opt/intel/oneapi/mpi/2021.5.0//include:/opt/intel/oneapi/mkl/2022.0.1/include' \
        PATH='/opt/intel/oneapi/mpi/2021.5.0//libfabric/bin:/opt/intel/oneapi/mpi/2021.5.0//bin:/opt/intel/oneapi/mkl/2022.0.1/bin/intel64:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:'
