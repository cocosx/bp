#!/usr/bin/python

import sys,csv

with open(sys.argv[1], newline='') as f:
  #for i in range(0,5):
  #  f.readline()
  d={}
  reader = csv.DictReader(f)
  for row in reader:
    margin=float(row['margin'])
    profit=float(row['network-profit'])
    if margin in d:
      d[margin].append(profit)
    else:
      d[margin]=[profit]
  #print(d)
  avgs={}
  for k in d.keys():
    s=0.0
    for v in d[k]:
      s+=v
    avgs[k]=s/len(d[k])
    #print(k,s/len(d[k]))
  k=list(avgs.keys())
  k.sort()
  for m in k:
    print(m,"\t",avgs[m])
