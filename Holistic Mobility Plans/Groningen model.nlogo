;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; extensions, breeds and variables ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;TODO:
; set SES


extensions [csv gis nw]

__includes ["Setup.nls" "Networks.nls" "HumatInitialize.nls" "HumatStrategies.nls" "HumatCognition.nls" "HumatReporter.nls" "PlotAndVis.nls" "Scenarios.nls"]

breed [humats humat]

undirected-link-breed [friends friend]
undirected-link-breed [works work]
undirected-link-breed [nbors nbor]

globals [
  voters
  buildings
  roads
  park
  districts
  groningen_population
  internal-clock
]

humats-own [
  district-name-humat ; row 0
  district-id-humat ; row 1
  education-level ; row 2
  economic-activity ; row 3
  gender ; row 4
  age ; row 5
  group
  mixgroup
  no-friends ; number of friends-links
  no-works ; number of work-links
  no-nbors

  ; HUMAT- variables
  behaviour
  ses ;socio-economic status ; for now random < 0 ; 1 >
  meetingparticipation
  voting?


  social-importance
  motive-1-importance
  motive-2-importance
  motive-3-importance
  motive-4-importance
  motive-5-importance
  motives-importances-sum ; sum of all motive-importances

  satisfaction ; satisfaction from a chosen BA; either satisfaction-A or satisfaction-B, depending on chosen BA
  satisfaction-A
  satisfaction-B
  social-satisfaction-A
  motive-1-satisfaction-A
  motive-2-satisfaction-A
  motive-3-satisfaction-A
  motive-4-satisfaction-A
  motive-5-satisfaction-A
  social-satisfaction-B
  motive-1-satisfaction-B
  motive-2-satisfaction-B
  motive-3-satisfaction-B
  motive-4-satisfaction-B
  motive-5-satisfaction-B

  evaluations-list-A
  social-evaluation-A ; evaluation of A (behavioural alternative i) with respect to social group of needs for HUMAT j <-1;1>
  motive-1-evaluation-A ; evaluation of A (behavioural alternative i) with respect to motive group of needs for HUMAT j <-1;1>
  motive-2-evaluation-A
  motive-3-evaluation-A
  motive-4-evaluation-A
  motive-5-evaluation-A
  evaluations-list-B
  social-evaluation-B ; evaluation of B (behavioural alternative ~i) with respect to social group of needs for HUMAT j <-1;1>
  motive-1-evaluation-B ; evaluation of B (behavioural alternative ~i) with respect to motive group of needs for HUMAT j <-1;1>
  motive-2-evaluation-B
  motive-3-evaluation-B
  motive-4-evaluation-B
  motive-5-evaluation-B


  dissonance-A ; the level of cognitive dissonance a behavioural alternative i (A) evokes in HUMAT j at time tn [Dij tn] <0;1>
  dissonance-B ; the level of cognitive dissonance a behavioural alternative i (B) evokes in HUMAT j at time tn [Dij tn] <0;1>
  dissonance-tolerance ; individual difference in tolerating dissonances before they evoke dissonance reduction strategies [Tj] normal trunc distribution with mean = 0.5, sd = 0.14 trunc to values <0;1>, this is the threshold determining if a reduction strategy is forgetting/distraction or if action has to be taken
  dissonance-strength ; individually perceived strength of cognitive dissonance a chosen behavioural alternative evokes in HUMAT j at time tn [Fij tn]; either dissonance-strenght-A or dissonance-strength-B, depending on chosen behavioural alternative
  dissonance-strength-A ; individually perceived strength of cognitive dissonance a behavioural alternative i (A) evokes in HUMAT j at time tn [Fij tn]; F because it's a fraction of maximum dissonance HUMAT j can possibly experience <0;1>
  dissonance-strength-B ; individually perceived strength of cognitive dissonance a behavioural alternative i (B) evokes in HUMAT j at time tn [Fij tn]; F because it's a fraction of maximum dissonance HUMAT j can possibly experience <0;1>
  dissatisfying-A ; the sum of dissatisfying evaluations of A <0;1,5>
  dissatisfying-B ; the sum of dissatisfying evaluations of B over three groups of needs <0;1,5>
  satisfying-A ; the sum of satisfying evaluations of A over three groups of needs <0;1,5>
  satisfying-B ; the sum of satisfying evaluations of B over three groups of needs <0;1,5>
  dilemma?

  ;;alter-representation variables;;;
  alter-representation-list ; impression of linked humats
  inquiring-list
  signaling-list
  inquired-humat  ; the list belongs to ego and contains information about the alter who the ego inquires with
  inquiring-humat ; the list belongs to an inquired alter and contains information about the ego who is inquiring
  signaled-humat  ; the list belongs to ego and contains information about the alter who the ego signals to
  signaling-humat ; the list belongs to a signaled alter and contains information about the ego who is signaling
  inquiring? ; boolean positive [1] if the ego is inquiring at a given tick
  #inquiring ;the number of times humat inquired with alters
  #inquired ; the number of times humat was inquired with by egos
  signaling? ; boolean positive [1] if the ego is signaling at a given tick
  #signaling ; the number of times humat signaled to alters
  #signaled ; the number of times humat was signaled to
]

