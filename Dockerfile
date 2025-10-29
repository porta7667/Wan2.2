# --- Base image ---
FROM nvidia/cuda:12.1.1-base-ubuntu22.04

# --- Install Python and system dependencies ---
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    git \
    build-essential \
    cuda-toolkit-12-1 \
    && rm -rf /var/lib/apt/lists/*

# --- Set environment variables ---
ENV TORCH_CUDA_INDEX_URL=https://download.pytorch.org/whl/cu121 \
    CUDA_HOME=/usr/local/cuda \
    PATH=/usr/local/cuda/bin:$PATH \
    FORCE_CUDA=1 \
    TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6"

# --- Working directory ---
WORKDIR /workspace

# --- Copy requirements first ---
COPY requirements.txt .

# --- Install PyTorch and dependencies in stages ---
RUN python3 -m pip install --upgrade pip && \
    # Stage 1: Install build tools
    python3 -m pip install --no-cache-dir \
    packaging \
    setuptools \
    wheel \
    pybind11 \
    cmake \
    ninja && \
    # Stage 2: Install PyTorch
    python3 -m pip install --no-cache-dir --extra-index-url ${TORCH_CUDA_INDEX_URL} \
    torch==2.5.1+cu121 \
    torchvision==0.20.1+cu121 \
    torchaudio==2.5.1+cu121 && \
    python3 -c "import torch; assert torch.cuda.is_available(), 'CUDA not available'"

# --- Install project requirements ---
RUN pip install --no-cache-dir -r requirements.txt

# --- Copy remaining project files ---
COPY . .

# --- Install Flash Attention (optional) ---
ARG INSTALL_FLASH_ATTN=false
RUN if [ "${INSTALL_FLASH_ATTN}" = "true" ]; then \
        python3 -m pip install --no-cache-dir flash-attn==2.8.3; \
    fi

# --- Default command ---
CMD ["python3", "-u", "handler.py"]
