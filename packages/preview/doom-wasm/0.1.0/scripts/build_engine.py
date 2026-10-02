"""Build DoomGeneric for Typst; optional codegen switches support measured trials."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
from wasm_imports import validate_plugin

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / 'vendor/doomgeneric/doomgeneric'


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--lto', action='store_true')
    parser.add_argument('--gc-sections', action='store_true')
    opt = parser.add_mutually_exclusive_group()
    opt.add_argument('--wasm-opt', metavar='PATH', help='Explicit Binaryen wasm-opt executable')
    opt.add_argument('--no-wasm-opt', action='store_true', help='Skip optional Binaryen optimization')
    parser.add_argument('--no-ccache', action='store_true')
    parser.add_argument('--jobs', type=int, default=os.cpu_count() or 8)
    parser.add_argument('--initial-memory', type=int, default=0,
                        help='Initial WASM bytes; 0 lets the linker choose its minimum')
    parser.add_argument('--output', type=Path, default=ROOT / 'engine/doom.wasm')
    args = parser.parse_args(argv)
    if args.initial_memory < 0 or args.initial_memory % 65536:
        parser.error('initial memory must be a nonnegative multiple of 65536')
    if args.jobs < 1:
        parser.error('jobs must be positive')
    sdk = Path(os.environ.get('WASI_SDK_PATH', ROOT / 'build/wasi-sdk-34.0-arm64-macos'))
    cc = sdk / 'bin/clang'
    if not cc.is_file():
        parser.error('Set WASI_SDK_PATH to a WASI SDK installation containing bin/clang.')
    (ROOT / 'build').mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='engine-', dir=ROOT / 'build') as directory:
        build(args, sdk, cc, Path(directory))


def build(args, sdk, cc, out):
    wasm_opt = None
    if not args.no_wasm_opt:
        wasm_opt = args.wasm_opt or os.environ.get('WASM_OPT') or shutil.which('wasm-opt')
        local_opt = ROOT / 'build/binaryen-version_131/bin/wasm-opt'
        if not wasm_opt and local_opt.is_file():
            wasm_opt = str(local_opt)
    cache = None if args.no_ccache else shutil.which('ccache')
    compiler = ([cache] if cache else []) + [str(cc)]
    env = dict(os.environ, CCACHE_DIR=str(ROOT / 'build/ccache'))
    sources = re.search(r'^SRC_DOOM = (.+)$', (SRC / 'Makefile').read_text(), re.M)[1].split()
    sources = [SRC / s.replace('.o', '.c') for s in sources if s != 'doomgeneric_xlib.o']
    sources += sorted((ROOT / 'engine/native').glob('*.c'))
    flags = ['-O2', '-D_DEFAULT_SOURCE', '-D_POSIX_C_SOURCE=200809L',
             '-DDOOMGENERIC_RESX=320', '-DDOOMGENERIC_RESY=200', '-I'+str(SRC),
             '-Wno-pointer-sign', '-Wno-format', '-Wno-unused-command-line-argument']
    link = []
    if args.lto:
        flags += ['-flto']
        # Keep the existing non-LTO libc: SDK 34's LTO libc adds a WASI
        # random_get import for stack-canary initialization. Engine TUs still
        # participate in whole-program optimization without that host dependency.
        link += ['-flto', '-L'+str(sdk / 'share/wasi-sysroot/lib/wasm32-wasip1')]
    if args.gc_sections:
        flags += ['-ffunction-sections', '-fdata-sections']
        link += ['-Wl,--gc-sections']

    def compile_one(source):
        obj = out / (source.stem + '.o')
        subprocess.run([*compiler, *flags, '-c', str(source), '-o', str(obj)], check=True, env=env)
        return str(obj)

    with ThreadPoolExecutor(max_workers=args.jobs) as pool:
        objects = list(pool.map(compile_one, sources))
    wrapped = re.findall(r'__wrap_(__wasi_\w+)\(', (ROOT / 'engine/native/wasi_stubs.c').read_text())
    wrapped += ['fopen', 'fclose', 'rename', 'remove', 'I_Quit', 'I_FinishUpdate',
                'W_OpenFile', 'R_DrawColumn', 'R_DrawSpan']
    candidate = out / 'doom.wasm'
    if args.initial_memory:
        link += ['-Wl,--initial-memory='+str(args.initial_memory)]
    subprocess.run([str(cc), *link, *objects, *['-Wl,--wrap='+name for name in wrapped],
                    '-nostartfiles', '-Wl,--no-entry', '-Wl,--strip-all',
                    '-Wl,-z,stack-size=1048576',
                    '-Wl,--max-memory=134217728', '-lm', '-o', str(candidate)], check=True)
    if wasm_opt:
        optimized = out / 'doom-opt.wasm'
        subprocess.run([wasm_opt, '-O3', '--strip-debug', '--enable-bulk-memory',
                        '--enable-nontrapping-float-to-int', '--enable-sign-ext', str(candidate),
                        '-o', str(optimized)], check=True)
        candidate = optimized
    validate_plugin(candidate)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    # Unique staging on the destination filesystem keeps publication atomic,
    # including concurrent builds targeting the same output (last one wins).
    staging = None
    try:
        with tempfile.NamedTemporaryFile(dir=args.output.parent,
                                         prefix=args.output.name + '.',
                                         suffix='.tmp', delete=False) as stream:
            staging = Path(stream.name)
            stream.write(candidate.read_bytes())
        staging.replace(args.output)
    finally:
        if staging is not None:
            staging.unlink(missing_ok=True)
    print(f'Binaryen: {wasm_opt or "disabled/unavailable"}; ccache: {cache or "disabled/unavailable"}')
    print(f'Built {args.output}; verified only the two Typst protocol imports.')


if __name__ == '__main__':
    main()
