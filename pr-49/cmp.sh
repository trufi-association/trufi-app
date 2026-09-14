#!/bin/bash
# cmp the GTFS files of two generated feeds. Usage: cmp.sh <A/gtfs> <B/gtfs>
A="$1"; B="$2"
for f in agency calendar fare_attributes fare_rules feed_info frequencies routes shapes stop_times stops trips; do
  if [ ! -f "$A/$f.txt" ] || [ ! -f "$B/$f.txt" ]; then echo "MISSING    $f.txt"; continue; fi
  if cmp -s "$A/$f.txt" "$B/$f.txt"; then echo "identical  $f.txt"; else echo "DIFFERS    $f.txt ($(wc -l < "$A/$f.txt" | tr -d ' ') vs $(wc -l < "$B/$f.txt" | tr -d ' ') lines)"; fi
done
echo "md5 stop_times: $(md5 -q "$A/stop_times.txt") vs $(md5 -q "$B/stop_times.txt")"
