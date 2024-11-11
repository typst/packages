use std::str;

use rinja::Template;
use wasm_minimal_protocol::*;

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
    let svg_height =
        str::from_utf8(arg1).map_err(|_| "Could not parse svg_width to string: Invalid UTF-8")?;
    let svg_width =
        str::from_utf8(arg2).map_err(|_| "Could not parse svg_height to string: Invalid UTF-8")?;
    let blur = str::from_utf8(arg3).map_err(|_| "Could not parse blur to string: Invalid UTF-8")?;
    let color =
        str::from_utf8(arg4).map_err(|_| "Could not parse color to string: Invalid UTF-8")?;
    let rect_height =
        str::from_utf8(arg5).map_err(|_| "Could not parse rect_height to string: Invalid UTF-8")?;
    let rect_width =
        str::from_utf8(arg6).map_err(|_| "Could not parse rect_width to string: Invalid UTF-8")?;
    let x_offset =
        str::from_utf8(arg7).map_err(|_| "Could not parse x_offset to string: Invalid UTF-8")?;
    let y_offset =
        str::from_utf8(arg8).map_err(|_| "Could not parse y_offest to string: Invalid UTF-8")?;
    let radius =
        str::from_utf8(arg9).map_err(|_| "Could not parse radius to string: Invalid UTF-8")?;

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
    svg_height: &'a str,
    svg_width: &'a str,
    blur: &'a str,
    color: &'a str,
    rect_height: &'a str,
    rect_width: &'a str,
    x_offset: &'a str,
    y_offset: &'a str,
    radius: &'a str,
}
