# --- Base image ---
FROM nvidia/cuda:12.1.1-base-ubuntu22.04

# --- Install Python and system dependencies ---
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 \
    python3-pip \
    git \
    curl \
    wget \
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
    PATH=/usr/local/cuda/bin:$PATH

# --- Install Python dependencies ---
ARG INSTALL_FLASH_ATTN=false

# Install base Python packages
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache-dir \
    packaging \
    setuptools \
    wheel \
    pybind11 \
    cmake \
    ninja

# Install PyTorch
RUN python3 -m pip install --no-cache-dir --extra-index-url ${TORCH_CUDA_INDEX_URL} \
    torch==2.5.1+cu121 \
    torchvision==0.20.1+cu121 \
    torchaudio==2.5.1+cu121 && \
    python3 -c "import torch; print('Torch', torch.__version__, 'available.')"

# Install flash-attention if enabled
RUN if [ "${INSTALL_FLASH_ATTN}" = "true" ]; then \
        echo "Attempting flash-attn install"; \
        if python3 -m pip install --no-cache-dir flash-attn==2.8.3; then \
            echo "flash-attn installed"; \
        else \
            echo "⚠️ flash-attn install failed; attention optimizations disabled"; \
        fi; \
    else \
        echo "Skipping flash-attn install (set INSTALL_FLASH_ATTN=true to attempt)"; \
    fi

# Install remaining requirements
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# --- Default command ---
CMD ["python3", "-u", "handler.py"]
