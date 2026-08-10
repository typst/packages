//! # Zig Port of Nayuki's QR Code Generator (fixed-configuration build)
//! ## Zig port notes:
//! * All public names are preserved from the C original (qrcodegen_* prefix)
//!   wherever a name still applies to this narrowed configuration.
//! * Buffer-length macros become comptime-evaluable inline functions and constants
//! * All `bool` return values and out-parameters follow the same conventions as C
//!
//! ## This build is intentionally narrowed to a single fixed configuration:
//! * Version:            15 (fixed, no version search)
//! * Error correction:   Medium (fixed, no boosting)
//! * Mode:               Byte (fixed; numeric/alphanumeric/kanji support removed)
//! * Character encoding: ISO/IEC 8859-2, selected via an ECI designator
//!   (assignment value 4) that is emitted ahead of the byte-mode segment.
//!   The caller is responsible for encoding its text into ISO/IEC 8859-2 bytes
//!   before calling qrcodegen_encodeIso88592(); this module does not transcode.
//!
//! Everything else (Reed-Solomon ECC, function-module drawing, penalty-based
//! automatic mask selection, etc.) follows the original algorithm unchanged;
//! only the parts that varied by version/ECC/mode have been specialized.

const std = @import("std");
const assert = std.debug.assert;

// ---- Fixed configuration constants ----

/// The only QR Code version this build produces.
pub const qrcodegen_VERSION: i32 = 15;

/// The side length (in modules) of a Version 15 QR Code.
pub const qrcodegen_SIZE: i32 = qrcodegen_VERSION * 4 + 17;

/// Calculates the number of bytes needed to store a QR Code of the given
/// version number, as a comptime expression.
pub inline fn qrcodegen_BUFFER_LEN_FOR_VERSION(n: i32) usize {
	const s: usize = @intCast((n * 4 + 17) * (n * 4 + 17));
	return (s + 7) / 8 + 1;
}

/// The number of bytes needed for the qrcode and dataAndTemp buffers.
pub const qrcodegen_BUFFER_LEN: usize = qrcodegen_BUFFER_LEN_FOR_VERSION(qrcodegen_VERSION);

/// The ECI assignment value that selects ISO/IEC 8859-2 (Latin-2).
const ISO_8859_2_ECI_ASSIGNMENT: u32 = 4;

/// Error correction codewords per block, and number of blocks, for
/// Version 15 at error correction level Medium (ISO/IEC 18004 Table 13).
const ECC_CODEWORDS_PER_BLOCK: usize = 24;
const NUM_BLOCKS: usize = 10;

/// The maximum degree of the Reed-Solomon generator polynomial actually used
/// (equal to ECC_CODEWORDS_PER_BLOCK, since that is the only degree needed).
pub const qrcodegen_REED_SOLOMON_DEGREE_MAX: usize = ECC_CODEWORDS_PER_BLOCK;

/// The number of data bits available (excluding function modules and
/// remainder bits) for a Version 15 QR Code, derived the same way as in
/// the general-purpose original.
const RAW_DATA_MODULES: i32 = blk: {
	var result: i32 = (16 * qrcodegen_VERSION + 128) * qrcodegen_VERSION + 64;
	const numAlign: i32 = @divTrunc(qrcodegen_VERSION, 7) + 2;
	result -= (25 * numAlign - 10) * numAlign - 55;
	result -= 36; // Version >= 7 always has two version-information blocks
	break :blk result;
};

/// The number of 8-bit codewords (data + ECC) in a Version 15 QR Code,
/// with the remainder bits discarded.
const RAW_CODEWORDS: i32 = @divTrunc(RAW_DATA_MODULES, 8);

/// The number of 8-bit data (non-ECC) codewords available at ECC level Medium.
const DATA_CODEWORDS: i32 = RAW_CODEWORDS - @as(i32, @intCast(ECC_CODEWORDS_PER_BLOCK * NUM_BLOCKS));

/// The total number of data bits available at ECC level Medium.
const DATA_CAPACITY_BITS: usize = @as(usize, @intCast(DATA_CODEWORDS)) * 8;

/// The alignment pattern center positions for Version 15 (ISO/IEC 18004 Annex E).
const ALIGN_PAT_POS: [4]u8 = blk: {
	const numAlign: i32 = @divTrunc(qrcodegen_VERSION, 7) + 2;
	const step: i32 = @divTrunc(@divTrunc(qrcodegen_VERSION * 4 + numAlign * 2 + 1, numAlign - 1), 2) * 2;
	var pos: i32 = qrcodegen_VERSION * 4 + 10;
	var result: [4]u8 = undefined;
	var i: isize = @intCast(numAlign - 1);
	while (i >= 1) : (i -= 1) {
		result[@intCast(i)] = @intCast(pos);
		pos -= step;
	}
	result[0] = 6;
	break :blk result;
};

// ---- Enumerations ----

