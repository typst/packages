// Presio HTML animation runtime.
//
// Runs first in the sandboxed frame that shows one HTML animation, before any
// of the animation's own code. It does three things:
//
//  1. Loads the animation from a bundle: the entry HTML plus its asset files,
//     carried as JSON in <script id="presio-bundle">. Relative URLs (in the
//     HTML, in CSS, in JS imports, and in fetch / XHR / src set at runtime)
//     resolve to those files, so a folder of HTML, JS, CSS and images works
//     without a server.
//  2. Owns the animation's clock. requestAnimationFrame, timers,
//     performance.now / Date.now, CSS and Web Animations, SVG (SMIL)
//     animations and <video>/<audio> all run on one virtual time, which can
//     be played, paused, sped up or slowed down, and seeked.
//  3. Draws optional controls (play / pause, restart, a scrubber when the
//     length is known) and talks to an embedding page over postMessage.
//
// Shared word for word with Presio's media plugin
// (client/plugins/media/html-runtime.js in PotentialHedge/presio) and the
// presio Typst package's HTML export (src/html-runtime.js), so an animation
// behaves the same in Presio and in a Typst HTML page. Keep the two copies in
// sync.
//
// The frame is sandboxed (allow-scripts, no allow-same-origin), so nothing in
// here is trusted with anything: it only drives the animation.
//
// Plain ES2019, no imports: it's inlined into a <script> as is (so it must
// never contain a closing script tag or an HTML comment opener).

