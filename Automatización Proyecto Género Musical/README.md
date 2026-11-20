# Proyecto Género Musical

Clasificación supervisada del género musical. La variable objetivo es `id_genero` (10 clases, con el mismo número de canciones en cada una). Cada canción pertenece a un solo género.

El reparto de entrenamiento y prueba es común a todo el grupo: 800 y 200 canciones, estratificado por `id_genero`, semilla 42, separado por `id_cancion`. Así, los fragmentos de una misma canción no quedan repartidos entre train y test. La clase asignada es la de mayor probabilidad o la de mayor voto. No se exige una probabilidad mínima.

Las métricas son el accuracy y el F1 macro. Con las clases equilibradas, el accuracy resume el acierto global. El F1 macro da el mismo peso a los 10 géneros. En la comparativa final también se recoge el tiempo de entrenamiento del modelo evaluado.

Los notebooks se pueden ejecutar en Jupyter, Visual Studio Code y Colab. Localizan solos las carpetas `datos originales` y `datos preprocesados` a partir de la carpeta del notebook o del directorio de trabajo. En Colab también los encuentran si el proyecto se descomprime en `/content`. Si los CSV se suben sueltos, junto a `sample_data`, sirven igual. No hay que buscarlos a mano.

Los CSV de `datos preprocesados` ya están generados. Para corregir basta con abrir cada notebook en el orden de abajo. Solo hace falta volver a ejecutar el preprocesado y la selección si se quieren regenerar esas tablas.

## Carpetas

```
datos originales/       tablas de partida
datos preprocesados/    tablas ya unidas y el reparto train/test
Algoritmos/             modelos y comparativa
```

En la raíz están los notebooks de exploración, preprocesado y reparto.

### datos originales

| Archivo | Qué es |
| :---- | :---- |
| `cancion.csv` | Una fila por canción: identificadores, título, duración, coste y `id_genero`. La duración viene en texto (`00:02:18`). |
| `features_30_sec.csv` | Características de audio del tramo de 30 segundos. Una fila por canción. |
| `features_3_sec.csv` | Las mismas características sobre fragmentos de unos 3 segundos. Varias filas por canción. |

### datos preprocesados

| Archivo | Qué es | Quién lo usa |
| :---- | :---- | :---- |
| `df_modelo_30.csv` | Unión de `cancion.csv` con las features de 30 s. 1000 canciones y 68 columnas. La duración sigue en texto. | La selección de train y test. |
| `df_cancion_30s.csv` | La misma unión, con la duración pasada a segundos. Es la tabla que pueden entrenar los modelos. | XGBoost, ANN, KNN y Naive Bayes. |
| `df_cancion_3s.csv` | Cada fragmento de 3 s unido a los datos de su canción. | GRU y LSTM. |
| `df_macro.csv` | Fragmentos de 3 s, features de 30 s e identificadores de la canción en la misma fila. | Random Forest, LightGBM y RNN simple. |
| `df_30s_3.csv` | Cada fragmento de 3 s unido solo a las features de 30 s de su canción. No es la tabla de una fila por canción. | Ningún modelo. Queda como resultado del preprocesado. |
| `ids_train.csv` | 800 `id_cancion` de entrenamiento. | Todos los modelos. |
| `ids_test.csv` | 200 `id_cancion` de prueba. | Todos los modelos. |

`df_modelo_30.csv` y `df_cancion_30s.csv` tienen las mismas filas, las mismas columnas y los mismos valores de audio. La única diferencia es `duracion`: texto en el primero y segundos en el segundo. XGBoost y la ANN usan esa columna como número, así que leen `df_cancion_30s.csv`.

## Orden de ejecución

### 1\. Exploración

Estos tres notebooks solo leen `datos originales`. Se encuentran en la carpeta `Trabajo previo` y no generan las tablas de los modelos y pueden ejecutarse en cualquier orden.

1. `Procesamiento de datos de features_30_sec .ipynb`  
2. `Procesamiento de datos de features_3_sec .ipynb`  
3. `analisis previo ML Cancion.ipynb`

### 2\. Construcción de las tablas

4. `preprocesado datos ML.ipynb`

Lee los tres CSV originales y guarda `df_modelo_30.csv`, `df_macro.csv`, `df_cancion_3s.csv` y `df_30s_3.csv`. No vuelve a escribir `df_cancion_30s.csv`: ese archivo es `df_modelo_30` con la duración ya convertida a segundos.

5. `seleccion train y test ML.ipynb`

Lee `df_modelo_30.csv` y `df_macro.csv`. Guarda `ids_train.csv` e `ids_test.csv`. Tiene que ejecutarse después del preprocesado si esas tablas se regeneran. Con la semilla 42 el reparto se mantiene.

### 3\. Modelos

Los notebooks de `Algoritmos` pueden ejecutarse en cualquier orden. Todos leen `datos preprocesados` y el mismo train/test.

| Notebook | Modelo | Entrada |
| :---- | :---- | :---- |
| `Alex - RandomForestClassifier.ipynb` | Random Forest | `df_macro.csv`. Predice el fragmento y, por voto mayoritario, la canción. |
| `Ana-LGBM macro.ipynb` | LightGBM | `df_macro.csv`. Igual que el Random Forest: fragmento y voto por canción. |
| `Gema - XGBoost (ML).ipynb` | XGBoost | `df_cancion_30s.csv`. Una predicción por canción. |
| `Miriam-KNN y Naives bayes(ML).ipynb` | KNN y Naive Bayes | `df_cancion_30s.csv`. Una predicción por canción. |
| `Gema-ANN (DL).ipynb` | Red neuronal densa | `df_cancion_30s.csv`. Una predicción por canción. |
| `Alex - GRU.ipynb` | GRU | `df_cancion_3s.csv`, leído como secuencia de fragmentos de la misma canción. |
| `Ana-RNN.ipynb` | RNN simple | `df_macro.csv`, leído como secuencia de fragmentos, sin las columnas de 30 s. |
| `Miriam-LSTM (DL).ipynb` | LSTM | `df_cancion_3s.csv`. Cada fragmento es una muestra y los pasos de la secuencia son sus características de audio. |

### 4\. Comparativa

6. `Algoritmos/Comparativa final.ipynb`

No entrena nada. Resume por qué se eligió cada familia de modelos, las diferencias entre la RNN simple, la LSTM y la GRU, los tiempos de entrenamiento y las tablas de accuracy y F1 macro. Se lee al final.