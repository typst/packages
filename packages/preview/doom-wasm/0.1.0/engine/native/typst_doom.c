// SPDX-License-Identifier: GPL-2.0-or-later
// Typst host adapter for DoomGeneric. Engine code remains in vendor/doomgeneric.
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include "doomgeneric.h"
#include "doomstat.h"
#include "d_loop.h"
#include "m_controls.h"
#include "doomkeys.h"
#include "i_video.h"
#include "d_event.h"
#include "r_state.h"
#include "g_game.h"
#include "p_saveg.h"
#include "w_wad.h"
#include "w_file.h"
#include "m_menu.h"
#include "memory_fs.h"

__attribute__((import_module("typst_env"), import_name("wasm_minimal_protocol_write_args_to_buffer")))
extern void host_args(void *);
__attribute__((import_module("typst_env"), import_name("wasm_minimal_protocol_send_result_to_host")))
extern void host_result(const void *, size_t);
#define EXPORT(name) __attribute__((export_name(name)))

static unsigned char *wad_data;
static size_t wad_size;
static int initialized;
static int quit_requested;
static uint32_t clock_ms = 1;
static unsigned char rgb_frame[320 * 200 * 3];
static int action_tics = 4;
static const char *wad_name = "doom1.wad";
extern gamestate_t wipegamestate;
extern void __wasm_call_ctors(void);
extern void D_Display(void);
extern void M_ClearMenus(void);

uint32_t DG_GetTicksMs(void) { return clock_ms; }
void DG_SleepMs(uint32_t ms) { clock_ms += ms; }
void DG_Init(void) {}
void DG_DrawFrame(void) {}
void DG_SetWindowTitle(const char *title) { (void)title; }
int DG_GetKey(int *pressed, unsigned char *key) { return 0; }
void __wrap_I_Quit(void) { quit_requested = 1; }

// Rendering updates Doom's indexed framebuffer every tic, but expanding it to
// RGB is only useful when Typst requests an image. No game code reads the host
// screen buffer, so this leaves simulation and renderer state unchanged.
void __wrap_I_FinishUpdate(void) {}
extern void __real_I_FinishUpdate(void);

// Use Doom's existing mapped-lump path over the immutable IWAD input. This
// avoids libc stream reads and duplicate zone allocations for cached lumps.
static void mapped_close(wad_file_t *file) { (void)file; }
static size_t mapped_read(wad_file_t *file, unsigned int offset, void *buffer, size_t length) {
    if (offset >= file->length) return 0;
    if (length > file->length - offset) length = file->length - offset;
    memcpy(buffer, file->mapped + offset, length);
    return length;
}
static wad_file_class_t mapped_class = {NULL, mapped_close, mapped_read};
static wad_file_t mapped_wad;
wad_file_t *__wrap_W_OpenFile(char *path) {
    if (!wad_data || strcmp(path, wad_name)) return NULL;
    mapped_wad.file_class = &mapped_class;
    mapped_wad.mapped = wad_data;
    mapped_wad.length = wad_size;
    return &mapped_wad;
}

// libc operates on a memory stream. Config/save file access has no host effects.
FILE *__wrap_fopen(const char *path, const char *mode) {
    if (wad_data && !strcmp(path, wad_name) && mode[0] == 'r')
        return fmemopen(wad_data, wad_size, "rb");
    return memory_open(path, mode);
}
int system(const char *cmd) { (void)cmd; return -1; }

static int fail(const char *message) { host_result(message, strlen(message)); return 1; }
static uint32_t le32(const unsigned char *p) {
    return (uint32_t)p[0] | (uint32_t)p[1] << 8 | (uint32_t)p[2] << 16 | (uint32_t)p[3] << 24;
}

