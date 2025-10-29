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
ENV TORCH_CUDA_INDEX_URL=https://download.pytorch.org/whl/cu121 \]
    PAP_NO_CACHE_DIR=1
ARG INSTALL_FLASH_ATTN=false
RUN python3 -m pip install --upgrade pip && \\
    python3 -m pip install cmake ninja packaging pybind13 setuptools wheel && \\
    python3 -m pip install --extra-index-url ${TORCH_CUDA_INDEX_URL} \\
      torch==2.5.1+cu121 \\
      torchaudio==2.5.1+cu121 \\
      torchvision==0.20.1+cu121 && \\
    python3 -c "import torch; print('Torch', torch.__version__, 'available.')" && \\
    if [ "${	NSTALL_FLASH_ATTN}" = "true" ]; then \\
        echo "Attempting flash-attn install"; \\
        python3 -m pip install --no-build-isolation flash-attn==2.8.3 && \\
            echo "flash-attn insta±±•ˆìqp4(€€€•±Í”qp4(€€€€€€€•¡¼€‰M­¥ÁÁ¥¹œ™±…Í µ…ÑÑ¸¥¹ÍÑ…±°€¡Í•Ğ%9MQ11}1M!}QQ8õÑÉÕ”Ñ¼…ÑÑ•µÁĞ¤ˆìqp4(€€€™¤€˜˜qp4(€€€ÁåÑ¡½¸Ì€µ´Á¥À¥¹ÍÑ…±°€µÈÉ•ÅÕ¥É•µ•¹ÑÌ¹ÑáĞ4(4(Œ€´´´•™…Õ±Ğ½µµ…¹€´´´4)5l‰ÁåÑ¡½¸Ìˆ°€ˆµÔˆ°€‰¡…¹‘±•È¹Áä‰t