patches-own [
district-id-patch
district-name-patch
district-nbors-patch
residential
%A
%B
%A-1994
%voters-1994
]
@#$#@#$#@
GRAPHICS-WINDOW
210
28
1465
750
-1
-1
1.78
1
15
1
1
1
0
0
0
1
-350
350
-200
200
0
0
1
ticks
30.0

BUTTON
4
31
70
64
NIL
Setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
5
67
203
100
N-pop
N-pop
0
50000
15301.0
1
1
NIL
HORIZONTAL

OUTPUT
1486
412
1847
710
13

BUTTON
104
102
203
135
NIL
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
5
102
102
135
NIL
go\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1604
86
1665
131
Car-free
precision ((count humats with [behaviour = \"A\"] / count humats )* 100) 2
17
1
11

PLOT
1486
259
1847
409
NIL
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Asking questions" 1.0 0 -8630108 true "" "plot count turtles with [inquiring? = 1]"
"Lecturing others" 1.0 0 -13791810 true "" "plot count turtles with [signaling? = 1]"

MONITOR
1604
180
1694
225
Dissonant
precision (count humats with [Further-Comparison-Needed? dissonance-A dissonance-B 1 and Further-Comparison-Needed? satisfaction-A satisfaction-B 2] / count humats * 100) 2
17
1
11

BUTTON
5
244
132
277
Vote Simulation
Color-Districts-Voters
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
72
31
202
64
end-ticks
end-ticks
0
50
39.0
1
1
NIL
HORIZONTAL

BUTTON
1681
721
1865
754
NIL
Display-District-%Voters
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1721
39
1785
84
Turnout
precision (Voter-Turnout * 100) 3
17
1
11

BUTTON
5
137
138
170
Color&Label
Color-Districts-Normal\nDisplay-Label
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1470
720
1670
753
NIL
Display-District-Voters-%A
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
5
209
100
242
Vote 1994
Color-Districts-Voters1994
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
5
715
194
748
Export Simulation Results
CSV-Simulation
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
6
10
156
28
Setup the simulation:
14
0.0
1

TEXTBOX
5
188
302
222
Display referendum results:
14
0.0
1

TEXTBOX
7
697
192
731
Export the results to CSV:
14
0.0
1

TEXTBOX
1594
18
1744
36
Population
14
0.0
1

TEXTBOX
1483
237
1739
271
Strategies to make up one's mind
14
0.0
1

MONITOR
1721
86
1786
131
Car-free
precision (Voter-%A * 100) 2
17
1
11

MONITOR
1604
133
1694
178
Undecided
precision (count humats with [Further-Comparison-Needed? satisfaction-A satisfaction-B 2] / count humats * 100) 2
17
1
11

BUTTON
140
137
203
170
Off
ask turtles with [breed = turtles] [die]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1722
17
1872
35
Voters
14
0.0
1

TEXTBOX
1484
142
1634
160
% Undecided
14
0.0
1

TEXTBOX
1484
194
1634
212
% Dissonant
14
0.0
1

TEXTBOX
1592
164
1742
182
NIL
11
0.0
1

TEXTBOX
1479
91
1588
125
% Car-free
14
0.0
1

TEXTBOX
1481
56
1631
74
Turnout
14
0.0
1

MONITOR
1721
133
1800
178
Undecided
precision (count humats with [Further-Comparison-Needed? satisfaction-A satisfaction-B 2 and voting? = 1] / count humats with [voting? = 1] * 100) 2
17
1
11

MONITOR
1722
180
1800
225
Dissonant
precision (count humats with [Further-Comparison-Needed? dissonance-A dissonance-B 1 and Further-Comparison-Needed? satisfaction-A satisfaction-B 2 and voting? = 1] / count humats with [voting? = 1] * 100) 2
17
1
11

TEXTBOX
2
291
152
309
Scenarios:
14
0.0
1

BUTTON
2
313
194
346
Affirmative transport convenience
Target-Randomly-Positive-Motive-3
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
2
348
194
381
Smearing shopping convenience
Target-Randomly-Negative-Motive-2 
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
3
383
193
416
Car accident
Target-Randomly-Importance-Motive-1 
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
29
501
167
546
policy_scenarios
policy_scenarios
1 2 3 4 5 6 7
6

CHOOSER
29
556
167
601
intervention_time
intervention_time
5 20 35
2

BUTTON
3
420
193
453
Townhall meeting
NIL
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
3
457
194
490
Neighborhood meeting
NIL
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Policy scenarios p2p3t35 1000" repetitions="1000" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>precision (Voter-%A * 100) 2</metric>
    <metric>precision (Voter-Turnout * 100) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 1] ) / ( count humats with [voting? = 1 and district-id-humat = 1] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 2] ) / ( count humats with [voting? = 1 and district-id-humat = 2] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 3] ) / ( count humats with [voting? = 1 and district-id-humat = 3] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 4] ) / ( count humats with [voting? = 1 and district-id-humat = 4] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 5] ) / ( count humats with [voting? = 1 and district-id-humat = 5] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 6] ) / ( count humats with [voting? = 1 and district-id-humat = 6] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 7] ) / ( count humats with [voting? = 1 and district-id-humat = 7] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 8] ) / ( count humats with [voting? = 1 and district-id-humat = 8] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 9] ) / ( count humats with [voting? = 1 and district-id-humat = 9] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 10] ) / ( count humats with [voting? = 1 and district-id-humat = 10] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 11] ) / ( count humats with [voting? = 1 and district-id-humat = 11] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 12] ) / ( count humats with [voting? = 1 and district-id-humat = 12] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 13] ) / ( count humats with [voting? = 1 and district-id-humat = 13] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 1] ) / ( count humats with [district-id-humat = 1] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 2] ) / ( count humats with [district-id-humat = 2] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 3] ) / ( count humats with [district-id-humat = 3] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 4] ) / ( count humats with [district-id-humat = 4] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 5] ) / ( count humats with [district-id-humat = 5] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 6] ) / ( count humats with [district-id-humat = 6] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 7] ) / ( count humats with [district-id-humat = 7] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 8] ) / ( count humats with [district-id-humat = 8] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 9] ) / ( count humats with [district-id-humat = 9] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 10] ) / ( count humats with [district-id-humat = 10] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 11] ) / ( count humats with [district-id-humat = 11] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 12] ) / ( count humats with [district-id-humat = 12] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 13] ) / ( count humats with [district-id-humat = 13] ) ) 2</metric>
    <metric>precision ( ( count humats with [Further-Comparison-Needed? satisfaction-A satisfaction-B 2] / count humats * 100 ) ) 2</metric>
    <metric>precision ( ( count humats with [Further-Comparison-Needed? dissonance-A dissonance-B 1 and Further-Comparison-Needed? satisfaction-A satisfaction-B 2] / count humats * 100)) 2</metric>
    <enumeratedValueSet variable="policy_scenarios">
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intervention_time">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Groupmeetings" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>precision (Voter-%A * 100) 2</metric>
    <metric>precision (Voter-Turnout * 100) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 1] ) / ( count humats with [voting? = 1 and district-id-humat = 1] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 2] ) / ( count humats with [voting? = 1 and district-id-humat = 2] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 3] ) / ( count humats with [voting? = 1 and district-id-humat = 3] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 4] ) / ( count humats with [voting? = 1 and district-id-humat = 4] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 5] ) / ( count humats with [voting? = 1 and district-id-humat = 5] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 6] ) / ( count humats with [voting? = 1 and district-id-humat = 6] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 7] ) / ( count humats with [voting? = 1 and district-id-humat = 7] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 8] ) / ( count humats with [voting? = 1 and district-id-humat = 8] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 9] ) / ( count humats with [voting? = 1 and district-id-humat = 9] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 10] ) / ( count humats with [voting? = 1 and district-id-humat = 10] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 11] ) / ( count humats with [voting? = 1 and district-id-humat = 11] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 12] ) / ( count humats with [voting? = 1 and district-id-humat = 12] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 13] ) / ( count humats with [voting? = 1 and district-id-humat = 13] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 1] ) / ( count humats with [district-id-humat = 1] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 2] ) / ( count humats with [district-id-humat = 2] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 3] ) / ( count humats with [district-id-humat = 3] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 4] ) / ( count humats with [district-id-humat = 4] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 5] ) / ( count humats with [district-id-humat = 5] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 6] ) / ( count humats with [district-id-humat = 6] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 7] ) / ( count humats with [district-id-humat = 7] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 8] ) / ( count humats with [district-id-humat = 8] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 9] ) / ( count humats with [district-id-humat = 9] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 10] ) / ( count humats with [district-id-humat = 10] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 11] ) / ( count humats with [district-id-humat = 11] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 12] ) / ( count humats with [district-id-humat = 12] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 13] ) / ( count humats with [district-id-humat = 13] ) ) 2</metric>
    <metric>precision ( ( count humats with [Further-Comparison-Needed? satisfaction-A satisfaction-B 2] / count humats * 100 ) ) 2</metric>
    <metric>precision ( ( count humats with [Further-Comparison-Needed? dissonance-A dissonance-B 1 and Further-Comparison-Needed? satisfaction-A satisfaction-B 2] / count humats * 100)) 2</metric>
    <enumeratedValueSet variable="policy_scenarios">
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intervention_time">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="policy_scenarios">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N-pop">
      <value value="15301"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intervention_time">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-ticks">
      <value value="39"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Gromso" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>precision (Voter-%A * 100) 2</metric>
    <metric>precision (Voter-Turnout * 100) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 1] ) / ( count humats with [voting? = 1 and district-id-humat = 1] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 2] ) / ( count humats with [voting? = 1 and district-id-humat = 2] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 3] ) / ( count humats with [voting? = 1 and district-id-humat = 3] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 4] ) / ( count humats with [voting? = 1 and district-id-humat = 4] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 5] ) / ( count humats with [voting? = 1 and district-id-humat = 5] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 6] ) / ( count humats with [voting? = 1 and district-id-humat = 6] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 7] ) / ( count humats with [voting? = 1 and district-id-humat = 7] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 8] ) / ( count humats with [voting? = 1 and district-id-humat = 8] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 9] ) / ( count humats with [voting? = 1 and district-id-humat = 9] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 10] ) / ( count humats with [voting? = 1 and district-id-humat = 10] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 11] ) / ( count humats with [voting? = 1 and district-id-humat = 11] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 12] ) / ( count humats with [voting? = 1 and district-id-humat = 12] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and behaviour = "A" and district-id-humat = 13] ) / ( count humats with [voting? = 1 and district-id-humat = 13] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 1] ) / ( count humats with [district-id-humat = 1] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 2] ) / ( count humats with [district-id-humat = 2] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 3] ) / ( count humats with [district-id-humat = 3] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 4] ) / ( count humats with [district-id-humat = 4] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 5] ) / ( count humats with [district-id-humat = 5] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 6] ) / ( count humats with [district-id-humat = 6] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 7] ) / ( count humats with [district-id-humat = 7] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 8] ) / ( count humats with [district-id-humat = 8] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 9] ) / ( count humats with [district-id-humat = 9] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 10] ) / ( count humats with [district-id-humat = 10] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 11] ) / ( count humats with [district-id-humat = 11] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 12] ) / ( count humats with [district-id-humat = 12] ) ) 2</metric>
    <metric>precision ( ( count humats with [voting? = 1 and district-id-humat = 13] ) / ( count humats with [district-id-humat = 13] ) ) 2</metric>
    <metric>precision ( ( count humats with [Further-Comparison-Needed? satisfaction-A satisfaction-B 2] / count humats * 100 ) ) 2</metric>
    <metric>precision ( ( count humats with [Further-Comparison-Needed? dissonance-A dissonance-B 1 and Further-Comparison-Needed? satisfaction-A satisfaction-B 2] / count humats * 100)) 2</metric>
    <enumeratedValueSet variable="policy_scenarios">
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intervention_time">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N-pop">
      <value value="15301"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-ticks">
      <value value="39"/>
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