(function () {
  "use strict";

  var W = window;
  var D = document;
  var bundleEl = D.getElementById("presio-bundle");
  if (!bundleEl) return;
  var bundle;
  try {
    bundle = JSON.parse(bundleEl.textContent || "{}");
  } catch (e) {
    return;
  }
  bundleEl.parentNode.removeChild(bundleEl);

  var opts = bundle.options || {};
  // Presio drives this frame; a Typst HTML page just shows it.
  var embedded = !!opts.embedded && W.parent !== W;
  // Asset paths live under this made-up origin, so relative URLs resolve
  // against it and can be told apart from real ones.
  var BASE = "https://presio.invalid/";

  // --- Files ---

  var files = {};
  var rawFiles = bundle.files || {};
  for (var key in rawFiles) {
    if (Object.prototype.hasOwnProperty.call(rawFiles, key)) {
      var norm = normalize(key);
      if (norm) files[norm] = rawFiles[key];
    }
  }
  var entry = normalize(bundle.entry || "index.html") || "index.html";
  var entryDir = entry.slice(0, entry.lastIndexOf("/") + 1);

  function normalize(path) {
    try {
      var abs = new URL(String(path), BASE).href;
      return abs.indexOf(BASE) === 0 ? decodeURIComponent(abs.slice(BASE.length).split(/[?#]/)[0]) : null;
    } catch (e) {
      return null;
    }
  }

  var MIME = {
    html: "text/html", htm: "text/html", js: "text/javascript", mjs: "text/javascript", css: "text/css",
    json: "application/json", svg: "image/svg+xml", png: "image/png", jpg: "image/jpeg", jpeg: "image/jpeg",
    gif: "image/gif", webp: "image/webp", avif: "image/avif", ico: "image/x-icon", mp4: "video/mp4",
    webm: "video/webm", mp3: "audio/mpeg", ogg: "audio/ogg", wav: "audio/wav", woff: "font/woff",
    woff2: "font/woff2", ttf: "font/ttf", otf: "font/otf", txt: "text/plain", csv: "text/csv",
    wasm: "application/wasm", glb: "model/gltf-binary", gltf: "model/gltf+json",
  };
  function extOf(path) {
    var m = /\.([A-Za-z0-9]+)$/.exec(path);
    return m ? m[1].toLowerCase() : "";
  }
  function mimeOf(path, file) {
    return (file && file.mime) || MIME[extOf(path)] || "application/octet-stream";
  }
  function bytesOf(file) {
    if (typeof file.text === "string") return file.text;
    var bin = atob(file.b64 || "");
    var out = new Uint8Array(bin.length);
    for (var i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
    return out;
  }
  function textOf(file) {
    if (typeof file.text === "string") return file.text;
    return new TextDecoder().decode(bytesOf(file));
  }

  var blobUrls = {};
  var blobPaths = {};
  function assetUrl(path) {
    if (blobUrls[path]) return blobUrls[path];
    var file = files[path];
    if (!file) return null;
    var ext = extOf(path);
    // Claim the slot first, so a stylesheet that imports itself ends.
    blobUrls[path] = "about:blank";
    var body;
    if (ext === "css") body = rewriteCss(textOf(file), path);
    else if (ext === "js" || ext === "mjs") body = rewriteJs(textOf(file), path);
    else body = bytesOf(file);
    blobUrls[path] = URL.createObjectURL(new Blob([body], { type: mimeOf(path, file) }));
    blobPaths[blobUrls[path]] = path;
    return blobUrls[path];
  }

  /** The blob URL for `url` when it names one of the bundle's files, else null. */
  function lookup(url, from) {
    if (url == null) return null;
    url = String(url).trim();
    if (!url || url.charAt(0) === "#" || /^(data|blob|about|javascript|mailto):/i.test(url)) return null;
    var abs;
    try {
      abs = new URL(url, BASE + (from || entry)).href;
    } catch (e) {
      return null;
    }
    if (abs.indexOf(BASE) !== 0) return null;
    var rest = abs.slice(BASE.length);
    var path = rest.split(/[?#]/)[0];
    try {
      path = decodeURIComponent(path);
    } catch (e) { /* keep as is */ }
    var found = assetUrl(path);
    if (!found) return null;
    var hash = rest.indexOf("#");
    return hash >= 0 ? found + rest.slice(hash) : found;
  }

  function rewriteCss(css, from) {
    return css
      .replace(/url\(\s*(['"]?)([^'")]+)\1\s*\)/g, function (m, q, u) {
        var r = lookup(u, from);
        return r ? 'url("' + r + '")' : m;
      })
      .replace(/@import\s+(['"])([^'"]+)\1/g, function (m, q, u) {
        var r = lookup(u, from);
        return r ? '@import "' + r + '"' : m;
      });
  }

  // Relative module specifiers become absolute (under BASE), which the import
  // map below sends to the files' blob URLs. Classic scripts don't match.
  var IMPORT_RE = /(\bfrom\s*|\bimport\s*\(\s*|\bimport\s+)(['"])(\.{0,2}\/[^'"\n]*)\2/g;
  function rewriteJs(js, from) {
    return js.replace(IMPORT_RE, function (m, pre, q, spec) {
      try {
        var abs = new URL(spec, BASE + from).href;
        return abs.indexOf(BASE) === 0 && files[normalize(abs)] ? pre + q + abs + q : m;
      } catch (e) {
        return m;
      }
    });
  }

  function rewriteSrcset(value, from) {
    return value
      .split(",")
      .map(function (part) {
        var bits = part.trim().split(/\s+/);
        var r = lookup(bits[0], from);
        if (r) bits[0] = r;
        return bits.join(" ");
      })
      .join(", ");
  }

  var XLINK = "http://www.w3.org/1999/xlink";

  function rewriteHtml(html) {
    var doc = new DOMParser().parseFromString(html, "text/html");
    var imports = {};
    for (var path in files) {
      var ext = extOf(path);
      if (ext === "js" || ext === "mjs") imports[BASE + path] = null; // filled lazily below
    }
    var nodes = doc.querySelectorAll("*");
    for (var i = 0; i < nodes.length; i++) {
      var el = nodes[i];
      var tag = el.localName;
      var attrs = ["src", "poster", "data"];
      if (tag === "link" || tag === "use" || tag === "image" || tag === "feimage" || tag === "script") attrs.push("href");
      for (var a = 0; a < attrs.length; a++) {
        if (el.hasAttribute(attrs[a])) {
          var r = lookup(el.getAttribute(attrs[a]), entry);
          if (r) el.setAttribute(attrs[a], r);
        }
      }
      if (el.hasAttributeNS(XLINK, "href")) {
        var rx = lookup(el.getAttributeNS(XLINK, "href"), entry);
        if (rx) el.setAttributeNS(XLINK, "xlink:href", rx);
      }
      if (el.hasAttribute("srcset")) el.setAttribute("srcset", rewriteSrcset(el.getAttribute("srcset"), entry));
      if (el.hasAttribute("style")) el.setAttribute("style", rewriteCss(el.getAttribute("style"), entry));
      if (tag === "style") el.textContent = rewriteCss(el.textContent, entry);
      if (tag === "script" && !el.hasAttribute("src")) {
        var type = (el.getAttribute("type") || "").toLowerCase();
        if (type === "module") el.textContent = rewriteJs(el.textContent, entry);
        else if (type === "importmap") {
          // Merge the page's own map into ours; its relative targets resolve too.
          try {
            var own = JSON.parse(el.textContent);
            for (var spec in own.imports || {}) imports[spec] = lookup(own.imports[spec], entry) || own.imports[spec];
          } catch (e) { /* leave it */ }
          el.parentNode.removeChild(el);
        }
      }
    }
    for (var k in imports) {
      if (imports[k] === null) imports[k] = assetUrl(normalize(k));
    }
    var head = doc.head;
    var base = doc.createElement("base");
    base.setAttribute("href", BASE + entryDir);
    var map = doc.createElement("script");
    map.setAttribute("type", "importmap");
    map.textContent = JSON.stringify({ imports: imports });
    head.insertBefore(map, head.firstChild);
    head.insertBefore(base, head.firstChild);
    return doc.documentElement.outerHTML;
  }

  // --- Patches: URLs set from script ---

  function patchUrlProperty(Ctor, prop) {
    if (!Ctor) return;
    var desc = Object.getOwnPropertyDescriptor(Ctor.prototype, prop);
    if (!desc || !desc.set) return;
    Object.defineProperty(Ctor.prototype, prop, {
      configurable: true,
      enumerable: desc.enumerable,
      get: desc.get,
      set: function (v) {
        desc.set.call(this, lookup(v) || v);
      },
    });
  }
  patchUrlProperty(W.HTMLImageElement, "src");
  patchUrlProperty(W.HTMLScriptElement, "src");
  patchUrlProperty(W.HTMLMediaElement, "src");
  patchUrlProperty(W.HTMLSourceElement, "src");
  patchUrlProperty(W.HTMLTrackElement, "src");
  patchUrlProperty(W.HTMLLinkElement, "href");
  patchUrlProperty(W.HTMLVideoElement, "poster");

  var realSetAttribute = Element.prototype.setAttribute;
  Element.prototype.setAttribute = function (name, value) {
    var n = String(name).toLowerCase();
    if (n === "src" || n === "poster" || n === "href" || n === "xlink:href") {
      var r = n === "href" && this.localName === "a" ? null : lookup(value);
      if (r) value = r;
    }
    return realSetAttribute.call(this, name, value);
  };

  var realFetch = W.fetch;
  if (realFetch) {
    W.fetch = function (input, init) {
      if (typeof input === "string" || input instanceof URL) {
        var r = lookup(input);
        if (r) input = r;
      } else if (input && input.url) {
        var rr = lookup(input.url);
        if (rr) input = new Request(rr, input);
      }
      return realFetch.call(W, input, init);
    };
  }
  var realOpen = W.XMLHttpRequest && W.XMLHttpRequest.prototype.open;
  if (realOpen) {
    W.XMLHttpRequest.prototype.open = function (method, url) {
      var args = Array.prototype.slice.call(arguments);
      var r = lookup(url);
      if (r) args[1] = r;
      return realOpen.apply(this, args);
    };
  }
  if (W.Worker) {
    var RealWorker = W.Worker;
    W.Worker = function (url, o) {
      return new RealWorker(lookup(url) || url, o);
    };
    W.Worker.prototype = RealWorker.prototype;
  }
  if (W.Audio) {
    var RealAudio = W.Audio;
    W.Audio = function (src) {
      return arguments.length ? new RealAudio(lookup(src) || src) : new RealAudio();
    };
    W.Audio.prototype = RealAudio.prototype;
  }

  // --- The clock ---

  var perf = W.performance;
  var realNow = perf.now.bind(perf);
  var realRaf = W.requestAnimationFrame.bind(W);
  var realSetTimeout = W.setTimeout.bind(W);
  var realClearTimeout = W.clearTimeout.bind(W);
  var realDateNow = Date.now;
  // performance.now() reads as if the page had been running since this frame
  // started; animation time `clock.t` (ms) starts at 0.
  var PERF0 = realNow();
  var EPOCH0 = realDateNow() - PERF0;
  var clock = { t: 0, playing: false, rate: 1, last: PERF0 };
  // Whether the page has run code on the clock (frames, timers): then only
  // a reload can take it back in time.
  var scripted = false;
  var stepping = false;

  function now() {
    if (clock.playing && !stepping) {
      var r = realNow();
      clock.t += (r - clock.last) * clock.rate;
      clock.last = r;
    }
    return clock.t;
  }

  perf.now = function () {
    return PERF0 + now();
  };
  Date.now = function () {
    return Math.floor(EPOCH0 + PERF0 + now());
  };

  function report(error) {
    realSetTimeout(function () {
      throw error;
    }, 0);
  }

  function call(fn, args) {
    if (typeof fn !== "function") return;
    try {
      fn.apply(W, args);
    } catch (e) {
      report(e);
    }
  }

  // Frames: held while paused, so a frame-counting animation stops too.
  var frames = [];
  var cancelled = {};
  var nextFrame = 1;
  W.requestAnimationFrame = function (cb) {
    scripted = true;
    var id = nextFrame++;
    frames.push({ id: id, cb: cb });
    return id;
  };
  W.cancelAnimationFrame = function (id) {
    cancelled[id] = true;
  };
  function runFrames() {
    var batch = frames;
    frames = [];
    var ts = PERF0 + clock.t;
    for (var i = 0; i < batch.length; i++) {
      if (!cancelled[batch[i].id]) call(batch[i].cb, [ts]);
    }
    cancelled = {};
  }

  // Timers: due at a virtual time; armed as real timeouts only while playing
  // (or, paused, when already due — zero-delay work still happens).
  var timers = {};
  var nextTimer = 1;
  function addTimer(fn, delay, args, repeat) {
    scripted = true;
    var id = nextTimer++;
    var ms = Math.max(0, Number(delay) || 0);
    if (repeat) ms = Math.max(4, ms);
    timers[id] = { fn: fn, args: args, delay: ms, repeat: repeat, due: now() + ms, real: null };
    arm(id);
    return id;
  }
  function arm(id) {
    var tm = timers[id];
    if (!tm || tm.real !== null || stepping) return;
    var t = now();
    if (!clock.playing && tm.due > t) return;
    var wait = clock.playing ? Math.max(0, (tm.due - t) / clock.rate) : 0;
    tm.real = realSetTimeout(function () {
      tm.real = null;
      fire(id);
    }, wait);
  }
  function disarm(tm) {
    if (tm.real !== null) {
      realClearTimeout(tm.real);
      tm.real = null;
    }
  }
  function rearmAll() {
    for (var id in timers) {
      disarm(timers[id]);
      arm(id);
    }
  }
  function fire(id) {
    var tm = timers[id];
    if (!tm) return;
    if (now() + 0.5 < tm.due) {
      arm(id); // early: the rate changed since it was armed
      return;
    }
    if (tm.repeat) tm.due += tm.delay;
    else delete timers[id];
    call(tm.fn, tm.args);
    if (tm.repeat && timers[id]) arm(id);
  }
  function clearTimer(id) {
    var tm = timers[id];
    if (tm) {
      disarm(tm);
      delete timers[id];
    }
  }
  W.setTimeout = function (fn, delay) {
    return addTimer(fn, delay, Array.prototype.slice.call(arguments, 2), false);
  };
  W.setInterval = function (fn, delay) {
    return addTimer(fn, delay, Array.prototype.slice.call(arguments, 2), true);
  };
  W.clearTimeout = clearTimer;
  W.clearInterval = clearTimer;

  // Every timer due by the clock's time, in order (seeking forward).
  function fireDue() {
    for (var guard = 0; guard < 10000; guard++) {
      var best = null;
      for (var id in timers) {
        if (timers[id].due <= clock.t && (best === null || timers[id].due < timers[best].due)) best = id;
      }
      if (best === null) return;
      fire(best);
    }
  }

  // CSS animations, transitions and Web Animations: each is paused and set
  // to its place on the clock, from the clock time it began at.
  var births = new WeakMap();
  var svgs = new WeakMap();
  // The first pass (at load) takes everything running as begun at 0; after
  // that, one first seen began at its own current time ago.
  var firstSync = true;
  function syncAnimations() {
    var t = clock.t;
    var fresh = firstSync;
    firstSync = false;
    var list = D.getAnimations ? D.getAnimations() : [];
    for (var i = 0; i < list.length; i++) {
      var a = list[i];
      if (a.playState === "idle") continue;
      if (!births.has(a)) births.set(a, fresh ? t : t - (Number(a.currentTime) || 0));
      if (a.playState !== "paused") a.pause();
      var want = t - births.get(a);
      if (Math.abs((Number(a.currentTime) || 0) - want) > 0.5) a.currentTime = want;
    }
    var roots = D.getElementsByTagName("svg");
    for (var j = 0; j < roots.length; j++) {
      var s = roots[j];
      if (s.ownerSVGElement || !s.pauseAnimations) continue;
      var info = svgs.get(s);
      if (!info) {
        info = { animated: !!s.querySelector("animate, animateTransform, animateMotion, set"), birth: fresh ? t : t - s.getCurrentTime() * 1000 };
        svgs.set(s, info);
        if (info.animated) s.pauseAnimations();
      }
      if (info.animated) s.setCurrentTime(Math.max(0, (t - info.birth) / 1000));
    }
  }

  // <video> and <audio> on the page: paused with the clock, resumed with it,
  // and muted when the embedder says so.
  var held = [];
  var muted = !!opts.muted;
  function mediaElements() {
    return Array.prototype.slice.call(D.querySelectorAll("video, audio"));
  }
  function holdMedia() {
    held = mediaElements().filter(function (m) {
      return !m.paused;
    });
    held.forEach(function (m) {
      m.pause();
    });
  }
  function resumeMedia() {
    held.forEach(function (m) {
      var p = m.play();
      if (p && p.catch) p.catch(function () {});
    });
    held = [];
  }
  function applyMute() {
    mediaElements().forEach(function (m) {
      if (muted) m.muted = true;
    });
  }

  // The animation's length (ms) when it has one: the author's, else the end
  // of its last finite CSS / Web Animation when nothing else drives it.
  var authored = Number(opts.duration) > 0 ? Number(opts.duration) * 1000 : null;
  var measured = null;
  function measure() {
    if (authored || scripted || !D.getAnimations) {
      measured = null;
      return;
    }
    var end = 0;
    var list = D.getAnimations();
    for (var i = 0; i < list.length; i++) {
      var timing = list[i].effect && list[i].effect.getComputedTiming();
      if (!timing) continue;
      if (!isFinite(timing.endTime)) {
        measured = null;
        return;
      }
      end = Math.max(end, (births.get(list[i]) || 0) + timing.endTime);
    }
    measured = end > 0 ? end : null;
  }
  function duration() {
    return authored || measured;
  }

  function setPlaying(playing) {
    if (playing === clock.playing) return;
    now();
    clock.playing = playing;
    clock.last = realNow();
    if (playing) {
      var d = duration();
      // Played at its end: from the top.
      if (d && clock.t >= d - 1) {
        seek(0);
        if (pendingReload) return;
      }
      rearmAll();
      resumeMedia();
    } else {
      // Only timers already due stay armed.
      rearmAll();
      holdMedia();
      syncAnimations();
    }
    status(true);
    renderUi();
  }

  function setRate(rate) {
    rate = Math.max(0.25, Math.min(4, Number(rate) || 1));
    if (rate === clock.rate) return;
    now();
    clock.rate = rate;
    if (clock.playing) rearmAll();
  }

  var pendingReload = false;

  /** Go to `target` ms. Forward steps the page through the time between
   *  (frames and timers run, quickly); back reloads it unless only CSS / SVG
   *  animations run, which can simply be set. */
  /** `state` (see shareable state, below), when given, is the page's state
   *  once there. */
  function seek(target, state) {
    target = Math.max(0, Number(target) || 0);
    var d = duration();
    if (d) target = Math.min(target, d);
    var t = now();
    // Animations started since the last frame begin now, not at the target.
    syncAnimations();
    if (target < t - 1 && scripted) {
      reload(target, state);
      return;
    }
    if (target > t && scripted) {
      fastForward(target);
    } else {
      clock.t = target;
      clock.last = realNow();
    }
    // Media keeps its place relative to the clock.
    var delta = (target - t) / 1000;
    if (delta) {
      mediaElements().forEach(function (m) {
        try {
          m.currentTime = Math.max(0, m.currentTime + delta);
        } catch (e) { /* not seekable */ }
      });
    }
    syncAnimations();
    if (state !== undefined) applyState(state);
    renderOnce = true;
    status(true);
    renderUi();
  }

  function fastForward(target) {
    var STEP = 1000 / 60;
    var deadline = realNow() + 400;
    stepping = true;
    for (var id in timers) disarm(timers[id]);
    while (clock.t < target) {
      if (realNow() > deadline) {
        // Out of time: jump the rest in one step.
        clock.t = target;
        fireDue();
        runFrames();
        break;
      }
      clock.t = Math.min(target, clock.t + STEP);
      fireDue();
      runFrames();
      // Animations the page starts on the way begin at the right time.
      syncAnimations();
    }
    stepping = false;
    clock.last = realNow();
    if (clock.playing) rearmAll();
  }

  var STATE_PREFIX = "presio-html:";
  // The page's shareable state comes along when going back to a moment
  // (what was dragged or set stays), but not on a restart from the top.
  function reload(target, state) {
    if (state === undefined) state = target > 0 ? readState() : null;
    pendingReload = true;
    try {
      W.name = STATE_PREFIX + JSON.stringify({ t: target, playing: clock.playing, rate: clock.rate, ui: ui, muted: muted, state: state });
    } catch (e) { /* no state to carry */ }
    if (embedded) post({ type: "reload" });
    W.location.reload();
  }

  var saved = null;
  if (typeof W.name === "string" && W.name.indexOf(STATE_PREFIX) === 0) {
    try {
      saved = JSON.parse(W.name.slice(STATE_PREFIX.length));
    } catch (e) { /* ignore */ }
    W.name = "";
  }

  // --- The frame loop ---

  var renderOnce = true;
  var frameCount = 0;
  var lastStatus = 0;
  var lastSent = null;

  function tick() {
    realRaf(tick);
    if (pendingReload) return;
    var t = now();
    var d = duration();
    if (d && t >= d && clock.playing) {
      if (opts.loop !== false) {
        seek(0);
        if (pendingReload) return;
      } else {
        clock.t = d;
        setPlaying(false);
      }
    }
    if (clock.playing || renderOnce) {
      renderOnce = false;
      runFrames();
    }
    syncAnimations();
    if (++frameCount % 30 === 0) {
      measure();
      applyMute();
    }
    status(false);
    if (uiShown) updateUi();
  }

  // --- The embedder ---

  function post(message) {
    if (!embedded) return;
    message.presio = "html";
    W.parent.postMessage(message, "*");
  }

  function status(force) {
    if (!embedded) return;
    var at = realNow();
    var every = clock.playing ? 250 : 2000;
    var d = duration();
    var key = clock.playing + ":" + d;
    if (!force && key === lastSent && at - lastStatus < every) return;
    lastStatus = at;
    lastSent = key;
    post({ type: "status", t: clock.t / 1000, playing: clock.playing, duration: d ? d / 1000 : null });
  }

  // What the embedder lets this frame show and do: its controls; whether
  // they act here or only tell the embedder (delegate); whether the
  // animation itself takes pointer input; and a "Sync" button (the
  // presenter's, while viewers run it themselves).
  var ui = {
    controls: opts.controls !== false,
    delegate: false,
    interactive: opts.interactive !== false,
    sync: false,
    share: false,
  };
  if (embedded) ui = { controls: false, delegate: true, interactive: false, sync: false, share: false };

  W.addEventListener("message", function (e) {
    if (e.source !== W.parent || !e.data || e.data.presio !== "html") return;
    var m = e.data;
    if (m.cmd === "play") setPlaying(true);
    else if (m.cmd === "pause") setPlaying(false);
    else if (m.cmd === "seek") seek(Number(m.t) * 1000);
    else if (m.cmd === "rate") setRate(m.rate);
    else if (m.cmd === "mute") {
      muted = !!m.muted;
      mediaElements().forEach(function (el) {
        el.muted = muted;
      });
    } else if (m.cmd === "ui") {
      ui = { controls: !!m.controls, delegate: !!m.delegate, interactive: !!m.interactive, sync: !!m.sync, share: !!m.share };
      lastShared = null;
      renderUi();
    } else if (m.cmd === "state") {
      applyState(m.state);
    } else if (m.cmd === "jump") {
      // Go to where the presenter is, as the presenter has it.
      setPlaying(!!m.playing);
      seek(Number(m.t) * 1000, m.state === undefined ? null : m.state);
    } else if (m.cmd === "snapshot") {
      snapshotAt(m.t, Number(m.scale) || 1);
    }
  });

  // Keys the animation doesn't use go to the deck (slide navigation), so a
  // click into the animation doesn't take the arrow keys away.
  var NAV_KEYS = { ArrowLeft: 1, ArrowRight: 1, ArrowUp: 1, ArrowDown: 1, PageUp: 1, PageDown: 1 };
  W.addEventListener("keydown", function (e) {
    if (!embedded || e.defaultPrevented || !NAV_KEYS[e.key] || e.metaKey || e.ctrlKey || e.altKey) return;
    var t = e.target;
    if (t && (t.isContentEditable || /^(input|textarea|select)$/i.test(t.localName || ""))) return;
    // After the page's own window listeners, which may still claim it.
    realSetTimeout(function () {
      if (!e.defaultPrevented) post({ type: "key", key: e.key });
    }, 0);
  });

  // Paused, input still draws a frame (on frozen time), so the page can
  // respond to a hover or a drag.
  ["pointerdown", "pointermove", "pointerup", "wheel", "keydown"].forEach(function (type) {
    W.addEventListener(type, function () {
      if (!clock.playing) renderOnce = true;
    }, true);
  });

  // --- Controls ---

  var uiHost = null;
  var uiRoot = null;
  var uiShown = false;
  var els = {};
  var hideTimer = null;
  var scrubbing = false;

  var ICONS = {
    play: '<path d="M7 4.5v15l12-7.5z" fill="currentColor"/>',
    pause: '<rect x="6" y="4" width="4" height="16" rx="1" fill="currentColor"/><rect x="14" y="4" width="4" height="16" rx="1" fill="currentColor"/>',
    sync: '<path d="M21 12a9 9 0 0 0-9-9 9.75 9.75 0 0 0-6.74 2.74L3 8" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M3 3v5h5M3 12a9 9 0 0 0 9 9 9.75 9.75 0 0 0 6.74-2.74L21 16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M16 16h5v5" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>',
    restart: '<path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M3 3v5h5" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>',
  };
  function svg(name) {
    return '<svg viewBox="0 0 24 24" aria-hidden="true">' + ICONS[name] + "</svg>";
  }

  var CSS =
    ":host{all:initial;position:fixed;inset:0;z-index:2147483647;pointer-events:none;font:12px/1 system-ui,-apple-system,sans-serif}" +
    ".shield{position:absolute;inset:0;pointer-events:auto}" +
    ".bar{position:absolute;left:8px;right:8px;bottom:8px;display:flex;align-items:center;gap:6px;padding:4px 8px 4px 4px;border-radius:8px;background:rgba(0,0,0,.62);color:#fff;pointer-events:auto;opacity:0}" +
    ".bar.show,.bar.paused{opacity:1}" +
    // No known length: no timeline, just the buttons.
    ".bar.compact{right:auto;padding:4px}" +
    ".bar.compact .scrub,.bar.compact .spacer,.bar.compact .time{display:none}" +
    ".sync{width:auto;display:flex;align-items:center;gap:5px;padding:6px 9px 6px 7px;font:500 12px/1 system-ui,-apple-system,sans-serif;white-space:nowrap}" +
    ".sync svg{width:16px;height:16px}" +
    "button{flex:none;width:28px;height:28px;padding:6px;border:0;border-radius:6px;background:transparent;color:inherit;cursor:pointer}" +
    "button:hover{background:rgba(255,255,255,.18)}" +
    "svg{display:block;width:100%;height:100%}" +
    "input{flex:1;min-width:0;margin:0;accent-color:#fff;cursor:pointer}" +
    ".time{flex:none;font-variant-numeric:tabular-nums;opacity:.85}" +
    ".spacer{flex:1}" +
    "[hidden]{display:none!important}";

  function buildUi() {
    if (uiHost || !D.documentElement) return;
    uiHost = D.createElement("presio-controls");
    uiRoot = uiHost.attachShadow ? uiHost.attachShadow({ mode: "closed" }) : uiHost;
    uiRoot.innerHTML =
      "<style>" + CSS + "</style>" +
      '<div class="shield" hidden></div>' +
      '<div class="bar" hidden>' +
      '<button class="toggle" type="button"></button>' +
      '<button class="restart" type="button" title="Restart" aria-label="Restart">' + svg("restart") + "</button>" +
      '<input class="scrub" type="range" min="0" max="1000" value="0" aria-label="Position">' +
      '<span class="spacer"></span>' +
      '<span class="time"></span>' +
      '<button class="sync" type="button" title="Jump every viewer to where you are" hidden>' + svg("sync") + "Sync</button>" +
      "</div>";
    els.shield = uiRoot.querySelector(".shield");
    els.bar = uiRoot.querySelector(".bar");
    els.toggle = uiRoot.querySelector(".toggle");
    els.restart = uiRoot.querySelector(".restart");
    els.scrub = uiRoot.querySelector(".scrub");
    els.spacer = uiRoot.querySelector(".spacer");
    els.time = uiRoot.querySelector(".time");
    els.sync = uiRoot.querySelector(".sync");
    els.sync.addEventListener("click", function () {
      post({ type: "syncViewers", state: readState() });
    });

    els.toggle.addEventListener("click", function () {
      act(clock.playing ? "pause" : "play");
    });
    els.restart.addEventListener("click", function () {
      act("reset");
    });
    els.scrub.addEventListener("input", function () {
      scrubbing = true;
      var d = duration();
      if (d) els.time.textContent = fmt((els.scrub.value / 1000) * d) + " / " + fmt(d);
    });
    els.scrub.addEventListener("change", function () {
      scrubbing = false;
      var d = duration();
      if (!d) return;
      var target = (els.scrub.value / 1000) * d;
      if (ui.delegate) post({ type: "seek", t: target / 1000 });
      else seek(target);
    });
    // Shown while the pointer is over the frame, and a moment after.
    W.addEventListener("pointermove", reveal, true);
    W.addEventListener("pointerdown", reveal, true);
    D.documentElement.addEventListener("pointerleave", function () {
      if (els.bar) els.bar.classList.remove("show");
    });
    D.documentElement.appendChild(uiHost);
  }

  function reveal() {
    if (!els.bar) return;
    els.bar.classList.add("show");
    if (hideTimer !== null) realClearTimeout(hideTimer);
    hideTimer = realSetTimeout(function () {
      hideTimer = null;
      if (clock.playing && els.bar) els.bar.classList.remove("show");
    }, 2000);
  }

  function act(action) {
    if (ui.delegate) {
      post({ type: "acted", action: action });
      return;
    }
    if (action === "play") setPlaying(true);
    else if (action === "pause") setPlaying(false);
    else seek(0);
  }

  function fmt(ms) {
    var s = Math.max(0, Math.round(ms / 1000));
    var m = Math.floor(s / 60);
    s = s % 60;
    return m + ":" + (s < 10 ? "0" : "") + s;
  }

  function renderUi() {
    buildUi();
    if (!uiHost) return;
    uiShown = ui.controls;
    els.bar.hidden = !ui.controls;
    els.sync.hidden = !ui.sync;
    // Not interactive: the page under the controls takes no input.
    els.shield.hidden = ui.interactive;
    if (!ui.controls && ui.interactive) uiHost.style.display = "none";
    else uiHost.style.display = "";
    updateUi();
  }

  function updateUi() {
    if (!els.bar) return;
    els.bar.classList.toggle("paused", !clock.playing);
    var label = clock.playing ? "Pause" : "Play";
    if (els.toggle.getAttribute("aria-label") !== label) {
      els.toggle.innerHTML = svg(clock.playing ? "pause" : "play");
      els.toggle.title = label;
      els.toggle.setAttribute("aria-label", label);
    }
    var d = duration();
    els.bar.classList.toggle("compact", !d);
    els.scrub.hidden = !d;
    els.spacer.hidden = !!d;
    if (!scrubbing) {
      if (d) {
        var pos = String(Math.round((Math.min(clock.t, d) / d) * 1000));
        if (els.scrub.value !== pos) els.scrub.value = pos;
      }
      var text = d ? fmt(clock.t) + " / " + fmt(d) : fmt(clock.t);
      if (els.time.textContent !== text) els.time.textContent = text;
    }
  }

  // --- Snapshots (posters) ---
  //
  // A still of the page at a moment of its clock, as a PNG data URL: what
  // Presio shows in thumbnails and Next Slide and bakes into a downloaded
  // PDF. Nothing outside the frame can screenshot it, so it draws itself:
  // the DOM is copied with every element's computed style written inline (so
  // animations are caught mid-flight and nothing restarts), canvases and
  // videos as images, SVG animations at their current values, and bundled
  // files as data URLs; then rendered through an SVG <foreignObject> onto a
  // canvas.

  var XHTML = "http://www.w3.org/1999/xhtml";
  var SVGNS = "http://www.w3.org/2000/svg";
  var dataUrls = {};

  function dataUrlOf(path) {
    if (dataUrls[path]) return dataUrls[path];
    var file = files[path];
    if (!file) return null;
    var b64 = typeof file.text === "string" ? btoa(unescape(encodeURIComponent(textOf(file)))) : file.b64 || "";
    dataUrls[path] = "data:" + mimeOf(path, file) + ";base64," + b64;
    return dataUrls[path];
  }
  function inlineUrls(text) {
    return String(text).replace(/blob:[^"')\s]+/g, function (b) {
      var path = blobPaths[b.split("#")[0]];
      return (path && dataUrlOf(path)) || b;
    });
  }

  // Each tag's computed style untouched by the page's CSS: only what differs
  // from it is written out, which keeps the copy small. The probes live in a
  // shadow root, where the page's stylesheets (even `html, body { … }`)
  // don't reach.
  var defaults = {};
  var defaultsHost = null;
  function defaultStyle(el) {
    var key = (el.namespaceURI === SVGNS ? "svg:" : "") + el.localName;
    if (defaults[key]) return defaults[key];
    if (!defaultsHost) {
      var shadowHost = D.createElement("presio-defaults");
      shadowHost.style.cssText = "all:initial;position:absolute;visibility:hidden;width:0;height:0;overflow:hidden";
      D.documentElement.appendChild(shadowHost);
      defaultsHost = D.createElement("div");
      defaultsHost.style.cssText = "all:initial";
      shadowHost.attachShadow({ mode: "closed" }).appendChild(defaultsHost);
    }
    var probe = el.namespaceURI === SVGNS ? D.createElementNS(SVGNS, el.localName) : D.createElement(el.localName);
    var parent = el.namespaceURI === SVGNS && el.localName !== "svg" ? D.createElementNS(SVGNS, "svg") : defaultsHost;
    if (parent !== defaultsHost) defaultsHost.appendChild(parent);
    parent.appendChild(probe);
    var cs = getComputedStyle(probe);
    var out = {};
    for (var i = 0; i < cs.length; i++) out[cs[i]] = cs.getPropertyValue(cs[i]);
    (parent === defaultsHost ? probe : parent).remove();
    defaults[key] = out;
    return out;
  }

  function inlineStyle(el, out) {
    var cs = getComputedStyle(el);
    var base = defaultStyle(el);
    var text = "";
    for (var i = 0; i < cs.length; i++) {
      var prop = cs[i];
      var value = cs.getPropertyValue(prop);
      if (base[prop] !== value || prop === "display") text += prop + ":" + value + ";";
    }
    text += "animation:none;transition:none;";
    out.setAttribute("style", inlineUrls(text));
  }

  var SKIP = { script: 1, noscript: 1, template: 1, link: 1, style: 1, meta: 1, base: 1, title: 1, "presio-controls": 1, "presio-defaults": 1 };
  var SMIL = { animate: 1, animateTransform: 1, animateMotion: 1, set: 1, animateColor: 1 };
  var GEOMETRY = ["cx", "cy", "r", "rx", "ry", "x", "y", "width", "height", "x1", "y1", "x2", "y2"];

  function imageOf(source, width, height, el) {
    var img = D.createElementNS(XHTML, "img");
    try {
      var c = D.createElement("canvas");
      c.width = width || 1;
      c.height = height || 1;
      c.getContext("2d").drawImage(source, 0, 0, c.width, c.height);
      img.setAttribute("src", c.toDataURL("image/png"));
    } catch (e) { /* tainted: leave it blank */ }
    inlineStyle(el, img);
    return img;
  }

  function copy(node) {
    if (node.nodeType === 3) return D.createTextNode(node.nodeValue);
    if (node.nodeType !== 1) return null;
    var el = node;
    var tag = el.localName;
    if (SKIP[tag] || SMIL[tag]) return null;
    var out;
    if (tag === "canvas") {
      out = D.createElementNS(XHTML, "img");
      try {
        out.setAttribute("src", el.toDataURL("image/png"));
      } catch (e) { /* tainted */ }
      inlineStyle(el, out);
      return out;
    }
    if (tag === "video") return imageOf(el, el.videoWidth, el.videoHeight, el);
    if (tag === "iframe") {
      out = D.createElementNS(XHTML, "div");
      inlineStyle(el, out);
      return out;
    }
    out = el.cloneNode(false);
    if (el.namespaceURI === SVGNS) {
      // SVG animations show their current values, not their base ones.
      for (var i = 0; i < GEOMETRY.length; i++) {
        var a = el[GEOMETRY[i]];
        if (a && a.animVal && typeof a.animVal.value === "number" && el.hasAttribute(GEOMETRY[i])) out.setAttribute(GEOMETRY[i], a.animVal.value);
      }
      var list = el.transform && el.transform.animVal;
      if (list && list.numberOfItems) {
        // (animVal is read-only, so no consolidate(): multiply it out.)
        var m = new DOMMatrix();
        for (var k = 0; k < list.numberOfItems; k++) m = m.multiply(list.getItem(k).matrix);
        out.setAttribute("transform", "matrix(" + [m.a, m.b, m.c, m.d, m.e, m.f].join(" ") + ")");
      }
      if (el.href && el.href.baseVal !== undefined && blobPaths[el.href.baseVal]) out.setAttribute("href", dataUrlOf(blobPaths[el.href.baseVal]));
    }
    if (tag === "img" && el.currentSrc) out.setAttribute("src", inlineUrls(el.currentSrc));
    if (tag === "input" || tag === "textarea" || tag === "select") {
      if ("value" in el) out.setAttribute("value", el.value);
      if (el.checked) out.setAttribute("checked", "");
    }
    if (tag !== "defs" && tag !== "head") inlineStyle(el, out);
    for (var c = el.firstChild; c; c = c.nextSibling) {
      var child = copy(c);
      if (child) out.appendChild(child);
    }
    return out;
  }

  // @font-face rules, so text keeps its fonts (with bundled font files inline).
  function fontFaces() {
    var css = "";
    for (var i = 0; i < D.styleSheets.length; i++) {
      var rules;
      try {
        rules = D.styleSheets[i].cssRules;
      } catch (e) {
        continue; // a stylesheet from another origin
      }
      for (var j = 0; j < rules.length; j++) {
        if (rules[j].type === 5) css += inlineUrls(rules[j].cssText);
      }
    }
    return css;
  }

  function render(scale) {
    var w = Math.max(1, D.documentElement.clientWidth || W.innerWidth);
    var h = Math.max(1, D.documentElement.clientHeight || W.innerHeight);
    var root = copy(D.documentElement);
    var faces = fontFaces();
    if (faces) {
      var style = D.createElementNS(XHTML, "style");
      style.textContent = faces;
      root.insertBefore(style, root.firstChild);
    }
    root.setAttribute("style", (root.getAttribute("style") || "") + "width:" + w + "px;height:" + h + "px;overflow:hidden;");
    var markup = new XMLSerializer().serializeToString(root);
    var svgText =
      '<svg xmlns="' + SVGNS + '" width="' + w + '" height="' + h + '"><foreignObject x="0" y="0" width="100%" height="100%">' +
      markup + "</foreignObject></svg>";
    return new Promise(function (done) {
      var img = new Image();
      img.onload = function () {
        try {
          var c = D.createElement("canvas");
          c.width = Math.round(w * scale);
          c.height = Math.round(h * scale);
          var ctx = c.getContext("2d");
          ctx.scale(scale, scale);
          ctx.drawImage(img, 0, 0, w, h);
          done(c.toDataURL("image/png"));
        } catch (e) {
          done(canvasFallback()); // the browser won't read back a foreignObject (Safari)
        }
      };
      img.onerror = function () {
        done(canvasFallback());
      };
      img.src = "data:image/svg+xml;charset=utf-8," + encodeURIComponent(svgText);
    });
  }

  // Without a DOM render: the page's biggest canvas, when it fills most of it.
  function canvasFallback() {
    var best = null;
    var area = 0;
    Array.prototype.forEach.call(D.getElementsByTagName("canvas"), function (c) {
      var a = c.clientWidth * c.clientHeight;
      if (a > area) {
        area = a;
        best = c;
      }
    });
    var total = (D.documentElement.clientWidth || 1) * (D.documentElement.clientHeight || 1);
    if (!best || area < total * 0.5) return null;
    try {
      return best.toDataURL("image/png");
    } catch (e) {
      return null;
    }
  }

  /** Post a still at `t` seconds — by default the end, for an animation with
   *  a length, else two seconds in — once the page has loaded. */
  function snapshotAt(t, scale) {
    function wait(ms) {
      return new Promise(function (r) {
        realSetTimeout(r, ms);
      });
    }
    var loaded = D.readyState === "complete" ? Promise.resolve() : new Promise(function (r) {
      W.addEventListener("load", r);
    });
    loaded
      .then(function () {
        return D.fonts && D.fonts.ready;
      })
      .then(function () {
        return wait(300); // data the page fetches, and what it builds from it
      })
      .then(function () {
        measure();
        var d = duration();
        var target = typeof t === "number" && t >= 0 ? t * 1000 : d ? d - 50 : 2000;
        setPlaying(false);
        seek(target);
        runFrames();
        syncAnimations();
        return wait(50);
      })
      .then(function () {
        return render(scale);
      })
      .then(
        function (url) {
          post({ type: "snapshot", url: url });
        },
        function () {
          post({ type: "snapshot", url: null });
        }
      );
  }

  // --- Shareable state ---
  //
  // What viewers following the presenter need besides the time: what the
  // presenter changed on the page. Form fields (sliders, checkboxes,
  // selects, text) come by value, by themselves; anything else the page
  // hands over:
  //
  //   presio.sync({ get: () => ({ points }), set: (s) => { points = s.points } })
  //
  // `get` returns JSON-able data and is asked a few times a second; `set`
  // gets a copy of what the presenter's returned.

  var stateApi = null;
  var pendingApp; // a state that came before the page called presio.sync
  var lastShared = null;

  W.presio = {
    sync: function (api) {
      if (!api || typeof api.get !== "function" || typeof api.set !== "function") {
        throw new TypeError("presio.sync takes { get, set }");
      }
      stateApi = api;
      lastShared = null;
      if (pendingApp !== undefined) {
        var app = pendingApp;
        pendingApp = undefined;
        setApp(app);
      }
    },
  };

  var NOT_FIELDS = /^(file|password|hidden|button|submit|reset|image)$/i;
  function formFields() {
    return Array.prototype.filter.call(D.querySelectorAll("input,select,textarea"), function (el) {
      return !NOT_FIELDS.test(el.type || "");
    });
  }
  function isCheck(el) {
    return el.type === "checkbox" || el.type === "radio";
  }

  /** { forms?, app? } — or null when there's nothing to share. */
  function readState() {
    var state = {};
    var fields = formFields();
    if (fields.length) {
      state.forms = fields.map(function (el) {
        return isCheck(el) ? el.checked : el.value;
      });
    }
    if (stateApi) {
      try {
        var app = stateApi.get();
        // A copy, also of what the page keeps changing in place.
        if (app !== undefined) state.app = JSON.parse(JSON.stringify(app));
      } catch (e) {
        console.error("presio.sync get():", e);
      }
    }
    return state.forms || "app" in state ? state : null;
  }

  function setApp(app) {
    try {
      stateApi.set(app);
    } catch (e) {
      console.error("presio.sync set():", e);
    }
  }

  function applyState(state) {
    if (!state || typeof state !== "object") return;
    if (Array.isArray(state.forms)) {
      var fields = formFields();
      state.forms.forEach(function (v, i) {
        var el = fields[i];
        if (!el) return;
        if (isCheck(el)) {
          if (typeof v !== "boolean" || el.checked === v) return;
          el.checked = v;
        } else {
          if (typeof v !== "string" || el.value === v) return;
          el.value = v;
        }
        // So the page reacts as if it were changed here.
        el.dispatchEvent(new Event("input", { bubbles: true }));
        el.dispatchEvent(new Event("change", { bubbles: true }));
      });
    }
    if ("app" in state) {
      if (stateApi) setApp(state.app);
      else pendingApp = state.app;
    }
    renderOnce = true;
  }

  // The presenter's frame reports its state when it changes.
  function share() {
    realSetTimeout(share, 100);
    if (!ui.share || pendingReload) return;
    var state = readState();
    var json = JSON.stringify(state);
    if (json === lastShared) return;
    lastShared = json;
    post({ type: "state", state: state });
  }

  // --- Start ---

  if (saved) {
    clock.rate = Number(saved.rate) || 1;
    if (saved.ui) ui = saved.ui;
    muted = !!saved.muted;
  }
  var html = files[entry] ? textOf(files[entry]) : "<!doctype html><p>Missing " + entry + "</p>";
  // Written in place of this script, so the page's own scripts run after the
  // patches above, on the clock.
  D.write(rewriteHtml(html));

  function start() {
    syncAnimations();
    renderUi();
    applyMute();
    if (saved) {
      seek(Number(saved.t) || 0, saved.state || undefined);
      setPlaying(!!saved.playing);
    } else if (!embedded && opts.autoplay !== false) {
      setPlaying(true);
    }
    post({ type: "ready", restored: !!saved });
    status(true);
    realRaf(tick);
    share();
  }
  if (D.readyState === "loading") D.addEventListener("DOMContentLoaded", start);
  else start();
})();
