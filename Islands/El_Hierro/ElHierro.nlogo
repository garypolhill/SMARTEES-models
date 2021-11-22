__includes["SocialNetwork.nls" "MakeAgents.nls" "Util.nls" "CriticalNodesMethods.nls" "GisDataMethods.nls" "CitizenMethods.nls" "ScenarioMethods.nls"]
globals[month year initial-year plot-highlight influencer-selected? influencer influencer2 csv-info scenario3-event1 scenario3-event2 scenario3-event3 scenario3-event4 ]
breed [humats humat]
breed [critical-nodes critical-node] ; critical node represeting local government
breed [strategy-managers strategy-manager] ;timeline strategy manager
breed [meetings-managers meeting-manager] ;meetings manager for scenario 2
breed [campaings-managers campaing-manager] ;campaings manager for scenario 3

links-own[
  ;1 if both link nodes have the same behavioural alternative, 0 otherwise
  same-ba?
  ;weigth the influence capacity of the other end over the link owner. Using the influence parameters
  trust
]

;we use the adjacent word instead of neighbor since neighbor is a netlogo reserved word
directed-link-breed [adjacents adjacent]
directed-link-breed [friends friend]
directed-link-breed [family-links family-link]
directed-link-breed [critical-node-links critical-node-link]
adjacents-own[
  ;1 if link owner already inquire the other end, 0 otherwise
  inquired?
  ;Persuasion of other end over link owner
  persuasion; use for sort inquire list

  ;1 if link owner already signaled the other end, 0 otherwise
  signaled?
  ;Persuasion of the link owner over the other end
  gullibility
]
friends-own [
  ;1 if link owner already inquire the other end, 0 otherwise
  inquired?
  ;Persuasion of other end over link owner
  persuasion; use for sort inquire list
  ;1 if link owner already signaled the other end, 0 otherwise
  signaled?
  ;Persuasion of the link owner over the other end
  gullibility

]

family-links-own [
  ;1 if link owner already inquire the other end, 0 otherwise
  inquired?
  ;Persuasion of other end over link owner
  persuasion; use for sort inquire list
  ;weigth the influence capacity of the other end over the link owner. Using the influence parameters
  relative-aspiration
  ;1 if link owner already signaled the other end, 0 otherwise
  signaled?
  ;Persuasion of the link owner over the other end
  gullibility

]
humats-own[
  ;needs importance
  energy-independence-importance
  environmental-quality-importance
  economic-sustainability-importance
  prestige-importance
  participation-importance
  social-importance


  ;needs satisfactions
  energy-independence-satisfaction-A
  environmental-quality-satisfaction-A
  economic-sustainability-satisfaction-A
  prestige-satisfaction-A
  participation-satisfaction-A
  social-satisfaction-A

  energy-independence-satisfaction-B
  environmental-quality-satisfaction-B
  economic-sustainability-satisfaction-B
  prestige-satisfaction-B
  participation-satisfaction-B
  social-satisfaction-B


  ;needs evaluations
  energy-independence-evaluation-A
  environmental-quality-evaluation-A
  economic-sustainability-evaluation-A
  prestige-evaluation-A
  participation-evaluation-A
  social-evaluation-A


  energy-independence-evaluation-B
  environmental-quality-evaluation-B
  economic-sustainability-evaluation-B
  prestige-evaluation-B
  participation-evaluation-B
  social-evaluation-B


  ;global satisfaction  mean evaluations
  satisfaction-A
  satisfaction-B
  satisfaction
  ;Behaviour of the optimal satisfaction
  behavior

  ;tolerance threshold
  dissonance-tolerance
  ;dissonance for all behavioral alternatives
  dissonance-A
  dissonance-B
  ;dissonance weigth if > 0 there is a dissonance
  dissonance-strength

  ; 1 if the humat have the dilemma, 0 otherwise
  energy-independence-dilemma?
  social-dilemma?
  environmental-quality-dilemma?
  economic-sustainability-dilemma?
  prestige-dilemma?
  participation-dilemma?
  ;influence parameters
  ;trust?
  adjacents-trust
  friends-trust
  ;critical nodes trust
  city-council-trust
  local-media-trust
  other-associations-trust
  gorona-viento-trust
  political-opposition-trust



  ;social network values
  age
  gender
  education-level
  economic-activity
  numFriends

  ;place citizen
  section

  ;simulate population values
  simulated
  bussiness-owner
  homeowner



  ;graph variables
  inquiring
  signaling
  random-conv
  meeting-conv

]

critical-nodes-own[
  node-type
  scope
  location
  trust-type
]
patches-own [
  district-id
]
strategy-managers-own[
strategies-list
]

meetings-managers-own[
meetings-list
]

campaings-managers-own[
campaings-list
]
;;;;;;;;;;;;;;;;;;;;;;;
;;; SetUp Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;
to setup-landscape
  clear-all
  ask patches [ set pcolor 9.7 ] ;; plain white background
  Make-Terrain
end

to setup-citizens
  set-default-shape humats "person" ;person shape for humats display
  Make-Sections-Population
  Make-Strategy-Manager
  Place-Citizen
  Make-Critical-Nodes
end
to setup-social-network
  Set-Social-Networks
  ;ask links [hide-link]
  Set-Friends-Networks
  ask links [hide-link]
  ;links color
  ;ask adjacents [set color blue]
  ;ask friends [set color orange]
end
;<summary>
; Setup function; clear the previous run ; Make humats and set initial satisfaction values ; set up the initial social network
;</summary>
to setup
  Set-Critical-Node-Network
  ask links [hide-link]
  Update-Social-Satisfaction
  ask humats [Update-Dissonances]
  ;choose initial behavior
  ask humats [Choose-Behaviour]
  Update-Social-Satisfaction
  ask humats [Update-Dissonances]
  Set-Links
  set csv-info []
  set month 1
  set initial-year 2006
  set year initial-year
  set scenario3-event1 0
  set scenario3-event2 0
  set scenario3-event3 0
  set scenario3-event4 0
  reset-ticks
