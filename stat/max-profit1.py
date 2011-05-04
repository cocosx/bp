#!/usr/bin/python

import sys,csv

with open(sys.argv[1], newline='') as f:
  #for i in range(0,5):
  #  f.readline()
  d={}
  reader = csv.DictReader(f)
  for row in reader:
    margin=float(row['margin'])
    profit=int(row['network-profit'])
    fee=int(row['monthly-fee'])
    sr=float(row['network-sale-revenue'])
    fr=int(row['network-fee-revenue'])
    sc=float(row['network-sponsor-cost'])
    count=int(row['members'])
    vect=(profit,sr,fr,sc,count)
    if fee in d:
      if margin in d[fee]:
        d[fee][margin].append(vect)
      else:
        d[fee][margin]=[vect]
    else:
      d[fee]={margin:[vect]}
  #print(d)
  avgs={}
  for fee in d.keys():
    avgs[fee]={}
    for margin in d[fee].keys():
      s=[0.0,0.0,0.0,0.0,0.0]
      for v in d[fee][margin]:
        for i in range(0,len(s)):
          s[i]+=v[i]
      avgs[fee][margin]=s
      for i in range(0,len(s)):
        avgs[fee][margin][i]=s[i]/len(d[fee][margin])
      #print(k,s/len(d[k]))
  fee=list(avgs.keys())
  fee.sort()
  print('fee',"\t",'margin',"\t",'profit05',"\t",'sale-rev',"\t",'fee-rev',"\t",'spons-cost',"\t",'members')
  for f in fee:
    margin=list(avgs[f].keys())
    margin.sort()
    for m in margin:
      p=[]
      for v in [f,m]+avgs[f][m]:
        p.append(str(round(v,2)))
      print("\t".join(p))
      #print(f,"\t",m,"\t",avgs[f][m])
