breed [persons person]
persons-own [consumption netmember? membership-length be-point exp-srev-init sum-exp-rev exp-srev-list srev-level my-subnetrev my-rev my-srev explored? last-margin invited? bottleneck?]
undirected-link-breed [friends friend]
directed-link-breed [sponsors sponsor]


globals [network-sale-revenue network-fee-revenue net-seed network-sponsor-cost last-profit current-profit network-profit network-manufacturing-cost]

to setup
  clear-all
  
  set-default-shape persons "circle"
  create-persons 1 [
    set size 1.5
    set color red
    set netmember? true
    set consumption 10000
  ]
  set net-seed person 0
  repeat number-of-persons [
    create-persons 1 [
      set color blue
      set netmember? false
      set consumption round random-normal 1000 500
      if consumption < 100 [ set consumption 200]
      set size consumption / 1000
      set be-point round (consumption * random-normal 1 0.5)
      if be-point < consumption * 0.5 [ set be-point (consumption * 0.5) ]
    ]
  ]
  ask one-of persons [
    create-friend-with one-of other persons
  ]
  ask persons [
    create-friend-with one-of other persons with [count friend-neighbors > 0]
  ]
  ;ask persons [
  ;  output-print count friend-neighbors
  ;]
  repeat number-of-friendships [
    ask one-of persons [ 
      create-friend-with one-of other persons
    ]
  ]
  ;output-print "-------"
  ;ask persons [
  ;  output-print count friend-neighbors
  ;]
  ask persons [
    set srev-level 0
    set exp-srev-init 0
    set invited? false
    set bottleneck? false
    let sum-friend-rev 0
    ask friend-neighbors [
       set sum-friend-rev (sum-friend-rev + consumption)
    ]
    let a (sum-friend-rev * (count friend-neighbors) ^ 1.3)
    set exp-srev-init (round (rev-to-srev a))
    set exp-srev-list []
    repeat 10 [set exp-srev-list lput exp-srev-init exp-srev-list]
    set last-margin margin
  ]
  ask net-seed [
    set sum-exp-rev (exp-srev-init * 6)
    set invited? true
  ]

  layout-radial persons links (turtle 0)
  display
  ask persons [
    set label exp-srev-init
  ]
  set last-profit -213218390218390
  set current-profit -1
end

to layout
  repeat 12 [
    layout-spring persons friends 0.05 1 1.2
  ]
end

to update-revenue
  set last-profit current-profit
  set network-fee-revenue count persons with [netmember?] * monthly-fee
  let rev 0
  let scost 0
  let mcost 0
  ask persons with [netmember?] [
    set mcost mcost + consumption
    set scost scost + my-srev
  ]
  ask net-seed [
    set mcost mcost - consumption
    set scost scost - my-srev
  ]
  
  ask persons with [(not netmember?) and (count friend-neighbors with [netmember?] > 0)] [
    set mcost mcost + consumption
  ]
  set rev mcost * (1 - margin)
  set network-sale-revenue rev
  ;set current-revenue rev
  set mcost mcost * manufacturing-cost
  set network-sponsor-cost scost
  set-current-plot "revenue"
  plot network-fee-revenue + network-sale-revenue
  set-current-plot "scost"
  plot network-sponsor-cost
  set-current-plot "mcost"
  plot mcost
  set network-manufacturing-cost mcost
  set network-profit round (network-fee-revenue + network-sale-revenue - network-sponsor-cost - mcost)
  set-current-plot "profit"
  plot network-profit
  set current-profit network-profit
  
end

to-report net-stable?
  report (round last-profit = round current-profit)
end

to-report netmember-avg-friend-count
  let s 0
  ask persons with [netmember?] [
    set s s + count friend-neighbors
  ]
  report s / count persons with [netmember?]
end

to-report all-persons-avg-friend-count
  let s 0
  ask persons [
    set s s + count friend-neighbors
  ]
  report s / count persons
end

