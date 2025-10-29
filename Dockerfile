# Use NVIDIA CUDA runtime image
FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TORCH_CUDA_INDEX_URL=https://download.pytorch.org/whl/cu121 \
    CUDA_HOME=/usr/local/cuda \
    PATH=/usr/local/cuda/bin:$PATH \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    git \
    build-essential \
    cuda-toolkit-12-1 \
    cuda-libraries-dev-12-1 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy requirements first
COPY requirements.txt .

# Install Python dependencies in stages
RUN python3 -m pip install --upgrade pip && \
    # Base tools
    python3 -m pip install --no-cache-dir \
    packaging \
    setuptools \
    wheel \
    pybind11 \
    cmake \
    ninja && \
    # PyTorch with CUDA support
    python3 -m pip install --no-cache-dir --extra-index-url ${TORCH_CUDA_INDEX_URL} \
    torch==2.5.1+cu121 \
    torchvision==0.20.1+cu121 \
    torchaudio==2.5.1+cu121 && \
    # Verify CUDA availability
    python3 -c "import torch; print('CUDA available:', torch.cuda.is_available())"

# Install project requirements
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# Copy remaining project files
COPY . .

# Default command
CMD ["python3", "-u", "handler.py"]