end
;<summary>
;calculate social satisfaction using the social network; update global satisfaction
;</summary>
to Update-Social-Satisfaction
  ask humats[
    carefully[
      ; go through alter-representation-list and count the alters, who behave similarily and who dissimilarity
      let #similar 0
      let #dissimilar 0
      let node-list sort [other-end] of my-out-links
      foreach node-list [agent -> ifelse [behavior] of agent = behavior [set #similar #similar + 1][set #dissimilar #dissimilar + 1]]

      let #alters count my-out-links

      let %similar #similar / #alters
      let %dissimilar #dissimilar / #alters

      ;social satisfaction of BAs
      set social-satisfaction-A 0
      set social-satisfaction-B 0

      ifelse behavior = "A"
      [
        set social-satisfaction-A Normalized-Min-Max %similar 0 1 -1 1
        set social-satisfaction-B Normalized-Min-Max %dissimilar 0 1 -1 1

      ]
      [
        set social-satisfaction-B Normalized-Min-Max %similar 0 1 -1 1
        set social-satisfaction-A Normalized-Min-Max %dissimilar 0 1 -1 1

      ]

      ;Set social evaluations
      set social-evaluation-A social-importance * social-satisfaction-A
      set social-evaluation-B social-importance * social-satisfaction-B

      ;update global satisfactions from BAs
      set satisfaction-A (energy-independence-evaluation-A + social-evaluation-A + environmental-quality-evaluation-A + economic-sustainability-evaluation-A + prestige-evaluation-A + participation-evaluation-A) / 6
      set satisfaction-B (energy-independence-evaluation-B + social-evaluation-B + environmental-quality-evaluation-B + economic-sustainability-evaluation-B + prestige-evaluation-B + participation-evaluation-B) / 6

    ][
      print("wrong network created")
      print(who)
    ]

  ]

end

;<summary>
; The BA comparison dimensions include:
;* overall satisfaction - preference for more satistying, if similarly satisfying (+/- 0.2 = 10% of the theoretical satisfaction range <-1;1>), then
;* dissonance level - preference for less dissonant, if similarily dissonant (+/- 0.1 = 10% of the theoretical dissonance range <0;1>), then
;* satisfaction on experiential need - preference for more satisfying, if similarly satisfying on experiantial need (+/- 0.2 = 10% of the theoretical experiential satisfaction range <-1;1>), then
;* random choice.
;</summary>
to Choose-Behaviour
  (ifelse Further-Comparison-Needed? satisfaction-A satisfaction-B 2 [Compare-Dissonances]
    [ifelse satisfaction-A > satisfaction-B
      [set behavior "A" set satisfaction satisfaction-A set color green]
      [set behavior "B" set satisfaction satisfaction-B set color red]
    ]
  )
end
;<summary>
; The BA comparison dimensions include:
;* dissonance level - preference for less dissonant, if similarily dissonant (+/- 0.1 = 10% of the theoretical dissonance range <0;1>), then
;* satisfaction on experiential need - preference for more satisfying, if similarly satisfying on experiantial need (+/- 0.2 = 10% of the theoretical experiential satisfaction range <-1;1>), then
;* random choice.
;</summary>
to Compare-Dissonances
  (ifelse Further-Comparison-Needed? dissonance-A dissonance-B 1 [Compare-Experiential-Needs]
   [ifelse dissonance-A < dissonance-B
     [set behavior "U" set satisfaction satisfaction-A set color blue]
     [set behavior "U" set satisfaction satisfaction-B set color blue]
   ]
  )
end
;<summary>
; The BA comparison dimensions include:
;* satisfaction on experiential need - preference for more satisfying, if similarly satisfying on experiantial need (+/- 0.2 = 10% of the theoretical experiential satisfaction range <-1;1>), then
;* random choice.
;</summary>
to Compare-Experiential-Needs
  (ifelse Further-Comparison-Needed?  energy-independence-evaluation-A  energy-independence-evaluation-B 2 [Choose-Randomly]
   [ifelse  economic-sustainability-evaluation-A >  economic-sustainability-evaluation-B
     [set behavior "U" set satisfaction satisfaction-A set color blue ]
     [set behavior "U" set satisfaction satisfaction-B set color blue]
   ]
  )
end
;<summary>
; The BA random choice.
;</summary>
to Choose-Randomly
set behavior one-of (list "A" "B")
ifelse behavior = "A"
  [set satisfaction satisfaction-A set color blue ]
  [set satisfaction satisfaction-B set color blue]
set behavior "U"

end


;;;;;;;;;;;;;;;;;;;;;;;
;;; Go Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;

to go
  ;clear graph values
  set plot-highlight 0
  ask humats[
    set inquiring 0
    set signaling 0
    set random-conv 0
    set meeting-conv 0
  ]
  Critical-Nodes-Strategy
  Inquire
  Signal
  ask humats [Random-Conversations]
  Trust-Event
  ;Run-Influencers
  ;if month = 6 and year = 2014 and influencer-selected? = 0[
    ;set influencer-selected?  1
    ;Select-Influencer
  ;]
  if scenario-3[
    Event-Scenario-3
  ]
  let comm  count humats with [inquiring = 1] + count humats with [signaling = 1] + count humats with [random-conv = 1] + count humats with [meeting-conv > 0]
  set csv-info lput (list count humats with [behavior = "A"] count humats with [behavior = "B"] count humats with [behavior = "U"] comm ) csv-info
  if month = 5 and year = 2021[
    export-plot "Energy Independence Satisfaction" (word "eic"  run-number  ".csv")
    export-plot "Environmental-Quality Satisfaction" (word "eqac"  run-number  ".csv")
    export-plot "Social Satisfaction" (word "sac"  run-number  ".csv")
    export-plot "Economic Sustainability Satisfaction" (word "esc"  run-number  ".csv")
    export-plot "Prestige Satisfaction" (word "peac"  run-number  ".csv")
    export-plot "Participation Satisfaction" (word "pac"  run-number  ".csv")
    (csv:to-file (word "ejecucion" run-number ".csv") csv-info ";")
    stop
  ]

  tick
  set month Get-Month
  set year Get-Year
end
;<summ;<summary>
; When a humat have dissonances and a values or experiential dilemma he tries to reduce that dissonance through his social network.
;</summary>
to Inquire
  ask humats [
    ;only a humat with dissonance and a values or experiential dilemma inquire
    if dissonance-strength > 0 and (energy-independence-dilemma? = 1 or environmental-quality-dilemma? = 1 or economic-sustainability-dilemma? = 1 or prestige-dilemma? = 1 or participation-dilemma? = 1)  [
      Inquire-Comm
    ]
  ]
end
;<summ;<summary>
; When a humat has dissonances and a social dilemma, he tries to reduce that dissonance by convincing other humats in his social network.
;</summary>
to Signal
  ask humats [
    if dissonance-strength > 0 and social-dilemma? = 1  [
      Signal-Comm
    ]
  ]
end
;<summary>
; ; weighing of alter's similarity of needs, applicable to each group of needs for each BA
;  ; can take a max value of 0,4 - if two agents value the same needs to the same extent, the influencing agent affects the influenced agent to a max degree of 40%
;(new value is 60% influnced agent's and 40% influencing agent). ; if two agents don't find the same needs important, the influencing agent does not affect the influenced agent
;</summary>
;<param name="need-evaluation-BA-ego">influeced humat need evaluation</param>
;<param name="need-evaluation-BA-alter">influencing humat need evaluation</param>
;<param name="need-importance-ego">influeced humat need importance</param>
;<param name="need-importance-alter">influencing humat need importance</param>
to-report Need-Similarity [need-evaluation-BA-ego need-evaluation-BA-alter need-importance-ego need-importance-alter]
  ifelse
  (need-evaluation-BA-ego > 0 and need-evaluation-BA-alter > 0) or
  (need-evaluation-BA-ego < 0 and need-evaluation-BA-alter < 0)
  [report 0.4 * (1 - abs(need-importance-ego - need-importance-alter))]
  [report 0]
end

;<summary>
; when humats are persuaded by other humats in their social networks, they change their satisfactions of needs for BAs
;to the extent that the alter is persuasive.
;</summary>
;<param name="need-satisfaction-BA">need satisfaction of the influenced humat</param>
;<param name="inquired-need-persuasion">persuasion of the influencing humat over the influenced</param>
;<param name="need-satisfaction-alter">need satisfaction of the influencing humat</param>
to-report New-Need-Satisfaction [need-satisfaction-BA inquired-need-persuasion need-satisfaction-alter]
  let val (1 - inquired-need-persuasion) * need-satisfaction-BA + inquired-need-persuasion * need-satisfaction-alter
  report val
end


to Update-Evaluations

  ; update evaluations = importances * satisfactions ; excluding social dimension
  ; A
  set energy-independence-evaluation-A energy-independence-importance * energy-independence-satisfaction-A
  set environmental-quality-evaluation-A environmental-quality-importance * environmental-quality-satisfaction-A
  set economic-sustainability-evaluation-A economic-sustainability-importance * economic-sustainability-satisfaction-A
  set prestige-evaluation-A prestige-importance * prestige-satisfaction-A
  set participation-evaluation-A participation-importance * participation-satisfaction-A
  ; B
  set energy-independence-evaluation-B energy-independence-importance * energy-independence-satisfaction-B
  set environmental-quality-evaluation-B environmental-quality-importance * environmental-quality-satisfaction-B
  set economic-sustainability-evaluation-B economic-sustainability-importance * economic-sustainability-satisfaction-B
  set prestige-evaluation-B prestige-importance * prestige-satisfaction-B
  set participation-evaluation-B participation-importance * participation-satisfaction-B

  ; go through alter-representation-list and count the alters, who behave similarily and who dissimilarity
  let #similar 0
  let #dissimilar 0
  let node-list sort [other-end] of my-out-links
  foreach node-list [agent -> ifelse [behavior] of agent = behavior [set #similar #similar + 1][set #dissimilar #dissimilar + 1]]

  let #alters count my-out-links
  let %similar #similar / #alters
  let %dissimilar #dissimilar / #alters


  ; Set social dimension: social satisfaction from BAs, evaluations of BAs
  set social-satisfaction-A 0
  set social-satisfaction-B 0

  ifelse behavior = "A"
  [
    set social-satisfaction-A Normalized-Min-Max %similar 0 1 -1 1
    set social-satisfaction-B Normalized-Min-Max %dissimilar 0 1 -1 1
  ]
  [
    set social-satisfaction-B %similar
    set social-satisfaction-A %dissimilar
  ]

  ;Set social evaluations
  set social-evaluation-A social-importance * social-satisfaction-A
  set social-evaluation-B social-importance * social-satisfaction-B

  ;update satisfactions from BAs
  set satisfaction-A (energy-independence-evaluation-A + social-evaluation-A + environmental-quality-evaluation-A + economic-sustainability-evaluation-A + prestige-evaluation-A + participation-evaluation-A) / 6
  set satisfaction-B (energy-independence-evaluation-B + social-evaluation-B + environmental-quality-evaluation-B + economic-sustainability-evaluation-B + prestige-evaluation-B + participation-evaluation-B) / 6


end

;<summary>
;Update dilemmas and dissonances;
;</summary>
to Update-Dissonances
  ; reset the previous values of dilemmas
  set energy-independence-dilemma? 0
  set social-dilemma? 0
  set environmental-quality-dilemma? 0
  set economic-sustainability-dilemma? 0
  set prestige-dilemma? 0
  set participation-dilemma? 0

  ;get evaluations list for the Dissatisfying-Status-BA function
  let evaluations-list-A (list social-evaluation-A energy-independence-evaluation-A environmental-quality-evaluation-A economic-sustainability-evaluation-A prestige-evaluation-A participation-evaluation-A)

  ;get sums of positive (satisfying) and negative (dissatisfying) evaluations for all behavioural alternatives
  let dissatisfying-A Dissatisfying-Status-BA evaluations-list-A
  let satisfying-A Satisfying-Status-BA evaluations-list-A

  ;get dissonance value
  set dissonance-A Dissonance-Status-BA satisfying-A dissatisfying-A

  ; calculating the need for dissonance reduction - a BA invokes the need to reduce dissonance if the level of dissonance for BA exceeds the dissonance-threshold
  let dissonance-strength-A (dissonance-A - dissonance-tolerance) / (1 - dissonance-tolerance)
  if dissonance-strength-A < 0 [set dissonance-strength-A 0]


  ;get evaluations list for the Dissatisfying-Status-BA function
  let evaluations-list-B (list social-evaluation-B energy-independence-evaluation-B environmental-quality-evaluation-B economic-sustainability-evaluation-B prestige-evaluation-B participation-evaluation-B)

  ;get sums of positive (satisfying) and negative (dissatisfying) evaluations for all behavioural alternatives
  let dissatisfying-B Dissatisfying-Status-BA evaluations-list-B
  let satisfying-B Satisfying-Status-BA evaluations-list-B

  ;get dissonance values
  set dissonance-B Dissonance-Status-BA satisfying-B dissatisfying-B

  ; calculating the need for dissonance reduction - a BA invokes the need to reduce dissonance if the level of dissonance for BA exceeds the dissonance-threshold
  let dissonance-strength-B (dissonance-B - dissonance-tolerance) / (1 - dissonance-tolerance)
  if dissonance-strength-B < 0 [set dissonance-strength-B 0]




  ; update dilemmas
  ifelse behavior = "A"
  [
    set dissonance-strength dissonance-strength-A
    ;wellness dilemma
    if (energy-independence-evaluation-A > 0 and environmental-quality-evaluation-A < 0 and economic-sustainability-evaluation-A < 0 and prestige-evaluation-A < 0 and participation-evaluation-A < 0 and social-evaluation-A < 0)  or
    (energy-independence-evaluation-A < 0 and environmental-quality-evaluation-A > 0 and economic-sustainability-evaluation-A > 0 and prestige-evaluation-A > 0 and participation-evaluation-A > 0 and social-evaluation-A > 0)
    [set energy-independence-dilemma? 1]
    ;environmental quality dilemma
    if (energy-independence-evaluation-A < 0 and environmental-quality-evaluation-A > 0 and economic-sustainability-evaluation-A < 0 and prestige-evaluation-A < 0 and participation-evaluation-A < 0 and social-evaluation-A < 0)  or
    (energy-independence-evaluation-A > 0 and environmental-quality-evaluation-A < 0 and economic-sustainability-evaluation-A > 0 and prestige-evaluation-A > 0 and participation-evaluation-A > 0 and social-evaluation-A > 0)
    [set environmental-quality-dilemma? 1]
    ; comfort dilemma
    if (energy-independence-evaluation-A < 0 and environmental-quality-evaluation-A < 0 and economic-sustainability-evaluation-A > 0 and prestige-evaluation-A < 0 and participation-evaluation-A < 0 and social-evaluation-A < 0)   or
    (energy-independence-evaluation-A > 0 and environmental-quality-evaluation-A > 0 and economic-sustainability-evaluation-A < 0 and prestige-evaluation-A > 0 and participation-evaluation-A > 0 and social-evaluation-A > 0)
    [set economic-sustainability-dilemma? 1]
    ;prestige dilemma
    if (energy-independence-evaluation-A < 0 and environmental-quality-evaluation-A < 0 and economic-sustainability-evaluation-A < 0 and prestige-evaluation-A > 0 and participation-evaluation-A < 0 and social-evaluation-A < 0)   or
    (energy-independence-evaluation-A > 0 and environmental-quality-evaluation-A > 0 and economic-sustainability-evaluation-A > 0 and prestige-evaluation-A < 0 and participation-evaluation-A > 0 and social-evaluation-A > 0)
    [set prestige-dilemma? 1]
    ;participation-dilemma?
    if (energy-independence-evaluation-A < 0 and environmental-quality-evaluation-A < 0 and economic-sustainability-evaluation-A < 0 and prestige-evaluation-A < 0 and participation-evaluation-A > 0 and social-evaluation-A < 0)   or
    (energy-independence-evaluation-A > 0 and environmental-quality-evaluation-A > 0 and economic-sustainability-evaluation-A > 0 and prestige-evaluation-A > 0 and participation-evaluation-A < 0 and social-evaluation-A > 0)
    [set participation-dilemma? 1]
    ;social-dilemma
    if (energy-independence-evaluation-A < 0 and environmental-quality-evaluation-A < 0 and economic-sustainability-evaluation-A < 0 and prestige-evaluation-A < 0 and participation-evaluation-A < 0 and social-evaluation-A > 0)   or
    (energy-independence-evaluation-A > 0 and environmental-quality-evaluation-A > 0 and economic-sustainability-evaluation-A > 0 and prestige-evaluation-A > 0 and participation-evaluation-A > 0 and social-evaluation-A < 0)
    [set social-dilemma? 1]

  ]
  [
    set dissonance-strength dissonance-strength-B
    ;wellness dilemma
    if (energy-independence-evaluation-B > 0 and environmental-quality-evaluation-B < 0 and economic-sustainability-evaluation-B < 0 and prestige-evaluation-B < 0 and participation-evaluation-B < 0 and social-evaluation-B < 0)  or
    (energy-independence-evaluation-B < 0 and environmental-quality-evaluation-B > 0 and economic-sustainability-evaluation-B > 0 and prestige-evaluation-B > 0 and participation-evaluation-B > 0 and social-evaluation-B > 0)
    [set energy-independence-dilemma? 1]
    ;environmental quality dilemma
    if (energy-independence-evaluation-B < 0 and environmental-quality-evaluation-B > 0 and economic-sustainability-evaluation-B < 0 and prestige-evaluation-B < 0 and participation-evaluation-B < 0 and social-evaluation-B < 0)  or
    (energy-independence-evaluation-B > 0 and environmental-quality-evaluation-B < 0 and economic-sustainability-evaluation-B > 0 and prestige-evaluation-B > 0 and participation-evaluation-B > 0 and social-evaluation-B > 0)
    [set environmental-quality-dilemma? 1]
    ; comfort dilemma
    if (energy-independence-evaluation-B < 0 and environmental-quality-evaluation-B < 0 and economic-sustainability-evaluation-B > 0 and prestige-evaluation-B < 0 and participation-evaluation-B < 0 and social-evaluation-B < 0)   or
    (energy-independence-evaluation-B > 0 and environmental-quality-evaluation-B > 0 and economic-sustainability-evaluation-B < 0 and prestige-evaluation-B > 0 and participation-evaluation-B > 0 and social-evaluation-B > 0)
    [set economic-sustainability-dilemma? 1]
    ;prestige dilemma
    if (energy-independence-evaluation-B < 0 and environmental-quality-evaluation-B < 0 and economic-sustainability-evaluation-B < 0 and prestige-evaluation-B > 0 and participation-evaluation-B < 0 and social-evaluation-B < 0)   or
    (energy-independence-evaluation-B > 0 and environmental-quality-evaluation-B > 0 and economic-sustainability-evaluation-B > 0 and prestige-evaluation-B < 0 and participation-evaluation-B > 0 and social-evaluation-B > 0)
    [set prestige-dilemma? 1]
    ;participation-dilemma?
    if (energy-independence-evaluation-B < 0 and environmental-quality-evaluation-B < 0 and economic-sustainability-evaluation-B < 0 and prestige-evaluation-B < 0 and participation-evaluation-B > 0 and social-evaluation-B < 0)   or
    (energy-independence-evaluation-B > 0 and environmental-quality-evaluation-B > 0 and economic-sustainability-evaluation-B > 0 and prestige-evaluation-B > 0 and participation-evaluation-B < 0 and social-evaluation-B > 0)
    [set participation-dilemma? 1]
    ;social-dilemma
    if (energy-independence-evaluation-B < 0 and environmental-quality-evaluation-B < 0 and economic-sustainability-evaluation-B < 0 and prestige-evaluation-B < 0 and participation-evaluation-B < 0 and social-evaluation-B > 0)   or
    (energy-independence-evaluation-B > 0 and environmental-quality-evaluation-B > 0 and economic-sustainability-evaluation-B > 0 and prestige-evaluation-B > 0 and participation-evaluation-B > 0 and social-evaluation-B < 0)
    [set social-dilemma? 1]
  ]
end


;;;;;;;;;;;;;;;;;
;;; Reporters ;;;
;;;;;;;;;;;;;;;;;
;<summary>
;Report the sum of all (evaluations < 0) for a behavioural alternative
;</summary>
;<param name="evaluations-list-BA">List of all evaluations for a behavioural alternative</param>
to-report Dissatisfying-Status-BA [evaluations-list-BA]
 let dissatisfying-list-BA filter [i -> i < 0] evaluations-list-BA
 let dissatisfying-stat-BA abs sum dissatisfying-list-BA
 report dissatisfying-stat-BA
end

;<summary>
;Report the sum of all (evaluations > 0) for a behavioural alternative
;</summary>
;<param name="evaluations-list-BA">List of all evaluations for a behavioural alternative</param>
to-report Satisfying-Status-BA [evaluations-list-BA]
 let satisfying-list-BA filter [i -> i > 0] evaluations-list-BA
 let satisfying-stat-BA sum satisfying-list-BA
 report satisfying-stat-BA
end

;<summary>
;Report the dissonance value for a behavioural alternative
;</summary>
;<param name="satisfying">value of the sum of all (evaluations > 0) for a behavioural alternative</param>
;<param name="dissatisfying">value of the sum of all (evaluations < 0) for a behavioural alternative</param>
to-report Dissonance-Status-BA [satisfying dissatisfying]
  let dissonant min (list satisfying dissatisfying)
  let consonant max (list satisfying dissatisfying) ; in case of the same values, it does not matter
  let dissonance 0
  if (dissonant + consonant) != 0 [
    set dissonance (2 * dissonant)/(dissonant + consonant)
  ]
  report dissonance
end

;<summary>
;1 if the diference beetween both dimensions is lower than 10% of the theoretical satisfaction range
;0 otherwise
;</summary>
;<param name="comparison-dimension-A">First dimension to compare</param>
;<param name="comparison-dimension-B">Second dimension to compare</param>
;<param name="theoretical-range">Range of the dimensions</param>
to-report Further-Comparison-Needed? [comparison-dimension-A comparison-dimension-B theoretical-range]
  let value 0
  ifelse (comparison-dimension-A > comparison-dimension-B - 0.25 * theoretical-range) and (comparison-dimension-A < comparison-dimension-B + 0.25 * theoretical-range) [Set value true] [Set value false]
  report value
end

;<summary>
  ; link-list sorted:
  ;(1) ascendingly by inquired? (not inquired first),
  ;(2) descendingly by same-BA? (same behaviour first),
  ;(3) descendingly by persuasion (strongest persuasion first).
;</summary>
;<param name="link-list">humat´s social network link list to be sorted</param>
to-report Sort-List-Inquiring [link-list]
  let sorted-link-list sort-by [[link1 link2] -> [persuasion] of link1 > [persuasion] of link2]  link-list ;(3) descendingly by persuasion (strongest persuasion first),
  set sorted-link-list sort-by [[link1 link2] -> [same-ba?] of link1 > [same-ba?] of link2]  sorted-link-list ;(2) descendingly by same-BA? (same behaviour first),
  set sorted-link-list sort-by [[link1 link2] -> [inquired?] of link1 < [inquired?] of link2]  sorted-link-list ;(1) ascendingly by inquired? (not inquired first).
  report sorted-link-list
end

to-report Sort-List-Signaling [link-list]
  ;(1) ascendingly by signaled? (not signaled to first),
  ; (2) descendingly by not the same-BA? (different behaviour first), and
  ; (3) descendingly by gullibility (the most easily persuaded first; sum of aspiration*similarity over experiential and values for both BAs; please note that ego will signal to all alters in its social network and then will focus on the most easily persuaded until that one changes its mind)
  let sorted-link-list sort-by [[link1 link2] -> [gullibility] of link1 > [gullibility] of link2]  link-list  ; (3) descendingly by gullibility (the most easily persuaded first)
  set sorted-link-list sort-by [[link1 link2] -> [same-ba?] of link1 < [same-ba?] of link2]  sorted-link-list ; (2) descendingly by not the same-BA? (different behaviour first),
  set sorted-link-list sort-by [[link1 link2] -> [signaled?] of link1 < [signaled?] of link2]  sorted-link-list ;(1) ascendingly by signaled? (not signaled to first).
  report sorted-link-list
end
@#$#@#$#@
GRAPHICS-WINDOW
360
13
1176
830
-1
-1
8.0
1
10
1
1
1
0
0
0
1
-50
50
-50
50
0
0
1
ticks
30.0

BUTTON
8
228
71
261
setup
setup
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
10
26
73
59
go
go
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
10
66
73
99
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
1

PLOT
1180
14
1447
201
Humats Acceptability
NIL
NIL
0.0
10.0
0.0
100.0
true
true
"" ""
PENS
"Accept" 1.0 0 -14439633 true "" "plot count humats with [behavior = \"A\"]"
"Reject" 1.0 0 -5298144 true "" "plot count humats with [behavior = \"B\"]"
"Undeciced" 1.0 0 -13345367 true "" "plot count humats with [behavior = \"U\"]"

PLOT
1181
595
1447
783
social satisfaction
NIL
NIL
-1.0
1.0
0.0
3000.0
false
true
"" ""
PENS
"Importance" 0.05 1 -14070903 true "histogram [social-importance] of humats" "histogram [social-importance] of humats"
"Accept" 0.05 0 -13840069 true "histogram [social-satisfaction-A] of humats" "histogram [social-satisfaction-A] of humats"
"Reject" 0.05 0 -2674135 true "histogram [social-satisfaction-B] of humats" "histogram [social-satisfaction-B] of humats"

PLOT
1179
403
1445
591
Environmental-Quality Satisfaction
NIL
NIL
-1.0
1.0
0.0
3000.0
false
true
"" ""
PENS
"Importance" 0.05 1 -14070903 true "" "histogram [environmental-quality-importance] of humats"
"Accept" 0.05 0 -14439633 true "" "histogram [environmental-quality-satisfaction-A] of humats"
"Reject" 0.05 0 -2674135 true "" "histogram [environmental-quality-satisfaction-B] of humats"

TEXTBOX
361
28
511
46
NIL
11
0.0
1

MONITOR
368
20
425
65
Month
month
17
1
11

SLIDER
183
152
355
185
social-reach
social-reach
0
10
1.0
1
1
NIL
HORIZONTAL

MONITOR
425
20
482
65
Year
year
17
1
11

OUTPUT
10
278
336
590
11

INPUTBOX
11
610
200
670
critical-nodes-config
CriticalNodeHierro.csv
1
0
String

INPUTBOX
9
675
200
735
strategies-table
strategies.csv
1
0
String

INPUTBOX
9
740
262
800
population-csv
/BasesDeDatos/DistribucionDemografica.csv
1
0
String

PLOT
1180
207
1445
395
Energy Independence Satisfaction
NIL
NIL
-1.0
1.0
0.0
3000.0
false
true
"" ""
PENS
"Accept" 0.05 0 -14439633 true "" "histogram [energy-independence-satisfaction-A] of humats"
"Importance" 0.05 1 -14454117 true "" "histogram [energy-independence-importance] of humats"
"Reject" 0.05 0 -5298144 true "" "histogram [energy-independence-satisfaction-B] of humats"

PLOT
1452
208
1716
397
Economic Sustainability Satisfaction
NIL
NIL
-1.0
1.0
0.0
3000.0
false
true
"" ""
PENS
"Accept" 0.05 0 -14439633 true "" "histogram [economic-sustainability-satisfaction-A] of humats"
"Importance" 0.05 1 -14454117 true "" "histogram [economic-sustainability-importance] of humats"
"Reject" 0.05 0 -5298144 true "" "histogram [economic-sustainability-satisfaction-B] of humats"

PLOT
1454
403
1715
590
Prestige Satisfaction
NIL
NIL
-1.0
1.0
0.0
3000.0
false
true
"" ""
PENS
"Accept" 0.05 0 -14439633 true "" "histogram [prestige-satisfaction-A] of humats"
"Importance" 0.05 1 -14454117 true "" "histogram [prestige-importance] of humats"
"Reject" 0.05 0 -5298144 true "" "histogram [prestige-satisfaction-B] of humats"

PLOT
1454
596
1716
783
Participation Satisfaction
NIL
NIL
-1.0
1.0
0.0
3500.0
false
true
"" ""
PENS
"Accept" 0.05 0 -14439633 true "" "histogram [participation-satisfaction-A] of humats"
"Importance" 0.05 1 -14454117 true "" "histogram [participation-importance] of humats"
"Reject" 0.05 0 -5298144 true "" "histogram [participation-satisfaction-B] of humats"

BUTTON
9
114
132
147
setup-landscape
setup-landscape
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
9
155
117
188
setup-citizens
setup-citizens
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
8
192
155
225
setup-social-network
setup-social-network
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
993
885
1179
918
TEMPORAL-DesvioCurva
TEMPORAL-DesvioCurva
0
1
0.2
0.01
1
NIL
HORIZONTAL

SWITCH
1719
15
1832
48
scenario-1
scenario-1
1
1
-1000

SWITCH
1720
60
1833
93
scenario-2
scenario-2
1
1
-1000

SWITCH
1720
105
1833
138
scenario-3
scenario-3
1
1
-1000

PLOT
1452
13
1715
200
Communications
NIL
NIL
0.0
10.0
0.0
600.0
true
false
"" ""
PENS
"Communication" 1.0 0 -16777216 true "" "if plot-highlight = 0 [\nset-plot-pen-color black\nplot (count humats with [inquiring = 1] + count humats with [signaling = 1] + count humats with [random-conv = 1] + count humats with [meeting-conv = 1])\n]\nif plot-highlight = 1 [\nset-plot-pen-color red\nplot (count humats with [inquiring = 1] + count humats with [signaling = 1] + count humats with [random-conv = 1] + count humats with [meeting-conv = 1])\n]"

SLIDER
1191
884
1396
917
TEMPORAL-DesvioCurvaPos
TEMPORAL-DesvioCurvaPos
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
663
890
835
923
norm-max
norm-max
0
1
0.8
0.01
1
NIL
HORIZONTAL

SWITCH
1720
146
1833
179
trust-event-flag
trust-event-flag
1
1
-1000

SLIDER
1721
188
1833
221
new-trust
new-trust
0
1
0.5
0.01
1
NIL
HORIZONTAL

INPUTBOX
10
807
90
867
run-number
100
1
0
String

SLIDER
1723
231
1895
264
scenario3-comm-prob
scenario3-comm-prob
0
1
0.05
0.01
1
NIL
HORIZONTAL

SLIDER
1723
273
1917
306
scenario3-comm-prob-late
scenario3-comm-prob-late
0
1
0.008388608000000004
0.01
1
NIL
HORIZONTAL

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

building institution
false
0
Rectangle -7500403 true true 0 60 300 270
Rectangle -16777216 true false 130 196 168 256
Rectangle -16777216 false false 0 255 300 270
Polygon -7500403 true true 0 60 150 15 300 60
Polygon -16777216 false false 0 60 150 15 300 60
Circle -1 true false 135 26 30
Circle -16777216 false false 135 25 30
Rectangle -16777216 false false 0 60 300 75
Rectangle -16777216 false false 218 75 255 90
Rectangle -16777216 false false 218 240 255 255
Rectangle -16777216 false false 224 90 249 240
Rectangle -16777216 false false 45 75 82 90
Rectangle -16777216 false false 45 240 82 255
Rectangle -16777216 false false 51 90 76 240
Rectangle -16777216 false false 90 240 127 255
Rectangle -16777216 false false 90 75 127 90
Rectangle -16777216 false false 96 90 121 240
Rectangle -16777216 false false 179 90 204 240
Rectangle -16777216 false false 173 75 210 90
Rectangle -16777216 false false 173 240 210 255
Rectangle -16777216 false false 269 90 294 240
Rectangle -16777216 false false 263 75 300 90
Rectangle -16777216 false false 263 240 300 255
Rectangle -16777216 false false 0 240 37 255
Rectangle -16777216 false false 6 90 31 240
Rectangle -16777216 false false 0 75 37 90
Line -16777216 false 112 260 184 260
Line -16777216 false 105 265 196 265

building store
false
0
Rectangle -7500403 true true 30 45 45 240
Rectangle -16777216 false false 30 45 45 165
Rectangle -7500403 true true 15 165 285 255
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 30 180 105 240
Rectangle -16777216 true false 195 180 270 240
Line -16777216 false 0 165 300 165
Polygon -7500403 true true 0 165 45 135 60 90 240 90 255 135 300 165
Rectangle -7500403 true true 0 0 75 45
Rectangle -16777216 false false 0 0 75 45

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

house colonial
false
0
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 45 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 60 195 105 240
Rectangle -16777216 true false 60 150 105 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Polygon -7500403 true true 30 135 285 135 240 90 75 90
Line -16777216 false 30 135 285 135
Line -16777216 false 255 105 285 135
Line -7500403 true 154 195 154 255
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 135 150 180 180

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
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Focalizado" repetitions="1" runMetricsEveryStep="true">
    <setup>setup-landscape
setup-citizens
setup-social-network
setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="norm-max">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-reach">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strategies-table">
      <value value="&quot;Focalizado.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TEMPORAL-DesvioCurvaPos">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-csv">
      <value value="&quot;/BasesDeDatos/DistribucionDemografica.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="critical-nodes-config">
      <value value="&quot;CriticalNodeHierro.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario-1">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TEMPORAL-DesvioCurva">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-event-flag">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario-2">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-trust">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="run-number">
      <value value="&quot;1&quot;"/>
      <value value="&quot;2&quot;"/>
      <value value="&quot;3&quot;"/>
      <value value="&quot;4&quot;"/>
      <value value="&quot;5&quot;"/>
      <value value="&quot;6&quot;"/>
      <value value="&quot;7&quot;"/>
      <value value="&quot;8&quot;"/>
      <value value="&quot;9&quot;"/>
      <value value="&quot;10&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario-3">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="All" repetitions="1" runMetricsEveryStep="true">
    <setup>setup-landscape
setup-citizens
setup-social-network
setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="norm-max">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-reach">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strategies-table">
      <value value="&quot;strategies.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TEMPORAL-DesvioCurvaPos">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-csv">
      <value value="&quot;/BasesDeDatos/DistribucionDemografica.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="critical-nodes-config">
      <value value="&quot;CriticalNodeHierro.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario-1">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TEMPORAL-DesvioCurva">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-event-flag">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario-2">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-trust">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="run-number">
      <value value="&quot;1&quot;"/>
      <value value="&quot;2&quot;"/>
      <value value="&quot;3&quot;"/>
      <value value="&quot;4&quot;"/>
      <value value="&quot;5&quot;"/>
      <value value="&quot;6&quot;"/>
      <value value="&quot;7&quot;"/>
      <value value="&quot;8&quot;"/>
      <value value="&quot;9&quot;"/>
      <value value="&quot;10&quot;"/>
      <value value="&quot;11&quot;"/>
      <value value="&quot;12&quot;"/>
      <value value="&quot;13&quot;"/>
      <value value="&quot;14&quot;"/>
      <value value="&quot;15&quot;"/>
      <value value="&quot;16&quot;"/>
      <value value="&quot;17&quot;"/>
      <value value="&quot;18&quot;"/>
      <value value="&quot;19&quot;"/>
      <value value="&quot;20&quot;"/>
      <value value="&quot;21&quot;"/>
      <value value="&quot;22&quot;"/>
      <value value="&quot;23&quot;"/>
      <value value="&quot;24&quot;"/>
      <value value="&quot;25&quot;"/>
      <value value="&quot;26&quot;"/>
      <value value="&quot;27&quot;"/>
      <value value="&quot;28&quot;"/>
      <value value="&quot;29&quot;"/>
      <value value="&quot;30&quot;"/>
      <value value="&quot;31&quot;"/>
      <value value="&quot;32&quot;"/>
      <value value="&quot;33&quot;"/>
      <value value="&quot;34&quot;"/>
      <value value="&quot;35&quot;"/>
      <value value="&quot;36&quot;"/>
      <value value="&quot;37&quot;"/>
      <value value="&quot;38&quot;"/>
      <value value="&quot;39&quot;"/>
      <value value="&quot;40&quot;"/>
      <value value="&quot;41&quot;"/>
      <value value="&quot;42&quot;"/>
      <value value="&quot;43&quot;"/>
      <value value="&quot;44&quot;"/>
      <value value="&quot;45&quot;"/>
      <value value="&quot;46&quot;"/>
      <value value="&quot;47&quot;"/>
      <value value="&quot;48&quot;"/>
      <value value="&quot;49&quot;"/>
      <value value="&quot;50&quot;"/>
      <value value="&quot;51&quot;"/>
      <value value="&quot;52&quot;"/>
      <value value="&quot;53&quot;"/>
      <value value="&quot;54&quot;"/>
      <value value="&quot;55&quot;"/>
      <value value="&quot;56&quot;"/>
      <value value="&quot;57&quot;"/>
      <value value="&quot;58&quot;"/>
      <value value="&quot;59&quot;"/>
      <value value="&quot;60&quot;"/>
      <value value="&quot;61&quot;"/>
      <value value="&quot;62&quot;"/>
      <value value="&quot;63&quot;"/>
      <value value="&quot;64&quot;"/>
      <value value="&quot;65&quot;"/>
      <value value="&quot;66&quot;"/>
      <value value="&quot;67&quot;"/>
      <value value="&quot;68&quot;"/>
      <value value="&quot;69&quot;"/>
      <value value="&quot;70&quot;"/>
      <value value="&quot;71&quot;"/>
      <value value="&quot;72&quot;"/>
      <value value="&quot;73&quot;"/>
      <value value="&quot;74&quot;"/>
      <value value="&quot;75&quot;"/>
      <value value="&quot;76&quot;"/>
      <value value="&quot;77&quot;"/>
      <value value="&quot;78&quot;"/>
      <value value="&quot;79&quot;"/>
      <value value="&quot;80&quot;"/>
      <value value="&quot;81&quot;"/>
      <value value="&quot;82&quot;"/>
      <value value="&quot;83&quot;"/>
      <value value="&quot;84&quot;"/>
      <value value="&quot;85&quot;"/>
      <value value="&quot;86&quot;"/>
      <value value="&quot;87&quot;"/>
      <value value="&quot;88&quot;"/>
      <value value="&quot;89&quot;"/>
      <value value="&quot;90&quot;"/>
      <value value="&quot;91&quot;"/>
      <value value="&quot;92&quot;"/>
      <value value="&quot;93&quot;"/>
      <value value="&quot;94&quot;"/>
      <value value="&quot;95&quot;"/>
      <value value="&quot;96&quot;"/>
      <value value="&quot;97&quot;"/>
      <value value="&quot;98&quot;"/>
      <value value="&quot;99&quot;"/>
      <value value="&quot;100&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario-3">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="scenario2" repetitions="1" runMetricsEveryStep="true">
    <setup>setup-landscape
setup-citizens
setup-social-network
setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="social-reach">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TEMPORAL-DesvioCurvaPos">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-csv">
      <value value="&quot;/BasesDeDatos/DistribucionDemografica.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario-1">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TEMPORAL-DesvioCurva">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario-2">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-trust">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario3-comm-prob">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="run-number">
      <value value="&quot;1&quot;"/>
      <value value="&quot;2&quot;"/>
      <value value="&quot;3&quot;"/>
      <value value="&quot;4&quot;"/>
      <value value="&quot;5&quot;"/>
      <value value="&quot;6&quot;"/>
      <value value="&quot;7&quot;"/>
      <value value="&quot;8&quot;"/>
      <value value="&quot;9&quot;"/>
      <value value="&quot;10&quot;"/>
      <value value="&quot;11&quot;"/>
      <value value="&quot;12&quot;"/>
      <value value="&quot;13&quot;"/>
      <value value="&quot;14&quot;"/>
      <value value="&quot;15&quot;"/>
      <value value="&quot;16&quot;"/>
      <value value="&quot;17&quot;"/>
      <value value="&quot;18&quot;"/>
      <value value="&quot;19&quot;"/>
      <value value="&quot;20&quot;"/>
      <value value="&quot;21&quot;"/>
      <value value="&quot;22&quot;"/>
      <value value="&quot;23&quot;"/>
      <value value="&quot;24&quot;"/>
      <value value="&quot;25&quot;"/>
      <value value="&quot;26&quot;"/>
      <value value="&quot;27&quot;"/>
      <value value="&quot;28&quot;"/>
      <value value="&quot;29&quot;"/>
      <value value="&quot;30&quot;"/>
      <value value="&quot;31&quot;"/>
      <value value="&quot;32&quot;"/>
      <value value="&quot;33&quot;"/>
      <value value="&quot;34&quot;"/>
      <value value="&quot;35&quot;"/>
      <value value="&quot;36&quot;"/>
      <value value="&quot;37&quot;"/>
      <value value="&quot;38&quot;"/>
      <value value="&quot;39&quot;"/>
      <value value="&quot;40&quot;"/>
      <value value="&quot;41&quot;"/>
      <value value="&quot;42&quot;"/>
      <value value="&quot;43&quot;"/>
      <value value="&quot;44&quot;"/>
      <value value="&quot;45&quot;"/>
      <value value="&quot;46&quot;"/>
      <value value="&quot;47&quot;"/>
      <value value="&quot;48&quot;"/>
      <value value="&quot;49&quot;"/>
      <value value="&quot;50&quot;"/>
      <value value="&quot;51&quot;"/>
      <value value="&quot;52&quot;"/>
      <value value="&quot;53&quot;"/>
      <value value="&quot;54&quot;"/>
      <value value="&quot;55&quot;"/>
      <value value="&quot;56&quot;"/>
      <value value="&quot;57&quot;"/>
      <value value="&quot;58&quot;"/>
      <value value="&quot;59&quot;"/>
      <value value="&quot;60&quot;"/>
      <value value="&quot;61&quot;"/>
      <value value="&quot;62&quot;"/>
      <value value="&quot;63&quot;"/>
      <value value="&quot;64&quot;"/>
      <value value="&quot;65&quot;"/>
      <value value="&quot;66&quot;"/>
      <value value="&quot;67&quot;"/>
      <value value="&quot;68&quot;"/>
      <value value="&quot;69&quot;"/>
      <value value="&quot;70&quot;"/>
      <value value="&quot;71&quot;"/>
      <value value="&quot;72&quot;"/>
      <value value="&quot;73&quot;"/>
      <value value="&quot;74&quot;"/>
      <value value="&quot;75&quot;"/>
      <value value="&quot;76&quot;"/>
      <value value="&quot;77&quot;"/>
      <value value="&quot;78&quot;"/>
      <value value="&quot;79&quot;"/>
      <value value="&quot;80&quot;"/>
      <value value="&quot;81&quot;"/>
      <value value="&quot;82&quot;"/>
      <value value="&quot;83&quot;"/>
      <value value="&quot;84&quot;"/>
      <value value="&quot;85&quot;"/>
      <value value="&quot;86&quot;"/>
      <value value="&quot;87&quot;"/>
      <value value="&quot;88&quot;"/>
      <value value="&quot;89&quot;"/>
      <value value="&quot;90&quot;"/>
      <value value="&quot;91&quot;"/>
      <value value="&quot;92&quot;"/>
      <value value="&quot;93&quot;"/>
      <value value="&quot;94&quot;"/>
      <value value="&quot;95&quot;"/>
      <value value="&quot;96&quot;"/>
      <value value="&quot;97&quot;"/>
      <value value="&quot;98&quot;"/>
      <value value="&quot;99&quot;"/>
      <value value="&quot;100&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario-3">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="norm-max">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strategies-table">
      <value value="&quot;strategies.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="critical-nodes-config">
      <value value="&quot;CriticalNodeHierro.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-event-flag">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario3-comm-prob-late">
      <value value="0.008388608000000004"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Sensibilidad" repetitions="1" runMetricsEveryStep="true">
    <setup>setup-landscape
setup-citizens
setup-social-network
setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="social-reach">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TEMPORAL-DesvioCurvaPos">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-csv">
      <value value="&quot;/BasesDeDatos/DistribucionDemografica.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario-1">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TEMPORAL-DesvioCurva">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario-2">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-trust">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario3-comm-prob">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="run-number">
      <value value="&quot;1&quot;"/>
      <value value="&quot;2&quot;"/>
      <value value="&quot;3&quot;"/>
      <value value="&quot;4&quot;"/>
      <value value="&quot;5&quot;"/>
      <value value="&quot;6&quot;"/>
      <value value="&quot;7&quot;"/>
      <value value="&quot;8&quot;"/>
      <value value="&quot;9&quot;"/>
      <value value="&quot;10&quot;"/>
      <value value="&quot;11&quot;"/>
      <value value="&quot;12&quot;"/>
      <value value="&quot;13&quot;"/>
      <value value="&quot;14&quot;"/>
      <value value="&quot;15&quot;"/>
      <value value="&quot;16&quot;"/>
      <value value="&quot;17&quot;"/>
      <value value="&quot;18&quot;"/>
      <value value="&quot;19&quot;"/>
      <value value="&quot;20&quot;"/>
      <value value="&quot;21&quot;"/>
      <value value="&quot;22&quot;"/>
      <value value="&quot;23&quot;"/>
      <value value="&quot;24&quot;"/>
      <value value="&quot;25&quot;"/>
      <value value="&quot;26&quot;"/>
      <value value="&quot;27&quot;"/>
      <value value="&quot;28&quot;"/>
      <value value="&quot;29&quot;"/>
      <value value="&quot;30&quot;"/>
      <value value="&quot;31&quot;"/>
      <value value="&quot;32&quot;"/>
      <value value="&quot;33&quot;"/>
      <value value="&quot;34&quot;"/>
      <value value="&quot;35&quot;"/>
      <value value="&quot;36&quot;"/>
      <value value="&quot;37&quot;"/>
      <value value="&quot;38&quot;"/>
      <value value="&quot;39&quot;"/>
      <value value="&quot;40&quot;"/>
      <value value="&quot;41&quot;"/>
      <value value="&quot;42&quot;"/>
      <value value="&quot;43&quot;"/>
      <value value="&quot;44&quot;"/>
      <value value="&quot;45&quot;"/>
      <value value="&quot;46&quot;"/>
      <value value="&quot;47&quot;"/>
      <value value="&quot;48&quot;"/>
      <value value="&quot;49&quot;"/>
      <value value="&quot;50&quot;"/>
      <value value="&quot;51&quot;"/>
      <value value="&quot;52&quot;"/>
      <value value="&quot;53&quot;"/>
      <value value="&quot;54&quot;"/>
      <value value="&quot;55&quot;"/>
      <value value="&quot;56&quot;"/>
      <value value="&quot;57&quot;"/>
      <value value="&quot;58&quot;"/>
      <value value="&quot;59&quot;"/>
      <value value="&quot;60&quot;"/>
      <value value="&quot;61&quot;"/>
      <value value="&quot;62&quot;"/>
      <value value="&quot;63&quot;"/>
      <value value="&quot;64&quot;"/>
      <value value="&quot;65&quot;"/>
      <value value="&quot;66&quot;"/>
      <value value="&quot;67&quot;"/>
      <value value="&quot;68&quot;"/>
      <value value="&quot;69&quot;"/>
      <value value="&quot;70&quot;"/>
      <value value="&quot;71&quot;"/>
      <value value="&quot;72&quot;"/>
      <value value="&quot;73&quot;"/>
      <value value="&quot;74&quot;"/>
      <value value="&quot;75&quot;"/>
      <value value="&quot;76&quot;"/>
      <value value="&quot;77&quot;"/>
      <value value="&quot;78&quot;"/>
      <value value="&quot;79&quot;"/>
      <value value="&quot;80&quot;"/>
      <value value="&quot;81&quot;"/>
      <value value="&quot;82&quot;"/>
      <value value="&quot;83&quot;"/>
      <value value="&quot;84&quot;"/>
      <value value="&quot;85&quot;"/>
      <value value="&quot;86&quot;"/>
      <value value="&quot;87&quot;"/>
      <value value="&quot;88&quot;"/>
      <value value="&quot;89&quot;"/>
      <value value="&quot;90&quot;"/>
      <value value="&quot;91&quot;"/>
      <value value="&quot;92&quot;"/>
      <value value="&quot;93&quot;"/>
      <value value="&quot;94&quot;"/>
      <value value="&quot;95&quot;"/>
      <value value="&quot;96&quot;"/>
      <value value="&quot;97&quot;"/>
      <value value="&quot;98&quot;"/>
      <value value="&quot;99&quot;"/>
      <value value="&quot;100&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="norm-max">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario-3">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strategies-table">
      <value value="&quot;strategies.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="critical-nodes-config">
      <value value="&quot;CriticalNodeHierro.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-event-flag">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario3-comm-prob-late">
      <value value="0.008388608000000004"/>
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