to-report netmember-avg-be-point
  let s 0
  ask persons with [netmember?] [
    set s s + be-point
  ]
  report s / count persons with [netmember?]
end

to-report all-persons-avg-be-point
  let s 0
  ask persons [
    set s s + be-point
  ]
  report s / count persons
end

to-report bottleneck-avg-friend-count
  if count persons with [bottleneck?] = 0 [report -1]
  let s 0
  ask persons with [bottleneck?] [
    set s s + count friend-neighbors
  ]
  report s / count persons with [bottleneck?]
end

to-report bottleneck-avg-be-point
  if count persons with [bottleneck?] = 0 [report -1]
  let s 0
  ask persons with [bottleneck?] [
    set s s + be-point
  ]
  report s / count persons with [bottleneck?]
end

to-report rev-to-srev [rev]
  report rev * 0.09  
end

to-report rev-to-level [rev]
  let cons rev / margin
  let brackets [200 600 1200 2400 4000 6600 10000]
  let perc [0 0.03 0.06 0.09 0.12 0.15 0.18 0.21]
  let points cons / 20
  let i 0
  if-else points > 10000 [set i 6]
  [
    while [points > (item i brackets)] [set i i + 1]
  ]
  report item i perc
end

to-report update-my-subnetrev ;;vcetne my-rev
  ifelse ((count in-sponsor-neighbors) = 0)
  [
    set my-subnetrev round my-rev
    set srev-level rev-to-level my-subnetrev
    set my-srev round my-rev * srev-level
    report my-subnetrev
  ]
  [
    let revsum my-rev
    ask in-sponsor-neighbors [
      set revsum (revsum + update-my-subnetrev)
    ]
    set my-subnetrev round (revsum)
    set srev-level rev-to-level my-subnetrev
    let msl srev-level
    let srevsum 0
    ask in-sponsor-neighbors [
      let dperc msl - srev-level
      if dperc < 0 [set dperc 0]
      set srevsum srevsum + (dperc * (my-rev / margin))
    ]
    set my-srev round srevsum
    report my-subnetrev
  ]
end

to update-points
  ask persons with [netmember?] [
    set my-subnetrev 0
    set srev-level 0
    set my-srev 0
    let mr consumption * margin
    ask friend-neighbors with [not netmember?] [
      set mr (mr + ((consumption * margin) / count friend-neighbors with [netmember?]))
    ]
    set my-rev mr
  ]
  
  ask net-seed [
    set my-subnetrev update-my-subnetrev
  ]  
end

to spread-network
  update-points
  ask persons with [netmember?] [
    set exp-srev-list lput my-srev exp-srev-list
    set exp-srev-list remove-item 0 exp-srev-list
    let avg-srev-exp (sum exp-srev-list) / (length exp-srev-list)
    set label round (avg-srev-exp + my-rev) - (be-point + monthly-fee)
    ifelse avg-srev-exp + my-rev < (be-point + monthly-fee)  ;;leave condition
    [ 
      set netmember? false
      set membership-length 0
      
      let sp one-of out-sponsor-neighbors 
      ask in-sponsor-neighbors [
        create-sponsor-to sp        
      ]
      ask my-out-sponsors [die]
      ask my-in-sponsors [die]
      
      set srev-level 0
      set last-margin margin
    ]
    [ set membership-length membership-length + 1 ]
  ]
  ask persons with [netmember?] [
      let p self
      ask friend-neighbors with [not netmember?] [
         let my-rev-exp consumption * margin
         ask friend-neighbors with [not netmember?] [
           set my-rev-exp my-rev-exp + ((consumption * margin) / (count friend-neighbors with [netmember?] + 1 ))
         ]
         let avg-srev-exp (sum exp-srev-list) / (length exp-srev-list)
         let d-margin (margin - last-margin)
         if ((my-rev-exp + avg-srev-exp) * (1 + d-margin)) >= (be-point + monthly-fee) ;;join condition
         [
           set netmember? true
           create-sponsor-to p
           set srev-level 0
           set membership-length 0
           set sum-exp-rev (exp-srev-init * 6)
         ]
         set invited? true         
      ]
      ;;copy ^
      if random-join? [
        ask one-of persons with [not netmember?] [
          let my-rev-exp consumption * margin
          ask friend-neighbors with [not netmember?] [
            set my-rev-exp my-rev-exp + ((consumption * margin) / (count friend-neighbors with [netmember?] + 1 ))
          ]
          let avg-srev-exp (sum exp-srev-list) / (length exp-srev-list)
          let d-margin (margin - last-margin)
          if ((my-rev-exp + avg-srev-exp) * (1 + d-margin)) >= (be-point + monthly-fee) ;;join condition
          [
            create-sponsor-to one-of persons with [netmember?]
            set netmember? true
            set srev-level 0
            set membership-length 0
            set sum-exp-rev (exp-srev-init * 6)
          ]
          set invited? true         
        ]
      ]
  ]
  ask persons with [netmember?] [
    set color green
  ]
  ask persons with [not netmember?] [
    set color blue
  ]
  ask sponsors [
    set color red
  ]
  ask persons [
    ;set label my-srev
  ]
