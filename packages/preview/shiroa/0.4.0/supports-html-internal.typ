
#import "html-bindings.typ": *
#import "sys.typ": x-url-base

#import "@preview/based:0.2.0": base64
#let data-url(mime, src) = {
  "data:" + mime + ";base64," + base64.encode(src)
}

#let virt-slot(name) = figure(kind: "virt-slot:" + name, supplement: "_virt-slot")[]
#let set-slot(name, body) = it => {
  show figure.where(kind: "virt-slot:" + name): slot => body

  it
}

#let styles = state("shiroa:styles", (:))
#let add-style(global-style, cond: true) = if cond {
  styles.update(it => {
    it.insert(global-style.text, global-style)
    it
  })
}

#let inline-assets(body) = {
  show raw.where(lang: "css"): it => {
    h.link(rel: "stylesheet", href: data-url("text/css", it.text))[]
  }
  show raw.where(lang: "js"): it => {
    script(src: data-url("application/javascript", it.text))[]
  }

  body
}

#let meta = meta.with[]

#let shiroa-asset-file(name, lang: "js", inline: true, is-debug: false, ..rest) = {
  if is-debug {
    let asset = raw(lang: lang, read("/assets/artifacts/" + name, encoding: none))
    if inline {
      inline-assets(asset)
    } else {
      asset
    }
  } else {
    if lang == "js" {
      script(src: x-url-base + "internal/" + name, ..rest)[]
    } else if lang == "css" {
      h.link(rel: "stylesheet", href: x-url-base + "internal/" + name, ..rest)[]
    } else {
      panic("Unsupported asset language: " + lang)
    }
  }
}

#let replace-raw(it, vars: (:)) = {
  raw(
    lang: it.lang,
    {
      let body = it.text

      for (key, value) in vars.pairs() {
        body = body.replace("{{ " + key + " }}", value)
      }

      body
    },
  )
}

#let dyn-svg-support(is-debug: false) = {
  shiroa-asset-file("shiroa.js", lang: "js", id: "shiroa-js", type: "module")
  inline-assets(
    replace-raw(
      // fetch()
      vars: (
        renderer_module: if is-debug {
          data-url(
            "application/wasm",
            read("/assets/artifacts/typst_ts_renderer_bg.wasm", encoding: none),
          )
        } else { x-url-base + "internal/typst_ts_renderer_bg.wasm" },
      ),
      ```js
      window.typstRerender = () => { };
      window.typstChangeTheme = () => { };

      var typstBookJsLoaded = new Promise((resolve, reject) => {
          document.getElementById('shiroa-js').addEventListener('load', resolve);
          document.getElementById('shiroa-js').addEventListener('error', reject);
      });

      var rendererWasmModule = fetch('{{ renderer_module }}');
      window.typstBookJsLoaded = typstBookJsLoaded;
      window.typstRenderModuleReady = typstBookJsLoaded.then(() => {
          var typstRenderModule = window.typstRenderModule =
              window.TypstRenderModule.createTypstRenderer();
          return typstRenderModule
              .init({
                  getModule: () => rendererWasmModule,
              }).then(() => typstRenderModule);
      }).catch((err) => {
          console.error('shiroa.js failed to load', err);
      });
      ```,
    ),
  )
}
