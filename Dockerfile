FROM python:3.12-slim

# Evitar prompts y mejorar logs
ENV PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1

WORKDIR /app
COPY requirements.txt .
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
 && rm -rf /var/lib/apt/lists/* \
 && pip install -r requirements.txt

# Copiamos solo lo necesario
COPY analyze_fasta.py .

# Por defecto ejecuta el analizador; pasá args con docker run
ENTRYPOINT ["python", "analyze_fasta.py"]