/// Mask pattern used in a QR Code symbol.
pub const qrcodegen_Mask = enum(i4) {
	/// A special value to tell the QR Code encoder to
	/// automatically select an appropriate mask pattern.
	qrcodegen_Mask_AUTO = -1,
	qrcodegen_Mask_0 = 0,
	qrcodegen_Mask_1 = 1,
	qrcodegen_Mask_2 = 2,
	qrcodegen_Mask_3 = 3,
	qrcodegen_Mask_4 = 4,
	qrcodegen_Mask_5 = 5,
	qrcodegen_Mask_6 = 6,
	qrcodegen_Mask_7 = 7,
};

/// Describes how a segment's data bits are interpreted.
/// Only the two modes actually used by this build are retained.
pub const qrcodegen_Mode = enum(u16) {
	qrcodegen_Mode_BYTE = 0x4,
	qrcodegen_Mode_ECI = 0x7,
};

// ---- Segment structure ----

/// A segment of ECI/binary data in a QR Code symbol.
pub const qrcodegen_Segment = struct {
	/// The mode indicator of this segment.
	mode: qrcodegen_Mode,
	/// The length of this segment's unencoded data. Measured in bytes for
	/// byte mode, and 0 for ECI mode. Always zero or positive.
	numChars: i32,
	/// The data bits of this segment, packed in bitwise big-endian.
	data: [*]u8,
	/// The number of valid data bits used in the buffer.
	bitLength: i32,
};

// ---- High-level encoding function ----

/// Encodes the given ISO/IEC 8859-2 encoded bytes into a Version 15,
/// error-correction-level Medium QR Code, returning true if encoding
/// succeeded (i.e. the data fits within the fixed capacity).
/// - The input dataAndTemp[0 : dataLen] must already be encoded in
///   ISO/IEC 8859-2; this function only emits the ECI designator, it does
///   not transcode.
/// - The arrays dataAndTemp and qrcode must each have a length of at least
///   qrcodegen_BUFFER_LEN.
/// - After the function returns, the contents of dataAndTemp may have
///   changed and are no longer meaningful; it is reused as scratch space,
///   matching the aliasing convention of the original library.
pub fn qrcodegen_encodeIso88592(
	dataAndTemp: []u8,
	dataLen: usize,
	qrcode: []u8,
) bool {
	var eciBuf: [1]u8 = undefined;
	const eciSeg = makeEciIso88592(&eciBuf);

	var byteSeg: qrcodegen_Segment = undefined;
	byteSeg.mode = qrcodegen_Mode.qrcodegen_Mode_BYTE;
	byteSeg.numChars = @intCast(dataLen);
	byteSeg.bitLength = calcByteSegmentBitLength(dataLen);
	if (byteSeg.bitLength == LENGTH_OVERFLOW) {
		qrcode[0] = 0;
		return false;
	}
	byteSeg.data = dataAndTemp.ptr;

	const segs = [2]qrcodegen_Segment{ eciSeg, byteSeg };
	return encodeSegmentsFixed(&segs, dataAndTemp, qrcode);
}

/// Returns a segment representing the ECI designator that selects
/// ISO/IEC 8859-2 (assignment value 4, which fits the single-byte form).
fn makeEciIso88592(buf: [*]u8) qrcodegen_Segment {
	var seg: qrcodegen_Segment = undefined;
	seg.mode = qrcodegen_Mode.qrcodegen_Mode_ECI;
	seg.numChars = 0;
	buf[0] = 0; // appendBitsToBuffer only ORs bits in, so the byte must start zeroed
	var bitLen: usize = 0;
	appendBitsToBuffer(ISO_8859_2_ECI_ASSIGNMENT, 8, buf[0..1], &bitLen);
	seg.bitLength = @intCast(bitLen);
	seg.data = buf;
	return seg;
}

// ---- Mid-level encoding function (fixed version/ECC/mask-auto) ----

