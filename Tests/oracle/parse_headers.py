#!/usr/bin/env python3
"""Parse ObjC headers into a per-class public selector surface.
Handles -/+ method declarations (multi-line) and @property (getter + setter).
Usage: parse_headers.py <headers_dir> [<headers_dir2> ...]
Output lines: '@@ Class' then 'i selector' / 'c selector' (sorted, deduped)."""
import re, glob, sys, os

classes = {}  # name -> set of 'i sel' / 'c sel'

def add(cls, kind, sel):
    if cls and sel:
        classes.setdefault(cls, set()).add(kind + sel)

def cap(name):
    return name[:1].upper() + name[1:] if name else name

def parse_property(cls, decl):
    # decl like: @property (nonatomic, getter=isBar, readonly) NSType *name
    body = decl[len('@property'):].strip()
    attrs = ''
    m = re.match(r'\((.*?)\)', body)
    if m:
        attrs = m.group(1); body = body[m.end():].strip()
    # last identifier before end is the property name
    ids = re.findall(r'[A-Za-z_]\w*', body)
    if not ids:
        return
    name = ids[-1]
    getter = name
    gm = re.search(r'getter\s*=\s*(\w+)', attrs)
    if gm: getter = gm.group(1)
    add(cls, 'i ', getter)
    if 'readonly' not in attrs:
        setter = 'set' + cap(name) + ':'
        sm = re.search(r'setter\s*=\s*([\w:]+)', attrs)
        if sm: setter = sm.group(1) if sm.group(1).endswith(':') else sm.group(1) + ':'
        add(cls, 'i ', setter)
    kind = 'c ' if 'class' in re.split(r'[ ,]', attrs) else 'i '
    # (class properties are rare; treat class-property getter as class method)
    if kind == 'c ':
        add(cls, 'c ', getter)

def parse_method(cls, decl):
    d = decl.strip()
    kind = 'i ' if d[0] == '-' else 'c '
    d = d[1:].strip()
    if d.startswith('('):  # strip return type (balanced parens)
        depth = 0
        for j, ch in enumerate(d):
            if ch == '(': depth += 1
            elif ch == ')':
                depth -= 1
                if depth == 0:
                    d = d[j+1:].strip(); break
    parts = re.findall(r'([A-Za-z_]\w*)\s*:', d)
    if parts:
        sel = ''.join(p + ':' for p in parts)
    else:
        m = re.match(r'([A-Za-z_]\w*)', d)
        sel = m.group(1) if m else None
    add(cls, kind, sel)

for d in sys.argv[1:]:
    for h in sorted(glob.glob(os.path.join(d, '*.h'))):
        try:
            text = open(h, errors='replace').read()
        except Exception:
            continue
        text = re.sub(r'/\*.*?\*/', ' ', text, flags=re.S)      # block comments
        text = re.sub(r'//[^\n]*', '', text)                     # line comments
        cur = None
        buf = ''
        for line in text.split('\n'):
            s = line.strip()
            if not s: continue
            mi = re.match(r'@interface\s+(\w+)', s)
            if mi: cur = mi.group(1); buf = ''; continue
            if re.match(r'@protocol\s+\w+', s): cur = None; buf = ''; continue
            if s.startswith('@end'): cur = None; buf = ''; continue
            if cur is None: continue
            if s.startswith('@property'):
                p = s
                while ';' not in p:
                    p += ' NEXT'  # properties are usually single-line; guard
                    break
                parse_property(cur, p.split(';')[0]); buf = ''; continue
            if s.startswith('-') or s.startswith('+') or buf:
                buf += ' ' + s
                if ';' in buf:
                    parse_method(cur, buf.split(';')[0]); buf = ''

for c in sorted(classes):
    print('@@ ' + c)
    for x in sorted(classes[c]):
        print(x)