EXPORT("init") int plugin_init(size_t wad_len, size_t config_len) {
    if (initialized) return fail("Engine already initialized; start from the base plugin.");
    if (wad_len < 12 || wad_len > 64 * 1024 * 1024 || config_len != 4)
        return fail("Expected an IWAD (under 64 MiB) and four configuration bytes.");
    __wasm_call_ctors();
    unsigned char *args = malloc(wad_len + config_len);
    if (!args) return fail("Cannot allocate WAD memory.");
    host_args(args);
    uint32_t count = le32(args + 4), directory = le32(args + 8);
    if (memcmp(args, "IWAD", 4) || directory > wad_len || count > (wad_len - directory) / 16) {
        free(args); return fail("Invalid IWAD directory.");
    }
    int has_doom1 = 0, has_doom2 = 0;
    for (uint32_t i = 0; i < count; ++i) {
        unsigned char *entry = args + directory + i * 16;
        uint32_t offset = le32(entry), length = le32(entry + 4);
        if (offset > wad_len || length > wad_len - offset) { free(args); return fail("IWAD lump outside file."); }
        if (!memcmp(entry + 8, "E1M1\0\0\0\0", 8)) has_doom1 = 1;
        if (!memcmp(entry + 8, "MAP01\0\0\0", 8)) has_doom2 = 1;
    }
    unsigned char *config = args + wad_len;
    if (config[0] < 1 || config[0] > 5 || config[1] < 1 || config[1] > 4 || config[2] < 1 || config[2] > 32 || config[3] < 1 || config[3] > 35) {
        free(args); return fail("Invalid skill, episode, map or ticks-per-command.");
    }
    action_tics = config[3];
    if (!has_doom1 && !has_doom2) { free(args); return fail("Expected a DOOM or DOOM II IWAD."); }
    int commercial_wad = has_doom2 && !has_doom1;
    wad_name = commercial_wad ? "doom2.wad" : "doom1.wad";
    char requested_map[9] = {0};
    if (commercial_wad) snprintf(requested_map, sizeof(requested_map), "MAP%02u", config[2]);
    else snprintf(requested_map, sizeof(requested_map), "E%uM%u", config[1], config[2]);
    int map_found = 0;
    for (uint32_t i = 0; i < count; ++i)
        if (!memcmp(args + directory + i * 16 + 8, requested_map, 8)) map_found = 1;
    if (!map_found) { free(args); return fail("The requested map is not present in this IWAD."); }
    char skill[4], episode[4], map[4];
    snprintf(skill, sizeof(skill), "%u", config[0]);
    snprintf(episode, sizeof(episode), "%u", config[1]);
    snprintf(map, sizeof(map), "%u", config[2]);
    // doom1.wad is a virtual filename, not an operating-system path.
    char *argv[] = {"typst-doom", "-iwad", (char *)wad_name, "-skill", skill,
        "-warp", commercial_wad ? map : episode, map, "-nosound", "-nomusic", "-nogui", "-mb", "16", NULL};
    // The engine retains argv: give it permanent, snapshot-safe storage.
    char **saved = calloc(14, sizeof(char *));
    for (int i = 0; i < 13; ++i) saved[i] = strdup(argv[i]);
    wad_data = args; wad_size = wad_len;
    singletics = true;
    wipegamestate = GS_LEVEL;
    doomgeneric_Create(13, saved);
    key_up = 'w'; key_down = 's'; key_strafeleft = 'a'; key_straferight = 'd';
    key_left = 'j'; key_right = 'l'; key_fire = 'f'; key_use = 'e';
    screenvisible = false;
    // This defines the starting weapon-raise/game state, not a disposable
    // screen-wipe delay. Shorter warmups change the initial frame and clock.
    for (int i = 0; i < 17; ++i) { clock_ms += 29; doomgeneric_Tick(); }
    screenvisible = true;
    wipegamestate = gamestate;
    D_Display();
    initialized = 1;
    host_result("", 0);
    return 0;
}

static void key_event(int key, int pressed) {
    event_t event = {0};
    event.type = pressed ? ev_keydown : ev_keyup;
    event.data1 = key;
    event.data2 = key;
    D_PostEvent(&event);
}

EXPORT("advance") int plugin_advance(size_t len) {
    if (!initialized) return fail("Initialize the engine before advancing it.");
    if (len > 4096) return fail("Advance accepts at most 4096 commands per transition.");
    unsigned char *actions = malloc(len ? len : 1);
    if (!actions) return fail("Cannot allocate input buffer.");
    host_args(actions);
    for (size_t i = 0; i < len; ++i) {
        if (quit_requested) break;
        int c = actions[i];
        if (!strchr("wasdjlfexm1234567qzWASDpikhocbyn", c) || c == 0) continue;
        int keys[3], key_count = 0;
        if (c == 'q' || c == 'z') { keys[key_count++] = c == 'q' ? 'w' : 's'; keys[key_count++] = 'f'; }
        else if (c >= 'A' && c <= 'Z') { keys[key_count++] = c + ('a' - 'A'); keys[key_count++] = KEY_RSHIFT; }
        else if (c != 'x') {
            switch (c) {
                case 'm': c = KEY_TAB; break;
                case 'p': c = KEY_ESCAPE; break;
                case 'i': c = KEY_UPARROW; break;
                case 'k': c = KEY_DOWNARROW; break;
                case 'h': c = KEY_LEFTARROW; break;
                case 'o': c = KEY_RIGHTARROW; break;
                case 'c': c = KEY_ENTER; break;
                case 'b': c = KEY_BACKSPACE; break;
            }
            keys[key_count++] = c;
        }
        for (int k = 0; k < key_count; ++k) key_event(keys[k], 1);
        for (int tic = 0; tic < action_tics; ++tic) {
            if (quit_requested) break;
            clock_ms += 29;
            // Render each tic: native rendering includes persistent fuzz/display
            // state, so skipping it would make results depend on chunk boundaries.
            screenvisible = false;
            doomgeneric_Tick();
            screenvisible = true;
            wipegamestate = gamestate;
            D_Display();
        }
        for (int k = 0; k < key_count; ++k) key_event(keys[k], 0);
        // Consume releases without adding an extra game tic (needed for use/map).
        extern void D_ProcessEvents(void);
        D_ProcessEvents();
    }
    free(actions);
    host_result("", 0);
    return 0;
}

