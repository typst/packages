//! Typst plugin entry point.
//!
//! Implements the `typst_env` WASM minimal protocol (see Typst docs) on top
//! of the fixed-configuration QR encoder in `qrcodegen.zig`, using `iso_iec_8859_2.zig` to
//! transcode the plugin's UTF-8 input into ISO-8859-2 first.
//!
//! There is a single exported function, `main`, taking one length argument
//! (the UTF-8 text to encode). This is the only argument the protocol needs
//! to pull out of the shared buffer, so `n = 1` here.
//!
//! Output by bytes (on success, return code 0):
//! * 0:                    the side length of the symbol, in modules
//!                         (always `qrcodegen_SIZE` = 77 for this build;
//!                         unlike `qrcode[0]` inside `qrcodegen.zig`, this
//!                         is the literal side length, not the version number)
//! * [1, size * size + 1]: one byte per module, row-major (y outer, x inner),
//!                         1 for a dark module and 0 for a light module
//!
//! On failure (return code 1), the sent buffer is a UTF-8 error message instead.

const std = @import("std");
const qr = @import("qrcodegen.zig");
const eci = @import("iso_iec_8859_2.zig");

const allocator = std.heap.page_allocator;

// Functions needed for the protocol
extern "typst_env" fn wasm_minimal_protocol_send_result_to_host(ptr: [*]const u8, len: usize) void;
extern "typst_env" fn wasm_minimal_protocol_write_args_to_buffer(ptr: [*]u8) void;

// The only exported function
export fn main(text_len: usize) i32 {
	const text = allocator.alloc(u8, text_len) catch return sendError("Out of memory reading input");
	defer allocator.free(text);
	wasm_minimal_protocol_write_args_to_buffer(text.ptr);

	// Scratch buffers for the transcoder and the encoder; both are reused/
	// clobbered internally, matching the aliasing convention of `qrcodegen.zig`.
	var textBuf: [qr.qrcodegen_BUFFER_LEN]u8 = undefined;
	var qrBuf: [qr.qrcodegen_BUFFER_LEN]u8 = undefined;

	// Transcoding from UTF-8 is NOT part of the QR code generator itself,
	// qrs.zig only emits the ECI designator and expects pre-transcoded bytes.
	const iecBytes = eci.utf8ToIso88592(text, &textBuf) catch |err| return switch (err) {
		error.InvalidUtf8 => sendError("Input is not valid UTF-8"),
		error.UnsupportedCharacter => sendError("Input contains a character with no ISO/IEC 8859-2 representation"),
		error.NoSpaceLeft => sendError("Input is too long to transcode"),
	};

	if (!qr.qrcodegen_encodeIso88592(&textBuf, iecBytes.len, &qrBuf)) {
		return sendError("Text too long for Version 15 / ECC Medium");
	}

	// This is fixed for this narrowed build (always 77), but computed via
	// the library's own accessor rather than assumed, in case that changes.
	const size = qr.qrcodegen_getSize(&qrBuf);
	const sizeUsize: usize = @intCast(size);
	const moduleCount = sizeUsize * sizeUsize;

	const result = allocator.alloc(u8, 1 + moduleCount) catch return sendError("Out of memory writing output");
	defer allocator.free(result);
	result[0] = @intCast(size);

	var y: i32 = 0;
	while (y < size) : (y += 1) {
		var x: i32 = 0;
		while (x < size) : (x += 1) {
			const idx: usize = 1 + @as(usize, @intCast(y)) * sizeUsize + @as(usize, @intCast(x));
			result[idx] = if (qr.qrcodegen_getModule(&qrBuf, x, y)) 1 else 0;
		}
	}

	wasm_minimal_protocol_send_result_to_host(result.ptr, result.len);
	return 0;
}

/// Sends `message` as the error payload and returns the protocol's error code.
fn sendError(message: []const u8) i32 {
	wasm_minimal_protocol_send_result_to_host(message.ptr, message.len);
	return 1;
}