/// Encodes the given ECI + byte segments to a Version 15, ECC-Medium QR Code.
/// This is the fixed-configuration counterpart of the original
/// qrcodegen_encodeSegmentsAdvanced(): no version search, no ECC boosting,
/// and the mask is always chosen automatically via penalty scoring.
fn encodeSegmentsFixed(segs: *const [2]qrcodegen_Segment, tempBuffer: []u8, qrcode: []u8) bool {
	assert(qrcodegen_BUFFER_LEN <= qrcode.len);
	assert(qrcodegen_BUFFER_LEN <= tempBuffer.len);

	// Check that everything fits in the fixed data capacity
	var bitLenTotal: i64 = 0;
	for (segs) |seg| {
		const ccBits: i32 = charCountBits(seg.mode);
		if (seg.numChars >= (@as(i32, 1) << @as(u5, @intCast(ccBits)))) {
			qrcode[0] = 0;
			return false;
		}
		bitLenTotal += 4 + ccBits + seg.bitLength;
	}
	if (bitLenTotal < 0 or bitLenTotal > @as(i64, @intCast(DATA_CAPACITY_BITS))) {
		qrcode[0] = 0;
		return false;
	}

	// Create the data bit string by concatenating both segments
	@memset(qrcode[0..qrcodegen_BUFFER_LEN], 0);
	var bitLen: usize = 0;
	for (segs) |seg| {
		appendBitsToBuffer(@intFromEnum(seg.mode), 4, qrcode[0..qrcodegen_BUFFER_LEN], &bitLen);
		appendBitsToBuffer(@intCast(seg.numChars), @intCast(charCountBits(seg.mode)), qrcode[0..qrcodegen_BUFFER_LEN], &bitLen);
		for (0..@intCast(seg.bitLength)) |j| {
			const bit: u32 = if (getBitFromMSB(seg.data[j >> 3], j & 7)) 1 else 0;
			appendBitsToBuffer(bit, 1, qrcode[0..qrcodegen_BUFFER_LEN], &bitLen);
		}
	}
	assert(bitLen == @as(usize, @intCast(bitLenTotal)));

	// Add terminator and pad up to a byte if applicable
	const terminatorBits: u5 = @intCast(@min(@as(usize, 4), DATA_CAPACITY_BITS - bitLen));
	appendBitsToBuffer(0, terminatorBits, qrcode[0..qrcodegen_BUFFER_LEN], &bitLen);
	appendBitsToBuffer(0, @intCast((8 - bitLen % 8) % 8), qrcode[0..qrcodegen_BUFFER_LEN], &bitLen);

	// Pad with alternating bytes until data capacity is reached
	var padByte: u8 = 0xEC;
	while (bitLen < DATA_CAPACITY_BITS) {
		appendBitsToBuffer(padByte, 8, qrcode[0..qrcodegen_BUFFER_LEN], &bitLen);
		padByte ^= 0xEC ^ 0x11;
	}
	assert(bitLen % 8 == 0);

	// Draw function and codeword modules
	addEccAndInterleave(qrcode[0..qrcodegen_BUFFER_LEN], tempBuffer[0..qrcodegen_BUFFER_LEN]);
	initializeFunctionModules(qrcode[0..qrcodegen_BUFFER_LEN]);
	drawCodewords(tempBuffer[0..@intCast(RAW_CODEWORDS)], qrcode[0..qrcodegen_BUFFER_LEN]);
	drawWhiteFunctionModules(qrcode[0..qrcodegen_BUFFER_LEN]);
	initializeFunctionModules(tempBuffer[0..qrcodegen_BUFFER_LEN]);

	// Automatically choose the mask pattern with the lowest penalty score
	var minPenalty: i32 = std.math.maxInt(i32);
	var bestMask: qrcodegen_Mask = qrcodegen_Mask.qrcodegen_Mask_0;
	var msk: i32 = 0;
	while (msk < 8) : (msk += 1) {
		const m: qrcodegen_Mask = @enumFromInt(msk);
		applyMask(tempBuffer[0..qrcodegen_BUFFER_LEN], qrcode[0..qrcodegen_BUFFER_LEN], m);
		drawFormatBits(m, qrcode[0..qrcodegen_BUFFER_LEN]);
		const penalty = getPenaltyScore(qrcode[0..qrcodegen_BUFFER_LEN]);
		if (penalty < minPenalty) {
			minPenalty = penalty;
			bestMask = m;
		}
		applyMask(tempBuffer[0..qrcodegen_BUFFER_LEN], qrcode[0..qrcodegen_BUFFER_LEN], m); // undo
	}
	applyMask(tempBuffer[0..qrcodegen_BUFFER_LEN], qrcode[0..qrcodegen_BUFFER_LEN], bestMask);
	drawFormatBits(bestMask, qrcode[0..qrcodegen_BUFFER_LEN]);
	return true;
}

/// Returns the bit width of the character count field for a segment in the
/// given mode, at the fixed Version 15 (which falls in the 10-26 range).
fn charCountBits(mode: qrcodegen_Mode) i32 {
	return switch (mode) {
		.qrcodegen_Mode_BYTE => 16,
		.qrcodegen_Mode_ECI => 0,
	};
}

// ---- Functions to extract raw data from QR codes ----

/// Returns the side length of the given QR Code, assuming that encoding succeeded.
/// For this build the result is always qrcodegen_SIZE (77).
pub fn qrcodegen_getSize(qrcode: []const u8) i32 {
	assert(qrcode.len > 0);
	const result: i32 = @as(i32, qrcode[0]) * 4 + 17;
	assert(21 <= result and result <= 177);
	return result;
}

