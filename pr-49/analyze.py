import csv, math, collections, statistics, sys
def hav(a,b):
    R=6371.0088
    la1,lo1=map(math.radians,a); la2,lo2=map(math.radians,b)
    d=math.sin((la2-la1)/2)**2+math.cos(la1)*math.cos(la2)*math.sin((lo2-lo1)/2)**2
    return 2*R*math.asin(math.sqrt(d))
def secs(t):
    h,m,s=map(int,t.split(':')); return h*3600+m*60+s
def load(d):
    stops={r['stop_id']:(float(r['stop_lat']),float(r['stop_lon'])) for r in csv.DictReader(open(d+'/stops.txt'))}
    trips={r['trip_id']:r for r in csv.DictReader(open(d+'/trips.txt'))}
    routes={r['route_id']:r for r in csv.DictReader(open(d+'/routes.txt'))}
    st=collections.defaultdict(list)
    for r in csv.DictReader(open(d+'/stop_times.txt')):
        st[r['trip_id']].append((int(r['stop_sequence']),r['stop_id'],r['arrival_time']))
    out={}
    for tid,rows in st.items():
        rows.sort()
        dist=sum(hav(stops[rows[i-1][1]],stops[rows[i][1]]) for i in range(1,len(rows)))
        dur=secs(rows[-1][2])
        rt=routes[trips[tid]['route_id']]
        # monotonic check
        mono=all(secs(rows[i][2])>=secs(rows[i-1][2]) for i in range(1,len(rows)))
        out[tid]=dict(ref=rt['route_short_name'],type=rt['route_type'],km=dist,min=dur/60,kmh=(dist/(dur/3600) if dur else float('nan')),stops=len(rows),mono=mono,name=trips[tid].get('trip_headsign',''))
    return out
def summary(label,data,types=None):
    sel=[v for v in data.values() if types is None or v['type'] in types]
    mins=sorted(v['min'] for v in sel)
    kms=[v['km'] for v in sel]
    print(f"{label}: trips={len(sel)} km mean={statistics.mean(kms):.1f} | duration min/median/mean/max = {mins[0]:.1f} / {statistics.median(mins):.1f} / {statistics.mean(mins):.1f} / {mins[-1]:.1f} min | implied speed mean={statistics.mean(v['kmh'] for v in sel):.1f} km/h | non-monotonic={sum(1 for v in sel if not v['mono'])}")
before=load(sys.argv[1]); after=load(sys.argv[2])
for label,types in [('ALL',None),('bus route_type 3',{'3'}),('light_rail route_type 0',{'0'}),('aerialway route_type 6',{'6'})]:
    summary('BEFORE '+label,before,types); summary('AFTER  '+label,after,types)
print()
print('trips whose stop_times changed:', sum(1 for t in before if abs(before[t]['min']-after[t]['min'])>1e-9 or before[t]['stops']!=after[t]['stops']))
print()
named=['5457000','5457001','14576926','9074378','14576927','9083839','11678428','19604339','6925236','6925237']
print(f"{'trip':>9} {'ref':>10} {'type':>4} {'km':>6} {'stops':>5} | {'before min':>10} {'kmh':>5} | {'after min':>9} {'kmh':>5}")
for t in named:
    b=before[t]; a=after[t]
    print(f"{t:>9} {b['ref']:>10} {b['type']:>4} {b['km']:6.2f} {b['stops']:5d} | {b['min']:10.1f} {b['kmh']:5.1f} | {a['min']:9.1f} {a['kmh']:5.1f}")
# a few more named bus lines by ref
print()
wanted=['1','130','Q','E','Z','270','10','3','L']
seen=set()
for t,v in sorted(after.items(), key=lambda kv: kv[1]['ref']):
    if v['ref'] in wanted and v['ref'] not in seen:
        seen.add(v['ref']); b=before[t]
        print(f"{t:>9} {v['ref']:>10} {v['type']:>4} {v['km']:6.2f} {v['stops']:5d} | {b['min']:10.1f} {b['kmh']:5.1f} | {v['min']:9.1f} {v['kmh']:5.1f}")
# longest / shortest bus trips after
bus=[(v['min'],t,v) for t,v in after.items() if v['type']=='3']
bus.sort()
print('\nshortest bus trip after:', bus[0][1], bus[0][2]['ref'], f"{bus[0][2]['km']:.1f} km {bus[0][0]:.1f} min")
print('longest bus trip after :', bus[-1][1], bus[-1][2]['ref'], f"{bus[-1][2]['km']:.1f} km {bus[-1][0]:.1f} min")
# duration histogram after (bus)
hist=collections.Counter(int(v['min']//15)*15 for v in after.values() if v['type']=='3')
print('bus duration histogram after (15-min bins):', sorted(hist.items()))
histb=collections.Counter(int(v['min']//15)*15 for v in before.values() if v['type']=='3')
print('bus duration histogram before (15-min bins):', sorted(histb.items()))