end

to bottleneck
  while [not net-stable?] [
    go
  ]
  ask persons [
    set size 0.1
  ]
  ask persons with [not invited?] [
    set color yellow
    set size 2
    ask friend-neighbors with [invited?] [
      set color red
      set size 2
      set bottleneck? true
    ]
  ]
  output-print count persons with [not invited?]
  output-print count persons with [color = red]
end

to stabilize
  while [not net-stable?] [
    go
  ]
end

to go
  if not any? persons [ stop ]
  
  ;;layout
  
  spread-network
  update-revenue
  
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
196
10
956
791
37
37
10.0
1
10
1
1
1
0
0
0
1
-37
37
-37
37
1
1
1
ticks

BUTTON
36
363
149
396
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
10
40
191
73
number-of-persons
number-of-persons
0
1000
300
1
1
NIL
HORIZONTAL

BUTTON
39
122
152
155
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
10
78
191
111
number-of-friendships
number-of-friendships
0
1000
300
1
1
NIL
HORIZONTAL

SLIDER
11
216
183
249
monthly-fee
monthly-fee
0
1000
0
1
1
NIL
HORIZONTAL

SLIDER
11
252
183
285
margin
margin
0.07
1
0.23
0.01
1
NIL
HORIZONTAL

MONITOR
970
18
1125
63
NIL
network-sale-revenue
0
1
11

MONITOR
970
66
1125
111
NIL
network-fee-revenue
17
1
11

BUTTON
36
443
149
476
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

PLOT
970
119
1170
269
revenue
NIL
NIL
0.0
10.0
0.0
10.0
true
false
PENS
"default" 1.0 0 -16777216 true
"revenue" 1.0 0 -16777216 true

PLOT
970
271
1170
421
scost
NIL
NIL
0.0
10.0
0.0
10.0
true
false
PENS
"default" 1.0 0 -16777216 true

PLOT
970
575
1170
725
profit
NIL
NIL
0.0
10.0
0.0
10.0
true
false
PENS
"default" 1.0 0 -16777216 true

SWITCH
11
324
183
357
random-join?
random-join?
1
1
-1000

OUTPUT
5
734
189
788
10

BUTTON
5
690
106
723
NIL
bottleneck
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

PLOT
970
423
1170
573
mcost
NIL
NIL
0.0
10.0
0.0
10.0
true
false
PENS
"default" 1.0 0 -16777216 true

MONITOR
970
731
1074
776
NIL
network-profit
17
1
11

SLIDER
11
288
183
321
manufacturing-cost
manufacturing-cost
0
1
0.4
0.01
1
NIL
HORIZONTAL

BUTTON
36
403
149
437
go till stable
stabilize
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

