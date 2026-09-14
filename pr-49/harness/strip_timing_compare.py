#!/usr/bin/env python3
"""Byte-identical check of two common_dump.dart outputs once timing fields
are removed (us per query, parse/spatial/build ms, avg/max ms)."""
import hashlib, json, sys

def canon(path):
    d = json.load(open(path))
    for k in ('parseMs', 'spatialMs', 'buildMs', 'avgQueryMs', 'maxQueryMs', 'feed'):
        d.pop(k, None)
    for q in d['queries']:
        q.pop('us', None)
    return json.dumps(d, sort_keys=True, ensure_ascii=False).encode()

a, b = canon(sys.argv[1]), canon(sys.argv[2])
ha, hb = hashlib.sha256(a).hexdigest(), hashlib.sha256(b).hexdigest()
qa = json.load(open(sys.argv[1]))['queries']
n = len(qa)
paths = sum(len(q['paths']) for q in qa)
print(f"{sys.argv[1].split('/')[-1]} sha256 {ha[:16]}…  {len(a)} bytes")
print(f"{sys.argv[2].split('/')[-1]} sha256 {hb[:16]}…  {len(b)} bytes")
print(f"queries={n} itineraries={paths} BYTE-IDENTICAL={'YES' if a == b else 'NO'}")
sys.exit(0 if a == b else 1)
