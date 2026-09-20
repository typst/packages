// SPDX-License-Identifier: GPL-2.0-or-later
#ifndef TYPST_MEMORY_FS_H
#define TYPST_MEMORY_FS_H
#include <stdio.h>
#include <stddef.h>
#define MEMORY_FILE_CAPACITY (512 * 1024)
// Multiple readers are supported. Writers and direct mutations require
// exclusive access; conflicting operations fail with errno = EBUSY.
FILE *memory_open(const char *path, const char *mode);
// Borrowed view, valid until the next mutation of this file.
const unsigned char *memory_read(const char *path, size_t *size);
int memory_write(const char *path, const unsigned char *data, size_t size);
#endif
