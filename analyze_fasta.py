import argparse
from Bio import SeqIO
from pathlib import Path
import pandas as pd

def gc_pct(seq: str) -> float:
    seq = seq.upper()
    if not seq:
        return 0.0
    g = seq.count("G")
    c = seq.count("C")
    return 100.0 * (g + c) / len(seq)
    
def main():
    p = argparse.ArgumentParser(description="Resumen por secuencia de un FASTA")
    p.add_argument("--input", required=True, help="Archivo FASTA (ej: data/ecoli_K12.fasta)")
    p.add_argument("--outdir", required=True, help="Directorio de salida (ej: results_py)")
    p.add_argument("--minlen", type=int, default=0, help="Filtrar secuencias con longitud < minlen")
    args = p.parse_args()

    in_path = Path(args.input)
    outdir = Path(args.outdir); outdir.mkdir(parents=True, exist_ok=True)

    records = list(SeqIO.parse(str(in_path), "fasta"))
    rows = []
    for r in records:
        L = len(r.seq)
        if L < args.minlen:
            continue
        rows.append({
            "id": r.id,
            "description": r.description,
            "length": L,
            "gc_pct": round(gc_pct(str(r.seq)), 3),
        })

    df = pd.DataFrame(rows).sort_values("length", ascending=False)
    csv_path = outdir / (in_path.stem + "_summary.csv")
    df.to_csv(csv_path, index=False)

    # pequeña salida por consola
    n = len(df)
    total_bp = int(df["length"].sum()) if n else 0
    print(f"OK ✔  {n} secuencias   total_bp={total_bp}   csv={csv_path}")
    
    
if __name__ == "__main__":
    main()