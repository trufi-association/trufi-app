#!/usr/bin/env python3
"""Compare two common_dump.dart outputs (A = baseline, B = candidate).

Per query: keys (route-id chains) present in A and B, scores, lost/new/worse.
Usage: compare.py A.json B.json [--verbose]
"""
import json
import sys


def load(path):
    with open(path) as f:
        return json.load(f)


def main():
    a = load(sys.argv[1])
    b = load(sys.argv[2])
    verbose = '--verbose' in sys.argv
    assert a['fingerprints'] == b['fingerprints'], 'pattern ids differ between builds!'
    qa = {q['id']: q for q in a['queries']}
    qb = {q['id']: q for q in b['queries']}
    assert qa.keys() == qb.keys()
    n = len(qa)
    tot_a = tot_b = 0
    routeless_a = routeless_b = 0
    identical = 0
    lost_keys = []       # key in A not in B (same query)
    worse_keys = []      # key in both, B score > A score
    better_keys = []     # key in both, B score < A score
    new_keys = []        # key in B not in A
    top_worse = []       # best score in B worse than best in A
    top_better = []
    directs_changed = []
    with_walk_between = 0
    same_name_chain_b = 0
    transfers_b = 0
    for qid in qa:
        pa, pb = qa[qid]['paths'], qb[qid]['paths']
        tot_a += len(pa)
        tot_b += len(pb)
        if not pa:
            routeless_a += 1
        if not pb:
            routeless_b += 1
        ka = {p['key']: p for p in pa}
        kb = {p['key']: p for p in pb}
        sig_a = [(p['key'], p['score']) for p in pa]
        sig_b = [(p['key'], p['score']) for p in pb]
        if sig_a == sig_b:
            identical += 1
        da = [p for p in pa if p['transfers'] == 0]
        db = [p for p in pb if p['transfers'] == 0]
        if [(p['key'], p['score']) for p in da] != [(p['key'], p['score']) for p in db]:
            directs_changed.append(qid)
        for k, p in ka.items():
            if k not in kb:
                lost_keys.append((qid, k, p['score']))
            elif kb[k]['score'] > p['score']:
                worse_keys.append((qid, k, p['score'], kb[k]['score']))
            elif kb[k]['score'] < p['score']:
                better_keys.append((qid, k, p['score'], kb[k]['score']))
        for k, p in kb.items():
            if k not in ka:
                new_keys.append((qid, k, p['score'], p['names']))
            if p['transfers'] >= 1:
                transfers_b += 1
                if p['legs'][0]['to'] != p['legs'][1]['from']:
                    with_walk_between += 1
                names = p['names'].split('>')
                if len(set(names)) < len(names):
                    same_name_chain_b += 1
        if pa and pb:
            if pb[0]['score'] > pa[0]['score']:
                top_worse.append((qid, pa[0]['key'], pa[0]['score'], pb[0]['key'], pb[0]['score']))
            elif pb[0]['score'] < pa[0]['score']:
                top_better.append((qid, pa[0]['key'], pa[0]['score'], pb[0]['key'], pb[0]['score']))
        elif pa and not pb:
            top_worse.append((qid, pa[0]['key'], pa[0]['score'], None, None))
        elif pb and not pa:
            top_better.append((qid, None, None, pb[0]['key'], pb[0]['score']))

    print(f"A={sys.argv[1].split('/')[-1]} B={sys.argv[2].split('/')[-1]}  queries={n}")
    print(f"  connections A={a['connections']} B={b['connections']}  build A={a['buildMs']}ms B={b['buildMs']}ms  "
          f"avg query A={a['avgQueryMs']:.2f}ms B={b['avgQueryMs']:.2f}ms  max A={a['maxQueryMs']:.1f} B={b['maxQueryMs']:.1f}")
    print(f"  itineraries A={tot_a} B={tot_b}  routeless A={routeless_a} B={routeless_b}  identical queries={identical}/{n}")
    print(f"  direct buckets changed in {len(directs_changed)} queries: {directs_changed[:10]}")
    print(f"  keys lost (in A, absent in B): {len(lost_keys)}   worse score: {len(worse_keys)}   better score: {len(better_keys)}   new keys: {len(new_keys)}")
    print(f"  top-1 worse: {len(top_worse)}   top-1 better: {len(top_better)}")
    print(f"  B transfer itineraries={transfers_b}, with walk between legs={with_walk_between}, same-short-name chains={same_name_chain_b}")
    if verbose or len(lost_keys) <= 30:
        for x in lost_keys[:60]:
            print('    LOST', x)
    if verbose or len(worse_keys) <= 30:
        for x in worse_keys[:60]:
            print('    WORSE', x)
    for x in top_worse[:30]:
        print('    TOP1-WORSE', x)
    if verbose:
        for x in new_keys[:60]:
            print('    NEW', x)
        for x in top_better[:30]:
            print('    TOP1-BETTER', x)


if __name__ == '__main__':
    main()