/// Returns the color of the module (pixel) at the given coordinates, which is
/// false for light or true for dark. The top-left corner has the coordinates (x=0, y=0).
/// If the given coordinates are out of bounds, then false (light) is returned.
pub fn qrcodegen_getModule(qrcode: []const u8, x: i32, y: i32) bool {
	const qrsize = qrcodegen_getSize(qrcode);
	if (0 <= x and x < qrsize and 0 <= y and y < qrsize) {
		const i: usize = @intCast(y * qrsize + x);
		return getBitFromMSB(qrcode[(i >> 3) + 1], i & 7);
	}
	return false;
}

// ---- Private helper functions and lookup tables ----

const LENGTH_OVERFLOW: i32 = -1;

/// Returns the number of data bits needed for a byte-mode segment of the
/// given length, or LENGTH_OVERFLOW on failure.
fn calcByteSegmentBitLength(numChars: usize) i32 {
	if (numChars > 0x7FFF)
		return LENGTH_OVERFLOW;
	const n: i32 = @intCast(numChars);
	if (n > std.math.maxInt(i16) / 8)
		return LENGTH_OVERFLOW;
	return n * 8;
}

/// Appends the given number of low-order bits of val to the given byte-based
/// bit buffer, increasing the bit length. Requires 0 <= numBits <= 31 and
/// val < 2^numBits. This matches the C original's constraint.
fn appendBitsToBuffer(val: u32, numBits: u5, buf: []u8, bitLen: *usize) void {
	assert(numBits <= 31 and (numBits == 0 or val >> numBits == 0));
	var i: i32 = @as(i32, numBits) - 1;
	while (i >= 0) : (i -= 1) {
		const bit: u1 = @truncate((val >> @intCast(i)) & 1);
		const shift: u3 = @intCast(7 - (bitLen.* & 7));
		buf[bitLen.* >> 3] |= @as(u8, bit) << shift;
		bitLen.* += 1;
	}
}

/// Returns true iff the i'th bit of x is set (bit 0 is LSB).
inline fn getBit(x: u8, i: u3) bool {
	return ((x >> i) & 1) != 0;
}

/// Returns true iff bit position `i` (counting from MSB=7) of x is set.
inline fn getBitFromMSB(x: u8, i: usize) bool {
	return getBit(x, @intCast(7 - (i & 7)));
}

// ---- Reed-Solomon ECC generator functions ----

/// Computes a Reed-Solomon ECC generator polynomial for the given degree,
/// storing in result[0..degree]. This could be implemented as a lookup table
/// over all possible parameter values, instead of as an algorithm.
pub fn reedSolomonComputeDivisor(degree: usize, result: []u8) void {
	assert(1 <= degree and degree <= qrcodegen_REED_SOLOMON_DEGREE_MAX);
	@memset(result[0..degree], 0);
	result[degree - 1] = 1; // Start with monomial x^0

	var root: u8 = 1;
	for (0..degree) |_| {
		// Multiply the current generator polynomial by (x - r^i)
		for (0..degree) |j| {
			result[j] = reedSolomonMultiply(result[j], root);
			if (j + 1 < degree)
				result[j] ^= result[j + 1];
		}
		root = reedSolomonMultiply(root, 0x02);
	}
}

/// Computes the Reed-Solomon ECC of the given data and divisor polynomials,
/// and stores the remainder into result[0..degree].
/// All polynomials are in big-endian, and the generator has an implicit leading 1 term.
pub fn reedSolomonComputeRemainder(
	data: []const u8,
	generator: []const u8,
	result: []u8,
) void {
	const degree = generator.len;
	assert(1 <= degree and degree <= qrcodegen_REED_SOLOMON_DEGREE_MAX);
	@memset(result[0..degree], 0);
	for (data) |b| {
		const factor = b ^ result[0];
		std.mem.copyForwards(u8, result[0 .. degree - 1], result[1..degree]);
		result[degree - 1] = 0;
		for (0..degree) |j| {
			result[j] ^= reedSolomonMultiply(generator[j], factor);
		}
	}
}

/// Returns the product of the two given field elements modulo GF(2^8/0x11D).
/// All inputs are valid. This could be implemented as a 256*256 lookup table.
pub fn reedSolomonMultiply(x: u8, y: u8) u8 {
	// Russian-peasant multiplication in GF(2^8) with primitive polynomial 0x11D.
	// Process y LSB-first: for each bit of y, if set XOR in x; then double x.
	var z: u8 = 0;
	var xi = x;
	var yi = y;
	var i: usize = 0;
	while (i < 8) : (i += 1) {
		if (yi & 1 != 0)
			z ^= xi;
		yi >>= 1;
		xi = (xi << 1) ^ (@as(u8, xi >> 7) * 0x1D);
	}
	return z;
}

// ---- Drawing function modules ----

