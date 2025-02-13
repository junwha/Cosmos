# SPDX-FileCopyrightText: Copyright (c) 2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Use NVIDIA PyTorch container as base image
FROM nvcr.io/nvidia/pytorch:24.10-py3

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy source code
COPY cosmos1 /workspace/cosmos1

# Copy main README
COPY README.md /workspace/

# Copy third-party licenses
COPY ATTRIBUTIONS.md /workspace/

# Copy requirements file
COPY requirements.txt /workspace/

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Nsight
RUN apt-get update -y && apt-get install -y software-properties-common
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub 
RUN add-apt-repository -y "deb https://developer.download.nvidia.com/devtools/repos/ubuntu22.04/$(dpkg --print-architecture)/ /"
RUN apt-get install -y nsight-systems 

# Utils
RUN apt-get install -y vim git bzip2 tmux wget tar htop

# X11 and OpenSSH for GUI
ENV LIBGL_DRIVERS_PATH /usr/lib/x86_64-linux-gnu/dri
ENV LIBGL_ALWAYS_INDIRECT 1
RUN apt-get install -y mesa-utils x11-apps
RUN apt-get install -y freeglut3-dev libglu1-mesa-dev mesa-common-dev libxkbfile-dev libgl1-mesa-glx
RUN apt-get install -y ssh openssh-server
RUN mkdir -p /var/run/sshd
RUN echo "root:root" | chpasswd
RUN echo "Port 22" >> /etc/ssh/sshd_config
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN echo "AddressFamily inet" >> /etc/ssh/sshd_config
RUN echo "X11DisplayOffset 10" >> /etc/ssh/sshd_config
RUN echo "X11UseLocalhost yes" >> /etc/ssh/sshd_config

EXPOSE 22

# Default command
CMD ["/bin/bash"]
