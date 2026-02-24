#!/usr/bin/env python3

import sys
import re
import json

# format: "+newzhlipsum < simp >"
KEY_NAME_RE = re.compile(r'\+newzhlipsum < (.+) >')
# format: "<content>,"
CONTENT_RE = re.compile(r'\<(.+)\>,?')
BIG5_HEADER = r'%<big5>'

if __name__ == '__main__':
    
    if len(sys.argv) != 3:
        print('Usage: {} <zhlipsum-text.dtx> <zhlipsum.json>'.format(sys.argv[0]))
        sys.exit(1)
    
    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()

    contents = {}
    cur_key = None

    for l in lines:
        l = l.strip()

        # skip comments
        if l.startswith('%'):
            if l.startswith(BIG5_HEADER):
                l = l.lstrip(BIG5_HEADER)
            else:
                continue
        
        # match key name
        if m := KEY_NAME_RE.match(l):
            cur_key = m.group(1)
            contents[cur_key] = []
        
        # match content
        elif m := CONTENT_RE.match(l):
            assert cur_key is not None
            contents[cur_key].append(m.group(1))

    # contents = dict(sorted(contents.items(), key=lambda x: x[0]))
    statistics = {k: len(v) for k, v in contents.items()}
    print('Extracted text:', statistics)

    with open(sys.argv[2], 'w') as f:
        json.dump(contents, f, ensure_ascii=False, indent=2)
