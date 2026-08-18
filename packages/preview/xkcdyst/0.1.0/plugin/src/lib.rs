//! `sketch` — a Typst WASM plugin that reimplements the TikZ/PGF
//! `sketch` decoration used by the "xkcd style" answer
//! <https://tex.stackexchange.com/a/445690> (Frunobulax, CC BY-SA 4.0).
//!
//! The original is a `\pgfdeclaredecoration` automaton stepping along the
//! path in 0.5pt increments, offsetting each step perpendicular to the path
//! by `amplitude * sin(2*pi*t/wavelength)`, where `t` performs a random walk
//!
//!     t <- mod(t + pow(randomness, rand), wavelength)
//!
//! `rand` is PGF's own PRNG, which we replicate bit-for-bit below so the
//! wobble is *the same wobble* LuaLaTeX would have produced for a given seed.
//!
//! Doing this in pure Typst markup means tens of thousands of interpreted
//! float ops per figure; here it is a few hundred microseconds of Rust.

use wasm_minimal_protocol::*;

initiate_protocol!();

// ---------------------------------------------------------------------------
// PGF's pseudo-random number generator
// ---------------------------------------------------------------------------
// pgfmathfunctions.random.code.tex: a Lehmer / Park-Miller generator evaluated
// with Schrage's trick so it never overflows TeX's 31-bit integers.
//
//     a = 69621   q = 30845   r = 23902   m = 2^31 - 1
//
struct PgfRng {
    z: i64,
}

impl PgfRng {
    const A: i64 = 69621;
    const Q: i64 = 30845;
    const R: i64 = 23902;
    const M: i64 = 2147483647;

    fn new(seed: i64) -> Self {
        // \pgfmathsetseed{n}
        let mut z = seed % Self::M;
        if z <= 0 {
            z += Self::M - 1;
        }
        PgfRng { z }
    }

    /// \pgfmathgeneratepseudorandomnumber
    fn next_z(&mut self) -> i64 {
        let hi = self.z / Self::Q;
        let lo = self.z % Self::Q;
        let mut t = Self::A * lo - Self::R * hi;
        if t < 0 {
            t += Self::M;
        }
        self.z = t;
        t
    }

    /// pgfmath's `rand`: uniform on [-1,1], quantised to 5 decimals.
    /// The TeX code computes ((z mod 200001) - 100000) and then prints it
    /// with an implied 5-digit fraction, so the value really is k/100000.
    fn rand(&mut self) -> f64 {
        let z = self.next_z();
        let v = (z % 200001) - 100000;
        v as f64 / 100000.0
    }
}

// ---------------------------------------------------------------------------
// geometry helpers
// ---------------------------------------------------------------------------
#[derive(Clone, Copy)]
struct Pt {
    x: f64,
    y: f64,
}

fn dist(a: Pt, b: Pt) -> f64 {
    ((b.x - a.x).powi(2) + (b.y - a.y).powi(2)).sqrt()
}

/// Ramer–Douglas–Peucker simplification.
///
/// The decoration emits one vertex every 0.5pt, but the offset it applies
/// varies *slowly* (a full sine period spans ~50pt), so consecutive vertices
/// are nearly collinear. Dropping the redundant ones cuts the vertex count by
/// well over 10x with no visible change, which keeps CeTZ fast downstream.
fn rdp(pts: &[Pt], eps: f64, out: &mut Vec<Pt>) {
    if pts.len() < 3 {
        out.extend_from_slice(pts);
        return;
    }
    let (first, last) = (pts[0], pts[pts.len() - 1]);
    let (dx, dy) = (last.x - first.x, last.y - first.y);
    let len = (dx * dx + dy * dy).sqrt();

    let mut best = 0.0f64;
    let mut idx = 0usize;
    for (i, p) in pts.iter().enumerate().take(pts.len() - 1).skip(1) {
        let d = if len < 1e-12 {
            dist(*p, first)
        } else {
            ((p.x - first.x) * dy - (p.y - first.y) * dx).abs() / len
        };
        if d > best {
            best = d;
            idx = i;
        }
    }

    if best > eps {
        rdp(&pts[..=idx], eps, out);
        out.pop();
        rdp(&pts[idx..], eps, out);
    } else {
        out.push(first);
        out.push(last);
    }
}