/// Clears the given QR Code grid with light modules, then marks every
/// function module as dark. Does not write non-function modules.
fn initializeFunctionModules(qrcode: []u8) void {
	// Initialize QR Code
	@memset(qrcode[0..qrcodegen_BUFFER_LEN], 0);
	qrcode[0] = @intCast(qrcodegen_VERSION);

	// Fill horizontal and vertical timing patterns
	fillRectangle(6, 0, 1, qrcodegen_SIZE, qrcode);
	fillRectangle(0, 6, qrcodegen_SIZE, 1, qrcode);

	// Fill 3 finder patterns (all corners except bottom-right) and format bits
	fillRectangle(0, 0, 9, 9, qrcode);
	fillRectangle(qrcodegen_SIZE - 8, 0, 8, 9, qrcode);
	fillRectangle(0, qrcodegen_SIZE - 8, 9, 8, qrcode);

	// Fill alignment patterns
	for (0..ALIGN_PAT_POS.len) |i| {
		for (0..ALIGN_PAT_POS.len) |j| {
			// Don't overlap with finder patterns
			if (!((i == 0 and j == 0) or (i == 0 and j == ALIGN_PAT_POS.len - 1) or (i == ALIGN_PAT_POS.len - 1 and j == 0))) {
				fillRectangle(
					@as(i32, ALIGN_PAT_POS[i]) - 2,
					@as(i32, ALIGN_PAT_POS[j]) - 2,
					5,
					5,
					qrcode,
				);
			}
		}
	}

	// Fill version blocks (Version 15 >= 7, so these are always present)
	fillRectangle(qrcodegen_SIZE - 11, 0, 3, 6, qrcode);
	fillRectangle(0, qrcodegen_SIZE - 11, 6, 3, qrcode);
}

/// Draws light function modules and possibly some dark modules onto the given
/// QR Code, without changing non-function modules. This does not draw the
/// format bits. This requires all function modules to be previously marked dark.
fn drawWhiteFunctionModules(qrcode: []u8) void {
	const qrsize: i32 = qrcodegen_SIZE;

	// Draw horizontal and vertical timing patterns
	var i: i32 = 7;
	while (i < qrsize - 7) : (i += 2) {
		setModuleBounded(qrcode, 6, i, false);
		setModuleBounded(qrcode, i, 6, false);
	}

	// Draw 3 finder patterns
	drawWhiteFinderPattern(qrcode, 3, 3);
	drawWhiteFinderPattern(qrcode, qrsize - 4, 3);
	drawWhiteFinderPattern(qrcode, 3, qrsize - 4);

	// Draw alignment patterns
	for (0..ALIGN_PAT_POS.len) |a| {
		for (0..ALIGN_PAT_POS.len) |b| {
			if (!((a == 0 and b == 0) or (a == 0 and b == ALIGN_PAT_POS.len - 1) or (a == ALIGN_PAT_POS.len - 1 and b == 0))) {
				const cx: i32 = ALIGN_PAT_POS[a];
				const cy: i32 = ALIGN_PAT_POS[b];
				var dy: i32 = -2;
				while (dy <= 2) : (dy += 1) {
					var dx: i32 = -2;
					while (dx <= 2) : (dx += 1) {
						const dist = @max(@abs(dx), @abs(dy));
						setModuleBounded(qrcode, cx + dx, cy + dy, dist != 1);
					}
				}
			}
		}
	}

	// Draw version blocks (Version 15 >= 7, so these are always present)
	var rem: u32 = @intCast(qrcodegen_VERSION);
	var j: usize = 0;
	while (j < 12) : (j += 1) {
		rem = (rem << 1) ^ ((rem >> 11) * 0x1F25);
	}
	var bits: u32 = (@as(u32, @intCast(qrcodegen_VERSION)) << 12) | rem;
	j = 0;
	while (j < 18) : (j += 1) {
		const dark = (bits & 1) != 0;
		bits >>= 1;
		setModuleBounded(qrcode, @intCast(qrsize - 11 + @as(i32, @intCast(j % 3))), @intCast(j / 3), dark);
		setModuleBounded(qrcode, @intCast(j / 3), @intCast(qrsize - 11 + @as(i32, @intCast(j % 3))), dark);
	}
}

fn drawWhiteFinderPattern(qrcode: []u8, cx: i32, cy: i32) void {
	var dy: i32 = -4;
	while (dy <= 4) : (dy += 1) {
		var dx: i32 = -4;
		while (dx <= 4) : (dx += 1) {
			const dist = @max(@abs(dx), @abs(dy));
			setModuleUnbounded(qrcode, cx + dx, cy + dy, dist != 2 and dist != 4);
		}
	}
}

/// Sets the module at the given coordinates, which must be in-bounds.
fn setModuleBounded(qrcode: []u8, x: i32, y: i32, dark: bool) void {
	const qrsize = qrcodegen_getSize(qrcode);
	assert(0 <= x and x < qrsize and 0 <= y and y < qrsize);
	const index: usize = @intCast(y * qrsize + x);
	const shift: u3 = @intCast(7 - (index & 7));
	const byte_index = (index >> 3) + 1; // +1 because qrcode[0] stores the version
	if (dark) {
		qrcode[byte_index] |= @as(u8, 1) << shift;
	} else {
		qrcode[byte_index] &= ~(@as(u8, 1) << shift);
	}
}

