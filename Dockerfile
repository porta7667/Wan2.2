# --- Base image ---
FROM nvidia/cuda:12.1.1-base-ubuntu22.04

# --- Install Python and system dependencies ---
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 \
    python3-pip \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# --- Working directory ---
WORKDIR /workspace

# --- Copy project files ---
COPY . .

# --- Set environment variables ---
ENV TORCH_CUDA_INDEX_URL=https://download.pytorch.org/whl/cu121 \
    PIP_NO_BUILD_ISOLATION=1 \
    CUDA_HOME=/usr/local/cuda \
    PATH=/usr/local/cuda/bin:$PATH \
    TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6"

# --- Install dependencies in stages ---
# Stage 1: Basic Python tools
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache-dir \
    packaging \
    setuptools \
    wheel \
    pybind11 \
    cmake \
    ninja

# Stage 2: PyTorch installation
RUN python3 -m pip install --no-cache-dir --extra-index-url ${TORCH_CUDA_INDEX_URL} \
    torch==2.5.1+cu121 \
    torchvision==0.20.1+cu121 \
    torchaudio==2.5.1+cu121 && \
    python3 -c "import torch; print('Torch', torch.__version__, 'available.')"

# Stage 3: Flash Attention (if enabled)
ARG INSTALL_FLASH_ATTN=false
RUN if [ "${INSTALL_FLASH_ATTN}" = "true" ]; then \
        echo "Attempting flash-attn install" && \
        python3 -m pip install --no-cache-dir flash-attn==2.8.3; \
    else \
        echo "Skipping flash-attn install (set INSTALL_FLASH_ATTN=true to attempt)"; \
    fi

# Stage 4: Project requirements
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# --- Default command ---
CMD ["python3", "-u", "handler.py"]
