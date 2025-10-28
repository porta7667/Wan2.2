# --- Base image ---
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121


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
