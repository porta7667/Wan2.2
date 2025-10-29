# --- Base image ---
FROM nvidia/cuda:12.1.1-base-ubuntu22.04

# --- Set environment variables for non-interactive installs ---
ENV DEBIAN_FRONTEND=noninteractive

# --- Install system dependencies ---
RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-pip git libgl1-mesa-glx ffmpeg && rm -rf /var/lib/apt/lists/*

# --- Working directory ---
WORKDIR /workspace

# --- Copy project files ---
COPY . .

# --- Install Python dependencies ---
ENV TORCH_CUDA_INDEX_URL=https://download.pytorch.org/whl/cu121 \
    PIP_NO_CACHE_DIR=1
ARG INSTALL_FLASH_ATTN=false
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install packaging setuptools wheel pybind11 cmake ninja && \
    python3 -m pip install --extra-index-url ${TORCH_CUDA_INDEX_URL} \
      torch==2.5.1+cu121 \
      torchvision==0.20.1+cu121 \
      torchaudio==2.5.1+cu121 && \
    python3 -c "import torch; print('Torch', torch.__version__, 'available.')" && \
    if [ "${INSTALL_FLASH_ATTN}" = "true" ]; then \
        echo "Attempting flash-attn install"; \
        python3 -m pip install --no-build-isolation flash-attn==2.8.3 && \
            echo "flash-attn installed"; \
    else \
        echo "Skipping flash-attn install (set INSTALL_FLASH_ATTN=true to attempt)"; \
    fi && \
    python3 -m pip install -r requirements.txt

# --- Default command ---
CMD ["python3", "-u", "handler.py"]
