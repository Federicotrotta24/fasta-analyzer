# FASTA Analyzer 🧬

Script en **Python** para analizar archivos FASTA: calcula longitud y %GC por secuencia, exporta resultados a CSV y (opcional) genera gráficos.  
Listo para correr tanto **localmente** como en **Docker**.

---

## 📂 Estructura del proyecto
fasta-analyzer/
├─ analyze_fasta.py # script principal
├─ requirements.txt # dependencias de Python
├─ Dockerfile # receta para contenedor
├─ data/ # colocar FASTA de entrada
├─ results_py/ # resultados del script
└─ .gitignore


---

## ⚙️ Requisitos
- Python 3.10+ (probado en 3.12)
- [pip](https://pip.pypa.io/)
- Docker (opcional, para contenedor)

---

## 🚀 Uso local (con venv)
```bash
# Crear entorno virtual
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip

# Instalar dependencias
pip install -r requirements.txt

# Ejecutar análisis
python analyze_fasta.py --input data/ecoli_K12.fasta --outdir results_py --minlen 1000


# 🐳 Uso con Docker
# Construir imagen
docker build -t fasta-analyzer .

# Ejecutar análisis (monta repo local en /work dentro del contenedor)
docker run --rm -v "$PWD":/work -w /work fasta-analyzer \
  --input data/ecoli_K12.fasta --outdir results_py --minlen 1000



# 📊 Salida esperada

Ejemplo de CSV:

id,description,length,gc_pct
NC_000913.3,"Escherichia coli K-12 MG1655, complete genome",4641652,50.791