/// Sets the module at the given coordinates, doing nothing if out of bounds.
fn setModuleUnbounded(qrcode: []u8, x: i32, y: i32, dark: bool) void {
	const qrsize = qrcodegen_getSize(qrcode);
	if (0 <= x and x < qrsize and 0 <= y and y < qrsize)
		setModuleBounded(qrcode, x, y, dark);
}

/// Fills a rectangle of modules with dark color.
fn fillRectangle(left: i32, top: i32, width: i32, height: i32, qrcode: []u8) void {
	var dy: i32 = 0;
	while (dy < height) : (dy += 1) {
		var dx: i32 = 0;
		while (dx < width) : (dx += 1) {
			setModuleBounded(qrcode, left + dx, top + dy, true);
		}
	}
}

// ---- Drawing data modules and masking ----

/// Draws the raw codewords (including data and ECC) onto the given QR Code.
/// This requires the initial state of the QR Code to be dark at function modules
/// and light at codeword modules (including unused remainder bits).
fn drawCodewords(data: []const u8, qrcode: []u8) void {
	const qrsize = qrcodegen_getSize(qrcode);
	var i: usize = 0; // Bit index into data
	// Do the funny zigzag scan
	var right: i32 = qrsize - 1;
	while (right >= 1) : (right -= 2) {
		if (right == 6) right = 5;
		var vert: i32 = 0;
		while (vert < qrsize) : (vert += 1) {
			var j: i32 = 0;
			while (j < 2) : (j += 1) {
				const x: i32 = right - j;
				const upward = ((right + 1) & 2) == 0;
				const y: i32 = if (upward) qrsize - 1 - vert else vert;
				if (!getModuleBounded(qrcode, x, y) and i < data.len * 8) {
					const dark = getBitFromMSB(data[i >> 3], i & 7);
					setModuleBounded(qrcode, x, y, dark);
					i += 1;
				}
			}
		}
	}
	assert(i == data.len * 8);
}

/// Returns the module at the given coordinates, which must be in-bounds.
fn getModuleBounded(qrcode: []const u8, x: i32, y: i32) bool {
	const qrsize = qrcodegen_getSize(qrcode);
	assert(0 <= x and x < qrsize and 0 <= y and y < qrsize);
	const index: usize = @intCast(y * qrsize + x);
	return getBitFromMSB(qrcode[(index >> 3) + 1], index & 7);
}

/// XORs the codeword modules in this QR Code with the given mask pattern.
/// The function modules must be marked as such.
fn applyMask(functionModules: []const u8, qrcode: []u8, mask: qrcodegen_Mask) void {
	assert(mask != qrcodegen_Mask.qrcodegen_Mask_AUTO);
	const qrsize = qrcodegen_getSize(qrcode);
	var y: i32 = 0;
	while (y < qrsize) : (y += 1) {
		var x: i32 = 0;
		while (x < qrsize) : (x += 1) {
			if (getModuleBounded(functionModules, x, y))
				continue;
			const invert: bool = switch (mask) {
				.qrcodegen_Mask_AUTO => unreachable,
				.qrcodegen_Mask_0 => @mod(x + y, 2) == 0,
				.qrcodegen_Mask_1 => @mod(y, 2) == 0,
				.qrcodegen_Mask_2 => @mod(x, 3) == 0,
				.qrcodegen_Mask_3 => @mod(x + y, 3) == 0,
				.qrcodegen_Mask_4 => @mod(@divTrunc(x, 3) + @divTrunc(y, 2), 2) == 0,
				.qrcodegen_Mask_5 => @mod(x * y, 2) + @mod(x * y, 3) == 0,
				.qrcodegen_Mask_6 => @mod(@mod(x * y, 2) + @mod(x * y, 3), 2) == 0,
				.qrcodegen_Mask_7 => @mod(@mod(x + y, 2) + @mod(x * y, 3), 2) == 0,
			};
			if (invert) {
				const index: usize = @intCast(y * qrsize + x);
				const shift: u3 = @intCast(7 - (index & 7));
				qrcode[(index >> 3) + 1] ^= @as(u8, 1) << shift;
			}
		}
	}
}

