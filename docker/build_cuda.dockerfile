FROM nvidia/cuda:11.2.1-cudnn8-devel-ubuntu16.04

RUN apt-get update --fix-missing

COPY install/ubuntu_install_core.sh /install/ubuntu_install_core.sh
RUN bash /install/ubuntu_install_core.sh

COPY install/ubuntu_install_build.sh /install/ubuntu_install_build.sh
RUN bash /install/ubuntu_install_build.sh

COPY install/ubuntu_install_gcc9.sh /install/ubuntu_install_gcc9.sh
RUN bash /install/ubuntu_install_gcc9.sh

COPY install/ubuntu_install_gflags.sh /install/ubuntu_install_gflags.sh
RUN bash /install/ubuntu_install_gflags.sh

ENV ARROW_CUDA=ON
ENV LIBRARY_PATH=$LIBRARY_PATH:/usr/local/cuda/lib64/stubs

COPY install/ubuntu_install_arrow.sh install/ubuntu_install_arrow.sh
RUN bash /install/ubuntu_install_arrow.sh