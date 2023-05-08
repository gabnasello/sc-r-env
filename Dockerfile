# docker-stacks/r-notebook [https://github.com/jupyter/docker-stacks/tree/master/r-notebook]
# https://hub.docker.com/r/jupyter/r-notebook/dockerfile

FROM jupyter/r-notebook:2023-03-27

# Configure environment
ENV DOCKER_IMAGE_NAME='sc-r-env'
ENV VERSION='2023-05-07' 

# Docker name to shell prompt
ENV PS1A="[docker] \[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$"
RUN echo 'PS1=$PS1A' >> ~/.bashrc
RUN echo 'conda activate base' >> ~/.bashrc

# How to connect all conda envs to jupyter notebook
# https://stackoverflow.com/questions/61494376/how-to-connect-r-conda-env-to-jupyter-notebook
RUN conda install -y -n base nb_conda_kernels

# Install packages in environment.yml file
ADD environment.yml .
RUN /bin/bash -c "conda env update --file environment.yml"

USER root
RUN apt-get update && \ 
    apt install -yq apt-utils build-essential libfontconfig1-dev tmux cmake vim
USER jovyan

# Install R packages
ADD install_r_packages.R /
RUN Rscript /install_r_packages.R

# Set the jl command to create a JupytetLab shortcut
ADD scripts/launch_jupyterlab.sh /
RUN echo "alias jl='bash /launch_jupyterlab.sh'" >> ~/.bashrc

ADD scripts/entrypoint.sh /
ADD scripts/message.sh /
RUN echo "bash /message.sh" >> ~/.bashrc