/// Calculates and draws the format bits (with its own error correction code)
/// based on the given mask, at the fixed error correction level Medium.
/// This always draws all modules of the format information, unlike
/// drawWhiteFunctionModules().
fn drawFormatBits(mask: qrcodegen_Mask, qrcode: []u8) void {
	assert(mask != qrcodegen_Mask.qrcodegen_Mask_AUTO);
	const qrsize = qrcodegen_getSize(qrcode);
	// Error correction level Medium always corresponds to eclBits = 0b00
	const eclBits: u32 = 0;
	const maskBits: u32 = @intCast(@intFromEnum(mask)); // safe: mask != AUTO so value is 0..7
	var rem: u32 = (eclBits << 3) | maskBits;
	var i: usize = 0;
	while (i < 10) : (i += 1) {
		rem = (rem << 1) ^ ((rem >> 9) * 0x537);
	}
	const bits: u32 = ((eclBits << 3) | maskBits) << 10 | rem;
	assert(bits >> 15 == 0);
	const b: u32 = bits ^ 0x5412;

	// Helper: get bit i of b (LSB-first) as bool
	const bitAt = struct {
		fn f(val: u32, idx: usize) bool {
			return ((val >> @intCast(idx)) & 1) != 0;
		}
	}.f;

	// Draw first copy
	i = 0;
	while (i <= 5) : (i += 1) {
		setModuleBounded(qrcode, 8, @intCast(i), bitAt(b, i));
	}
	setModuleBounded(qrcode, 8, 7, bitAt(b, 6));
	setModuleBounded(qrcode, 8, 8, bitAt(b, 7));
	setModuleBounded(qrcode, 7, 8, bitAt(b, 8));
	i = 9;
	while (i < 15) : (i += 1) {
		setModuleBounded(qrcode, 14 - @as(i32, @intCast(i)), 8, bitAt(b, i));
	}

	// Draw second copy
	i = 0;
	while (i < 8) : (i += 1) {
		setModuleBounded(qrcode, qrsize - 1 - @as(i32, @intCast(i)), 8, bitAt(b, i));
	}
	i = 8;
	while (i < 15) : (i += 1) {
		setModuleBounded(qrcode, 8, qrsize - 15 + @as(i32, @intCast(i)), bitAt(b, i));
	}
	setModuleBounded(qrcode, 8, qrsize - 8, true); // always dark
}

// ---- ECC/interleaving functions ----

/// Calculates the Reed-Solomon error correction codewords for each block of
/// the given data array, appends them to the end of the array, then interleaves
/// input and output bytes together, for the fixed Version 15 / ECC Medium
/// configuration (10 blocks, 24 ECC codewords per block).
/// data[0 : rawCodewords - totalEcc] contains the input data.
/// data[rawCodewords - totalEcc : rawCodewords] is used as a temporary work
/// area and will be clobbered by this function.
/// The final answer is stored in result[0 : rawCodewords].
fn addEccAndInterleave(data: []u8, result: []u8) void {
	assert(data.len >= qrcodegen_BUFFER_LEN);
	assert(result.len >= qrcodegen_BUFFER_LEN);

	const numBlocks: usize = NUM_BLOCKS;
	const blockEccLen: usize = ECC_CODEWORDS_PER_BLOCK;
	const rawCodewords: usize = @intCast(RAW_CODEWORDS);
	const dataLen: usize = @intCast(DATA_CODEWORDS);
	const numShortBlocks: usize = numBlocks - rawCodewords % numBlocks;
	const shortBlockDataLen: usize = rawCodewords / numBlocks - blockEccLen;

	// Split data into blocks and append ECC after all data
	var generator: [qrcodegen_REED_SOLOMON_DEGREE_MAX]u8 = undefined;
	reedSolomonComputeDivisor(blockEccLen, generator[0..blockEccLen]);
	var blockStart: usize = 0;
	var i: usize = 0;
	while (i < numBlocks) : (i += 1) {
		const blockDataLen = shortBlockDataLen + (if (i < numShortBlocks) @as(usize, 0) else 1);
		reedSolomonComputeRemainder(
			data[blockStart .. blockStart + blockDataLen],
			generator[0..blockEccLen],
			data[dataLen + i * blockEccLen .. dataLen + (i + 1) * blockEccLen],
		);
		blockStart += blockDataLen;
	}

	// Interleave (not concatenate) the bytes from every block into a single sequence
	blockStart = 0;
	i = 0;
	while (i < numBlocks) : (i += 1) {
		const blockDataLen = shortBlockDataLen + (if (i < numShortBlocks) @as(usize, 0) else 1);
		var j: usize = 0;
		while (j < blockDataLen) : (j += 1) {
			// For the extra byte in long blocks (index shortBlockDataLen), place after all short-block bytes
			result[j * numBlocks + i - (if (j < shortBlockDataLen) @as(usize, 0) else numShortBlocks)] = data[blockStart + j];
		}
		blockStart += blockDataLen;
	}
	// Interleave ECC bytes
	i = 0;
	while (i < numBlocks) : (i += 1) {
		var j: usize = 0;
		while (j < blockEccLen) : (j += 1) {
			result[rawCodewords - numBlocks * blockEccLen + j * numBlocks + i] = data[dataLen + i * blockEccLen + j];
		}
	}
}

// ---- Penalty scoring ----

