# --- Base image ---
FROM nvidia/cuda:12.1.1-base-ubuntu22.04

# --- Install Python and system dependencies ---
RUN apt-get update && \
    apt-get install -y python3 python3-pip git && \
    rm -rf /var/lib/apt/lists/*

# --- Working directory ---
WORKDIR /workspace

# --- Copy project files ---
COPY . .

# --- Install Python dependencies ---
RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# --- Default command ---
CMD ["python3", "-u", "handler.py"]

