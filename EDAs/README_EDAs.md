# EDAs Género musical

Notebooks de análisis exploratorio listos para abrir en **Jupyter, VS Code, Cursor o PyCharm**. No hace falta Google Colab.

## Estructura

```
EDAs/
  Data/
    raw/          # JSON y CSV originales
    processed/    # dataframes generados tras el EDA
  Notebooks/      # análisis exploratorio
  requirements.txt
  README.md
```

### Notebooks

| Notebook | Origen | Genera |
|---|---|---|
| `Procesamiento de datos de CancionInfo.ipynb` | `cancioninfo.json` | `cancion.csv`, `cancion_ids.csv`, `id_disco.csv`, `id_genero.csv` |
| `Procesamiento de datos de Fecha Publicacion.ipynb` | `fecha.json` | `fecha_publicacion.csv`, `fecha_limpio.csv` |
| `Procesamiento de datos de artista_info.ipynb` | `artistainfo.json` | `artistas.csv`, `artistas_ids.csv`, `artistas_sql.csv`, `id_artistas_sql.csv` |
| `Procesamiento de datos de Favoritos.ipynb` | `favoritos.json` + `cancion_ids.csv` | `favoritos.csv`, `favoritos_eda.csv` |
| `Procesamiento de datos de Listas.ipynb` | `listas.json` + `cancion_ids.csv` | `listas_canciones.csv` |
| `Procesamiento de datos de Popularidad.ipynb` | `popularidad.json` + `cancion.csv` | `popularidad.csv` |
| `Procesamiento de datos de features_3_sec.ipynb` | `features_3_sec.csv` (raw) | `features_3_sec.csv` (processed) |
| `Procesamiento de datos de features_30_sec.ipynb` | `features_30_sec.csv` (raw) | `features_30_sec.csv` (processed) |
| `Comparativa 30 sg vs 3 sg.ipynb` | `features_3_sec.csv` y `features_30_sec.csv` (processed) | — (solo análisis) |

### Datos

- **Raw:** `cancioninfo.json`, `fecha.json`, `artistainfo.json`, `favoritos.json`, `listas.json`, `popularidad.json`, `features_3_sec.csv`, `features_30_sec.csv`
- **Processed:** `cancion.csv`, `cancion_ids.csv`, `id_disco.csv`, `id_genero.csv`, `fecha_publicacion.csv`, `fecha_limpio.csv`, `artistas.csv`, `artistas_ids.csv`, `artistas_sql.csv`, `id_artistas_sql.csv`, `favoritos.csv`, `favoritos_eda.csv`, `listas_canciones.csv`, `popularidad.csv`, `features_3_sec.csv`, `features_30_sec.csv`

## Cómo empezar

1. Abre esta carpeta `EDAs` como proyecto en tu editor o en Jupyter.
2. Instala dependencias (recomendado en un entorno virtual):

```bash
pip install -r requirements.txt
```

3. Abre cualquier `.ipynb` de `Notebooks/`. El kernel debe ser **Python 3**.

Las rutas son relativas a la raíz del proyecto. Funcionan tanto si el directorio de trabajo es `EDAs/` como si es `Notebooks/`.

Si acabas de cambiar el nombre de la carpeta del proyecto, **reinicia el kernel** antes de ejecutar.

## Orden de ejecución

Algunos notebooks leen CSV que generan otros:

1. `Procesamiento de datos de CancionInfo.ipynb`
2. `Procesamiento de datos de Fecha Publicacion.ipynb`
3. `Procesamiento de datos de artista_info.ipynb`
4. Vuelve a ejecutar en CancionInfo las celdas de unión con artistas (si `artistas_ids.csv` no existía aún) para completar `cancion.csv`
5. `Procesamiento de datos de Favoritos.ipynb` y `Procesamiento de datos de Listas.ipynb`
6. `Procesamiento de datos de Popularidad.ipynb`
7. `Procesamiento de datos de features_3_sec.ipynb` y `Procesamiento de datos de features_30_sec.ipynb` (independientes)
8. `Comparativa 30 sg vs 3 sg.ipynb` — compara las features de 30 s y 3 s ya procesadas

Los archivos de `Data/processed/` se crean al ejecutar las celdas de guardado de cada notebook. Esta carpeta ya incluye una primera versión de esos CSV.