/// Calculates and returns the penalty score based on state of the given QR Code's
/// current modules. This is used by the automatic mask choice algorithm to find
/// the mask pattern that yields the lowest score.
fn getPenaltyScore(qrcode: []const u8) i32 {
	const qrsize = qrcodegen_getSize(qrcode);
	var result: i32 = 0;

	// Adjacent modules in row having same color, and finder-like patterns
	var y: i32 = 0;
	while (y < qrsize) : (y += 1) {
		var runColor = false;
		var runX: i32 = 0;
		var runHistory = [_]i32{0} ** 7;
		var x: i32 = 0;
		while (x < qrsize) : (x += 1) {
			if (getModuleBounded(qrcode, x, y) == runColor) {
				runX += 1;
				if (runX == 5)
					result += PENALTY_N1
				else if (runX > 5)
					result += 1;
			} else {
				finderPenaltyAddHistory(runX, &runHistory);
				if (!runColor)
					result += finderPenaltyCountPatterns(&runHistory) * PENALTY_N3;
				runColor = getModuleBounded(qrcode, x, y);
				runX = 1;
			}
		}
		result += finderPenaltyTerminateAndCount(runColor, runX, &runHistory, qrsize) * PENALTY_N3;
	}

	// Adjacent modules in column having same color, and finder-like patterns
	var xi: i32 = 0;
	while (xi < qrsize) : (xi += 1) {
		var runColor = false;
		var runY: i32 = 0;
		var runHistory = [_]i32{0} ** 7;
		var yi: i32 = 0;
		while (yi < qrsize) : (yi += 1) {
			if (getModuleBounded(qrcode, xi, yi) == runColor) {
				runY += 1;
				if (runY == 5)
					result += PENALTY_N1
				else if (runY > 5)
					result += 1;
			} else {
				finderPenaltyAddHistory(runY, &runHistory);
				if (!runColor)
					result += finderPenaltyCountPatterns(&runHistory) * PENALTY_N3;
				runColor = getModuleBounded(qrcode, xi, yi);
				runY = 1;
			}
		}
		result += finderPenaltyTerminateAndCount(runColor, runY, &runHistory, qrsize) * PENALTY_N3;
	}

	// 2*2 blocks of modules having same color
	y = 0;
	while (y < qrsize - 1) : (y += 1) {
		var xa: i32 = 0;
		while (xa < qrsize - 1) : (xa += 1) {
			const color = getModuleBounded(qrcode, xa, y);
			if (color == getModuleBounded(qrcode, xa + 1, y) and
				color == getModuleBounded(qrcode, xa, y + 1) and
				color == getModuleBounded(qrcode, xa + 1, y + 1))
				result += PENALTY_N2;
		}
	}

	// Balance of dark and light modules
	var dark: i32 = 0;
	y = 0;
	while (y < qrsize) : (y += 1) {
		var xb: i32 = 0;
		while (xb < qrsize) : (xb += 1) {
			if (getModuleBounded(qrcode, xb, y)) dark += 1;
		}
	}
	const total: i32 = qrsize * qrsize;
	const diff: i32 = @intCast(@abs(dark * 20 - total * 10));
	const k: i32 = @divTrunc(diff + total - 1, total) - 1;
	assert(0 <= k and k <= 9);
	result += k * PENALTY_N4;
	assert(0 <= result and result <= 2568888);
	return result;
}

const PENALTY_N1: i32 = 3;
const PENALTY_N2: i32 = 3;
const PENALTY_N3: i32 = 40;
const PENALTY_N4: i32 = 10;

fn finderPenaltyCountPatterns(runHistory: *const [7]i32) i32 {
	const n = runHistory[1];
	const core = n > 0 and runHistory[2] == n and runHistory[3] == n * 3 and
		runHistory[4] == n and runHistory[5] == n;
	return (if (core and runHistory[0] >= n * 4 and runHistory[6] >= n) @as(i32, 1) else 0) +
		(if (core and runHistory[6] >= n * 4 and runHistory[0] >= n) @as(i32, 1) else 0);
}

fn finderPenaltyTerminateAndCount(currentRunColor: bool, currentRunLen: i32, runHistory: *[7]i32, qrsize: i32) i32 {
	if (currentRunColor) {
		finderPenaltyAddHistory(currentRunLen, runHistory);
		finderPenaltyAddHistory(0, runHistory);
	} else {
		finderPenaltyAddHistory(currentRunLen + qrsize, runHistory);
	}
	return finderPenaltyCountPatterns(runHistory);
}

fn finderPenaltyAddHistory(currentRunLen: i32, runHistory: *[7]i32) void {
	if (runHistory[0] == 0) {
		runHistory[0] = currentRunLen;
	} else {
		var i: isize = 6;
		while (i >= 1) : (i -= 1) {
			runHistory[@intCast(i)] = runHistory[@intCast(i - 1)];
		}
		runHistory[0] = currentRunLen;
	}
}
