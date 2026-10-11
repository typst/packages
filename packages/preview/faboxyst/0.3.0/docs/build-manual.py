#!/usr/bin/env python3
"""Build the faboxyst manual, one chapter at a time (a single compile of the
whole manual needs too much memory), then merge the PDFs.

    python3 docs/build-manual.py [en|fr|both] [--ns preview|local] [--out DIR]
Needs: typst >= 0.15.1 and `pip install pypdf`.
"""
import json, os, re, subprocess, sys, tempfile
from concurrent.futures import ThreadPoolExecutor
from pypdf import PdfReader, PdfWriter

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
args = sys.argv[1:]
langs = ['en', 'fr'] if not args or args[0] == 'both' else [args[0]]
ns = args[args.index('--ns') + 1] if '--ns' in args else 'preview'
package_path = os.environ.get('TYPST_PACKAGE_PATH')
out = args[args.index('--out') + 1] if '--out' in args else os.path.join(root, 'docs', 'build')
os.makedirs(out, exist_ok=True)
data = open(os.path.join(root, 'docs', '_data.typ'), encoding='utf-8').read()
ids = re.findall(r'\(id: "([^"]+)"', data)
titles = {}
for m in re.finditer(r'\(id: "([^"]+)", en: "([^"]*)", fr: "([^"]*)"', data):
    titles[m.group(1)] = (m.group(2), m.group(3))

def compile(lang, chapter, first=1, starts=None):
    pdf = os.path.join(out, f'{lang}-{chapter}.pdf')
    cmd = ['typst', 'compile', '--root', root, os.path.join(root, 'docs', 'manual.typ'), pdf,
           '--input', f'lang={lang}', '--input', f'chapter={chapter}', '--input', f'first={first}', '--input', f'ns={ns}']
    if starts is not None: cmd += ['--input', 'starts=' + json.dumps(starts)]
    if package_path: cmd += ['--package-path', package_path]
    subprocess.run(cmd, check=True)
    return pdf

def build(lang):
    order = ['cover', 'whatsnew', 'toc', 'start'] + ids + ['aliases']
    # 1) page counts (parallel, 2 at a time)
    with ThreadPoolExecutor(2) as ex:
        pdfs = list(ex.map(lambda c: compile(lang, c), order))
    counts = {c: len(PdfReader(p).pages) for c, p in zip(order, pdfs)}
    starts, page = {}, 1
    for c in order:
        starts[c] = page; page += counts[c]
    # 2) final numbering
    with ThreadPoolExecutor(2) as ex:
        pdfs = list(ex.map(lambda c: compile(lang, c, starts[c], starts), order))
    w = PdfWriter(); pos = 0
    names = {'cover': ('Cover', 'Couverture'), 'whatsnew': ("What's new in v0.3.0", 'Nouveautés de la v0.3.0'), 'toc': ('Contents', 'Sommaire'), 'start': ('Getting started', 'Prise en main'), 'aliases': ('Aliases and index', 'Alias et index')}
    for c, p in zip(order, pdfs):
        r = PdfReader(p)
        for pg in r.pages: w.add_page(pg)
        t = names.get(c) or titles[c]
        w.add_outline_item(t[1] if lang == 'fr' else t[0], pos); pos += len(r.pages)
    dst = os.path.join(out, f'faboxyst-0.3.0-manual-{lang}.pdf')
    w.write(dst); print(lang, pos, 'pages ->', dst)

for l in langs: build(l)