TEXTBOX
15
17
165
35
Setup variables
12
0.0
1

TEXTBOX
14
194
164
212
Run-time variables
12
0.0
1

TEXTBOX
9
638
159
683
Bottleneck experiment\nred = bottlenecks\nyellow = not invited
12
0.0
1

@#$#@#$#@
WHAT IS IT?
-----------


THINGS TO NOTICE
----------------


EXTENDING THE MODEL
-------------------


NETLOGO FEATURES
----------------


RELATED MODELS
--------------
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="spread1" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>net-stable?</exitCondition>
    <metric>count persons with [netmember?]</metric>
    <enumeratedValueSet variable="random-join?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-friendships">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-persons">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="margin">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-fee">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="spread2" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>net-stable?</exitCondition>
    <metric>netmember-avg-friend-count</metric>
    <metric>all-persons-avg-friend-count</metric>
    <enumeratedValueSet variable="random-join?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-friendships">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-persons">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="margin">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-fee">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="spread3" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>net-stable?</exitCondition>
    <metric>netmember-avg-be-point</metric>
    <metric>all-persons-avg-be-point</metric>
    <enumeratedValueSet variable="random-join?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-friendships">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-persons">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="margin">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-fee">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="random-join1" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>net-stable?</exitCondition>
    <metric>count persons with [netmember?]</metric>
    <enumeratedValueSet variable="random-join?">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number-of-friendships" first="50" step="2" last="500"/>
    <enumeratedValueSet variable="number-of-persons">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="margin">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-fee">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="random-join2" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>net-stable?</exitCondition>
    <metric>count persons with [netmember?]</metric>
    <enumeratedValueSet variable="random-join?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number-of-friendships" first="50" step="2" last="500"/>
    <enumeratedValueSet variable="number-of-persons">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="margin">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-fee">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="random-join-584" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>net-stable?</exitCondition>
    <metric>all-persons-avg-friend-count</metric>
    <enumeratedValueSet variable="random-join?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-friendships">
      <value value="584"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-persons">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="margin">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-fee">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="bottleneck" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>bottleneck</go>
    <exitCondition>net-stable?</exitCondition>
    <metric>all-persons-avg-friend-count</metric>
    <metric>bottleneck-avg-friend-count</metric>
    <metric>all-persons-avg-be-point</metric>
    <metric>bottleneck-avg-be-point</metric>
    <metric>count persons with [bottleneck?]</metric>
    <metric>count persons with [not invited?]</metric>
    <steppedValueSet variable="number-of-friendships" first="50" step="10" last="500"/>
    <enumeratedValueSet variable="number-of-persons">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-join?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-fee">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="margin">
      <value value="0.3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="max-profit1" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <exitCondition>net-stable?</exitCondition>
    <metric>network-profit</metric>
    <metric>network-sale-revenue</metric>
    <metric>network-fee-revenue</metric>
    <metric>network-sponsor-cost</metric>
    <metric>network-manufacturing-cost</metric>
    <steppedValueSet variable="margin" first="0.01" step="0.01" last="0.6"/>
    <enumeratedValueSet variable="manufacturing-cost">
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-friendships">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-fee">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-join?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-persons">
      <value value="300"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="max-profit2" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <exitCondition>net-stable?</exitCondition>
    <metric>network-profit</metric>
    <metric>network-sale-revenue</metric>
    <metric>network-fee-revenue</metric>
    <metric>network-sponsor-cost</metric>
    <metric>network-manufacturing-cost</metric>
    <metric>count persons with [netmember?]</metric>
    <steppedValueSet variable="margin" first="0.05" step="0.01" last="0.9"/>
    <enumeratedValueSet variable="manufacturing-cost">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-friendships">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-fee">
      <value value="0"/>
      <value value="50"/>
      <value value="100"/>
      <value value="150"/>
      <value value="200"/>
      <value value="250"/>
      <value value="300"/>
      <value value="350"/>
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-join?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-persons">
      <value value="300"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
