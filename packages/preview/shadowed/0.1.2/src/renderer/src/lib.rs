use std::str;

use rinja::Template;
use wasm_minimal_protocol::*;

macro_rules! float {
    ($bytes:expr, $arg:expr) => {{
        let buffer: [u8; 8] = $bytes
            .try_into()
            .map_err(|_| concat!("Could not cast ", $arg, " to f64: Length must be 8 bytes"))?;

        Ok::<f64, String>(f64::from_le_bytes(buffer))
    }};
}

macro_rules! string {
    ($bytes:expr, $arg:expr) => {{
        str::from_utf8($bytes)
            .map_err(|_| concat!("Could not cast ", $arg, " to str: Invalid UTF-8"))
    }};
}

initiate_protocol!();

#[wasm_func]
#[allow(clippy::too_many_arguments)]
pub fn render(
    arg1: &[u8],
    arg2: &[u8],
    arg3: &[u8],
    arg4: &[u8],
    arg5: &[u8],
    arg6: &[u8],
    arg7: &[u8],
    arg8: &[u8],
    arg9: &[u8],
) -> Result<Vec<u8>, String> {
    let svg_height = float!(arg1, "svg-height")?;
    let svg_width = float!(arg2, "svg-width")?;
    let blur = float!(arg3, "blur")?;
    let color = string!(arg4, "color")?;
    let rect_height = float!(arg5, "rect-height")?;
    let rect_width = float!(arg6, "rect-width")?;
    let x_offset = float!(arg7, "x-offset")?;
    let y_offset = float!(arg8, "y-offset")?;
    let radius = float!(arg9, "radius")?;

    let svg = SvgTemplate {
        svg_height,
        svg_width,
        blur,
        color,
        rect_height,
        rect_width,
        x_offset,
        y_offset,
        radius,
    };

    let mut buffer = Vec::new();

    svg.write_into(&mut buffer)
        .map_err(|err| format!("Could not render template: {err}"))?;

    Ok(buffer)
}

#[derive(Template)]
#[template(path = "shadow.svg.jinja")]
struct SvgTemplate<'a> {
    svg_height: f64,
    svg_width: f64,
    blur: f64,
    color: &'a str,
    rect_height: f64,
    rect_width: f64,
    x_offset: f64,
    y_offset: f64,
    radius: f64,
}
