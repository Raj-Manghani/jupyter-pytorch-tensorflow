FROM quay.io/jupyter/tensorflow-notebook:latest
USER root
RUN apt-get update && apt-get install -y \
    build-essential \
    libjpeg-dev \
    libpng-dev \
    && rm -rf /var/lib/apt/lists/*
RUN conda update -n base -c conda-forge conda -y
# Reinstall TensorFlow 2.19.0 with GPU support
RUN pip install --force-reinstall tensorflow==2.19.0
# Install PyTorch 2.5.1 with CUDA 12.1
RUN pip install torch==2.5.1 torchvision==0.20.1 -f https://download.pytorch.org/whl/cu121
RUN pip install fastai fastbook
USER ${NB_UID}
WORKDIR /home/jovyan/work
