// SPDX-License-Identifier: GPL-2.0-or-later
// No OS capabilities are exposed to the plugin. Memory streams need no WASI I/O.
#include <wasi/api.h>
#include <string.h>
__wasi_errno_t __wrap___wasi_clock_time_get(
    
    __wasi_clockid_t id,
    
    __wasi_timestamp_t precision, __wasi_timestamp_t *retptr0) { *retptr0 = 0; return 0; }
__wasi_errno_t __wrap___wasi_fd_close(__wasi_fd_t fd) { return __WASI_ERRNO_BADF; }
__wasi_errno_t __wrap___wasi_fd_fdstat_get(__wasi_fd_t fd, __wasi_fdstat_t *retptr0) { return __WASI_ERRNO_BADF; }
__wasi_errno_t __wrap___wasi_fd_prestat_get(__wasi_fd_t fd, __wasi_prestat_t *retptr0) { return __WASI_ERRNO_BADF; }
__wasi_errno_t __wrap___wasi_fd_prestat_dir_name(
    __wasi_fd_t fd,
    
    uint8_t *path, __wasi_size_t path_len) { return __WASI_ERRNO_BADF; }
__wasi_errno_t __wrap___wasi_fd_seek(__wasi_fd_t fd,
                              
                              __wasi_filedelta_t offset,
                              
                              __wasi_whence_t whence,
                              __wasi_filesize_t *retptr0) { return __WASI_ERRNO_BADF; }
__wasi_errno_t
__wrap___wasi_fd_write(__wasi_fd_t fd,
                
                const __wasi_ciovec_t *iovs,
                
                size_t iovs_len, __wasi_size_t *retptr0) { *retptr0 = 0; for (size_t i = 0; i < iovs_len; ++i) *retptr0 += iovs[i].buf_len; return 0; }
__wasi_errno_t
__wrap___wasi_path_create_directory(__wasi_fd_t fd,
                             
                             const char *path) { return __WASI_ERRNO_BADF; }
__wasi_errno_t
__wrap___wasi_path_remove_directory(__wasi_fd_t fd,
                             
                             const char *path) { return __WASI_ERRNO_BADF; }
__wasi_errno_t __wrap___wasi_path_rename(
    __wasi_fd_t fd,
    
    const char *old_path,
    
    __wasi_fd_t new_fd,
    
    const char *new_path) { return __WASI_ERRNO_BADF; }
__wasi_errno_t __wrap___wasi_path_unlink_file(__wasi_fd_t fd,
                                       
                                       const char *path) { return __WASI_ERRNO_BADF; }
_Noreturn void __wrap___wasi_proc_exit(__wasi_exitcode_t code) { (void)code; __builtin_trap(); }
