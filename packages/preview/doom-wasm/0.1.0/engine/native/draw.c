// SPDX-License-Identifier: GPL-2.0-or-later
// Adapted from DoomGeneric r_draw.c:
// Copyright(C) 1993-1996 Id Software, Inc.
// Copyright(C) 2005-2014 Simon Howard
//
// Keep texture/lighting pointers in locals across each pixel loop. The original
// globals can alias byte stores from the compiler's perspective, forcing WASM
// to reload them per pixel. Texture coordinates and lookup order are unchanged.
#include <stdint.h>
#include "doomdef.h"
#include "r_main.h"
#include "r_draw.h"

extern byte *ylookup[];
extern int columnofs[];

void __wrap_R_DrawColumn(void) {
    int count = dc_yh - dc_yl;
    if (count < 0) return;
    byte *dest = ylookup[dc_yl] + columnofs[dc_x];
    const byte *source = dc_source;
    const byte *map = dc_colormap;
    uint32_t step = dc_iscale;
    uint32_t frac = (uint32_t)dc_texturemid + (uint32_t)(dc_yl - centery) * step;
    do {
        *dest = map[source[(frac >> FRACBITS) & 127]];
        dest += SCREENWIDTH;
        frac += step;
    } while (count--);
}

void __wrap_R_DrawSpan(void) {
    uint32_t position = (((uint32_t)ds_xfrac << 10) & 0xffff0000u)
                      | (((uint32_t)ds_yfrac >> 6) & 0xffffu);
    uint32_t step = (((uint32_t)ds_xstep << 10) & 0xffff0000u)
                  | (((uint32_t)ds_ystep >> 6) & 0xffffu);
    byte *dest = ylookup[ds_y] + columnofs[ds_x1];
    const byte *source = ds_source;
    const byte *map = ds_colormap;
    int count = ds_x2 - ds_x1;
    do {
        unsigned spot = (position >> 26) | ((position >> 4) & 0xfc0);
        *dest++ = map[source[spot]];
        position += step;
    } while (count--);
}
