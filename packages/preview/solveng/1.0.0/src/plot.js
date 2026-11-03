// solveng's graphs in HTML: drawn from the engine's figure (ranges, ticks, samples, marks) in the schoolbook style
// of the printed ones, with the document's own math as labels. Curves draw in when the graph comes into view; the
// pointer shows every curve's value with its unit. Without scripts the static picture beside it stays.
(() => {
  // once per page; a changed copy (a live preview runs the new one in place of the old) takes over from the one there
  const source = document.currentScript ? document.currentScript.textContent : '';
  const before = window.solvengPlot;
  if (before && before.source === source) return;
  if (before && before.stop) before.stop();
  const NS = 'http://www.w3.org/2000/svg';
  const CSS = `
.solveng-plot-live { position: relative; margin: 0 auto; max-width: 100%; text-align: left; }
.solveng-plot .solveng-plot-live svg { display: block; overflow: visible; max-width: none; height: auto; margin: 0; }
.solveng-plot-live .sp-lab { position: absolute; white-space: nowrap; line-height: 1.1; pointer-events: none; }
.solveng-plot-live .sp-legend { position: absolute; padding: 0.3em 0.55em; border: 1px solid rgba(127,127,127,.35); border-radius: 4px;
  background: color-mix(in srgb, Canvas 88%, transparent); line-height: 1.5; pointer-events: none; }
.solveng-plot-live .sp-row { display: flex; align-items: center; gap: 0.45em; white-space: nowrap; }
.solveng-plot-live .sp-tip { position: absolute; left: 0; top: 0; pointer-events: none; border-radius: 6px; overflow: hidden;
  background: Canvas; color: CanvasText; border: 1px solid rgba(127,127,127,.3); box-shadow: 0 3px 12px rgba(0,0,0,.14); box-sizing: content-box;
  opacity: 0; line-height: 1.5; transition: width .18s cubic-bezier(.2,.7,.2,1), opacity .12s; }
.solveng-plot-live .sp-tip-in { width: max-content; padding: 0.4em 0.6em; }
.solveng-plot-live .sp-trow { display: grid; grid-template-rows: 1fr; transition: grid-template-rows .2s ease, opacity .2s ease; }
.solveng-plot-live .sp-trow.sp-off { grid-template-rows: 0fr; opacity: 0; }
.solveng-plot-live .sp-trow > .sp-row { overflow: hidden; min-height: 0; }
.solveng-plot-live .sp-num { display: inline-block; font-variant-numeric: tabular-nums; }
@keyframes sp-snap { from { transform: translateY(40%); opacity: .25; } to { transform: none; opacity: 1; } }
.solveng-plot-live .sp-snap { animation: sp-snap .18s ease-out; }
.solveng-plot-live .sp-glide { transition: opacity .12s; }
@media (prefers-reduced-motion: reduce) { .solveng-plot-live .sp-tip, .solveng-plot-live .sp-glide, .solveng-plot-live .sp-trow { transition: opacity .12s; } .solveng-plot-live .sp-snap { animation: none; } }
@keyframes sp-pop { from { transform: scale(0); } 60% { transform: scale(1.3); } to { transform: scale(1); } }
@keyframes sp-fade { from { opacity: 0; } to { opacity: 1; } }
.solveng-plot-live .sp-pop { transform-box: fill-box; transform-origin: center; animation: sp-pop .38s ease-out both; }
.solveng-plot-live .sp-mk { transform-box: fill-box; transform-origin: center; transition: scale .16s cubic-bezier(.2,.7,.2,1); }
.solveng-plot-live .sp-mk.sp-hot { scale: 1.9; }
/* the point under the pointer sits on the line with a ring of the page's color around it, as the dots on curves do */
.solveng-plot-live .sp-mk.sp-hot { stroke: Canvas; stroke-width: 2.2px; paint-order: stroke; }
.solveng-plot-live .sp-fade { animation: sp-fade .4s ease-out both; }`;
  const reduced = () => window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;
  const el = (name, attrs, parent) => {
    const e = document.createElementNS(NS, name);
    for (const [k, v] of Object.entries(attrs || {})) e.setAttribute(k, v);
    if (parent) parent.appendChild(e);
    return e;
  };
  const div = (cls, parent) => { const d = document.createElement('div'); d.className = cls; if (parent) parent.appendChild(d); return d; };
  // ids unique to this copy too: an old copy's graphs may still be in the page
  let uid = 0;
  const tag = Math.random().toString(36).slice(2, 7);

  // numbers as the document writes them: its significant digits and decimal separator, a real minus
  // a value read at the pointer is only as exact as a pixel: given that step, it has the decimals the step has and keeps
  // its trailing zeros, so its width stays put while the pointer moves; exact values (data points) drop them
  const fmt = (v, spec, step) => {
    if (!isFinite(v)) return '';
    const dec = step > 0 ? Math.ceil(-Math.log10(step) - 1e-9) : NaN;
    if (dec >= 0 && dec <= 12 && Math.abs(v) < 1e7) {
      const s = Math.abs(v) < Math.pow(10, -dec) / 2 ? (0).toFixed(dec) : v.toFixed(dec);
      return s.replace('.', spec.sep || '.').replace(/^-/, '−');
    }
    let s = Math.abs(v) < 1e-12 ? '0' : String(Number(v.toPrecision(Math.max(1, Math.min(spec.digits || 4, 15)))));
    if (s.includes('e')) {
      const [m, e] = s.split('e');
      s = m + ' · 10' + String(Number(e)).replace(/-/g, '⁻').replace(/\d/g, d => '⁰¹²³⁴⁵⁶⁷⁸⁹'[d]);
    }
    return s.replace('.', spec.sep || '.').replace(/^-/, '−');
  };

  // a dot of a curve, size s across: its shape's corners as the printed graph has them (none: a circle), with a ring
  // of the page's color drawn under it, so dots stand apart from lines and from each other where they touch
  function dotEl(corners, x, y, s, color, parent) {
    const a = {fill: color, stroke: 'Canvas', 'stroke-width': 2.2, 'stroke-linejoin': 'round', 'paint-order': 'stroke'};
    if (!corners) return el('circle', {...a, cx: x, cy: y, r: s / 2}, parent);
    return el('path', {...a, d: 'M' + corners.map(([u, v]) => (x + u * s).toFixed(2) + ',' + (y + v * s).toFixed(2)).join('L') + 'Z'}, parent);
  }
  // the printed dot sizes (pt) on screen
  const PX = 1.45;
  // a legend or tooltip swatch: what the curve draws – its line with its dash, its dot, or both
  function swatch(c) {
    const s = el('svg', {width: 26, height: 12, viewBox: '0 0 26 12'});
    if (c.legend !== 'dot') el('line', {x1: 1, y1: 6, x2: 25, y2: 6, stroke: c.color, 'stroke-width': 1.8, 'stroke-dasharray': c.dash, 'stroke-linecap': 'round'}, s);
    if (c.legend !== 'line') dotEl(c.corners, 13, 6, (c.legend === 'dot' ? 5 : 4) * PX, c.color, s);
    return s;
  }

  // the y of a curve at x: interpolated along functions, the nearest point of data
  function valueAt(spec, curve, x, tol) {
    let best = null;
    // a function's single points (2 for x = 1): its value right there, also where a line passes them
    const own = spec.series.filter(s => s.c === curve && !s.data && !s.beyond && s.p.length === 1);
    // (the same x up to rounding: axes in units are scaled)
    const same = 1e-9 * (spec.x1 - spec.x0);
    for (const s of own) if (Math.abs(s.p[0][0] - x) <= same) return {x, y: s.p[0][1]};
    for (const s of spec.series) {
      // the lines joining a function's pieces (joined: true) are drawn, not read
      if (s.c !== curve || s.bridge || s.beyond) continue;
      const p = s.p;
      if (s.data || p.length === 1) {
        for (const q of p) { const d = Math.abs(q[0] - x); if (d <= tol && (!best || d < best.d)) best = {d, y: q[1], x: q[0]}; }
        continue;
      }
      for (let i = 0; i + 1 < p.length; i++) {
        const [xa, ya] = p[i], [xb, yb] = p[i + 1];
        if ((x - xa) * (x - xb) <= 0 && xa !== xb) return {x, y: ya + (yb - ya) * (x - xa) / (xb - xa)};
      }
    }
    return best;
  }

  function render(root, animate) {
    const spec = JSON.parse(root.querySelector('.solveng-plot-spec').textContent);
    // the y arrow's end has the axis label, not a tick; the x axis writes its last value there too, the label
    // beside it (labels keep their index in the engine's list)
    const far = (v, a, b) => Math.abs(v - b) <= 1e-9 * (b - a);
    spec.xt = spec.xt.map((t, i) => [...t, i]);
    spec.yt = spec.yt.map((t, i) => [...t, i]).filter(([v]) => !far(v, spec.y0, spec.y1));
    const store = root.querySelector('.solveng-plot-labels');
    const labelOf = k => { const s = store.querySelector(`[data-k="${k}"]`); return s && s.childNodes.length ? s : null; };
    const clone = k => { const s = labelOf(k); const d = document.createElement('span'); if (s) for (const n of s.childNodes) d.appendChild(n.cloneNode(true)); return d; };
    let live = root.querySelector('.solveng-plot-live');
    if (live) live.remove();
    live = div('solveng-plot-live', root);
    // the document's text size, which its math labels have too, not the page's larger one
    if (spec.em) live.style.fontSize = spec.em + 'pt';
    root.querySelector('.solveng-plot-static').style.display = 'none';

    // labels first: the margins make room for them
    const lab = (k, parent = live) => { const d = clone(k); d.className = 'sp-lab'; parent.appendChild(d); return d; };
    const xls = spec.xt.map(t => lab('xt' + t[2])), yls = spec.yt.map(t => lab('yt' + t[2]));
    const xl = lab('x'), yl = lab('y');
    const size = e => ({w: e.offsetWidth, h: e.offsetHeight});
    // the x axis's label clear of the value written at the arrow's end
    const endX = spec.xt.findIndex(([v]) => far(v, spec.x0, spec.x1));
    const xlAt = Math.max(16, endX < 0 ? 0 : size(xls[endX]).w / 2 + 8);
    const maxW = Math.max(0, ...yls.map(e => size(e).w)), tickH = Math.max(12, ...xls.map(e => size(e).h));
    // the legend, measured now: beside the plot it takes room on the right
    const named = spec.curves.map((c, i) => [c, i]).filter(([c]) => c.named);
    const lg = named.length ? div('sp-legend', live) : null;
    named.forEach(([c, i]) => {
      const row = div('sp-row', lg);
      row.appendChild(swatch(c));
      row.appendChild(clone('c' + i));
    });
    const beside = lg && spec.legend === 'outside' ? size(lg).w + 16 : 0;
    const avail = root.clientWidth || 600;
    // the printed size, scaled to the larger type of a screen
    const W = Math.min(avail, Math.max(360, spec.size.w * 2));
    const H = Math.round(W * spec.size.h / spec.size.w);
    const m = {l: (spec.yz && spec.x0 < 0 ? 8 : maxW + 12), r: size(xl).w + xlAt + 2 + beside, t: size(yl).h + 14, b: (spec.xz && spec.y0 < 0 ? 8 : tickH + 10)};
    live.style.width = W + 'px';
    const svg = el('svg', {width: W, height: H, viewBox: `0 0 ${W} ${H}`, role: 'img'});
    live.insertBefore(svg, live.firstChild);
    const X = v => m.l + (v - spec.x0) / (spec.x1 - spec.x0) * (W - m.l - m.r);
    const Y = v => H - m.b - (v - spec.y0) / (spec.y1 - spec.y0) * (H - m.t - m.b);
    const [left, right, top, bottom] = [X(spec.x0), X(spec.x1), Y(spec.y1), Y(spec.y0)];
    const axY = spec.xz ? Y(0) : bottom, axX = spec.yz ? X(0) : left;
    const ink = 'currentColor';

    // grid at the regular ticks, axes with arrows, ticks
    const grid = el('g', {stroke: ink, 'stroke-opacity': 0.13, 'stroke-width': 1}, svg);
    // open at the edges: no grid line closes the plot area on any side
    const inner = (v, a, b) => Math.abs(v - a) > 1e-9 * (b - a) && Math.abs(v - b) > 1e-9 * (b - a);
    spec.xt.forEach(([v, marked]) => { if (!marked && inner(v, spec.x0, spec.x1)) el('line', {x1: X(v), x2: X(v), y1: top, y2: bottom}, grid); });
    spec.yt.forEach(([v, marked]) => { if (!marked && inner(v, spec.y0, spec.y1)) el('line', {y1: Y(v), y2: Y(v), x1: left, x2: right}, grid); });
    const aid = 'sp-arrow-' + tag + (++uid);
    el('path', {d: 'M0,0L10,5L0,10L3,5Z', fill: ink}, el('marker', {id: aid, viewBox: '0 0 10 10', refX: 9, refY: 5, markerWidth: 8, markerHeight: 8, orient: 'auto'}, el('defs', {}, svg)));
    const axes = el('g', {stroke: ink, 'stroke-width': 1}, svg);
    el('line', {x1: left, y1: axY, x2: right + 10, y2: axY, 'marker-end': `url(#${aid})`}, axes);
    el('line', {x1: axX, y1: bottom, x2: axX, y2: top - 10, 'marker-end': `url(#${aid})`}, axes);
    spec.xt.forEach(([v]) => el('line', {x1: X(v), x2: X(v), y1: axY - 3, y2: axY + 3}, axes));
    spec.yt.forEach(([v]) => el('line', {y1: Y(v), y2: Y(v), x1: axX - 3, x2: axX + 3}, axes));
    const put = (e, x, y, ax, ay) => { const s = size(e); e.style.left = (x - ax * s.w) + 'px'; e.style.top = (y - ay * s.h) + 'px'; };
    // axes through the origin with a 0 on both: the y axis's is enough
    const both0 = spec.xz && spec.yz && spec.yt.some(([v]) => v === 0);
    xls.forEach((e, i) => { if (both0 && spec.xt[i][0] === 0) e.remove(); else put(e, X(spec.xt[i][0]), axY + 5, 0.5, 0); });
    yls.forEach((e, i) => put(e, axX - 6, Y(spec.yt[i][0]), 1, 0.5));
    put(xl, right + xlAt, axY, 0, 0.5);
    put(yl, axX - 4, top - 12, 1, 1);
    if (spec.origin) { const o = document.createElement('span'); o.className = 'sp-lab'; o.textContent = '0'; live.appendChild(o); put(o, axX - 4, axY + 4, 1, 0); }

    // curves, clipped to the data area; revealed left to right
    const cid = 'sp-clip-' + tag + uid;
    const clipRect = el('rect', {x: left - 4, y: top - 4, width: animate ? 0 : right - left + 8, height: bottom - top + 8}, el('clipPath', {id: cid}, svg.querySelector('defs')));
    // the series in the order written, as on paper: each one's line, then its dots, over the ones before it. Lines are
    // clipped to the data area (and revealed left to right), dots only a little beyond it, so dots on its edge are whole.
    el('rect', {x: left - 8, y: top - 8, width: right - left + 16, height: bottom - top + 16}, el('clipPath', {id: cid + '-m'}, svg.querySelector('defs')));
    const layers = el('g', {}, svg);
    const pops = [], drawn = [];
    const dot = (e, x, y, c, at) => { e.classList.add('sp-mk'); pops.push([e, at]); drawn.push({x, y, el: e, c}); };
    spec.series.forEach(s => {
      const c = spec.curves[s.c];
      // joins (joined: true) are faint, as on paper: where the curve has values stays clear
      if (s.line) el('path', {d: 'M' + s.p.map(([x, y]) => X(x).toFixed(2) + ',' + Y(y).toFixed(2)).join('L'), fill: 'none', stroke: c.color, 'stroke-width': 1.7, 'stroke-opacity': s.bridge ? 0.4 : 1,
        'stroke-dasharray': c.dash, 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'clip-path': `url(#${cid})`}, layers);
      if (!s.d.length) return;
      const g = el('g', {'clip-path': `url(#${cid}-m)`}, layers);
      // a dot on a dot of another curve is smaller, the one below a ring around it
      s.d.forEach(([x, y, below]) => dot(dotEl(c.corners, X(x), Y(y), s.size * PX * Math.pow(0.6, below), c.color, g), x, y, s.c, x));
    });
    // marked points: their guide lines under the curves, their dots over everything
    const guides = svg.insertBefore(el('g', {stroke: '#6e6e6e', 'stroke-width': 0.8, 'stroke-dasharray': '4 3'}), layers);
    const marked = el('g', {}, svg);
    (spec.points || []).forEach(p => {
      if (p.guides !== '') el('line', {x1: X(p.x), x2: X(p.x), y1: Y(spec.ax), y2: Y(p.y)}, guides);
      if (p.guides === 'xy') el('line', {x1: X(spec.ay), x2: X(p.x), y1: Y(p.y), y2: Y(p.y)}, guides);
      dot(dotEl(null, X(p.x), Y(p.y), 4 * PX, ink, marked), p.x, p.y, -1, spec.x1);
    });

    // legend in the corner the graph picked, or beside it
    if (lg) {
      const s = size(lg), [v, h] = spec.legend.split('-');
      lg.style.left = (beside ? W - s.w : h === 'left' ? left + 8 : right - s.w - 8) + 'px';
      lg.style.top = (beside || v === 'top' ? top + 6 : bottom - s.h - 6) + 'px';
    }

    if (animate) {
      const dur = 1100, t0 = performance.now(), full = right - left + 8;
      const step = now => {
        const t = Math.min(1, Math.max(0, (now - t0) / dur)), e = 1 - Math.pow(1 - t, 3);
        clipRect.setAttribute('width', full * e);
        if (t < 1) requestAnimationFrame(step);
      };
      requestAnimationFrame(step);
      pops.forEach(([n, x]) => { n.classList.add('sp-pop'); n.style.animationDelay = (dur * Math.max(0, (x - spec.x0) / (spec.x1 - spec.x0)) * 0.9) + 'ms'; });
      guides.classList.add('sp-fade'); guides.style.animationDelay = dur * 0.8 + 'ms';
    }

    // the values under the pointer: one popup that glides along, eases to its new size and fades rows in and out
    const tip = div('sp-tip', live), tin = div('sp-tip-in', tip);
    // the line goes under the drawn points, so a point it reads sits on top of it
    const hovLine = svg.insertBefore(el('g', {opacity: 0}), layers), hov = svg.insertBefore(el('g', {opacity: 0}), marked);
    const showHov = o => { hovLine.setAttribute('opacity', o); hov.setAttribute('opacity', o); };
    const rule = el('line', {x1: 0, x2: 0, y1: top, y2: bottom, stroke: ink, 'stroke-opacity': 0.35, class: 'sp-glide'}, hovLine);
    const dots = spec.curves.map(c => el('circle', {r: 4, fill: c.color, style: 'stroke: Canvas', 'stroke-width': 1.5, class: 'sp-glide'}, hov));
    // the pointer counts a little beyond the data area, so points on its edges stay reachable all around
    const reach = 14;
    const area = el('rect', {x: left - reach, y: top - reach, width: right - left + 2 * reach, height: bottom - top + 2 * reach, fill: 'transparent'}, svg);
    const unit = k => { if (!labelOf(k)) return null; const d = clone(k); d.style.marginLeft = '0.25em'; return d; };
    const num = () => { const n = document.createElement('span'); n.className = 'sp-num'; return n; };
    // U = 3.2 V, then each curve's value: by its legend name, or the y axis's name for a curve without one
    const head = div('sp-row', tin), hx = num();
    if (labelOf('xn')) { head.appendChild(clone('xn')); head.appendChild(document.createTextNode('=')); }
    hx.style.fontWeight = 600; head.appendChild(hx);
    const xu = unit('xu'); if (xu) head.appendChild(xu);
    const rows = spec.curves.map((c, i) => {
      const r = div('sp-trow sp-off', tin), row = div('sp-row', r), n = num();
      row.appendChild(swatch(c));
      const key = labelOf('c' + i) ? 'c' + i : labelOf('yn') ? 'yn' : null;
      const name = key ? clone(key) : null;
      if (name) { row.appendChild(name); row.appendChild(document.createTextNode(key === 'yn' ? '=' : ':')); }
      row.appendChild(n);
      const yu = unit('yu'); if (yu) row.appendChild(yu);
      return {r, n, key, name, at: null, data: spec.series.some(s => s.c === i && s.data)};
    });
    // a value read at a point near the pointer, not at its x, says where: y(1) = 4 – the x put in for the axis's
    // variable in the curve's name, or after it, data (k = 1), where the name has none
    const MATHML = 'http://www.w3.org/1998/Math/MathML';
    const xname = labelOf('xn') ? labelOf('xn').textContent.trim() : '';
    const where = (row, at) => {
      if (!row.name || row.at === at) return;
      row.at = at;
      const d = clone(row.key);
      if (at !== null) {
        const value = fmt(at, spec);
        let put = false;
        if (xname) d.querySelectorAll('mi').forEach(mi => {
          if (mi.textContent.trim() !== xname) return;
          const mn = document.createElementNS(MATHML, 'mn'); mn.textContent = value; mi.replaceWith(mn); put = true;
        });
        if (!put) {
          d.appendChild(document.createTextNode('\u2009('));
          if (xname) { d.appendChild(clone('xn')); d.appendChild(document.createTextNode(' = ')); }
          d.appendChild(document.createTextNode(value + ')'));
        }
      }
      row.name.replaceChildren(...d.childNodes);
    };
    // a value that jumps to the next data point rolls in; values gliding along a function just change
    // numbers drop trailing zeros, so their width only grows while shown: the popup doesn't twitch with every digit
    const set = (n, text, snap) => {
      if (n.textContent === text) return;
      n.textContent = text;
      n.style.minWidth = Math.max(parseFloat(n.style.minWidth) || 0, n.offsetWidth) + 'px';
      if (snap) { n.classList.remove('sp-snap'); void n.offsetWidth; n.classList.add('sp-snap'); }
    };
    const tol = 12 / (W - m.l - m.r) * (spec.x1 - spec.x0);
    // what a pixel is worth on each axis, for the values read at the pointer
    const xstep = (spec.x1 - spec.x0) / (W - m.l - m.r), ystep = (spec.y1 - spec.y0) / (bottom - top);
    let shown = false;
    // what the line can pin to: the data's points and the marked points, with the mark drawn for each if there is one
    const inside = ({x, y}) => x >= spec.x0 && x <= spec.x1 && y >= spec.y0 && y <= spec.y1;
    const pins = [...drawn, ...spec.series.filter(s => s.data && !drawn.some(d => d.c === s.c)).flatMap(s => s.p.map(([x, y]) => ({x, y, el: null, c: s.c})))].filter(inside);
    const markOf = (c, x, y) => drawn.find(d => d.c === c && d.x === x && d.y === y);
    // the mark under the pointer grows
    let lit = [];
    const light = (els) => { lit.forEach(([e, k]) => e.classList.remove(k)); lit = els.filter(([e]) => e); lit.forEach(([e, k]) => e.classList.add(k)); };
    // following the pointer is immediate; only jumps glide: pinning to a point and letting go, a data value moving to
    // its next point, the popup changing sides. The element is drawn where it was and that offset eases away while it
    // keeps following the pointer, so a glide runs to its end however fast the pointer moves. Entering, nothing
    // glides in from where it was last.
    const moving = new Set();
    let raf = 0;
    const offset = e => {
      const t = e.g ? (performance.now() - e.g.t0) / 200 : 1;
      if (t >= 1) { e.g = null; return [0, 0]; }
      const k = Math.pow(1 - t, 3);
      return [e.g.dx * k, e.g.dy * k];
    };
    const draw = e => { const [ox, oy] = offset(e); e.style.transform = `translate(${e.p[0] + ox}px, ${e.p[1] + oy}px)`; return e.g; };
    const tick = () => { raf = 0; moving.forEach(e => { if (!draw(e)) moving.delete(e); }); if (moving.size) raf = requestAnimationFrame(tick); };
    const place = (e, x, y, jump) => {
      if (jump && shown && e.p && !reduced() && (x !== e.p[0] || y !== e.p[1])) {
        const [ox, oy] = offset(e);
        e.g = {dx: e.p[0] + ox - x, dy: e.p[1] + oy - y, t0: performance.now()};
        moving.add(e);
        if (!raf) raf = requestAnimationFrame(tick);
      }
      e.p = [x, y];
      draw(e);
    };
    let pinned = null;
    area.addEventListener('pointermove', ev => {
      const r = svg.getBoundingClientRect(), px = (ev.clientX - r.left) * W / r.width, py = (ev.clientY - r.top) * H / r.height;
      // pinned only with the pointer on a point; then every curve is read at its x, else at the pointer's
      let hit = null, best = 9;
      for (const q of pins) { const d = Math.hypot(X(q.x) - px, Y(q.y) - py); if (d <= best) { best = d; hit = q; } }
      const near = hit ? hit.x : null, pin = near !== pinned; pinned = near;
      const glow = hit && hit.el ? [[hit.el, 'sp-hot']] : [];
      const x = near ?? Math.min(spec.x1, Math.max(spec.x0, spec.x0 + (px - m.l) / (W - m.l - m.r) * (spec.x1 - spec.x0)));
      let any = false;
      spec.curves.forEach((c, i) => {
        // data shows the value of a point the line passes close to, at the point
        const v = valueAt(spec, i, x, tol), row = rows[i];
        if (!v || !(v.y >= spec.y0 && v.y <= spec.y1)) { dots[i].setAttribute('opacity', 0); row.r.classList.add('sp-off'); return; }
        any = true;
        // a drawn point the line reads shows itself, no dot covers it
        where(row, Math.abs(v.x - x) > 1e-9 * (spec.x1 - spec.x0) ? v.x : null);
        if (markOf(i, v.x, v.y)) { dots[i].setAttribute('opacity', 0); row.r.classList.remove('sp-off'); set(row.n, fmt(v.y, spec), true); return; }
        place(dots[i], X(v.x), Y(v.y), pin || (row.data && dots[i].getAttribute('opacity') === '1'));
        dots[i].setAttribute('opacity', 1);
        row.r.classList.remove('sp-off');
        set(row.n, fmt(v.y, spec, row.data || near !== null ? 0 : ystep), row.data);
      });
      light(glow);
      set(hx, fmt(x, spec, near === null ? xstep : 0), pin && near !== null);
      place(rule, X(x), 0, pin);
      showHov(1);
      // the size follows the content, the side follows the room
      // changing sides needs a margin past the edge, or a popup right at it flips back and forth
      const tw = tin.offsetWidth, tx = X(x), side = tip.side ? tx + 14 + tw > W - 24 : tx + 14 + tw > W;
      place(tip, side ? tx - 14 - tw : tx + 14, top + 4, pin || side !== tip.side);
      tip.side = side;
      tip.style.width = tw + 'px';
      tip.style.opacity = any ? 1 : 0;
      shown = true;
    });
    area.addEventListener('pointerleave', () => { [tip, rule, ...dots].forEach(e => { e.g = null; }); [hx, ...rows.map(r => r.n)].forEach(n => { n.style.minWidth = ''; }); showHov(0); tip.style.opacity = 0; shown = false; pinned = null; light([]); });
  }

  const stops = [];
  function start() {
    const st = document.createElement('style'); st.textContent = CSS; document.head.appendChild(st);
    stops.push(() => st.remove());
    const draw = (r, animate) => { try { render(r, animate); } catch (e) { console.error('solveng graph:', e); } };
    const known = new WeakSet();
    // drawn when it comes into view, so the curves draw in where the reader sees them; the static picture until then
    const io = 'IntersectionObserver' in window && !reduced() ? new IntersectionObserver(es => es.forEach(e => {
      if (e.isIntersecting) { draw(e.target, true); io.unobserve(e.target); }
    }), {threshold: 0.35}) : null;
    // every graph once, also those a live preview puts into the page later (editors update the page in place)
    const scan = () => document.querySelectorAll('.solveng-plot').forEach(r => {
      if (known.has(r) || !r.querySelector('.solveng-plot-spec')) return;
      known.add(r);
      if (io) io.observe(r); else draw(r, false);
    });
    scan();
    const mo = new MutationObserver(scan);
    mo.observe(document.body, {childList: true, subtree: true});
    let w = window.innerWidth, timer;
    const resize = () => {
      if (window.innerWidth === w) return;
      w = window.innerWidth; clearTimeout(timer);
      timer = setTimeout(() => document.querySelectorAll('.solveng-plot').forEach(r => { if (r.querySelector('.solveng-plot-live')) draw(r, false); }), 150);
    };
    window.addEventListener('resize', resize);
    stops.push(() => { mo.disconnect(); if (io) io.disconnect(); window.removeEventListener('resize', resize); clearTimeout(timer); });
  }
  window.solvengPlot = {render, source, stop: () => stops.splice(0).forEach(f => f())};
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start); else start();
})();
