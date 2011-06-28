#!/usr/bin/python

import sys,csv

with open(sys.argv[1], newline='') as f:
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
  for mm1 in range(10,80,5):
    mm=mm1/100.0
    print('mm',mm)
    for f in fee:
      margin=list(avgs[f].keys())
      margin.sort()
      maxprofit=-45456
      maxmargin=0
      for m in margin:
        #mxprof
        p=[]
        mcost=avgs[f][m][1]*mm/(1-m)
        profit=avgs[f][m][2]+avgs[f][m][1]-avgs[f][m][3]-mcost
        if profit>maxprofit:
          maxprofit=profit
          maxmargin=m
      #print(f,round(maxprofit),maxmargin)
      print(maxmargin)
      print(round(maxprofit))
        #for v in [f,m]+avgs[f][m]+[mcost,profit]:
        #  p.append(str(round(v,2)))
        #print("\t".join(p))
        #print(f,"\t",m,"\t",avgs[f][m])
