# --- Base image ---
FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

# --- Environment variables ---
ENV DEBIAN_FRONTEND=noninteractive \
    TORCH_CUDA_INDEX_URL=https://download.pytorch.org/whl/cu121 \
    CUDA_HOME=/usr/local/cuda \
    PATH=/usr/local/cuda/bin:$PATH \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# --- Install system dependencies ---
RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# --- Working directory ---
WORKDIR /workspace

# --- Copy requirements first ---
COPY requirements.txt .

# --- Install PyTorch and dependencies ---
RUN python3 -m pip install --upgrade pip && \
    # Base tools
    python3 -m pip install --no-cache-dir \
    packaging \
    setuptools \
    wheel \
    pybind11 \
    cmake \
    ninja && \
    # PyTorch with CUDA
    python3 -m pip install --no-cache-dir --extra-index-url ${TORCH_CUDA_INDEX_URL} \
    torch==2.5.1+cu121 \
    torchvision==0.20.1+cu121 \
    torchaudio==2.5.1+cu121 && \
    # Verify PyTorch installation
    python3 -c "import torch; print('PyTorch', torch.__version__)"

# --- Install Flash Attention (optional) ---
ARG INSTALL_FLASH_ATTN=false
RUN if [ "${INSTALL_FLASH_ATTN}" = "true" ]; then \
        python3 -m pip install --no-cache-dir flash-attn==2.8.3; \
    fi

# --- Install remaining requirements ---
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# --- Copy project files ---
COPY . .

# --- Default command ---
CMD ["python3", "-u", "handler.py"]