// Native save format. These calls do not advance the simulation clock.
EXPORT("save") int plugin_save(size_t len) {
    unsigned char slot;
    if (!initialized || len != 1) return fail("Save expects an initialized game and one slot byte.");
    host_args(&slot);
    if (slot > 5 || gamestate != GS_LEVEL) return fail("Save requires slot 0–5 and an active level.");
    extern void G_DoSaveGame(void);
    extern boolean sendsave;
    G_SaveGame(slot, "TYPST DOOM");
    sendsave = false;
    G_DoSaveGame();
    host_result("", 0);
    return 0;
}
EXPORT("saved") int plugin_saved(size_t len) {
    unsigned char slot;
    if (!initialized || len != 1) return fail("Saved expects one slot byte.");
    host_args(&slot);
    if (slot > 5) return fail("Save slot must be 0–5.");
    size_t size;
    const unsigned char *data = memory_read(P_SaveGameFile(slot), &size);
    if (!data) return fail("That save slot is empty.");
    host_result(data, size);
    return 0;
}
EXPORT("load") int plugin_load(size_t len) {
    if (!initialized || len < 51 || len >= MEMORY_FILE_CAPACITY) return fail("Expected a native DOOM save file under 512 KiB.");
    unsigned char *data = malloc(len);
    if (!data) return fail("Cannot allocate save buffer.");
    host_args(data);
    char version[16] = {0};
    snprintf(version, sizeof(version), "version %i", G_VanillaVersionCode());
    char name[9] = {0};
    if (gamemode == commercial) snprintf(name, sizeof(name), "MAP%02u", data[42]);
    else snprintf(name, sizeof(name), "E%uM%u", data[41], data[42]);
    if (memcmp(data + 24, version, 16) || data[40] > 4 || W_CheckNumForName(name) < 0 || data[len - 1] != 0x1d) {
        free(data); return fail("Save version, map or trailer does not match this game.");
    }
    int written = memory_write("typst-import.dsg", data, len);
    free(data);
    if (written) return fail("Cannot store imported save.");
    extern void G_DoLoadGame(void);
    G_LoadGame("typst-import.dsg");
    G_DoLoadGame();
    M_ClearMenus();
    quit_requested = 0;
    wipegamestate = gamestate;
    D_Display();
    host_result("", 0);
    return 0;
}

EXPORT("frame") int plugin_frame(void) {
    if (!initialized) return fail("Initialize the engine before requesting a frame.");
    __real_I_FinishUpdate();
    for (size_t i = 0; i < 320 * 200; ++i) {
        uint32_t pixel = DG_ScreenBuffer[i];
        rgb_frame[i * 3] = pixel >> 16;
        rgb_frame[i * 3 + 1] = pixel >> 8;
        rgb_frame[i * 3 + 2] = pixel;
    }
    host_result(rgb_frame, sizeof(rgb_frame));
    return 0;
}

EXPORT("info") int plugin_info(void) {
    if (!initialized) return fail("Engine not initialized.");
    player_t *p = &players[consoleplayer];
    int64_t ceiling_sum = 0;
    for (int i = 0; i < numsectors; ++i) ceiling_sum += sectors[i].ceilingheight;
    char json[768];
    int n = snprintf(json, sizeof(json),
        "{\"health\":%d,\"armor\":%d,\"ammo\":%d,\"kills\":%d,\"items\":%d,\"secrets\":%d,\"episode\":%d,\"map\":%d,\"tic\":%d,\"state\":%d,\"x\":%d,\"y\":%d,\"angle\":%u,\"weapon\":%d,\"automap\":%s,\"menu\":%s,\"quit\":%s,\"sectors\":%d,\"ceiling_sum\":%lld}",
        p->health, p->armorpoints, p->ammo[am_clip], p->killcount, p->itemcount,
        p->secretcount, gameepisode, gamemap, gametic, gamestate,
        p->mo ? p->mo->x : 0, p->mo ? p->mo->y : 0, p->mo ? p->mo->angle : 0,
        p->readyweapon, automapactive ? "true" : "false", menuactive ? "true" : "false", quit_requested ? "true" : "false", numsectors, (long long)ceiling_sum);
    host_result(json, n);
    return 0;
}
