// Renderizado a través del espacio `appendix` de la plantilla: aparece después
// de las referencias, con encabezados numerados con letras (A, A.1, ...).

= Material complementario

Usa el apéndice para material que respalde la tesis pero que interrumpiría el
texto principal: tablas extensas, figuras adicionales, derivaciones,
cuestionarios o notas sobre dónde encontrar tu código y tus datos. Los
encabezados del apéndice se numeran con letras (A, A.1, A.2, ...) para que se
distingan claramente de los capítulos numerados.

== Disponibilidad de código y datos

Si tu trabajo involucra software o datos, indica claramente dónde puede
encontrarlos el lector. Un señalamiento corto y directo suele bastar:

#align(center)[
  #link("https://github.com/your-handle/your-project")
]

== Reproducción de un análisis

También puedes registrar los comandos exactos usados para producir un resultado,
de modo que pueda reproducirse. Los listados más largos se renderizan en un
bloque de código sombreado:

```sh
# Ejemplo: regenerar el conjunto de datos procesado a partir de la entrada sin procesar
python scripts/build_dataset.py \
    --input data/raw.tsv \
    --threshold 0.80 \
    --output data/processed.tsv
```

Agrega tantas secciones de apéndice como necesites; cada nuevo encabezado de
nivel uno en este archivo se convierte en el siguiente apéndice con letra
(B, C, ...).
