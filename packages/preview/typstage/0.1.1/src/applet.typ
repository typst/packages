// The applet document that goes into the frame.


/// Colour as three 0…255 components, the way the GeoGebra API wants it.
#let rgb255(c) = {
  let p = rgb(c).components()
  (int(calc.round(p.at(0) / 100% * 255)),
   int(calc.round(p.at(1) / 100% * 255)),
   int(calc.round(p.at(2) / 100% * 255)))
}

/// Das Bootskript, beim Übersetzen gelesen.
///
/// Es liegt bei den Laufzeitdateien in `assets/`, denn es ist eine: Code, der
/// im Browser läuft und nicht in Typst. Ohne Versionsnummer im Namen, anders
/// als die beiden anderen -- die tragen sie, damit ein CDN mehrere Fassungen
/// nebeneinander halten kann, und dieses Skript geht nie über ein CDN. Es
/// steht wörtlich im `srcdoc` des Rahmens.
#let boot = read("../assets/geogebra-boot.js")

/// Build the standalone document for one applet.
///
/// It is a document of its own, not a `div` in the slide: the runtime always
/// keeps the previous and the next step around, so the snippet would otherwise
/// sit in the same page three times over.
#let applet-document(
  name, material, app, perspective, language, grid, axes,
  seamless, background, animation-button, codebase, width, height,
  pan, font-size,
) = {
  let params = (
    appName: app,
    width: int(calc.round(width)),
    height: int(calc.round(height)),
    showToolBar: false, showAlgebraInput: false, showMenuBar: false,
    enableRightClick: false, showResetIcon: false,
    // Den Ausschnitt zieht die Folie, nicht die Hand. Wer im Vortrag danebengreift,
    // schöbe sonst die ganze Ebene weg, und die Konstruktion ist fort. `pan: true`
    // gibt es zurück, wo das Verschieben zur Sache gehört.
    enableShiftDragZoom: pan,
    showAnimationButton: animation-button,
    ..if seamless { (borderColor: "none") },
    ..if material != none { (material_id: material) },
    ..if perspective != none { (perspective: perspective) },
    ..if language != none { (language: language) },
    ..if grid != auto { (showGrid: grid) },
    ..if axes != auto { (showAxes: axes) },
  )
  let boot-js = boot
    .replace("__PARAMS__", json.encode(params))
    .replace("__ID__", json.encode(name))
    .replace("__SCHRIFT__", str(calc.round(font-size)))
    .replace("__BOOTVIEW__", if seamless {
      "try{a.setGraphicsOptions(1,{bgColor:" + json.encode(background.to-hex()) + "});}catch(e){}"
    } else { "" })
  (
    "<!doctype html><meta charset=\"utf-8\">"
      + "<style>html,body{margin:0;height:100%;overflow:hidden"
      + (if seamless { ";background:" + background.to-hex() } else { "" }) + "}"
      + ".ts-fit{width:100%;height:100%}"
      // GeoGebra's own frame container is white and sits a pixel around the
      // drawing area — otherwise a bright ring would remain.
      + (if seamless {
           ".GeoGebraFrame{background:" + background.to-hex() + "!important;border:0!important}"
         } else { "" })
      + "</style>"
      + "<div id=\"ts-ggb\" class=\"ts-fit\"></div>"
      + "<script src=\"" + codebase.trim("/") + "/deployggb.js\"></script>"
      + "<script>" + boot-js + "</script>"
  )
}
