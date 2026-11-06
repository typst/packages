"""Small WebAssembly import inspector (no external Python dependencies)."""
from pathlib import Path

def imports(path):
    data = Path(path).read_bytes()
    if data[:8] != b"\0asm\1\0\0\0":
        raise ValueError("Invalid WebAssembly header")
    pos = 8
    def uint():
        nonlocal pos
        n = shift = 0
        while True:
            b = data[pos]; pos += 1
            n |= (b & 127) << shift
            if not b & 128: return n
            shift += 7
    def string():
        nonlocal pos
        n = uint(); s = data[pos:pos+n].decode(); pos += n
        return s
    found = []
    while pos < len(data):
        section = data[pos]; pos += 1
        length = uint(); end = pos + length
        if section == 2:
            for _ in range(uint()):
                module, name = string(), string()
                kind = data[pos]; pos += 1
                if kind != 0: raise ValueError('Unexpected non-function import')
                uint()
                found.append((module, name))
        pos = end
    return found

EXPECTED_IMPORTS = {
    ('typst_env', 'wasm_minimal_protocol_write_args_to_buffer'),
    ('typst_env', 'wasm_minimal_protocol_send_result_to_host'),
}


def validate_plugin(path):
    found = imports(path)
    actual = set(found)
    if actual != EXPECTED_IMPORTS or len(found) != len(EXPECTED_IMPORTS):
        raise ValueError(f'Unexpected plugin imports: {found!r}; expected {sorted(EXPECTED_IMPORTS)!r}')
    return found


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Require exactly the two Typst protocol imports')
    parser.add_argument('path', type=Path)
    args = parser.parse_args()
    try:
        found = validate_plugin(args.path) if args.check else imports(args.path)
    except (ValueError, IndexError, OSError) as error:
        parser.exit(1, f'{error}\n')
    for module, name in found:
        print(module, name)
