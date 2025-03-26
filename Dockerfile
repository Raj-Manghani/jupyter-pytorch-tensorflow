# NOTES: Host should have persistent folder UID & GID set to 1000:1000 (i.e. ~/jupyter_data)

# Description:  This Dockerfile combines compatible version of FastAI, pytorch, tensorflow, NVIDA GPU support and Jupyter Labs/Notebook.

# NVIDIA Driver/CUDA Used  >>>> NVIDIA Driver Version: 570.124.06     CUDA Version: 12.8   

# Example Docker Commands:  
# >>>> docker build -t fastai-tf-pyt-jupyter-03262025 .

# >>>> docker run -d --gpus all -p 8888:8888 -v /root/jupyter_data:/home/jovyan/work fastai-tf-pyt-jupyter-03262025

# Use a non-deprecated CUDA 12.4.1 base
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    NB_UID=1000 \
    NB_GID=100 \
    HOME=/home/jovyan \
    PATH="/usr/local/bin:${PATH}" \
    TF_CPP_MIN_LOG_LEVEL=2

# Install system dependencies as root
RUN apt-get update && apt-get install -y \
    build-essential \
    libjpeg-dev \
    libpng-dev \
    python3.11 \
    python3.11-dev \
    python3.11-distutils \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default and upgrade pip
RUN ln -sf /usr/bin/python3.11 /usr/bin/python3 \
    && ln -sf /usr/bin/python3.11 /usr/bin/python \
    && ln -sf /usr/bin/pip3 /usr/bin/pip \
    && python3.11 -m pip install --upgrade pip

# Create jovyan user and set up home directory
RUN useradd -m -u ${NB_UID} -g ${NB_GID} -s /bin/bash jovyan \
    && mkdir -p ${HOME}/work \
    && chown -R ${NB_UID}:${NB_GID} ${HOME}

# Install Python packages as root (system-wide)
RUN python3.11 -m pip install \
    torch==2.1.0+cu121 \
    torchvision==0.16.0+cu121 \
    torchaudio==2.1.0+cu121 \
    -f https://download.pytorch.org/whl/torch_stable.html \
    --no-cache-dir

RUN python3.11 -m pip install tensorflow==2.19.0 --no-cache-dir

RUN python3.11 -m pip install fastai==2.7.15 fastbook==0.0.29 --no-cache-dir

RUN python3.11 -m pip install jupyter notebook jupyter-resource-usage ipympl ipykernel --no-cache-dir \
    && python3.11 -m ipykernel install --name fastai_env --display-name "FastAI+TF Env" \
    && jupyter kernelspec uninstall -y python3

RUN python3.11 -m pip install numpy==1.26.4 psutil==5.9.8 ipython==8.27.0 numba==0.60.0 --no-cache-dir --force-reinstall

# Switch to jovyan user
USER jovyan
WORKDIR ${HOME}/work

# Expose Jupyter port
EXPOSE 8888

# Start Jupyter
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
