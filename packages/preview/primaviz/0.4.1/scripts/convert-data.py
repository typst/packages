#!/usr/bin/env python3
"""Convert JSON data into primaviz chart-ready JSON formats.

Usage:
    python scripts/convert-data.py <input.json> <format> [options]

Formats:
    simple      {"key": value, ...} → {"labels": [...], "values": [...]}
    series      {"label": {"series": val}} → {"labels": [...], "series": [...]}
    scatter     [{"x": .., "y": ..}] → {"x": [...], "y": [...]}
    bubble      [{"x": .., "y": .., "size": ..}] → {"x": [...], "y": [...], "size": [...]}
    hierarchy   [{"name": .., "parent": .., "value": ..}] → nested tree

Options:
    --label-key KEY   For series format: which field holds labels (default: auto-detect)
    --output FILE     Write to file instead of stdout
    --pretty          Pretty-print JSON output

Examples:
    python scripts/convert-data.py sales.json simple
    python scripts/convert-data.py metrics.json series --label-key month
    python scripts/convert-data.py points.json scatter --output data/points.json
"""

import json
import sys
import argparse


def convert_simple(raw):
    if isinstance(raw, dict):
        if "labels" in raw and "values" in raw:
            return raw
        return {"labels": list(raw.keys()), "values": list(raw.values())}
    elif isinstance(raw, list):
        if not raw:
            return {"labels": [], "values": []}
        first = raw[0]
        if isinstance(first, list):
            return {"labels": [str(p[0]) for p in raw], "values": [p[1] for p in raw]}
        elif isinstance(first, dict):
            lkey = next((k for k in ("label", "name", "key") if k in first), list(first.keys())[0])
            vkey = next((k for k in ("value", "val") if k in first), list(first.keys())[1])
            return {"labels": [str(r[lkey]) for r in raw], "values": [r[vkey] for r in raw]}
        else:
            return {"labels": [str(i) for i in range(len(raw))], "values": raw}
    raise ValueError(f"Expected dict or array, got {type(raw).__name__}")


def convert_series(raw, label_key=None):
    if isinstance(raw, dict):
        if "labels" in raw and "series" in raw:
            return raw
        labels = list(raw.keys())
        first_inner = raw[labels[0]]
        series_names = list(first_inner.keys())
        series = [{"name": name, "values": [raw[lbl].get(name, 0) for lbl in labels]} for name in series_names]
        return {"labels": labels, "series": series}
    elif isinstance(raw, list):
        if not raw:
            return {"labels": [], "series": []}
        first = raw[0]
        if label_key is None:
            label_key = next((k for k in first if isinstance(first[k], str)), list(first.keys())[0])
        labels = [str(r[label_key]) for r in raw]
        series_keys = [k for k in first if k != label_key]
        series = [{"name": k, "values": [r.get(k, 0) for r in raw]} for k in series_keys]
        return {"labels": labels, "series": series}
    raise ValueError(f"Expected dict or array, got {type(raw).__name__}")


def convert_scatter(raw):
    if isinstance(raw, dict):
        if "x" in raw and "y" in raw:
            return raw
        raise ValueError("Dict must have 'x' and 'y' keys")
    elif isinstance(raw, list):
        if not raw:
            return {"x": [], "y": []}
        first = raw[0]
        if isinstance(first, dict):
            result = {"x": [r["x"] for r in raw], "y": [r["y"] for r in raw]}
            lkey = next((k for k in ("label", "name") if k in first), None)
            if lkey:
                result["labels"] = [str(r[lkey]) for r in raw]
            return result
        elif isinstance(first, list):
            result = {"x": [p[0] for p in raw], "y": [p[1] for p in raw]}
            if len(first) >= 3:
                result["labels"] = [str(p[2]) for p in raw]
            return result
    raise ValueError(f"Expected dict or array, got {type(raw).__name__}")


def convert_bubble(raw):
    if isinstance(raw, dict):
        if "x" in raw and "y" in raw and "size" in raw:
            return raw
        raise ValueError("Dict must have 'x', 'y', and 'size' keys")
    elif isinstance(raw, list):
        if not raw:
            return {"x": [], "y": [], "size": []}
        first = raw[0]
        if isinstance(first, dict):
            result = {"x": [r["x"] for r in raw], "y": [r["y"] for r in raw], "size": [r["size"] for r in raw]}
            lkey = next((k for k in ("label", "name") if k in first), None)
            if lkey:
                result["labels"] = [str(r[lkey]) for r in raw]
            return result
        elif isinstance(first, list):
            result = {"x": [p[0] for p in raw], "y": [p[1] for p in raw], "size": [p[2] for p in raw]}
            if len(first) >= 4:
                result["labels"] = [str(p[3]) for p in raw]
            return result
    raise ValueError(f"Expected dict or array, got {type(raw).__name__}")


def convert_hierarchy(raw):
    if isinstance(raw, dict) and "name" in raw:
        return raw
    elif isinstance(raw, list):
        by_name = {}
        for item in raw:
            name = str(item["name"])
            by_name[name] = {"name": name, "value": item.get("value", 0), "children": []}
        roots = []
        for item in raw:
            name = str(item["name"])
            parent = item.get("parent")
            if not parent:
                roots.append(name)
            elif str(parent) in by_name:
                by_name[str(parent)]["children"].append(by_name[name])
        def clean(node):
            if not node["children"]:
                return {"name": node["name"], "value": node["value"]}
            return {"name": node["name"], "value": node["value"], "children": [clean(c) for c in node["children"]]}
        if len(roots) == 1:
            return clean(by_name[roots[0]])
        return {"name": "root", "value": sum(by_name[r]["value"] for r in roots), "children": [clean(by_name[r]) for r in roots]}
    raise ValueError(f"Expected dict with 'name' or array of nodes")


CONVERTERS = {
    "simple": lambda raw, **_: convert_simple(raw),
    "series": lambda raw, **kw: convert_series(raw, label_key=kw.get("label_key")),
    "scatter": lambda raw, **_: convert_scatter(raw),
    "bubble": lambda raw, **_: convert_bubble(raw),
    "hierarchy": lambda raw, **_: convert_hierarchy(raw),
}


def main():
    parser = argparse.ArgumentParser(description="Convert JSON to primaviz chart formats")
    parser.add_argument("input", help="Input JSON file")
    parser.add_argument("format", choices=CONVERTERS.keys(), help="Target chart format")
    parser.add_argument("--label-key", help="Field name for labels (series format)")
    parser.add_argument("--output", "-o", help="Output file (default: stdout)")
    parser.add_argument("--pretty", action="store_true", help="Pretty-print output")
    args = parser.parse_args()

    with open(args.input) as f:
        raw = json.load(f)

    result = CONVERTERS[args.format](raw, label_key=args.label_key)

    indent = 2 if args.pretty else None
    output = json.dumps(result, indent=indent, ensure_ascii=False)

    if args.output:
        with open(args.output, "w") as f:
            f.write(output + "\n")
        print(f"Wrote {args.format} format to {args.output}", file=sys.stderr)
    else:
        print(output)


if __name__ == "__main__":
    main()
