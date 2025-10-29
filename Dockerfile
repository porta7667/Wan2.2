ENV TORCH_CUDA_INDEX_URL=https://download.pytorch.org/whl/cu121 \
    PIP_NO_BUILD_ISOLATION=1
ARG INSTALL_FLASH_ATTN=false
RUN python3 -m pip install --upgrade pip \
 && python3 -m pip install --no-cache-dir packaging setuptools wheel pybind11 cmake ninja \
 && python3 -m pip install --no-cache-dir --extra-index-url ${TORCH_CUDA_INDEX_URL} \
      torch==2.5.1+cu121 \
      torchvision==0.20.1+cu121 \
      torchaudio==2.5.1+cu121 \
 && python3 -c "import torch; print('Torch', torch.__version__, 'available.')" \
 && if [ "${INSTALL_FLASH_ATTN}" = "true" ]; then \
        echo "Attempting flash-attn install"; \
        if python3 -m pip install --no-cache-dir --no-build-isolation --no-deps flash-attn==2.8.3; then \
            echo "flash-attn installed"; \
        else \
            echo "⚠️ flash-attn install failed; attention optimizations disabled"; \
        fi; \
    else \
        echo "Skipping flash-attn install (set INSTALL_FLASH_ATTN=true to attempt)"; \
    fi \
 && python3 -m pip install --no-cache-dir -r requirements.txt


