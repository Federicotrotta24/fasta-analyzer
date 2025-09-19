#!/usr/bin/env bash
set -euo pipefail

# ==== Paths ====
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

mkdir -p data qc/raw qc/trimmed results

# ==== Helpers ====
has_pairs=false
pairs=()

# 1) Detecta pares con patrón *_R1/_R2
for r1 in data/*_R1.fastq.gz; do
  [[ -e "$r1" ]] || continue
  base="${r1##*/}"                 # p.ej. ecoli_R1.fastq.gz
  sample="${base%_R1.fastq.gz}"    # p.ej. ecoli
  r2="data/${sample}_R2.fastq.gz"
  if [[ -f "$r2" ]]; then
    pairs+=("${sample}:::${r1}:::${r2}")
    has_pairs=true
  fi
done

# 2) Detecta pares con patrón *_1/_2 (ENA/SRA)
for r1 in data/*_1.fastq.gz; do
  [[ -e "$r1" ]] || continue
  base="${r1##*/}"              # p.ej. SRR2584863_1.fastq.gz
  sample="${base%_1.fastq.gz}"  # p.ej. SRR2584863
  r2="data/${sample}_2.fastq.gz"
  if [[ -f "$r2" ]]; then
    pairs+=("${sample}:::${r1}:::${r2}")
    has_pairs=true
  fi
done

if ! $has_pairs; then
  echo "⚠️  No encontré pares en data/ con *_R1/_R2 ni *_1/_2."
  echo "    Ejemplos válidos:"
  echo "    - data/ecoli_R1.fastq.gz  + data/ecoli_R2.fastq.gz"
  echo "    - data/SRR2584863_1.fastq.gz + data/SRR2584863_2.fastq.gz"
  exit 1
fi

# ==== 1) FastQC (raw) en TODO data/*.fastq.gz ====
echo "▶ FastQC RAW → qc/raw/"
docker run --rm -v "$PWD":/data -w /data \
  biocontainers/fastqc:v0.11.9_cv7 \
  fastqc -o qc/raw data/*.fastq.gz

# ==== 2) fastp (trimming) por cada par ====
for trio in "${pairs[@]}"; do
  IFS=":::" read -r sample r1 r2 <<< "$trio"
  echo "▶ fastp: ${sample}"
  docker run --rm -v "$PWD":/data -w /data \
    quay.io/biocontainers/fastp:0.23.2--h79da9fb_0 \
    fastp \
      -i "$r1" -I "$r2" \
      -o "qc/trimmed/${sample}_R1.trim.fastq.gz" \
      -O "qc/trimmed/${sample}_R2.trim.fastq.gz" \
      -j "qc/trimmed/${sample}.fastp.json" \
      -h "qc/trimmed/${sample}.fastp.html" \
      --thread 4 --cut_front --cut_tail --cut_mean_quality 20 --length_required 30
done

# ==== 3) FastQC (post-trim) sobre los recortados ====
echo "▶ FastQC TRIMMED → qc/trimmed/"
docker run --rm -v "$PWD":/data -w /data \
  biocontainers/fastqc:v0.11.9_cv7 \
  fastqc -o qc/trimmed qc/trimmed/*_R*.trim.fastq.gz

# ==== 4) MultiQC (consolida todo) ====
echo "▶ MultiQC → results/"
docker run --rm -v "$PWD":/data -w /data \
  multiqc/multiqc \
  multiqc -o results .

echo "✅ Listo. Abrí el reporte: open results/multiqc_report.html"