// ---------------------------------------------------------------------------
// the decoration itself
// ---------------------------------------------------------------------------
/// Walk `input` (a flattened polyline, in points) at `seg` intervals,
/// offsetting perpendicular to the local tangent.
fn sketch(
    input: &[Pt],
    seg: f64,
    amplitude: f64,
    randomness: f64,
    wavelength: f64,
    seed: i64,
    closed: bool,
) -> Vec<Pt> {
    // cumulative arc length of the input polyline
    let mut acc = vec![0.0f64];
    for i in 1..input.len() {
        let d = dist(input[i - 1], input[i]);
        acc.push(acc[i - 1] + d);
    }
    let total = *acc.last().unwrap_or(&0.0);
    if total <= 0.0 || input.len() < 2 {
        return input.to_vec();
    }

    // position + unit normal at arc length s
    let at = |s: f64| -> (Pt, Pt) {
        let s = s.clamp(0.0, total);
        let mut i = match acc.binary_search_by(|v| v.partial_cmp(&s).unwrap()) {
            Ok(i) => i,
            Err(i) => i - 1,
        };
        if i >= input.len() - 1 {
            i = input.len() - 2;
        }
        let seglen = acc[i + 1] - acc[i];
        let u = if seglen > 1e-12 { (s - acc[i]) / seglen } else { 0.0 };
        let (a, b) = (input[i], input[i + 1]);
        let p = Pt {
            x: a.x + (b.x - a.x) * u,
            y: a.y + (b.y - a.y) * u,
        };
        let (tx, ty) = (b.x - a.x, b.y - a.y);
        let tl = (tx * tx + ty * ty).sqrt().max(1e-12);
        // normal = tangent rotated +90 deg, matching PGF's local frame
        (p, Pt { x: -ty / tl, y: tx / tl })
    };

    let mut rng = PgfRng::new(seed);
    let mut t = 0.0f64; // \state{init} sets t = 0
    let n = (total / seg).floor() as usize;

    let mut raw: Vec<Pt> = Vec::with_capacity(n + 2);
    raw.push(input[0]); // the decoration starts on the path

    let mut last_off = 0.0;
    for k in 1..=n {
        // \state{draw} persistent precomputation
        t = (t + randomness.powf(rng.rand())) % wavelength;
        let off = (2.0 * t * std::f64::consts::PI / wavelength).sin() * amplitude;
        let (p, nrm) = at(k as f64 * seg);
        raw.push(Pt {
            x: p.x + nrm.x * off,
            y: p.y + nrm.y * off,
        });
        last_off = off;
    }

    // finish exactly on the path end (closed paths must meet their start)
    if closed {
        let first = raw[0];
        raw.push(first);
    } else {
        let (p, nrm) = at(total);
        raw.push(Pt {
            x: p.x + nrm.x * last_off,
            y: p.y + nrm.y * last_off,
        });
    }
    raw
}

// ---------------------------------------------------------------------------
// plugin entry point
// ---------------------------------------------------------------------------
fn parse_floats(b: &[u8]) -> Result<Vec<f64>, String> {
    core::str::from_utf8(b)
        .map_err(|e| e.to_string())?
        .split_ascii_whitespace()
        .map(|s| s.parse::<f64>().map_err(|e| e.to_string()))
        .collect()
}

/// `params` : "seg amplitude randomness wavelength seed closed epsilon"
/// `points` : "x0 y0 x1 y1 ..." flattened polyline, in TeX points
/// returns  : "x0 y0 x1 y1 ..." the decorated (and simplified) polyline
#[wasm_func]
pub fn decorate(params: &[u8], points: &[u8]) -> Result<Vec<u8>, String> {
    let p = parse_floats(params)?;
    if p.len() < 7 {
        return Err("expected 7 parameters".into());
    }
    let (seg, amp, rnd, wave) = (p[0], p[1], p[2], p[3]);
    let (seed, closed, eps) = (p[4] as i64, p[5] != 0.0, p[6]);

    let f = parse_floats(points)?;
    if f.len() < 4 || f.len() % 2 != 0 {
        return Err("need an even number of coordinates (>= 2 points)".into());
    }
    let mut pts: Vec<Pt> = f.chunks_exact(2).map(|c| Pt { x: c[0], y: c[1] }).collect();
    if closed && dist(pts[0], pts[pts.len() - 1]) > 1e-9 {
        pts.push(pts[0]);
    }

    let raw = sketch(&pts, seg, amp, rnd, wave, seed, closed);

    let mut simp = Vec::with_capacity(raw.len());
    if eps > 0.0 {
        rdp(&raw, eps, &mut simp);
    } else {
        simp = raw;
    }

    let mut s = String::with_capacity(simp.len() * 16);
    for q in &simp {
        if !s.is_empty() {
            s.push(' ');
        }
        s.push_str(&format!("{:.4} {:.4}", q.x, q.y));
    }
    Ok(s.into_bytes())
}

/// Expose the PRNG on its own, so the Typst side can reproduce things like
/// TikZ's `rand`-driven jitter outside of a path decoration.
#[wasm_func]
pub fn randoms(args: &[u8]) -> Result<Vec<u8>, String> {
    let a = parse_floats(args)?;
    if a.len() < 2 {
        return Err("expected: seed count".into());
    }
    let mut rng = PgfRng::new(a[0] as i64);
    let out: Vec<String> = (0..a[1] as usize).map(|_| format!("{:.5}", rng.rand())).collect();
    Ok(out.join(" ").into_bytes())
}
