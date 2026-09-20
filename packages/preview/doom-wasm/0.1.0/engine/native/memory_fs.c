// SPDX-License-Identifier: GPL-2.0-or-later
// A snapshot-local filesystem for native save slots and configuration files.
#include "memory_fs.h"
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#define FILE_COUNT 32
typedef struct { char *path; unsigned char *data; size_t size, capacity; } memory_file;
typedef struct { FILE *stream; memory_file *file; int writable; } memory_handle;
static memory_file files[FILE_COUNT];
static memory_handle handles[FILE_COUNT];
extern int __real_fclose(FILE *stream);

// Readers can coexist; a writer or direct mutation needs exclusive access.
// fmemopen retains its buffer pointer, so resizing an open file is unsafe.
static int busy(memory_file *file, int exclusive) {
    for (int i = 0; i < FILE_COUNT; ++i)
        if (handles[i].stream && handles[i].file == file &&
            (exclusive || handles[i].writable)) {
            errno = EBUSY;
            return 1;
        }
    return 0;
}

static int reserve(memory_file *file, size_t capacity) {
    if (file->capacity >= capacity) return 0;
    unsigned char *data = realloc(file->data, capacity);
    if (!data) { errno = ENOMEM; return -1; }
    memset(data + file->capacity, 0, capacity - file->capacity);
    file->data = data;
    file->capacity = capacity;
    return 0;
}

static memory_file *find_file(const char *path, int create) {
    memory_file *empty = NULL;
    for (int i = 0; i < FILE_COUNT; ++i) {
        if (files[i].path && !strcmp(files[i].path, path)) return &files[i];
        if (!files[i].path && !empty) empty = &files[i];
    }
    if (!create) { errno = ENOENT; return NULL; }
    if (!empty) { errno = ENOSPC; return NULL; }
    empty->path = strdup(path);
    if (!empty->path) {
        free(empty->path); free(empty->data); memset(empty, 0, sizeof(*empty));
        errno = ENOMEM; return NULL;
    }
    return empty;
}
FILE *memory_open(const char *path, const char *mode) {
    int writable = mode[0] == 'w' || mode[0] == 'a' || strchr(mode, '+');
    memory_file *file = find_file(path, mode[0] == 'w' || mode[0] == 'a');
    if (!file) return NULL;
    if (busy(file, writable)) return NULL;
    memory_handle *handle = NULL;
    for (int i = 0; i < FILE_COUNT; ++i) if (!handles[i].stream) { handle = &handles[i]; break; }
    if (!handle) { errno = EMFILE; return NULL; }
    if (writable && reserve(file, MEMORY_FILE_CAPACITY)) return NULL;
    FILE *stream = fmemopen(file->data, writable ? file->capacity : file->size,
                           writable ? (mode[0] == 'w' ? "w+b" : "r+b") : "rb");
    if (!stream) return NULL;
    if (mode[0] == 'w') file->size = 0;
    if (mode[0] == 'a') fseek(stream, file->size, SEEK_SET);
    handle->stream = stream; handle->file = file; handle->writable = writable;
    return stream;
}
int __wrap_fclose(FILE *stream) {
    for (int i = 0; i < FILE_COUNT; ++i) if (handles[i].stream == stream) {
        long position = ftell(stream);
        int result = __real_fclose(stream);
        if (handles[i].writable && position >= 0 && (size_t)position > handles[i].file->size)
            handles[i].file->size = position;
        // Keep the full write limit while a stream is open, then retain only
        // its contents. Subsequent writes grow it again before opening a FILE.
        memory_file *file = handles[i].file;
        if (handles[i].writable && result == 0 && file->size + 1 < file->capacity) {
            unsigned char *data = realloc(file->data, file->size + 1);
            if (data) { file->data = data; file->capacity = file->size + 1; }
        }
        memset(&handles[i], 0, sizeof(handles[i]));
        return result;
    }
    return __real_fclose(stream);
}
int __wrap_remove(const char *path) {
    memory_file *file = find_file(path, 0);
    if (!file) return -1;
    if (busy(file, 1)) return -1;
    free(file->path); free(file->data); memset(file, 0, sizeof(*file));
    return 0;
}
int __wrap_rename(const char *old_path, const char *new_path) {
    if (!strcmp(old_path, new_path)) return 0;
    memory_file *file = find_file(old_path, 0);
    if (!file) return -1;
    if (busy(file, 1)) return -1;
    memory_file *destination = find_file(new_path, 0);
    if (destination && busy(destination, 1)) return -1;
    char *name = strdup(new_path);
    if (!name) { errno = ENOMEM; return -1; }
    if (destination) __wrap_remove(new_path);
    free(file->path); file->path = name;
    return 0;
}
const unsigned char *memory_read(const char *path, size_t *size) {
    memory_file *file = find_file(path, 0);
    if (!file) return NULL;
    if (busy(file, 0)) return NULL;
    *size = file->size;
    return file->data;
}
int memory_write(const char *path, const unsigned char *data, size_t size) {
    if (size >= MEMORY_FILE_CAPACITY) return -1;
    memory_file *file = find_file(path, 1);
    if (!file) return -1;
    if (busy(file, 1)) return -1;
    if (reserve(file, size + 1)) return -1;
    memcpy(file->data, data, size); file->size = size;
    return 0;
}
