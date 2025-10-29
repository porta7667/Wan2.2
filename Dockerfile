# --- Base image ---
FROM nvidia/cuda:12.1.1-base-ubuntu22.04

# --- Install Python and system dependencies ---
# 👇 This section is key — note the addition of git
RUN apt-get update && \
    apt-get install -y python3 python3-pip git && \
    rm -rf /var/lib/apt/lists/*

# --- Working directory ---
WORKDIR /workspace

# --- Copy project files ---
COPY . .

# --- Install Python dependencies ---
RUN python3 -m pip install --upgrade pip \
 && python3 -m pip install --no-cache-dir packaging setuptools wheel pybind11 cmake ninja \
 && python3 -m pip install --no-cache-dir \
      torch==2.5.1+cu121 \
      torchvision==0.20.1+cu121 \
      torchaudio==2.5.1+cu121 \
      --index-url https://download.pytorch.org/whl/cu121 \
 && (python3 -m pip install --no-cache-dir --no-build-isolation flash-attn==2.8.3 \
     || (echo "⚠️ flash-attn skipped; attention optimizations disabled" && true)) \
 && python3 -m pip install --no-cache-dir -r requirements.txt


# --- Default command ---
CMD ["python3", "-u", "handler.py"]

