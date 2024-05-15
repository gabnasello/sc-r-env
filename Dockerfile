FROM quay.io/jupyter/r-notebook:2023-12-14

# Configure environment
ENV DOCKER_IMAGE_NAME='sc-r-env'
ENV VERSION='2024-05-15' 

# Remove work directory
RUN rm -r /home/jovyan/work

# How to connect all conda envs to jupyter notebook
# https://stackoverflow.com/questions/61494376/how-to-connect-r-conda-env-to-jupyter-notebook
RUN conda install -y -n base nb_conda_kernels

# Install packages in environment.yml file
ADD environment.yml .
RUN /bin/bash -c "conda env update --file environment.yml"

# Remove environment.yml file
RUN rm environment.yml

USER root
RUN apt-get update && \ 
    apt install -yq apt-utils build-essential libfontconfig1-dev tmux cmake vim
USER jovyan

# Install R packages
ADD install_r_packages.R /
RUN Rscript /install_r_packages.R

RUN echo "alias jl='jupyter server list'" >> ~/.bashrc