extensions [ gis table csv array profiler cbr mgr ]

; A tick is one day.
; e.g. A household of disparate individuals can act a single agent with
; consistent and predictable response.

; Conventions
; ===========

; reporter and procedure parameter names are always prefixed with "some-"
; variables that are created from the context are prefixed with "this-"
; reported or variables suffixed by "?" will always contain booleans.


globals [
  DEBUG_LEVEL; Debug messages may be true or false.
  actual-hh-out ; actual household output file (modified using experiment name/no)
  actual-bus-out ; ditto for businesses
  actual-stats-out ; ditto for stats
  actual-nrg-out ; ditto for energy providers
  actual-consumption-out; ditto for the energy consumption
  energy-types; This will be "electric" "gas" "heat" (and "new-technology" in one scenario)
  possible-advisors; These are the list of agents from who advice may be sought
                   ; At the moment these might me:
                   ;   "me"
                   ;   "social"
                   ;   "neighbour"
                   ;   "work
                   ;   "school"
                   ;   "community"
                   ;   "bank"
                   ;   "landlord"
                   ;   "family"
                   ;   "advice"
                   ;   "national"
                   ;   "local"
                   ;   "energy"
  max-catchment; This is the biggest radius that the current patch grid
               ; can support. This is derived in setup.
  reach ; A table containing the reaches for a given network, if we are
        ; are using the Hamill and Gilbert network type.
        ; This is of the form [ i j k ... ] where i, j, k, ... are integer
        ; reaches. The key of the table is one of:
        ;    social
        ;    neighbour
  trust-values; A table that has "*" or the name of an agent as the key.
              ; If the key "*" this is a general trust metric for all
              ; agents. The value of the key is a selection of the agents
              ; found in "possible-advisors" above and the order is the
              ; relative order the named agent trusts those classes of
              ; advisors.
  ; See issue #087 for an explanation of this
  pipeline; The file containing the planned Aberdeen heat pipe network layer
  pipeline-pathname; The NetLogo GIS object containing the planned Aberdeen heat pipe network layer
  addresses; The NetLogo GIS object containing point addresses layer
  addresses-pathname; The file containing the point addresses
  streets; The road map NetLogo GIS layer object
  streets-pathname; The file containing the roads layer
  probability-of-city-wide-power-failure; Proability of city wide power failure for a single day
  probability-of-regional-power-failure; Proability of regional wide power failure for a single day
  probability-of-building-power-failure;  Proability of building power failure for a single day
  surveyed-values; A list of the questions that will be used to populate
                    ; the attitudes for either a household or person.
  population-values; a table, keyed on name of a series of values in order
                   ; of surveyed-values
  gis-dir; The data directory with all the GIS data - this may be relative or
         ; absolute
  banks-spec-dir; The data directory with all banks' specification data
  energy-providers-spec-dir; The data directory with all the energy-providers'
                           ; specifications
  landlords-spec-dir; Data directory with all the specifications for each of
  advisory-bodies-spec-dir; Data directory containing all the specifications
                          ; for the advisory agencies
  grant-bodies-spec-dir; Grant bodies specification directory
  employers-spec-dir; Data directory containing files for specification of
                    ; employers
  schools-spec-dir; ; Data directory with the specification for all the schools.
  msm-spec-dir; Data directory with the specification for main stream media
  social-media-spec-dir; Data directory with the specification for social media.
  community-organizations-spec-dir; Data directory will the specification for
                                  ; all the community-organizations.
  weather-spec-dir; Data directory containing files about the weather
  community-charge; table A - G with the current years community charge per
                  ; band
  business-rate; standard business rate
  absolute-humidity; A table using day of the year as offset giving mean
                   ; humidity for that day
                   ; MIN 0
                   ; MAX 100
  temperature; A table using day of the year as offset giving mean temperature
             ; for that day
  year; The year we are in.
  case-base-pool; The case from which intial case bases are set up.
  decision-contexts; the event that has stimulated the decision to consult the
                   ; case-base, may be one of:
                   ; "power-restored-after-regional-outage"
                   ; "power-restored-after-city-wide-outage"
                   ; "moved-in"
                   ; "repair"
                   ; "replace"
                   ; "awareness-raising-event"
                   ; "yearly-maintenance"
                   ; "clean-install"
                   ; "connection"
                   ; "street-voting"
  possible-decisions; the possible decisions that a household can make. May be
                    ;one of:
                    ; "install"; install central heating - this includes
                    ;  upgrading the heating system after need for replacement
                    ;  due to break-down
                    ; "abandon"
                    ; "repair"
                    ; "get-advice"
                    ; "follow-advice"
  decision-record ; table recording outcome of consult-on? each tick
  street-vote-record ; list of [ n-voted n-for ] for each street voted this tick
  nof-streets-voted-to-join; total of streets that have voted to join
  schedule-for-new-builds; A table indexed by year containing tables indexed by
                         ; day-of-year and a GIS file
  schedule-for-laying-pipes; A table indexed by year containing tables indexed
                           ; by day-of-year and a GIS file
  energy-ratings ; A table, indexed by post-code containing the energy ratings
                 ; for all properties in Aberdeen
  council-taxes ; A table, indexed by post-code containing the energy ratings
                ; for all properties in Aberdeen
  household-pool ; Pre-defined households.
  household-postcodes; A list of household names keyed on postcode - this allows
                     ; different households at the same postcode.
  seed ;table, indexed on network type of a seed for the networks that need them
  family-dynamics; list of the possible family dynamics - I have made these up.
                 ; these need some serious research.
  setup?         ; Are we setting up (true) or going (false)
  nof-cannot-pay-bill; The number of people who have not paid their bill.
  annual-units-consumed; Number of units consumed on a year basis
  lowest-profit-%
  highest-profit-%
  mean-profit-%
]

breed [ nexuses nexus ]

breed [ heat-pipes heat-pipe ]

breed [ buildings building ]

buildings-own [

  ; something simple ( a relationship to the household ) that tells us how much
  ; energy is needed to heat the house given the weather the weather say an
  ; anonymous function that returns temperature for energy-input.

  street-name; The street on which the building resides - this should
                      ; be provided by the GIS data.
  postcode; The postcode on which the building resides - this should
          ; be provided by the GIS data.
  nof-households; number of flats, or 1 if this is a house
  energy-rating; This can be A-G - A being the best
  has?; a table of booleans keyed by energy-type - these being currently
      ;  "electric" "gas" and "heat"
  council-tax-band; This is used to calculate the monthly council tax
                  ; This could be done at a household level, but we don't
                  ; go down to that granularity
  building-fuel-poverty; This is an aggregate of all the households in that
                       ; building:
                       ;    0 - no fuel poverty
                       ;    1 - fuel poverty
                       ;    2 - extreme fuel poverty
]

breed [ persons person ]

persons-own [

  age; the person's age in the range [0-81]

  sex; male or female

  ethnicity; All kinds of complications introduced here, based on probabilities, which
           ; will be set in the interface

  case-base; a person's case base for making decisions

  heuristic-type; alternative to cbr, may be "innovator", "early-adopter", "majority" or "laggard"
  adoption-likelihood-threshold; if you are in the majority, how likely it is to adopt the heating.


  recommendations; a table of recommendation this person has made to
                 ; others. This is in the range [0,1].

  degree; the number of degrees of connection this person should have

  name; A name for acessing loaded data values

  trust; A list containing trust values. This is a ranking
       ; over the valid classes. If a class does not appear
       ; then the agent does not trust it at all.

  income; Approximate monthly income

  ongoing-costs; Approximate monthly outgoings excluding energy, rent or
               ; mortgage

  hours-away-from-household; A holder to calculate how many hours the heating
                           ; will not be used (presuming of course it is off,
                           ; whilst members of the household are out.)

  ; Attitudes table - orignally I had these broken down into separate variable,
  ; but this is going to be too difficult to maintain, so I am going with a
  ; table. This will be used to populate the case base "state".

  on-benefits?; this affects how income is generated, if random.

  attitude

  ; The table currently contains the following:

  ; age
  ; sex

  ; Q7. Level of education
  ; Q15. In your daily life- how often do you do the following things? [i. Travel by bus]
  ; Q15. In your daily life- how often do you do the following things? [ii. Travel by bike]
  ; Q15. In your daily life- how often do you do the following things? [iii. Travel by car]
  ; Q15. In your daily life- how often do you do the following things? [iv. Travel by train]
  ; Q15. In your daily life- how often do you do the following things? [v. Travel on foot]
  ; Q16. In your daily life- how often do you do the following things? [i. Participate in community meetings or events]
  ; Q16. In your daily life- how often do you do the following things? [ii. Switch off heating unless i really need it ]
  ; Q16. In your daily life- how often do you do the following things? [iii. Switch off electrical appliances that are not being used]
  ; Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [i. My heating bills have increased]
  ; Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [ii. could afford to keep my home warm]
  ; Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [iii. I have had to choose between keeping my home warm and buying food or essentials for myself or my family]
  ; Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [iv. My heating system was able to keep my home warm]
  ; Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [v. My house sometimes felt uncomfortably cold in the winter]
  ; Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [vi. Insulation was installed in my home]
  ; Q20. How likely are you to join the district heating scheme- if it becomes available in your area?
  ; Q23. How important are the following factors to you? [i. My health]
  ; Q23. How important are the following factors to you? [ii. My quality of life]
  ; Q23. How important are the following factors to you? [iii. The warmth of my home]
  ; Q23. How important are the following factors to you? [iv. Reliability of my household’s energy supply]
  ; Q23. How important are the following factors to you? [v. The quality of my accommodation]
  ; Q23. How important are the following factors to you? [vi. My financial security]
  ; Q24. How concerned are you about the following? [i. Energy being too expensive for many people in Aberdeen]
  ; Q24. How concerned are you about the following? [ii. Aberdeen being too dependent on fossil fuels such as oil and gas. ]
  ; Q24. How concerned are you about the following? [iii. Climate change]
  ; Q24. How concerned are you about the following? [iv. Power cuts in Aberdeen]
  ; Q25. How important are the following factors to you? [i. Living in a society where everyone has the same opportunities to use energy for their needs.]
  ; Q25. How important are the following factors to you? [ii. Being part of a community that is working together]
  ; Q25. How important are the following factors to you? [iii. Being involved in decisions that affect my local area]
  ; Q25. How important are the following factors to you? [iv. Availability of transparent information from Aberdeen City Council]
  ; Q25. How important are the following factors to you? [v. Having opportunities to communicate with Aberdeen City Council]
  ; Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [i. Protecting society’s weak and vulnerable members is important to him/her]
  ; Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [ii. Tradition is important to her/him. she/he triesto follow the customs handed down by family or religion]
  ; Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [iii. He/she thinks it is important to do lots of different things in life- and is always looking for new things to do]
  ; Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [iv. Being very successful is important to her/him. She/he hopes that their achievements are recognised by people]
  ; Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [v. He/she seeks every chance to have fun. Having a good time is important to him/her]

  ; So we will have a table with a key of "Q"question(-sub-question)?) against a value.
  ; So the attitudes file will have the following:

  ; Name, Q7, Q15-1, Q15-2, ..., Q26-4

]

breed [ households household ]

households-own [

  name; A name for acessing loaded data values

  trust; A list containing trust values. This is a ranking
       ; over the valid classes. If a class does not appear
       ; then the agent does not trust it at all.


  degree; the number of degrees of connection this household should have

  case-base; a household case base for making decisions

  heuristic-type; alternative to cbr, may be "innovator", "early-adopter", "majority" or "laggard"
  adoption-likelihood-threshold; if you are in the majority, how likely it is to adopt the heating.

  recommendations; a table of recommendation this household has made to
                 ; others. This is in the range [0,1].

  dynamic; how a family is organized and pertains to how a household
         ; arrrives at a decision.

  ethnicity; All kinds of complications introduced here, based on probabilities, which
           ; will be set in the interface


  wants-to-join? ; If they vote to join a heatnetwork then they bloody well will!

  ; Finances

  income; Approximate monthly income
  owns-property?
  owns-outright?
  ongoing-costs; Approximate monthly outgoings excluding energy, rent or
               ; mortgage
  balance; available money

  ; The following is because there may well be multiple links to the same
  ; institution for differing payments. The key is the same across all 3
  ; payment tables and consists of the agent-name concatenated with the
  ; purpose - this is reasonably unique, but not entirely so be careful.
  payment-for; a table with the above key against
             ; what it pays for, e.g this could be for "mortgage",
             ; "electricty", "gas", "heat" or "electricity."
  payment-to; a table with the above key against whom it is paid,
            ; for example "Aberdeen Heat and Power"
  payment-name; a table with the above key against the institution's
              ; name for the payment. For instance, this might be
              ; "daily tariff"

  ; Energy consumption

  ; The status of the household heating may be one of the following:

  ;      "working"
  ;      "replace"
  ;      "repair"
  ;      "building-failure"
  ;      "regional-failure"
  ;      "city-wide-failure"

  heating-status
  heating-system; may be one of "electric", "gas", if uses-heat-network true
                ; then this must be "heat"
  heating-system-age; age in ticks of the heating system.
  boiler-size; This is in the range 16-42 Kw/h
             ; https://www.boilerguide.co.uk/articles/what-size-boiler-needed
  air-conditioner-size ; TODO and initialise this in load a household
                       ; factor this into energy expenditure calculations.
  last-energy-provider; If this doesn't change then might indicates some kind
                      ; of trust.
  min-units-of-energy-per-day; baseline number of units that a household uses,
                             ; and this is purely electrical energy. This is
                             ; for stuff like lights, TV, fridges, etc.
  units-of-energy-used; a table keyed on one of "electric", "heat" or "gas"
                      ; zeroised after payment a table containing the household
                      ; name for the payment against to whom it is paid
  max-units-of-energy-per-day; maximum units that a household can use, based on balance
  rent-includes?; a table keyed on one of "electric", "heat" or "gas";
                ; indicates whether cost of heating included in rent
  uses?; a table keyed on one of "electric", "heat" or "gas"; indicates whether
       ; this house uses that type of energy
  contract-expires ; the tick that the household can switch
  requires-maintenance?; a table keyed on one of "electric", "heat" or "gas";
                       ; indicatcdes whether yearly maintenance is required for
                       ; the system.
  serviced?; a table keyed on one of "electric", "heat" or "gas" indicates
           ; whether yearly maintenance has taken place.

  hours-away-from-household; A holder to calculate how many hours the heating
                           ; will not be used (presuming of course it is off,
                           ; whilst members of the household are out.)

  ; Household energy costs

  last-bill; This is the sum of the last bill paid, or zero
  fuel-poverty; How much of the income of the household is spent on energy.
              ; This is a number in the range [0,1]
  history-of-fuel-poverty; Whenever fuel-poverty is calculated the old value
                         ; will be stored here
  current-temperature; the temperature of the household
  money-spent; Money spent so far this month
  history-of-temperature; records the temperature each time a bill is paid or not paid
  history-of-units-used-for-heating; record of the monthly units used

  monthly-fuel-payment ; Sum of payments paid this month
  switched-heating-off? ; Did they switch off the heating to save money

  ; Attitudes table - orignally I had these broken down into separate variable,
  ; but this is going to be too difficult to maintain, so I am going with a
  ; table. This will be used to populate the case base "state".


  attitude

  ; The table currently contains the following:

  ; Q7. Level of education
  ; Q15. In your daily life- how often do you do the following things? [i. Travel by bus]
  ; Q15. In your daily life- how often do you do the following things? [ii. Travel by bike]
  ; Q15. In your daily life- how often do you do the following things? [iii. Travel by car]
  ; Q15. In your daily life- how often do you do the following things? [iv. Travel by train]
  ; Q15. In your daily life- how often do you do the following things? [v. Travel on foot]
  ; Q16. In your daily life- how often do you do the following things? [i. Participate in community meetings or events]
  ; Q16. In your daily life- how often do you do the following things? [ii. Switch off heating unless i really need it ]
  ; Q16. In your daily life- how often do you do the following things? [iii. Switch off electrical appliances that are not being used]
  ; Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [i. My heating bills have increased]
  ; Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [ii. could afford to keep my home warm]
  ; Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [iii. I have had to choose between keeping my home warm and buying food or essentials for myself or my family]
  ; Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [iv. My heating system was able to keep my home warm]
  ; Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [v. My house sometimes felt uncomfortably cold in the winter]
  ; Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [vi. Insulation was installed in my home]
  ; Q20. How likely are you to join the district heating scheme- if it becomes available in your area?
  ; Q23. How important are the following factors to you? [i. My health]
  ; Q23. How important are the following factors to you? [ii. My quality of life]
  ; Q23. How important are the following factors to you? [iii. The warmth of my home]
  ; Q23. How important are the following factors to you? [iv. Reliability of my household’s energy supply]
  ; Q23. How important are the following factors to you? [v. The quality of my accommodation]
  ; Q23. How important are the following factors to you? [vi. My financial security]
  ; Q24. How concerned are you about the following? [i. Energy being too expensive for many people in Aberdeen]
  ; Q24. How concerned are you about the following? [ii. Aberdeen being too dependent on fossil fuels such as oil and gas. ]
  ; Q24. How concerned are you about the following? [iii. Climate change]
  ; Q24. How concerned are you about the following? [iv. Power cuts in Aberdeen]
  ; Q25. How important are the following factors to you? [i. Living in a society where everyone has the same opportunities to use energy for their needs.]
  ; Q25. How important are the following factors to you? [ii. Being part of a community that is working together]
  ; Q25. How important are the following factors to you? [iii. Being involved in decisions that affect my local area]
  ; Q25. How important are the following factors to you? [iv. Availability of transparent information from Aberdeen City Council]
  ; Q25. How important are the following factors to you? [v. Having opportunities to communicate with Aberdeen City Council]
  ; Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [i. Protecting society’s weak and vulnerable members is important to him/her]
  ; Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [ii. Tradition is important to her/him. she/he triesto follow the customs handed down by family or religion]
  ; Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [iii. He/she thinks it is important to do lots of different things in life- and is always looking for new things to do]
  ; Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [iv. Being very successful is important to her/him. She/he hopes that their achievements are recognised by people]
  ; Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [v. He/she seeks every chance to have fun. Having a good time is important to him/her]

  ; So we will have a table with a key of "Q"question(-sub-question)?) against a value.
  ; So the attitudes file will have the following:

  ; Name, Q7, Q15-1, Q15-2, ..., Q26-4
]

breed [ msms msm ]

msms-own [

  ; This will connect as a star to either every household or person.

  name; A unique identifier for disambiguation in reports

  organization-type; may be national or local

  case-base; The main-stream media's case base for making decisions

  recommendations; a table of recommendation the msm has made to
                 ; others. This is in the range [0,1].
]

breed [ businesses business ]

businesses-own [
  name; A unique identifier for disambiguation in reports

  case-base; a business's case base for making decisions

  recommendations; a table of recommendation this business has made to
                 ; others. This is in the range [0,1].

  uses? ; a table keyed on one of "electric", "heat" or "gas"; indicates
        ; whether this business uses that type of energy
  min-electrical-units-of-energy-per-day; This is the minimum energy that the
                                        ; business uses each day
  units-of-energy-per-day-for-heating; This is the amount the business uses for
                                     ; heating.
  units-of-energy-used; a table keyed on one of "electric", "heat" or "gas";
                      ; zeroised after payment

  ; The following is because there may well be multiple links to the same
  ; institution for differing payments
  payment-for; a table containing the household name for the payment against
             ; what it pays for
  payment-to; a table containing the household name for the payment against to
            ; whom it is paid
  payment-name; a table containing the household name for the payment against
              ; to what the paid institution calls it
  rateable-value; used to calculate yearly business rates
  heating-system; What kind of heating is used by the business
  last-bill;
  balance;
]

; { business | household } -> building

directed-link-breed [ residents resident ]

breed [ banks bank ]

banks-own [
  name; A unique identifier for disambiguation in reports

  case-base; a banks's case base for making decisions

  recommendations; a table of recommendation this bank has made to
                 ; others.. This is in the range [0,1].

  ; The following are all tables, keyed on a payment-name.
  purpose; what the bank is making the loan for
  principal; how much the loan is - this is for home improvements such as
           ; heat-network installation
  payment ; table of loan-name against: repayment
  frequency; how often the repayment is made:  can be daily, weekly, monthly,
           ; quaterly or yearly.
  nof-payments; table of loan-name against: time period over which the amount
              ; must be paid
]

breed [ landlords landlord ]

landlords-own [
  name; A unique identifier for disambiguation in reports

  case-base; a landlords's case base for making decisions

  private?; whether is this a public landlord (like the council) or private

  recommendations; a table of recommendation this landlord has made to
                 ; others. This is in the range [0,1].

  ; The following are all tables, keyed on a rent-name.

  rent; table of rent type against name and payment
  frequency; table of rent type against how often rentee pays:
]

breed [energy-providers energy-provider ]

energy-providers-own [
  name; A unique identifier for disambiguation in reports

  case-base; an energy provider's case base for making decisions

  recommendations; a table of recommendation this energy-provider has made to
                 ; others.. This is in the range [0,1].


  profitability; the current balance for the energy provider
  profits; historical profits

  daily-income
  daily-outgoings
  overhead

  ; The following are all tables, keyed on a tariff-name.

  retail-unit-cost; table of tariff against: how much it costs the customer
  wholesale-unit-cost; table of tariff against: how much it costs the suppplier
  frequency; period for which the customer is billed: can be daily, weekly,
           ; monthly, quarterly or yearly.
  energy-type; table of tariff against: energy-type - maybe gas, electric or
             ; heat
  standing-charge; table of tariff against: standing charge
  disconnection-cost; table of tariff against: one off disconnection cost
  installation-cost; table of tariff against: one-off connection cost
  yearly-maintenance; table of tariff against: yearly-maintenancve
  ; Used to have the following, but feel this is just complicating things a bit
  ; much - you would need some method by which to move the tariffs - it is something
  ; to think about, and would be done in the events section, but for the period
  ; we are thinking of running the  model for, over 10 years, then I am going to
  ; take a punt and say these do not matter.
  ; next-tariff; table of tariff against:
  ; period-of-tariff; table of tariff against: in ticks
  ; Similarly for disruption - I originally thought I would feed this
  ; into the case base selection, but getting the data is hard. amd
  ; calibrating it would be even worse. So the better part of valour
  ; and all that...
  ; disruption; disruption level when installing the heating system.
]

breed [ grant-bodies grant-body ]

grant-bodies-own [
  name; A unique identifier for disambiguation in reports

  case-base; a grant body's case base for making decisions

  recommendations; a table of recommendation this grant-body has made to
                 ; others. This is in the range [0,1].

  energy-type; may be "gas", "electric", "heat" or "insulation"
  amount; the grant amount
  maximum-income; A top amount for income and then not eligible.
  x-locus; The next 3 limit the geographic scope of the grant
  y-locus
  radius
]

breed [ advisory-bodies advisory-body ]

advisory-bodies-own [
  name; A unique identifier for disambiguation in reports

  case-base; an advisory body's case base for making decisions

  recommendations; a table of recommendation this advisory-body has made to
                 ; others. This is in the range [0,1].

  ;TODO all the below can go into the case base.

  action;  a table with the advice name as index: will be something like
        ; install gas, heat-network, or get loan
  energy-type; a table with the advice name as index: this may electric, gas,
             ; heat-network etc.
  recommended-institution; points at the institution where you can get the
                         ; grant or loan. Done this way because NetLogo cannot
                         ; cope with mutliple links between objects.
  finance; a table indicating what kind of finance this is - it is either a
         ; loan or a grant.
  calendar; a table with the advice name as index: when awareness raising
          ; takes place - these are day of the year
  x-locus; the x-coordinate of centre of the awareness event;
  y-locus; the x-coordinate of centre of the awareness event;
  radius; the radius in which awareness is being raised, if this is <= 0 then
        ; it is global
]

breed [ institutions institution ]

institutions-own [
  name; A unique identifier for disambiguation in reports

  organization-type; may be school, work or community-organization

  case-base; an institutions's case base for making decisions

  recommendations; a table of recommendation this institution has made to
                 ; others.. This is in the range [0,1].

  catchment-radius; for schools and community-organizations - you have to live
                  ;in the catchment area to attend.
  calendar; mod these with 7 to get the day of the week
  fixed-holidays; fixed holidays for an institution
  floating-holidays; number of holidays a person who works at this institution
                   ; has
  probability-of-attendance; sicky likely in the range [0,1]
  working-from-home; the number of hours somebody at
                         ; this institution works from home
]

breed [ associations association ]

associations-own [
  surcharge
  payment-is-to
  payment-name
  payment-frequency
]

directed-link-breed [ associates associate ]

; Goes from building -> { instution of type landlord | household | business } }

directed-link-breed [ properties-of property-of ]

; Knowledge network

directed-link-breed [ knows know ]

knows-own [
  network; maybe "family" "neighbor" "work" "school" "community" "advice" "social"
  ethnic-group; if ethnicity switched on then you will only be allowed join a social network if you are of the same ethnicity, unless the

]

; This indicates whether a person attends an institution.

directed-link-breed [ all-attends attends ]

all-attends-own [
  holidays-used
]

; Geographic stuff.

breed [ roads road ]

roads-own [
  name; The road the patch is on
  my-patches
  voted?; Whether buildings on a patch have voted or not
  last-voted; when the road last voted for pipe.
  near-heat-network?
]

patches-own [
  my-roads
  pipe-present?; Indicates if a pipe passes through this place
  pipe-possible?; Is pipe allowed on this patch. This is either an intersection
               ; with an existing pipe GIS file or it must be a street.
  junction? ; Is the patch a junction between streets
]

directed-link-breed [members-of member-of]

undirected-link-breed [ pipes  pipe ]

; SMARTEES colours for reference:
; Existing network - #732600
; Potential network - #E69800
; Infrastructure (roads) - #D1D1D1

; {observer|ad-hoc} setup

to setup

  clear-all
  msg "setup: start -- clearing everything and calling GIS"
  profiler:start
  reset-timer
  set setup? true
  set nof-streets-voted-to-join 0
  set nof-cannot-pay-bill 0
  set annual-units-consumed 0
  ifelse display-gis? [
    gis ; This used to be in the setup button and in the experiment, but is now here instead as clear-all is used rather than selective clearing
  ]
  [
    ask patches [set pcolor white]
    if pipe-possible-input-output-file = "" or not file-exists? pipe-possible-input-output-file [
      err (word "No GIS set and no pipe input file: " pipe-possible-input-output-file)
    ]
    input-possible-pipe-line
    if roads-input-output-file = "" or not file-exists? roads-input-output-file [
      err (word "No GIS set and no roads input file: " roads-input-output-file)
    ]
    input-roads
  ]

  ifelse behaviorspace-run-number > 0 [
    set actual-hh-out ifelse-value (household-output = "") [""] [
      (word behaviorspace-experiment-name "-" behaviorspace-run-number "-" household-output)
    ]
    set actual-nrg-out ifelse-value (energy-provider-output-file = "") [""] [
      (word behaviorspace-experiment-name "-" behaviorspace-run-number "-" energy-provider-output-file)
    ]
    set actual-stats-out ifelse-value (stats-output-file = "") [""] [
      (word behaviorspace-experiment-name "-" behaviorspace-run-number "-" stats-output-file)
    ]
    set actual-bus-out ifelse-value (business-output = "") [""] [
      (word behaviorspace-experiment-name "-" behaviorspace-run-number "-" business-output)
    ]
    set actual-consumption-out ifelse-value (consumption-output = "") [""] [
      (word behaviorspace-experiment-name "-" behaviorspace-run-number "-" consumption-output)
    ]
  ] [
    set actual-hh-out household-output
    set actual-nrg-out energy-provider-output-file
    set actual-stats-out stats-output-file
    set actual-bus-out business-output
    set actual-consumption-out consumption-output
  ]

  ; See issue #087 for an explanation of this
  set probability-of-city-wide-power-failure (( 0.08 / 365 ) ^ 106000)
  set probability-of-regional-power-failure ( 0.08 / 365 ) ^ 15
  set probability-of-building-power-failure ( 0.08 / 365 ) ^ ( 208000 / 106000)

  set possible-advisors [
    "me"
    "social"
    "neighbour"
    "work"
    "school"
    "community"
    "bank"
    "landlord"
    "family"
    "advice"
    "national"
    "local"
    "energy"
  ]

  set DEBUG_LEVEL "full"

  set energy-types ["heat" "electric" "gas"]
  ; Q7. Level of education
  ; Q15. In your daily life- how often do you do the following things? [i. Travel by bus]
  ; Q15. In your daily life- how often do you do the following things? [ii. Travel by bike]
  ; Q15. In your daily life- how often do you do the following things? [iii. Travel by car]
  ; Q15. In your daily life- how often do you do the following things? [iv. Travel by train]
  ; Q15. In your daily life- how often do you do the following things? [v. Travel on foot]
  ; Q16. In your daily life- how often do you do the following things? [i. Participate in community meetings or events]
  ; Q16. In your daily life- how often do you do the following things? [ii. Switch off heating unless i really need it ]
  ; Q16. In your daily life- how often do you do the following things? [iii. Switch off electrical appliances that are not being used]
  ; Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [i. My heating bills have increased]
  ; Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [ii. could afford to keep my home warm]
  ; Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [iii. I have had to choose between keeping my home warm and buying food or essentials for myself or my family]
  ; Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [iv. My heating system was able to keep my home warm]
  ; Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [v. My house sometimes felt uncomfortably cold in the winter]
  ; Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [vi. Insulation was installed in my home]
  ; Q20. How likely are you to join the district heating scheme- if it becomes available in your area?
  ; Q23. How important are the following factors to you? [i. My health]
  ; Q23. How important are the following factors to you? [ii. My quality of life]
  ; Q23. How important are the following factors to you? [iii. The warmth of my home]
  ; Q23. How important are the following factors to you? [iv. Reliability of my household’s energy supply]
  ; Q23. How important are the following factors to you? [v. The quality of my accommodation]
  ; Q23. How important are the following factors to you? [vi. My financial security]
  ; Q24. How concerned are you about the following? [i. Energy being too expensive for many people in Aberdeen]
  ; Q24. How concerned are you about the following? [ii. Aberdeen being too dependent on fossil fuels such as oil and gas. ]
  ; Q24. How concerned are you about the following? [iii. Climate change]
  ; Q24. How concerned are you about the following? [iv. Power cuts in Aberdeen]
  ; Q25. How important are the following factors to you? [i. Living in a society where everyone has the same opportunities to use energy for their needs.]
  ; Q25. How important are the following factors to you? [ii. Being part of a community that is working together]
  ; Q25. How important are the following factors to you? [iii. Being involved in decisions that affect my local area]
  ; Q25. How important are the following factors to you? [iv. Availability of transparent information from Aberdeen City Council]
  ; Q25. How important are the following factors to you? [v. Having opportunities to communicate with Aberdeen City Council]
  ; Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [i. Protecting society’s weak and vulnerable members is important to him/her]
  ; Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [ii. Tradition is important to her/him. she/he triesto follow the customs handed down by family or religion]
  ; Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [iii. He/she thinks it is important to do lots of different things in life- and is always looking for new things to do]
  ; Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [iv. Being very successful is important to her/him. She/he hopes that their achievements are recognised by people]
  ; Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [v. He/she seeks every chance to have fun. Having a good time is important to him/her]

  set surveyed-values [
    "Q7"
    "Q15-1"
    "Q15-2"
    "Q15-3"
    "Q15-4"
    "Q15-5"
    "Q16-1"
    "Q16-2"
    "Q16-3"
    "Q19-1"
    "Q19-2"
    "Q19-3"
    "Q19-4"
    "Q19-5"
    "Q19-6"
    "Q20"
    "Q23-1"
    "Q23-2"
    "Q23-3"
    "Q23-4"
    "Q23-5"
    "Q23-6"
    "Q24-1"
    "Q24-2"
    "Q24-3"
    "Q24-4"
    "Q25-1"
    "Q25-2"
    "Q25-3"
    "Q25-4"
    "Q25-5"
    "Q26-1"
    "Q26-2"
    "Q26-3"
    "Q26-4"
    "Q26-5"
  ]
  set family-dynamics []
  if all-adults? [
    set family-dynamics lput "all-adults" family-dynamics
  ]
  if matriarchal? [
    set family-dynamics lput "matriarchal" family-dynamics
  ]
  if patriarchal? [
    set family-dynamics lput "patriarchal" family-dynamics
  ]
  if random? [
    set family-dynamics lput "random" family-dynamics
  ]
  if whole-family? [
    set family-dynamics lput "household" family-dynamics
  ]

  if resolution = "person" and length family-dynamics = 0 [
    set family-dynamics one-of [ "all-adults" "matriarchal" "patriarchal" "random" "household" ]
    warn "No family dynamics selected for person resolution"
  ]

  set max-catchment random sqrt ((max-pxcor - min-pxcor) ^ 2 + (max-pycor - min-pycor) ^ 2)

  set population-values table:make
  set year start-year

  ; Directories

  set banks-spec-dir "data/banks"
  set energy-providers-spec-dir "data/energy-providers"
  set landlords-spec-dir "data/landlords"
  set advisory-bodies-spec-dir "data/advisory-bodies"
  set grant-bodies-spec-dir "data/grant-bodies"
  set community-organizations-spec-dir "data/community-organizations"
  set schools-spec-dir "data/employers"
  set employers-spec-dir "data/schools"
  set weather-spec-dir "data/weather"
  set gis-dir "data/gis"

  ; Weather
  ; =======

  update-weather (word weather-spec-dir "/" "weather.initial.csv")

  ; We have to load the energy providers because these provide the range
  ; on the energy providers for get-affordability

  load-an-energy-provider-from-a-file "energy_company_1"
  load-an-energy-provider-from-a-file "energy_company_2"
  load-an-energy-provider-from-a-file "energy_company_3"
  load-an-energy-provider-from-a-file "energy_company_4"
  load-an-energy-provider-from-a-file "energy_company_5"
  load-an-energy-provider-from-a-file "energy_company_6"
  ifelse extent = "Timisoara" [
    load-an-energy-provider-from-a-file "Colterm"
  ]
  [
    load-an-energy-provider-from-a-file "AHP"
    load-an-energy-provider-from-a-file "DEAL"
  ]


  ; Load trust which must contain a default, if it is being used.

  load-trust-from-a-file

  ; Get energy ratings
  ; ==================

  load-energy-ratings-from-a-file

  ; Get council taxes
  ; =================

  load-council-taxes-from-a-file

  ; Create some institutions
  ; ========================

  load-a-bank-from-a-file "Bank 1"
  load-a-bank-from-a-file "Bank 2"

  load-a-landlord-from-a-file "Private Landlord" true


 if extent != "Timisoara" [
    load-a-landlord-from-a-file "Aberdeen Council" false
    load-a-landlord-from-a-file "Housing Association" false
    load-a-grant-body-from-a-file "Aberdeen Council"

    load-an-advisory-body-from-a-file "SCARF"
    ;load-an-advisory-body-from-a-file "Scottish Government"
    ;load-an-advisory-body-from-a-file "Dementia Charity"
    ;load-an-advisory-body-from-a-file "Social Worker"
  ]

  foreach n-values (nof-employers) [ i -> (word "employer-" i) ] [
    company-name ->
    let data-pathname (word employers-spec-dir "/" company-name ".csv")
    ifelse file-exists? data-pathname [
      load-an-institution-from-a-file company-name "work"
    ]
    [
      create-a-random-institution company-name "work"
    ]
  ]

  foreach n-values nof-community-organizations [
    i -> (word "community-organization-" i) ] [
    community-organization-name ->
    let data-pathname (word community-organizations-spec-dir "/"
      community-organization-name ".csv")
    ifelse file-exists? data-pathname [
      load-an-institution-from-a-file community-organization-name "community"
    ]
    [
      create-a-random-institution community-organization-name "community"
    ]
  ]

  foreach n-values nof-schools [ i -> (word "school-" i) ] [
    school-name ->
    let data-pathname (word schools-spec-dir "/" school-name ".csv")
    ifelse file-exists? data-pathname [
      load-an-institution-from-a-file data-pathname "school"
    ]
    [
      create-a-random-institution school-name "school"
    ]
  ]

  if use-cbr? [

    ; Case Base
    ; =========

    debug "building a case pool..."

    set case-base-pool []

    ; TODO - needs to be done in the validation of cbr:new

    set decision-contexts [
      "power-restored-after-regional-outage"
      "power-restored-after-city-wide-outage"
      "moved-in"
      "repair"
      "replace"
      "awareness-raising-event"
      "yearly-maintenance"
      "clean-install"
      "connection"
      "street-voting"
    ]

    set possible-decisions [
      "install"; install central heating - this includes upgrading the heating
               ; system after need for replacement due to break-down
      "abandon"
      "repair"
      "get-advice"
      "follow-advice"
    ]

    if initial-case-base-file != "" and
    file-exists? initial-case-base-file [
      load-cases-from-a-file
      initial-case-base-file
    ]
    create-random-cases

    ; Populate the case base for the various aegencies

    ask (turtle-set
      energy-providers
      banks
      landlords
      institutions
      grant-bodies
      advisory-bodies) [
      foreach case-base-pool [ case ->
        if table:get case "name"  = name [
          let ignore cbr:add case-base
          table:get case "state"
          table:get case "decision"
          table:get case "outcome"
        ]
      ]
      ;    foreach case-base-pool [ case ->
      ;      show (word "name -> " table:get case "name" " decision -> " table:get case "decision" " outcome -> " table:get case "outcome")
      ;    ]
    ]

    debug "...finished case base pool."
  ]

  setup-msm "national-newspaper" "national"
  setup-msm "local radio" "local"

  ; Create a base population
  ; ========================

  load-population-from-a-file

  ; Households
  ; ==========

  set household-pool table:make
  set household-postcodes table:make
  load-households-from-a-file

  ; Pipe laying
  ; ===========

  debug "laying pipe..."

  ifelse pipe-present-input-output-file != "" and file-exists? pipe-present-input-output-file [
    input-present-pipe-line
  ]
  [
    if display-gis? [
      (ifelse
        extent = "Torry" [
          set pipeline-pathname (word gis-dir "/heat-network.torry.seed.shp")
          set pipeline gis:load-dataset pipeline-pathname
        ]
        extent = "Aberdeen" [
          set pipeline-pathname (word gis-dir "/heat-network.aberdeen.full.shp")
          set pipeline gis:load-dataset pipeline-pathname
        ]
        [
          set pipeline-pathname (word gis-dir "/heat-network.timisoara.full.shp")
          set pipeline gis:load-dataset pipeline-pathname
        ]
      )
      ask patches [
        if not pipe-in-any-street? [
          set pipe-possible? false
        ]
        set pipe-present? false
      ]

      ask patches gis:intersecting pipeline [
        set pipe-possible? true
        if start-with-pipe-present? [
          set pipe-present? true
          sprout-heat-pipes 1 [
            set color blue
            set size 1
            if extent = "Torry" [
              set size 2
            ]
            set shape "square"
          ]
        ]
        ask heat-pipes [
          if any? neighbors with [pipe-possible? and not pipe-present?] [
            ask neighbors with [pipe-possible? and not pipe-present?] [
              if my-roads != nobody [
                ask my-roads [
                  set near-heat-network? true
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]

  set schedule-for-laying-pipes table:make
  if pipe-laying-schedule-file != "" and file-exists? pipe-laying-schedule-file [
    get-pipe-laying-schedule
  ]

  if random-street-naming? [
    random-street-names-and-pipe-route
  ]

  ; This is the seed if the pipe is to be grown or is stochastically implemented
  ; The first check is to make sure there is no pre-existing pipe from a
  ; pre-loaded file.

  if count patches with [pipe-present?] <= 0 [
    if street-voting != "disabled" [
        let some-street-name one-of [name] of roads with [
        my-patches != nobody
        and member? true [pipe-possible?] of my-patches and name != ""
        and pxcor > -100 and pxcor < 100
        and pycor > -100 and pycor < 100
      ]
      ask one-of roads with [
        name = some-street-name and
        my-patches != nobody and
        member? true [pipe-possible?] of my-patches] [
        hatch-heat-pipes 1 [
          set color blue
          set size 2
          set shape "square"
        ]
        ask patch-here [
          set pipe-present? true
        ]
      ]
    ]
  ]


  debug "new builds..."

  ; New builds (if any)
  ; ====================

  set schedule-for-new-builds table:make
  if new-builds-schedule-file != "" [
    get-new-build-schedule
  ]


  ; Council tax - vary this on a yearly basis with a file at some point.

  set community-charge table:make
  table:put community-charge "A" 1179.05
  table:put community-charge "B" 1375.55
  table:put community-charge "C" 1572.06
  table:put community-charge "D" 1768.57
  table:put community-charge "E" 2282.98
  table:put community-charge "F" 2793.72
  table:put community-charge "G" 3333.88
  table:put community-charge "H" 4133.09

  ; Business rate - could be varied.

  set business-rate 0.49

  ; Set up a seed for the network creation

  set seed table:make
  set reach table:make
  table:put reach "social" read-from-string social-network-reaches-spec
  if not is-list? table:get reach "social"  [
    error "Invalid social-reaches-spec must be of the form '[n m ...]'"
  ]
  table:put reach "neighbour" read-from-string neighbourhood-network-reaches-spec
  if not is-list? table:get reach "neighbour" [
    error "Invalid neighbourhood-reaches-spec must be of the form '[n m ...]'"
  ]

  ; Create some buildings with their associated households
  ; ======================================================


  ifelse buildings-input-output-file != "" and file-exists? buildings-input-output-file [
    input-buildings
  ]
  [
    (ifelse
      extent = "Torry" [
        structures-for-torry
      ]
      extent = "Aberdeen" [
        structures-for-aberdeen
      ]
      [
        structures-for-timisoara
      ]
    )

  ]

  profiler:stop
  output-print profiler:report
  profiler:reset

  reset-ticks
  msg "set-up: ...has ended."


  set setup? false
end

to gis
  set gis-dir "data/gis"
  if extent = "Aberdeen" [
    set addresses-pathname (word gis-dir "/aberdeen.addresses.shp")
    set addresses gis:load-dataset addresses-pathname
  ]

  ask patches [
    set pcolor white
    set my-roads nobody
    set pipe-possible? false
  ]

  ask roads [
    die
  ]

  debug "setting up map..."

  let abm-map-file ""
  (ifelse
    extent = "Torry" [
      set abm-map-file "torry"
    ]
    extent = "Aberdeen" [
      set abm-map-file "roads.aberdeen"
    ]
    [
      set abm-map-file "buildings.timisoara"
    ]
  )

  let abm-map-data gis-load-dataset (word gis-dir "/" abm-map-file ".shp")
  gis:set-world-envelope gis:envelope-of abm-map-data

  debug "drawing map..."
  gis:set-drawing-color grey + 2
  gis:draw abm-map-data 1

  ifelse pipe-possible-input-output-file != "" and file-exists? pipe-possible-input-output-file [
    input-possible-pipe-line
    input-roads
  ]
  [

    debug "...reading street vectors"
    ifelse extent = "Timisoara" [
      set streets-pathname (word gis-dir "/roads.timisoara.shp")
    ]
    [
      set streets-pathname (word gis-dir "/roads.aberdeen.shp")
    ]
    set streets gis:load-dataset streets-pathname

    let total length (gis:feature-list-of streets)
    let progress 0
    foreach (gis:feature-list-of streets) [ vertex ->
      set progress progress + 1
      if progress mod 100 = 0 [
        debug (word "gis:features " progress " / " total)
      ]
      let some-road-name gis:property-value vertex "NAME"
      let some-road nobody
      let new-patches (patches gis:intersecting vertex)
      if any? new-patches and some-road-name != "" [
        debug (word "Got a street " some-road-name)

        ifelse any? roads with [name = some-road-name ] [
          set some-road one-of roads with [name = some-road-name ]
        ]
        [
          create-roads 1 [
            set hidden? true
            set some-road self
            set name some-road-name
            set last-voted -1 * random voting-gap
            set voted? false
            set near-heat-network? false
            ask new-patches [
              set pipe-possible? true
              set my-roads (turtle-set my-roads some-road)
            ]
            set my-patches nobody
            let some-patch one-of new-patches
            setxy [pxcor] of some-patch [pycor] of some-patch
          ]
        ]
        ask some-road [
          set my-patches (patch-set my-patches new-patches)
        ]
        ask new-patches [
          set pipe-possible? true
          set my-roads (turtle-set my-roads some-road)
          set pcolor green
        ]
      ]
    ]
    debug "...finished reading street vectors"
  ]
  debug (word ":GIS: ...ended setting up map with " count roads " roads.")

end
; {observer|ad-hoc} go

to go
  ;export-view (word "aberdeen-" leading-zeroes ticks 5 ".png")
  ;export-interface (word "aberdeen-interface-" leading-zeroes ticks 5 ".png")
  init-decision-record
  set street-vote-record []

  ifelse compress-time? [
    compressed-go
  ] [
    if member? ticks [2 7 59 182 365] [
      output-print (word "profiling tick: " ticks)
      profiler:start
    ]

    if ticks != 0 [
      events

      daily

      if ticks mod 7 = 0  [
        weekly

      ]
      ; [ 31 28 31 30 31 30 31 31 30 31 30 31 ]
      if  member? (ticks mod 365) [0 31 59 90 120 151 181 212 243 273 304 334]  [
        monthly

      ]
      if member? (ticks mod 365) [91 182 273 364] [
        quarterly
      ]
      if ticks mod 365 = 0  [
        yearly

      ]
      stats

      ; Visualization and messaging -- no modelling after this point!

      ask buildings [
        visualize-fuel-poverty
      ]
    ]
    msg (word "go: Completed tick: " ticks )
    if member? ticks [2 7 59 182 365] [
      output-print (word "profiler report for tick: " ticks)
      profiler:stop
      output-print profiler:report
      profiler:reset
    ]
    tick
  ]
end

; In compressed time:
;
; A week is every other day
; A month is every other week
; A quarter is every other month
; A year is every other year

to compressed-go
  if member? ticks [1 2 4 8 16] [
    output-print (word "profiling tick: " ticks)
    profiler:start
  ]

  events
  daily
  if ticks mod 2 = 0 and ticks != 0 [
    weekly
  ]
  ; [ 31 28 31 30 31 30 31 31 30 31 30 31 ]
  if ticks mod 4 = 0 and ticks != 0 [
    monthly
  ]
  if ticks mod 8 = 0 and ticks != 0 [
    quarterly
  ]
  if ticks mod 16 = 0 and ticks != 0 [
    yearly
  ]
  stats

  ; Visualization and messaging -- no modelling after this point!

  ask buildings [
    visualize-fuel-poverty
  ]

  debug  (word "go: Completed tick: " ticks )
  if member? ticks [1 2 4 8 16] [
    output-print (word "profiler report for tick: " ticks)
    profiler:stop
    output-print profiler:report
    profiler:reset
  ]
  tick

end
; {observer} events

to events

  ; Systemic infrastucture failure for gas, electric and heat network
  ; Household infrastructure gas, electric and heat network
  ; Awareness raising event - this could be connecting a proprtion of house to
  ; SCARF or something
  ; All thresholds on the power laws have been rectally extracted from mythical
  ; creatures.
  ; A building flat or a house may go vacant or get a new family, depending
  ; upon probility.

  if ticks > tick-new-technology [
    set energy-types ["electric" "gas" "heat" "new-technology"]
  ]
  debug "events: pipelaying"
  if table:has-key? schedule-for-laying-pipes year [
    let year-subtable table:get schedule-for-laying-pipes year
    if table:has-key? year-subtable (ticks mod 365) [
      debug "file: laying pipe..."
      let heating-pipe-network gis-load-dataset
      table:get year-subtable (ticks mod 365)
      ask patches gis:intersecting heating-pipe-network [
        set pipe-present? true
        set pipe-possible? true
        let this-patch self
        ask my-roads [
          sprout-heat-pipes 1 [
            set color blue
            set size 2
            set shape "square"
          ]

          ifelse eligibility = "by-proximity" [
            ask buildings with
              [distance this-patch <= proximal-qualification-distance] [
                connect-building-to-heat-network
            ]
          ]
          [
            ask buildings with [ street-name = name ] [
              connect-building-to-heat-network
            ]
          ]
        ]
      ]
      debug "events: ... laying-pipe - completed"
    ]
    ask heat-pipes [
      if any? neighbors with [pipe-possible? and not pipe-present?] [
        ask neighbors with [pipe-possible? and not pipe-present?] [
          if my-roads != nobody [
            ask my-roads [
              set near-heat-network? true
            ]
          ]
        ]
      ]
    ]
  ]

  ; New builds
  debug "events: new builds"
  if table:has-key? schedule-for-new-builds year [
    let year-subtable table:get schedule-for-new-builds year
    if table:has-key? year-subtable (ticks mod 365) [
      debug "file: new builds..."
      foreach gis:feature-list-of table:get year-subtable (ticks mod 365) [
        vector-feature ->
        let some-street-name gis:property-value
          vector-feature "street-des"
        let some-nof-residences gis:property-value
          vector-feature "nof-residences"
        let some-postcode gis:property-value
          vector-feature "postcode"
        ask patches gis:intersecting vector-feature [
          setup-a-dwelling some-nof-residences
            some-street-name
            some-postcode
        ]
      ]
      debug "events: ...new builds - completed"
    ]
  ]

  debug "events: moving out"
  ; Moving out
  ask households [
    if random-float 1 < probability-of-moving-out [
      ask in-member-of-neighbors [
        die
      ]
      die
    ]
  ]

  ; Moving in
  debug "events: moving in"
  ask buildings with [count in-resident-neighbors < nof-households] [
    if random-float 1 < probability-of-moving-in [
      let this-building self
      hatch-households 1 [
        create-resident-from this-building [ set hidden? true ]
        create-a-random-household
          [table:get has? "electric"] of this-building
          [table:get has? "gas"] of this-building
          [table:get has? "heat"] of this-building
        if [table:get has? "heat"] of this-building [
          maybe-do-something-after "moved-in" "heat"
        ]
        if [table:get has? "electric"] of this-building [
          maybe-do-something-after "moved-in" "electric"
        ]
        if [table:get has? "gas"] of this-building [
          maybe-do-something-after "moved-in" "gas"
        ]
      ]
    ]
  ]

  debug "events: connections"

  ask buildings [
    ifelse eligibility = "by-proximity" [
      if any? patches in-radius proximal-qualification-distance with [pipe-present?] [
        connect-building-to-heat-network
      ]
    ]
    [
      let my-road-name street-name
      let some-roads roads with [ name = my-road-name ]
      if any? some-roads with [any? my-patches with [pipe-present?]] [
        connect-building-to-heat-network
      ]
    ]

  ]
  ; First recovery from previous events -  events mostly fixed by a day.
  debug "events: restoration"
  foreach energy-types [ some-energy-type ->
    ; Reading the literature, this seems to imply that the vast
    ; majority of outages are fixed in minutes, but the minimum resolution
    ; here is a tick, so we are abitrarily going to make that as the normal
    ; time for an outage is generally less than a day..
    if any? households with [ member? "-failure" heating-status  and
      heating-system = some-energy-type ] [
      ask households with [ member? "-failure" heating-status  and
        heating-system = some-energy-type and
        random-exponential 1.0 < 1.0] [
        set heating-status "working"
        maybe-do-something-after (word "power-restored-after-" heating-status)
          some-energy-type
      ]
    ]
  ]

  ; Households deal with household and building level failures
  debug "events: city wide"

  ; Do new failures...
  foreach energy-types [ some-energy-type ->
    ask energy-providers [
      if random-float 1.0 < probability-of-city-wide-power-failure [
        ;debug "CITY-WIDE FAILURE"
        ask households with [heating-system = some-energy-type] [
          set heating-status "city-wide-failure"
        ]
      ]
    ]
  ]

  debug "events: regional"
  foreach energy-types [ some-energy-type ->
    ask energy-providers [
      ; See issue #087 for an explanation of this
      if random-float 1.0 <  probability-of-regional-power-failure [
        ;debug "REGIONAL FAILURE"
        let ground-zero one-of households with [
          heating-status = "working" and heating-system = some-energy-type ]
        let size-of-region random 10
        ask ground-zero [
          set heating-status (list "regional-failure"
            ground-zero size-of-region)
          ask households in-radius size-of-region with [
            heating-system = some-energy-type ] [
            set heating-status "regional-failure"
          ]
        ]
      ]
    ]
  ]
  debug "events: building"

  foreach energy-types [ some-energy-type ->
    ask buildings with [table:has-key? has? some-energy-type and
      nof-households > 1 ] [
      if random-float 1.0 < probability-of-building-power-failure [
        ;debug "BUILDING FAILURE"
        ask in-resident-neighbors with [ heating-status = "working"
          and heating-system = some-energy-type ] [
          set heating-status "building-failure"
        ]
      ]
    ]
  ]

  debug "events: household"

  foreach energy-types [ some-energy-type ->
    if some-energy-type != "heat" [
      ask households with [ heating-system = some-energy-type ] [
        ; https://www.help-link.co.uk/advice-centre/how-long-do-boilers-last/
        if heating-system-age >= floor (random-normal (15 * 365) (42 / 4))
          and heating-status = "working"  [
          ;debug "HOUSEHOLD FAILURE - REPAIR"
          ifelse random-float 1.0 < probability-of-repair-vs-replace [
            set heating-status "repair"
            maybe-do-something-after "repair" some-energy-type
            if heating-status = "repair" [
              ; So nothing happend when we consulted our case-base, therefore we
              ; are going to repair and if memory is working then we will record
              ; the conditions under which we did this.
              forced-to-repair-heating-system
            ]
          ]
          [
            ;debug "HOUSEHOLD FAILURE - REPLACE"
            set heating-status "replace"
            maybe-do-something-after "replacement" some-energy-type
            if heating-system = "replace" [
              ; So nothing happend when we consulted our case-base, therefore we
              ; are going to replace and if memory is working then we will record
              ; the conditions under which we did this.
              forced-to-replace-heating-system
            ]
          ]
        ]
      ]
    ]
  ]

  debug "events: advisory bodies"
  ask advisory-bodies [
    foreach table:keys calendar [ advice-topic ->
      if member? (ticks mod 365) table:get calendar advice-topic  [
        let this-advisory-body self
        let some-patch one-of patches with [
          pxcor = [
            table:get x-locus advice-topic] of this-advisory-body and
              pycor = [table:get y-locus advice-topic] of this-advisory-body ]
        ifelse table:get radius advice-topic <= 0  [
          ask households [
            maybe-do-something-after "awareness-raising-event" [
              table:get energy-type advice-topic] of this-advisory-body
          ]
        ]
        [
          ask households with [ distance some-patch <
            [table:get radius advice-topic] of this-advisory-body ] [
            maybe-do-something-after "awareness-raising-event" [
              table:get energy-type advice-topic] of this-advisory-body
          ]
        ]
      ]
    ]
  ]
  debug "events: review trust"
  if trust-feedback? [
    review-trust
  ]
  if ticks > tick-close-associations [
    debug "events: close associations"
    ask associations [
      die
    ]
  ]
  debug "events: street-voting:"
  street-votes
end

; {observer} daily

to daily
  ; Weather happens - read a CSV file
  ; Households use heat acccording to the weather and their profile
  ; Suppliers provide heat and incur costs doing so
  ; community-organizations, school and work meet and possibly exchange
  ; information for week-days and build case base based on their calendars.


  debug "daily: businesses"
  ask businesses [
    ;This line is problematic
    table:put units-of-energy-used "electric"
      table:get units-of-energy-used "electric" +
      min-electrical-units-of-energy-per-day

    table:put units-of-energy-used heating-system
      table:get units-of-energy-used heating-system +
      units-of-energy-per-day-for-heating;
    foreach table:keys payment-for [ bill ->
      if is-energy-provider? table:get payment-to bill [
        let this-energy-provider table:get payment-to bill
        let this-tariff table:get payment-name bill
        let this-energy-type table:get payment-for bill
        if [table:get frequency this-tariff] of this-energy-provider = "daily" [
          pay-energy-provider this-energy-provider this-tariff this-energy-type
        ]
      ]
    ]
  ]
  debug "daily: associations calculate"
  if any? associations [
    ask associations  [

    ]
  ]
  debug "daily: households calculate"
  ask households with [ not any? out-associate-neighbors ] [
    if heating-system = "electric" or heating-system = "gas" [
      set heating-system-age heating-system-age + 1
    ]
    calculate-energy-consumption
    foreach table:keys payment-for [ bill ->
      if is-energy-provider? table:get payment-to bill [
        let this-energy-provider table:get payment-to bill
        let this-tariff table:get payment-name bill
        let this-energy-type table:get payment-for bill
        if [table:get frequency this-tariff] of this-energy-provider = "daily" [
          pay-energy-provider this-energy-provider this-tariff this-energy-type
          calculate-fuel-poverty
        ]
      ]
    ]
  ]
  debug "daily: households maintenance"
  ask households [
    if table:get uses? "gas" and not table:get serviced? "gas" and
      table:get requires-maintenance? "gas" [
      if random 366 = 1 [
        maintenance-for "gas"
      ]
    ]
    if table:get uses? "electric" and
      not table:get serviced? "electric" and
      table:get requires-maintenance? "electric" [
      if random 366 = 1 [
        maintenance-for "electric"
      ]
    ]
  ]

  ; Do the hours away from home for the heating bills.
  debug "daily: households hours away"
  ifelse resolution = "household" [
    ask households [
      set hours-away-from-household 0
      let this-household self
      ask my-all-attends [
        let my-link self
        ask other-end [
          let this-institution self
          if member? (ticks mod 7) calendar and
          not member? (ticks mod 365) fixed-holidays [
            ifelse [holidays-used] of my-link < floating-holidays and
            random 365 < floating-holidays - [holidays-used] of my-link [
              ask my-link [
                set holidays-used holidays-used + 1
              ]
            ]
            [
              if random-float 1.0 < probability-of-attendance [
                ; Reduce this by somebody being at a club, being at work or being
                ; at school. Assuming:
                ; 1 hours for a commute both ways in Scotland
                ; (https://moovitapp.com/insights/en-gb/Moovit_Insights_Public_Transport_Index_United_Kingdom_Scotland-402)
                ; https://www2.gov.scot/Topics/Statistics/Browse/Labour-Market/Earnings/ASHE-SCOT-2017 - loads of lovely stats
                ; 8 hours for school
                ; 10 hours for work
                ; 3 hours for a community organization
                ; 2 hours of travelling for work and school on average.
                ; TODO This needs more research
                if organization-type = "work" [
                  ask this-household [
                    set hours-away-from-household hours-away-from-household + (2 + (34.5 + 38) / 10) * (1 - [working-from-home] of this-institution)
                  ]
                ]
                if organization-type = "school" [
                  ask this-household [
                    set hours-away-from-household hours-away-from-household + 8 * (1 - [working-from-home] of this-institution)
                  ]
                ]
                if organization-type = "community" [
                  ask this-household [
                    set hours-away-from-household hours-away-from-household + 3
                  ]

                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
  [
    ask households [
      set hours-away-from-household 0
      let this-household self
      ask in-member-of-neighbors [
        let this-person self
        ask my-all-attends [
          let my-link self
          ask other-end [
            let this-institution self
            if member? (ticks mod 7) calendar and
            not member? (ticks mod 365) fixed-holidays [
              ifelse [holidays-used] of my-link < floating-holidays and
              random 365 < floating-holidays - [holidays-used] of my-link [
                ask my-link [
                  set holidays-used holidays-used + 1
                ]
              ]
              [
                if random-float 1.0 < probability-of-attendance [
                  ; Reduce this by somebody being at a club, being at work or being
                  ; at school. Assuming:
                  ; 1 hours for a commute both ways in Scotland
                  ; (https://moovitapp.com/insights/en-gb/Moovit_Insights_Public_Transport_Index_United_Kingdom_Scotland-402)
                  ; https://www2.gov.scot/Topics/Statistics/Browse/Labour-Market/Earnings/ASHE-SCOT-2017 - loads of lovely stats
                  ; 8 hours for school
                  ; 10 hours for work
                  ; 3 hours for a community organization
                  ; 2 hours of travelling for work and school on average.
                  ; TODO This needs more research
                  if organization-type = "work" [
                    ask this-household [
                      set hours-away-from-household hours-away-from-household + (2 + (34.5 + 38) / 10) * (1 - [working-from-home] of this-institution)
                    ]
                  ]
                  if organization-type = "school" [
                    ask this-household [
                      set hours-away-from-household hours-away-from-household + 8 * (1 - [working-from-home] of this-institution)
                    ]
                  ]
                  if organization-type = "community" [
                    ask this-household [
                      set hours-away-from-household hours-away-from-household + 3
                    ]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
  debug "daily: record profits"
  ask energy-providers [
    record-profits
    set daily-income lput 0 daily-income
    set daily-outgoings lput 0 daily-outgoings
  ]
end

; {observer} weekly

to weekly
  ask businesses [
    foreach table:keys payment-for [ bill ->
      if is-energy-provider? table:get payment-to bill [
        let this-energy-provider table:get payment-to bill
        let this-tariff table:get payment-name bill
        let this-energy-type table:get payment-for bill
        if [table:get frequency this-tariff] of this-energy-provider = "weekly" [
          pay-energy-provider this-energy-provider this-tariff this-energy-type
        ]
      ]
    ]
  ]
  ask households [
    foreach table:keys payment-for [ bill ->
      if is-energy-provider? table:get payment-to bill [
        let this-payment-to table:get payment-to bill
        let this-payment-name table:get payment-name bill
        let this-payment-for table:get payment-for bill
        if [table:get frequency this-payment-name] of this-payment-to = "weekly" [
          pay-energy-provider this-payment-to this-payment-name this-payment-for
          calculate-fuel-poverty
        ]
      ]
    ]
  ]
  ask households [
    foreach table:keys payment-for [ bill ->
      if is-bank? table:get payment-to bill [
        let this-payment-to table:get payment-to bill
        let this-payment-name table:get payment-name bill
        if [table:get frequency this-payment-name] of this-payment-to = "weekly" [
            pay-bank this-payment-to this-payment-name
        ]
      ]
    ]
  ]
  ask households [
    foreach table:keys payment-for [ bill ->
      if is-landlord? table:get payment-to bill [
        let this-payment-to table:get payment-to bill
        let this-payment-name table:get payment-name bill
        if [table:get frequency this-payment-name] of this-payment-to = "weekly" [
            pay-landlord this-payment-to this-payment-name
        ]
      ]
    ]
  ]
  ;street-votes
end

; {observer|ad-hoc} monthly

to  monthly
  debug "monthly starting..."
  ; Households pay for heating (depending on tariff)
  ; Mortgage company update ‘rent’ (csv)
  ; Community charge
  ; Household expenditure
  ; Energy companies disconnect or enforce tariff change? (if in arrears change
  ; tariff)(flag tarrif for arrears).
  ; Households get income (depending on employment)
  ; Energy companies update variable tariffs (csv file)
  ask households [
    set monthly-fuel-payment 0
  ]
  ask households [
    foreach table:keys payment-for [ bill ->
      if is-energy-provider? table:get payment-to bill [
        let this-payment-to table:get payment-to bill
        let this-payment-name table:get payment-name bill
        let this-payment-for table:get payment-for bill
        if [table:get frequency this-payment-name] of this-payment-to = "monthly" [
          calculate-fuel-poverty
          pay-energy-provider this-payment-to this-payment-name this-payment-for
        ]
      ]
    ]
  ]
  ask households [
    foreach table:keys payment-for [ bill ->
      if is-bank? table:get payment-to bill [
        let this-payment-to table:get payment-to bill
        let this-payment-name table:get payment-name bill
        if [table:get frequency this-payment-name] of this-payment-to = "monthly" [
            pay-bank this-payment-to this-payment-name
        ]
      ]
    ]
  ]
  ask households [
    ifelse heating-system = "heat" [
      set balance balance - (1 - discount-on-council-tax-for-installation /
        100 ) * [table:get community-charge council-tax-band] of one-of in-resident-neighbors / 12
    ]
    [
      set balance balance - [table:get community-charge council-tax-band] of one-of in-resident-neighbors / 12
    ]
  ]
  ask households [
    foreach table:keys payment-for [ bill ->
      if is-landlord? table:get payment-to bill [
        let this-payment-to table:get payment-to bill
        let this-payment-name table:get payment-name bill
        if [table:get frequency this-payment-name] of this-payment-to = "monthly" [
            pay-landlord this-payment-to this-payment-name
        ]
      ]

    ]
  ]
  ask households [
    set balance balance + income - ongoing-costs
  ]
  ask energy-providers [
    let update-file (word energy-providers-spec-dir "/" name ".monthly." year ".csv")
    if file-exists? update-file [
      debug (word "monthly: Am updating " name " with " update-file)
      update-energy-provider-with update-file
    ]
  ]
  debug "monly...ending monthly"
end

; {observer} quarterly

to quarterly
  debug "quarterly starting..."
  ; Households pay for heating (depending on tariff)
  ; AHP install new infrastructure (allowing households to connect) -- update
  ; via scenario GIS files and other files.
  ask households [
    foreach table:keys payment-for [ bill ->
      if is-energy-provider? table:get payment-to bill [
        let this-payment-to table:get payment-to bill
        let this-payment-name table:get payment-name bill
        let this-payment-for table:get payment-for bill
        if [table:get frequency this-payment-name] of this-payment-to = "quarterly" [
          pay-energy-provider this-payment-to this-payment-name this-payment-for
          calculate-fuel-poverty
        ]
      ]
    ]
  ]
  debug "...ending quarterly"
end

; {observer} yearly

to yearly

  debug "yearly starting..."
  ; Maintenance of the heating system (different days for different households
  ; though! Might need to ask landlords and the council how they organize it)
  ; Grant awarding bodies update subsidies (csv files)
  ; Landlords update rent (csv file)
  ; Mortgage companies update products offered (csv file)
  ; Advice giving agents plan promotions
  ; Energy companies update tariff profile
  ; Energy companies calculate profitability
  ; Households have a probability of moving (different days for different
  ; households -- something simpler than DIReC!) Randomly change households,
  ; to simulate moving households, such as changing structure of household.
  ; Load a new year's worth of weather, or repeat this year.
  set year year + 1
  debug "Updating grant-bodies"
  ask grant-bodies [
    let update-file (word grant-bodies-spec-dir "/" name ".yearly." year ".csv")
    if file-exists? update-file [
      update-grants-with update-file
    ]
  ]
  debug "Updating energy-providers"
  ask energy-providers [
    let update-file (word energy-providers-spec-dir "/" name ".yearly." year ".csv")
    ifelse member? "gas" table:values energy-type and ramp-up-prices-per-annum > 0 [
      debug (word "yearly: ramping up gas prices by " ramp-up-prices-per-annum)
      foreach table:keys energy-type [ some-tariff ->
        if table:get energy-type some-tariff = "gas" [
          table:put retail-unit-cost some-tariff (table:get retail-unit-cost some-tariff * ((100 + ramp-up-prices-per-annum) / 100 ))
          table:put wholesale-unit-cost some-tariff (table:get wholesale-unit-cost some-tariff * ((100 + ramp-up-prices-per-annum) / 100 ))
        ]
      ]
    ]
    [
      if file-exists? update-file [
        update-energy-provider-with update-file
      ]
    ]
  ]
  debug "Updating landlords"
  ask landlords [
    let update-file (word landlords-spec-dir "/" name ".yearly." year ".csv")
    if file-exists? update-file [
      update-rents-with update-file
    ]
  ]
  debug "Updating banks"
  ask banks [
    let update-file (word banks-spec-dir "/" name ".yearly." year ".csv")
    if file-exists? update-file [
      update-bank-with update-file
    ]
  ]
  debug "Updating advisory bodies"
  ask advisory-bodies [
    let update-file (word
      advisory-bodies-spec-dir "/" name ".yearly." year ".csv")
    if file-exists? update-file [
      update-advice-with update-file
    ]
  ]
  debug "Updating households"
  ask households [
    table:put serviced? "electric" false
    table:put serviced? "gas" false
    modify-household
      [table:get has? "electric"] of one-of in-resident-neighbors
      [table:get has? "gas"] of one-of in-resident-neighbors
      [table:get has? "heat"] of one-of in-resident-neighbors
  ]
  debug "Updating weather"
  let weather-update (word
    weather-spec-dir "/" "weather" "." "yearly" "." year ".csv")
  if file-exists? weather-update [
    update-weather weather-update
  ]
  ; zeroise the holiday entitlement
  debug "Updating holidays-used"
  ask all-attends [
    set holidays-used 0
  ]
  debug "...ending yearly"
end

; { person | household } add-to-network

; Some class may be:

; "Erdős and Rényi"
; "Watts and Strogatz"
; "Barabási and Albert"
; "Hamill and Gilbert"

; some-network might

; entity is some agent like a person or a household

to add-to-network [some-class some-network some-connection-or-rewire-probability some-degree-or-nof-seeds some-reaches-spec]

  let me self
  if not is-household? me and not is-person? me [
    error (word "Trying to add " me " to a network that is neither a person or household")
  ]
  let some-nodes (turtle-set nobody)
  let my-family (turtle-set nobody)
  (ifelse
    some-network = "school" or some-network = "work" or some-network = "community" [
      ifelse resolution = "household" and is-person? me [
        let my-institution one-of out-attends-neighbors
        ask [in-attends-neighbors with [self != me]] of my-institution [
          set some-nodes (turtle-set some-nodes out-member-of-neighbors)
        ]
        set me one-of out-member-of-neighbors
        set my-family (turtle-set me)
      ]
      [
        set my-family (turtle-set me)
        let my-institution one-of out-attends-neighbors
        set some-nodes [in-attends-neighbors with [self != me]] of my-institution
      ]
    ]
    is-household? me [
      set my-family (turtle-set me)
      ask my-knows with [ network = some-network ] [
        set some-nodes (turtle-set some-nodes end1 end2)
      ]
    ]
    is-person? me [
      ask my-knows with [ network = some-network ] [
        set some-nodes (turtle-set some-nodes end1 end2)
      ]
      let my-household one-of out-member-of-neighbors
      if my-household != nobody [
        set my-family [in-member-of-neighbors with [ self != me ] ] of my-household
      ]
    ]
    [
      err "add-network: This should not happen"
    ]
  )
  if member? me some-nodes [
    stop
  ]
  ask me [
    (ifelse
      some-class = "Erdős and Rényi" [
        ask some-nodes [
          let target self
          if not member? target my-family [
            if random-float 1.0 < some-connection-or-rewire-probability [
              friend me some-network
            ]
          ]
        ]
      ]
      some-class = "Watts and Strogatz" [


        ifelse count some-nodes = 0 [

          ; We have an empty network, so to build the first link...

          ifelse table:has-key? seed some-network and table:get seed some-network != nobody [
            set some-nodes (turtle-set table:get seed some-network)
            friend one-of some-nodes some-network
          ]
          [
            table:put seed some-network me
          ]
        ]
        [
          ask some-nodes [
            let this-node self
            if not member? this-node my-family [

              ; Try and find a non-full node.

              ifelse count my-out-knows with [ network = some-network ] < 2 * some-degree-or-nof-seeds [
                ; Now lets do a possible random rewire on this node
                ifelse random-float 1.0 < some-connection-or-rewire-probability [
                  ; Let's find another node to rewire to far, far, away
                  ask one-of some-nodes with [ not member? self [my-out-knows] of me and self != this-node ] [
                    ask one-of my-out-links with [ not member? this-node both-ends and not member? me both-ends ] [
                      friend me some-network
                      die
                    ]
                  ]
                ]
                [
                  friend me some-network
                ]
              ]
              [

                ; We need to set up a new networked node by expanding it.
                ; so what we do is take any mode, create a new node
                ; and rewire both the nodes to this new node.

                ask one-of some-nodes with [
                  count my-out-knows with [ network = some-network ] > 0 ]  [
                  let old-node self
                  friend me some-network

                  ask one-of out-know-neighbors with [
                    self != me and
                    network = some-network] [
                    friend me some-network
                    ask my-out-knows with [ other-end = old-node] [
                      die
                    ]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
      some-class = "Barabási and Albert" [

        ; Let do a probabilistic connection to a node that is already
        ; present, but make it more likely if the node is already
        ; highly connected
        let connected? false

        ifelse count some-nodes = 0 [

          ; We have an empty network, so to build the first link...

          ifelse table:has-key? seed some-network [
            set some-nodes (turtle-set table:get seed some-network)
            friend one-of some-nodes some-network
          ]
          [
            table:put seed some-network me
          ]
        ]
        [
          foreach (sort-by [ [node-1 node-2] -> [count my-out-knows] of node-1 > [count my-out-knows] of node-2] some-nodes) [
            node ->
            ask node with [not member? self my-family] [
              if random-float 1.0 < some-connection-or-rewire-probability
              and not connected? [
                friend me some-network
                set connected? true
              ]
            ]
          ]
          ; Randomnly select a node if we didn't get a connection
          if not connected? and count some-nodes > 0 [
            ask one-of some-nodes with [not member? self my-family] [
              friend me some-network
            ]
          ]
        ]
      ]
      [
        ; Hamill and Gilbert

        ifelse is-person? me  [
          let max-connections count other persons with  [not member? self my-family]  in-radius one-of table:get reach some-network
          if max-connections > 0 [
            ask up-to-n-of max-connections other persons with  [not member? self my-family]  in-radius one-of table:get reach some-network [
              friend me some-network
            ]
          ]
        ]
        [
          let max-connections count other households  in-radius one-of table:get reach some-network
          if max-connections > 0 [
            ask up-to-n-of max-connections other households  in-radius one-of table:get reach some-network [
              friend me some-network
            ]
          ]
        ]
      ]
    )
  ]
end

; {nexus} between-nexuses

to between-nexuses [ to-nexus ]

  let from-patch [patch-here] of self
  let to-patch [patch-here] of to-nexus
  let direction 0
  ask from-patch [
    if pxcor - [pxcor] of to-patch != 0 [
      set direction atan  ([pxcor] of to-patch - pxcor) ([pycor] of to-patch - pycor)
    ]
    foreach n-values (distance to-patch * 10) [ i -> i / 10 ] [ i ->
      if is-patch? patch-at-heading-and-distance direction i [
        ask patch-at-heading-and-distance direction i [
          set pipe-present? true
        ]
      ]
    ]
  ]

end

; {business} business-wants-to-connnect?

to-report business-wants-to-connect?
  if heat-network-mandatory-for-businesses? [
    report true
  ]
  if discount-on-business-rate-for-installation > 0 [
    report true
  ]
  report false
end

; {institution} catchement-contains?

; For now I am using physiological equivalent temperature (PET) (see
; "Hoppe - 1999 - The physiological equivalent temperature--a universal index
; for the biometeorological assessment of the thermal environment"
; in the literature section under this directory).

; {household|association} calculate-energy-consumption

to calculate-energy-consumption
  let energy-used-today 0
  let energy-used-for-heating-today 0
  set current-temperature table:get temperature (ticks mod 365)

  if count my-in-members-of = 0 [
    if table:get uses? "electric" [
      table:put units-of-energy-used "electric" 0
    ]
    table:put units-of-energy-used heating-system 0
    if table:get temperature (ticks mod 365) < ideal-temperature [
      set switched-heating-off? true
    ]
    stop
  ]
  let this-household self
  let spend 0
  if table:get uses? "electric" [
    let this-energy-provider nobody
    let tariff ""
    foreach table:keys payment-for [ bill ->
      if table:get payment-for bill = "electric" [
        set tariff table:get payment-name bill
        set this-energy-provider table:get payment-to bill
        set spend [table:get retail-unit-cost tariff] of this-energy-provider * min-units-of-energy-per-day
      ]
    ]
    if balance - spend - money-spent < 0 and not any? out-associate-neighbors [
      set history-of-temperature lput current-temperature history-of-temperature
      table:put units-of-energy-used "electric" 0
      table:put units-of-energy-used heating-system 0
      debug (word "calculate-energy-consumption: Household: " this-household " cannot cover minimum energy-expenditure")
      if current-temperature < ideal-temperature [
        set switched-heating-off? true
      ]
      stop
    ]

    table:put units-of-energy-used "electric" (
      table:get units-of-energy-used "electric" + min-units-of-energy-per-day)
    set energy-used-today energy-used-today + min-units-of-energy-per-day
    set money-spent money-spent + spend

    ask this-energy-provider [
      let costs [table:get wholesale-unit-cost tariff] of this-energy-provider * energy-used-today
      set profitability profitability - costs - overhead
      set daily-income replace-item 0 daily-income (item 0 daily-income + spend)
      set daily-outgoings replace-item 0 daily-outgoings (item 0 daily-outgoings - costs - overhead)
    ]
  ]

  if heating-system != "" [
    let this-energy-provider nobody
    let tariff ""
    foreach table:keys payment-for [ bill ->
      if table:get payment-for bill = heating-system [
        set tariff table:get payment-name bill
        set this-energy-provider table:get payment-to bill
      ]
    ]
    let PET (
      table:get temperature (ticks mod 365) * temperature-factor +
      table:get absolute-humidity (ticks mod 365) * humidity-factor +
      table:get absolute-humidity (ticks mod 365) *
      table:get temperature (ticks mod 365) * combined-factor)
    let optimal (ideal-temperature * temperature-factor +
      ideal-absolute-humidity * humidity-factor + combined-factor *
      ideal-absolute-humidity * ideal-temperature)
    let some-building one-of in-resident-neighbors
    set energy-used-for-heating-today (((optimal - PET) *
      units-of-energy-per-degree /
      (energy-efficiency [ energy-rating ] of some-building)) *
      max-units-of-energy-per-day * boiler-size / max-boiler-size)
    set energy-used-for-heating-today (24 - hours-away-from-household /
      ( count my-in-members-of * 24 )) * energy-used-for-heating-today
    set spend [table:get retail-unit-cost tariff] of this-energy-provider * energy-used-for-heating-today
    if balance - spend - money-spent < 0  and not any? out-associate-neighbors [
      set history-of-temperature lput current-temperature history-of-temperature
      table:put units-of-energy-used heating-system 0
      if current-temperature < ideal-temperature [
        set switched-heating-off? true
      ]
      record-household-daily-consumption energy-used-today
      debug (word "calculate-energy-consumption: Household: " this-household " cannot cover heating energy-expenditure")
      stop
    ]
    set energy-used-today energy-used-today + energy-used-for-heating-today
    set money-spent money-spent + spend
    table:put units-of-energy-used heating-system table:get units-of-energy-used heating-system + energy-used-for-heating-today
    set current-temperature ideal-temperature
    ask this-energy-provider [
      let costs [table:get wholesale-unit-cost tariff] of this-energy-provider * energy-used-for-heating-today
      set profitability profitability - costs - overhead
      set daily-income replace-item 0 daily-income (item 0 daily-income + spend)
      set daily-outgoings replace-item 0 daily-outgoings (item 0 daily-outgoings - costs - overhead)
    ]
  ]
  record-household-daily-consumption energy-used-today
  set history-of-temperature lput current-temperature history-of-temperature
  set annual-units-consumed annual-units-consumed + energy-used-today
end

; {household} calculate-fuel-poverty

to calculate-fuel-poverty
  set fuel-poverty ifelse-value (income = 0) [ 1 ] [ min (list 1 (monthly-fuel-payment / income)) ]
  set history-of-fuel-poverty lput fuel-poverty history-of-fuel-poverty
end


; {institution} catchment-contains?

to-report catchment-contains? [some-household]
  if distance some-household <= catchment-radius [
    report true
  ]
  report false
end

; {building} connect-building-to-network

to connect-building-to-heat-network
  table:put has? "heat" true
  ;set size 30
  let this-building self
  if count my-residents = 0 and not setup? [
    debug "connect-building-to-network: No residents."
    stop
  ]
  ifelse any? my-residents with [is-business? other-end] [
    set color lime
    ask in-resident-neighbors [
      if business-wants-to-connect? [
        if heating-system != "" [
          uninstall-heating-system
        ]
        install-new-heating-system "heat"
      ]
    ]
  ]
  [
    ifelse nof-households = 1 [
      set color turquoise - 2
      ask in-resident-neighbors [
        ifelse owns-property? [
          maybe-do-something-after "connection" "heat"
        ]
        [
          if landlord-wants-to-connect? [
            if heating-system != "" [
              uninstall-heating-system
            ]
            install-new-heating-system "heat"
          ]
        ]
        if heating-system = "heat" [
          set color green
        ]
      ]
    ]
    [
      ifelse nof-households < 6 [
        set color turquoise
      ]
      [
        set color turquoise + 2
      ]
      ifelse building-voting? [
        let decided-to-install? true
        ask in-resident-neighbors [
          if not household-votes-for-installation? [
            set decided-to-install? false
          ]
        ]
        if decided-to-install? [
          set color green
          ask in-resident-neighbors [
          if heating-system != "heat" and heating-system != "" [
              uninstall-heating-system
            ]
            install-new-heating-system "heat"
          ]
        ]
      ]
      [
        ; Forcing the issue - that is if a building connnects we are forcing
        ; everybody to have the heating.
        ask in-resident-neighbors [
          if heating-system != "heat" and heating-system != "" [
            uninstall-heating-system
            install-new-heating-system "heat"
          ]
        ]
      ]

    ]
  ]
end


; {household} consult-on

to-report consult-on? [some-decision some-state]

  ; Making gas illegal
  if ticks > tick-gas-illegal and some-decision = "install" and item 0 some-state = "gas" [
    output-decision some-decision some-state false
    report false
  ]

  if heat-network-mandatory-for-council-tenants? [
    if some-decision = "install" and item 0 some-state = "heat"  [
      let some-payers (turtle-set table:values payment-to)
      if count some-payers > 0 and any? some-payers with [ is-landlord? self and not private? ] [
        output-decision some-decision some-state true
        report true
      ]
    ]
  ]

  let trusters (turtle-set self)
  let outcome? false
  if resolution = "person" [
    (ifelse
      dynamic = "all-adults" [
        set trusters in-member-of-neighbors with [ age > 18 ]
      ]
      dynamic = "matriarchal" [
        set trusters max-one-of in-member-of-neighbors with [ sex = "female" ] [age]
      ]
      dynamic = "patriarchal" [
        set trusters max-one-of in-member-of-neighbors with [ sex = "male" ] [age]
      ]
      dynamic = "random" [
        set trusters one-of in-member-of-neighbors
      ]
      dynamic = "household" [
        set trusters in-member-of-neighbors
      ]
    )
  ]
  if trusters = nobody [
    show ("empty trusters")
    output-decision some-decision some-state false
    report false
  ]

  if some-decision = "install" and wants-to-join? [
    set outcome? true
    if memory? and trusters != nobody and use-cbr? [
      ask trusters [
        let case cbr:add case-base some-state some-decision outcome?
      ]
    ]
    if some-decision = "install" and item 0 some-state = "heat" [
    ]
    output-decision some-decision some-state outcome?
    report outcome?
  ]
  ; So if the resolution is at person level, then we need to
  ; take into account the family dynamics.

  let for 0
  let against 0
  ; Get the total number of endorsers before hand
  let nof-endorsements count (turtle-set trusters)
  if consult-social-networks? [
    set nof-endorsements nof-endorsements + count in-know-neighbors
  ]

  ifelse use-cbr? [
    ifelse trusters = nobody [
      debug (word "consult-on: decision = " some-decision " some-state = " some-state " dynamic = " dynamic)
      ask in-member-of-neighbors [
        debug (word "consult-on: sex = " sex " age = " age)
      ]
    ]
    [
      ask trusters [
        let me self
        let some-outcome? false
        let match cbr:match case-base some-state some-decision
        ifelse match != nobody [
          set some-outcome? cbr:outcome case-base match
          ; I have experienced this before, so I trust myself most
          ifelse some-outcome? [
            set for for + b ^ (1 + length trust)
          ] [
            set against against + b ^ (1 + length trust)
          ]
        ]
        [
          ; I have not experienced this before, so I'm least confident in my decision-bias
          ifelse some-outcome? [
            set for for + 1 ; N.B. trust rank is 0 so b ^ 0, which is 1
          ]
          [
            set against against + 1
          ]
        ]
        if consult-social-networks? [
          let who-to-consult-knows  up-to-n-of max-nof-consultees  my-knows
          if use-most-trusted? and count my-knows > max-nof-consultees [
            set who-to-consult-knows max-n-of max-nof-consultees  my-knows [  position network [trust] of me ]
          ]
          ask  who-to-consult-knows [

            if member? network [trust] of me [
              let trust-rank 1 + position network [trust] of me
              ask other-end [
                set match cbr:match case-base some-state some-decision
                if match != nobody [
                  ; I have a relevant case to offer a recommendation with
                  set some-outcome? cbr:outcome case-base match
                  ; TODO This is a horrible fix for a bug in the cbr code, but I need this working quickly
                  if some-outcome? = nobody [
                    set some-outcome? false
                  ]
                  ifelse some-outcome? [
                    set for for + (recommend some-decision true) * b ^ trust-rank
                  ] [
                    set against against + (recommend some-decision false) * b ^ trust-rank
                  ]
                  ; Handle keeping track of what I recommended
                  if memory?  [
                    let case cbr:add case-base some-state some-decision some-outcome?
                  ]
                  if remember-recommendations? [
                    table:put recommendations [who] of me (list some-decision some-outcome? me)
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
  [
    ifelse some-decision != "install" [
      ask trusters [
        let me self
        let my-household me
        let my-building nobody
        if not is-household? me [
          set my-household one-of out-member-of-neighbors
        ]
        ask my-household [
          set my-building one-of in-resident-neighbors
        ]
        ;debug (word "consult-on?: non-install decision: " some-decision " " item 0 some-state)
        let who-to-consult (turtle-set [other-end] of my-knows with [ network = "family" or network = "neighbour" or network = "social" or network = "work" or network = "school" or network = "community" or network = "advice" ])
        let some-threshold 0
        ask who-to-consult [
          ifelse is-advisory-body? self [
            set some-threshold some-threshold + 1
          ]
          [
            let some-household self
            if not is-household? self [
              set some-household one-of out-member-of-neighbors
            ]

            if (([heating-system] of some-household = "heat" and extent != "Timisoara") or
              ([heating-system] of some-household = "new-technology" and extent != "Timisoara" and ticks > tick-new-technology) or
              ([heating-system] of some-household = "gas" and extent = "Timisoara") or
              ([heating-system] of some-household = "heat" and extent = "Timisoara" and awareness-campaign?)) [
              set some-threshold some-threshold + 1
            ]
          ]
        ]
        ifelse count who-to-consult > 0 [
          ifelse (some-threshold / (count who-to-consult)) * 100 >= adoption-likelihood-threshold [
            set for for + 1
            debug (word "consult-on?: We have one from non-install decisions")
          ]
          [
            set against against + 1
          ]
        ]
        [
          set against against + 1
        ]
      ]
    ]
    [
      ask trusters [
        let me self
        let my-household me
        let my-building nobody
        if not is-household? me [
          set my-household one-of out-member-of-neighbors
        ]
        ask my-household [
          set my-building one-of in-resident-neighbors
        ]
        (ifelse
          heuristic-type = "innovator" [
            if ((some-decision = "install" and extent != "Timisoara" and item 0 some-state = "heat")
              or (some-decision = "install" and extent != "Timisoara" and item 0 some-state = "new-technology" and ticks > tick-new-technology)
              or (some-decision = "install" and extent = "Timisoara" and item 0 some-state = "gas")
              or (some-decision = "install" and extent = "Timisoara" and item 0 some-state = "heat" and awareness-campaign?  )) [
              debug (word "consult-on?: innovator " some-decision " " item 0 some-state)
              set for for + 1
            ]
          ]
          heuristic-type = "early-adopter" [
            if ((some-decision = "install" and extent != "Timisoara" and item 0 some-state = "heat")
              or (some-decision = "install" and extent != "Timisoara" and item 0 some-state = "new-technology" and ticks > tick-new-technology)
              or (some-decision = "install" and extent = "Timisoara" and item 0 some-state = "gas")
              or (some-decision = "install" and extent = "Timisoara" and item 0 some-state = "heat" and awareness-campaign?  )) [
              ;debug (word "consult-on?: early-adopter " some-decision " " item 0 some-state)
              let my-new-energy-provider nobody
              ifelse extent = "Timisora" [
                set my-new-energy-provider one-of energy-providers with [member? "gas" table:values energy-type]
              ]
              [
                set my-new-energy-provider one-of energy-providers with [name = "AHP" or name = "Colterm"]
              ]
              if my-new-energy-provider = nobody [
                err "consult-on?: cannot find new energy provider"
              ]
              let my-tariff one-of [table:keys retail-unit-cost] of my-new-energy-provider
              ifelse exceeds-current-yearly-costs? my-new-energy-provider my-tariff [
                set against against + 1
              ]
              [
                ifelse awareness-campaign? [
                  set for for + 1
                  debug (word "consult-on?: We have an EARLY ADOPTER because of an awareness campaign")
                ]
                [
                  let who-to-consult nobody
                  ifelse use-most-trusted?  [
                    let who-to-consult-knows my-knows with [ network = "family" or network = "neighbour" or network = "social" or network = "work" or network = "school" or network = "community" or network = "advice" ]
                    if count who-to-consult-knows > max-nof-consultees [
                      set who-to-consult-knows max-n-of max-nof-consultees  who-to-consult-knows [  position network [trust] of me ]
                    ]
                    set who-to-consult  (turtle-set [other-end] of who-to-consult-knows)
                  ]
                  [
                    set who-to-consult up-to-n-of max-nof-consultees (turtle-set [other-end] of my-knows with [ network = "family" or network = "neighbour" or network = "social" or network = "work" or network = "school" or network = "community" or network = "advice" ] )
                  ]

                  let my-tally 0
                  let my-total 0

                  ask who-to-consult [

                    let our-knows one-of my-knows with [other-end = me]
                    let my-trust [trust] of me
                    if length my-trust = 0 [
                      error (word "Trust of " me " is empty")
                    ]
                    if not member? [network] of our-knows my-trust [
                      error (word "\"" [network] of our-knows "\" isn't in trust rankings [" (reduce [ [ string next ] -> (word string ", " next) ] my-trust) "] of " ([who] of me))
                    ]
                    let trust-rank 1 + position [network] of our-knows my-trust
                    set my-total my-total + b ^ trust-rank
                    ifelse is-advisory-body? self [
                      set my-tally my-tally + b ^ trust-rank
                    ]
                    [
                      let some-friend self
                      let friend-recommendation? false
                      let friend-household some-friend
                      let friend-building nobody
                      if not is-household? some-friend [
                        set friend-household one-of out-member-of-neighbors
                      ]
                      ask friend-household [
                        set friend-building one-of in-resident-neighbors
                      ]
                      if [table:get has? "heat"] of friend-building [
                        let friend-total-nof-payments length [history-of-temperature] of my-household
                        let friend-times-warm-enough length filter [ temp -> is-number? temp and temp > 15 ] [history-of-temperature] of my-household
                        if friend-times-warm-enough >= friend-total-nof-payments / 2 [
                          set friend-recommendation? true
                        ]
                      ]
                      set my-total my-total + b ^ trust-rank
                      if friend-recommendation? [
                        set my-tally my-tally + b ^ trust-rank
                      ]
                      if remember-recommendations? [
                        table:put recommendations [who] of me (list some-decision friend-recommendation? me)
                      ]
                    ]
                  ]
                  ifelse my-tally >= my-total / 2 [
                    set for for + 1
                    debug (word "consult-on?: We have an EARLY ADOPTER")
                  ]
                  [
                    set against against + 1
                  ]
                ]
              ]
            ]
          ]
          heuristic-type = "majority" [
            ;debug (word "consult-on?: majority " some-decision " " item 0 some-state)
            let who-to-consult (turtle-set [other-end] of my-knows with [ network = "family" or network = "neighbour" or network = "social" or network = "work" or network = "school" or network = "community" or network = "advice" ])
            ; HERE
            let some-threshold 0
            ask who-to-consult [
              ifelse is-advisory-body? self [
                set some-threshold some-threshold + 1
              ]
              [
                let some-household self
                if not is-household? self [
                  set some-household one-of out-member-of-neighbors
                ]

                if (([heating-system] of some-household = "heat" and extent != "Timisoara") or
                  ([heating-system] of some-household = "new-technology" and extent != "Timisoara" and ticks > tick-new-technology) or
                  ([heating-system] of some-household = "gas" and extent = "Timisoara") or
                  ([heating-system] of some-household = "heat" and extent = "Timisoara" and awareness-campaign?)) [
                  set some-threshold some-threshold + 1
                ]
              ]
            ]
            ifelse count who-to-consult > 0 [
              ifelse (some-threshold / (count who-to-consult)) * 100 >= adoption-likelihood-threshold  or
              (awareness-campaign? and (some-threshold / (count who-to-consult)) * 100 >= adoption-likelihood-threshold * reduce-threshold-by / 100) [
                set for for + 1
                debug (word "consult-on?: We have one from MAJORITY")
              ]
              [
                set against against + 1
              ]
            ]
            [
              set against against + 1
            ]
          ]
          heuristic-type = "laggard" [
            if ((some-decision = "install" and extent != "Timisoara" and item 0 some-state = "heat")
              or (some-decision = "install" and extent != "Timisoara" and item 0 some-state = "new-technology" and ticks > tick-new-technology)
              or (some-decision = "install" and extent = "Timisoara" and item 0 some-state = "gas")
              or (some-decision = "install" and extent = "Timisoara" and item 0 some-state = "heat" and awareness-campaign?  )) [

              ;debug (word "consult-on?: laggard " some-decision " " item 0 some-state)

              ask my-building [
                (ifelse
                  table:get has? "heat" and extent != "Timisoara" [
                    set for for + 1
                  ]
                  table:get has? "gas" and extent = "Timisoara" [
                    set for for + 1
                  ]
                  table:get has? "heat" and extent = "Timisoara" and awareness-campaign? [
                    set for for + 1
                  ]
                  [
                    set against against + 1
                  ]
                )
              ]
            ]
          ]
          [
            set against against + 1
          ]
        )
      ]
    ]
  ]
  if for >= against [
    set outcome? true
  ]

  if memory? and trusters != nobody and use-cbr? [
    ask trusters [
      let case cbr:add case-base some-state some-decision outcome?
    ]
  ]
  output-decision some-decision some-state outcome?
  report outcome?
end

; {observer} create-a-random-business

to create-a-random-business [ some-name ]

  ;debug (word "create-a-random-business: " some-name " starts...")
  set name some-name
  set payment-for table:make
  set payment-to table:make
  set payment-name table:make
  if use-cbr? [
    set case-base cbr:new
    cbr:lambda case-base simple-comparator
  ]
  set recommendations table:make

  ; Given that the average house is 90m^2 or 968.752 square feet (https://www.dwh.co.uk/advice-and-inspiration/average-house-sizes-uk/ 2021-02-03)
  ; Taken from here these are 64 commercial properties (https://propertylink.estatesgazette.com/retail-for-rent/aberdeen on 2020-02-03)
  ; The mean square footage is 3312.015625 on 64 randomly selected commercial properties with a
  ; standard deviation of 3991.2765.

  ; So on average the a commercial property is 3312 / 969 times as big with the standard deviation as shown above.

  set heating-system ""
  ; TODO an estimate but sufficient for now
  ; So using the stats for a residential house as a basis; average as 3100 minimum energy requirement per year
  ; and heating as 12000 on average.
 ; https://www.ofgem.gov.uk/data-portal/retail-market-indicators) on 2020-10-05 -> Prices and profits -> Methodology
  set units-of-energy-per-day-for-heating  random-normal (3312 / 969 * 12000 / 365) (3312 / 969 * 12000 / 365) * (3991 / 3312)
  set min-electrical-units-of-energy-per-day random-normal (3312 / 969 * 3100 / 365) (3312 / 969 * 3100 / 365) * (3991 / 3312)

  set units-of-energy-used table:make
  table:put units-of-energy-used "electric" 0
  table:put units-of-energy-used "gas" 0
  table:put units-of-energy-used "heat" 0
  if tick-new-technology >= 0 [
    table:put units-of-energy-used "new-technology" 0
  ]

  set last-bill 0
  set balance 0

  ;  I am presuming we have electricity if it is available.
  set uses? table:make
  table:put uses? "electric" false
  if [table:get has? "electric"] of one-of resident-neighbors [
    table:put uses? "electric" true
    set heating-system "electric"
    ; TODO an estimate but sufficient for now
    let electricity-company one-of energy-providers with [
      member? "electric" table:values energy-type]
    let electricity-tariff one-of (filter
      [some-tariff -> [table:get energy-type some-tariff] of
      electricity-company = "electric"]
      [table:keys energy-type] of electricity-company )
    let this-payment (word who "-" length table:keys payment-for)
    table:put payment-for this-payment "electric"
    table:put payment-name this-payment electricity-tariff
    table:put payment-to this-payment electricity-company
  ]

  table:put uses? "heat" false
  if [table:get has? "heat"] of one-of resident-neighbors [
    ; TODO an estimate but sufficient for now
    table:put uses? "heat" one-of [true false]
    if table:get uses? "heat" [
      set heating-system "heat"
      ; TODO this is an estimate but will do for now.
      let heat-network-company one-of energy-providers with [
        member? "heat" table:values energy-type]
      let heat-network-tariff one-of (filter
        [some-tariff -> [table:get energy-type some-tariff] of
        heat-network-company = "heat"]
        [table:keys energy-type] of heat-network-company)
      let this-payment (word who "-" length table:keys payment-for)
      table:put payment-for this-payment "heat"
      table:put payment-name this-payment heat-network-tariff
      table:put payment-to this-payment heat-network-company
    ]
  ]

  table:put uses? "gas" false
  if heating-system != "gas" and
    [table:get has? "gas"] of one-of resident-neighbors [
    table:put uses? "gas" one-of [true false]
    if table:get uses? "gas" [
      set heating-system "gas"
      ; TODO this is an estimate but will do for now.
      let gas-company one-of energy-providers with [
        member? "gas" table:values energy-type]
      let gas-tariff one-of (filter
        [some-tariff -> [table:get energy-type some-tariff] of
          gas-company = "gas"]
        [table:keys energy-type] of gas-company)
      let this-payment (word who "-" length table:keys payment-for)
      table:put payment-for this-payment "gas"
      table:put payment-name this-payment gas-tariff
      table:put payment-to this-payment gas-company
    ]
  ]
  ;debug (word "create-a-random-business: " some-name " ...ends.")
end

; {household} create-a-random-household

to create-a-random-household [ has-electricity? has-gas? has-heat-network?]

  ;debug (word "create-a-random-household [ " has-electricity? " " has-gas? " " has-heat-network? " ] starts...")
  let this-household self

  set name who
  set income 0
  let minimum-income-required 0
  set current-temperature temperature
  set money-spent 0
  let housing-benefit 0

  set hidden? true
  set wants-to-join? false

  set heating-system ""

  set recommendations table:make

  set last-bill 0
  set monthly-fuel-payment 0
  set switched-heating-off? false
  set payment-for table:make
  set payment-to table:make
  set payment-name table:make
  set attitude table:make
  set uses? table:make
  set contract-expires 0
  set rent-includes? table:make
  set requires-maintenance? table:make
  set serviced? table:make

  set fuel-poverty 0
  set history-of-fuel-poverty []
  set history-of-temperature []
  set history-of-units-used-for-heating []

  ; TODO Need to make sure that the Mortgage is relevant to the property
  set owns-property? false
  if random-float 1.0 < probability-of-owning-property [
    set owns-property? true
  ]
  set owns-outright? false
  ifelse owns-property? [
    if random-float 1.0 < probability-of-owning-property-outright [
      set owns-outright? true
    ]
    if not owns-outright? [
      let this-bank one-of banks
      let this-payment (word who "-" length table:keys payment-for)
      table:put payment-for this-payment "mortgage"
      table:put payment-name this-payment one-of filter [
        loan-name ->
        [table:get purpose loan-name] of this-bank  = "mortgage" ]
        [table:keys purpose] of this-bank
      table:put payment-to this-payment this-bank
      informed-by this-bank
      let multiplier 1.0
      let some-frequency [table:get frequency [table:get payment-name this-payment] of this-household] of this-bank
      (ifelse
        some-frequency = "daily" [
          set multiplier 365 / 12
        ]
        some-frequency = "weekly" [
          set multiplier 52 / 12
        ]
        some-frequency = "quarterly" [
          set multiplier 4 / 12
        ]
      )
      set housing-benefit multiplier * [table:get payment [table:get payment-name this-payment] of this-household] of this-bank
      set minimum-income-required minimum-income-required + housing-benefit
    ]
  ]
  [
    let this-landlord one-of landlords with [not private?]
    if this-landlord = nobody or random-float 1.0 < probability-of-private-rental-vs-public [
      set this-landlord one-of landlords with [private?]
    ]
    let this-payment (word who "-" length table:keys payment-for)
    table:put payment-for this-payment "rent"
    table:put payment-name this-payment one-of
      [table:keys rent] of this-landlord
    table:put payment-to this-payment this-landlord
    informed-by this-landlord
    let multiplier 1.0
    let some-frequency [table:get frequency [table:get payment-name this-payment] of this-household] of this-landlord
    (ifelse
      some-frequency = "daily" [
        set multiplier 365 / 12
      ]
      some-frequency = "weekly" [
        set multiplier 52 / 12
      ]
      some-frequency = "quarterly" [
        set multiplier 4 / 12
      ]
    )
    set housing-benefit multiplier * [table:get rent [table:get payment-name this-payment] of this-household] of this-landlord
    set minimum-income-required minimum-income-required + housing-benefit
  ]

  ; https://www.ofgem.gov.uk/data-portal/retail-market-indicators) on 2020-10-05 -> Prices and profits -> Methodology
  ; I did a run on the propeties for sale on ASPC on aberdeen and what I got is that the average property has
  ; 6 rooms with a standard deviation of 3.55, so if we assume that size is proportional to energy expenditure
  ;
  ; then the standard deviation should scale by 3.55 / 6 * mean
  ; https://www.ovoenergy.com/guides/energy-guides/how-much-heating-energy-do-you-use.html for approximately how much is spent on heating and other things.
  set min-units-of-energy-per-day random-normal ((3100 / 365)  * 0.5)  ((3.55 / 6) *  (3100 / 365) * 0.5)
  while [min-units-of-energy-per-day <= 0] [
    set min-units-of-energy-per-day random-normal ((3100 / 365)  * 0.5)  ((3.55 / 6) *  (3100 / 365) * 0.5)
  ]
  ; https://www.ofgem.gov.uk/data-portal/retail-market-indicators) on 2020-10-05 -> Prices and profits -> Methodology

  set max-units-of-energy-per-day random-normal (3100 / 365) ((3100 / 365) * (3.55 / 6))
  while [max-units-of-energy-per-day <= min-units-of-energy-per-day or max-units-of-energy-per-day > (12000 + 3100) / 365] [
    set max-units-of-energy-per-day random-normal (3100 / 365) ((3100 / 365) * (3.55 / 6))
  ]

  set units-of-energy-used table:make
  table:put units-of-energy-used "electric" 0
  table:put units-of-energy-used "gas" 0
  table:put units-of-energy-used "heat" 0
  if tick-new-technology >= 0 [
    table:put units-of-energy-used "new-technology" 0
    table:put rent-includes? "new-technology" false
  ]

  set heating-status "working"

  table:put uses? "electric" false
  table:put rent-includes? "electric" false
  table:put requires-maintenance? "electric" false
  table:put serviced? "electric" false

  if has-electricity? [
    if not owns-property? and random-float 1.0 < probability-of-rent-including-utilities [
      table:put rent-includes? "electric" true
    ]
    table:put uses? "electric" true
    let electricity-company one-of energy-providers with [
      member? "electric" table:values energy-type]
    let electricity-tariff one-of (filter
      [some-tariff -> [table:get energy-type some-tariff] of
      electricity-company = "electric"]
      [table:keys energy-type] of electricity-company )
    if [table:get yearly-maintenance electricity-tariff] of
      electricity-company > 0 [
      table:put requires-maintenance? "electric" true
    ]
    let this-payment (word who "-" length table:keys payment-for)
    table:put payment-for this-payment "electric"
    table:put payment-name this-payment electricity-tariff
    table:put payment-to this-payment electricity-company
    informed-by electricity-company
    if not table:get rent-includes? "electric" [
      let some-frequency [table:get frequency [table:get payment-name this-payment] of this-household] of electricity-company
      let multiplier 1.0
      (ifelse
        some-frequency = "daily" [
          set multiplier 365 / 12
        ]
        some-frequency = "weekly" [
          set multiplier 52 / 12
        ]
        some-frequency = "quarterly" [
          set multiplier 4 / 12
        ]
      )
      set minimum-income-required minimum-income-required + multiplier * [table:get standing-charge [table:get payment-name this-payment] of this-household] of electricity-company
    ]
  ]
  table:put uses? "heat" false
  table:put rent-includes? "heat" false
  if has-heat-network? [
    if not owns-property? and
    random-float 1.0 < probability-of-rent-including-utilities [
      table:put rent-includes? "heat" true
    ]
    if random-float 1.0 < probability-of-central-heating-installed [
      table:put uses? "heat" true
    ]
    if table:get uses? "heat" [
      set heating-system "heat"
      let heat-network-company one-of energy-providers with [
        member? "heat" table:values energy-type]
      let heat-network-tariff one-of (filter
        [some-tariff -> [table:get energy-type some-tariff] of
        heat-network-company = "heat"]
        [table:keys energy-type] of heat-network-company)
      let this-payment (word who "-" length table:keys payment-for)
      table:put payment-for this-payment "heat"
      table:put payment-name this-payment heat-network-tariff
      table:put payment-to this-payment heat-network-company
      informed-by heat-network-company
      if not table:get rent-includes? "heat" [
        let some-frequency [table:get frequency [table:get payment-name this-payment] of this-household] of heat-network-company
        let multiplier 1.0
        (ifelse
          some-frequency = "daily" [
            set multiplier 365 / 12
          ]
          some-frequency = "weekly" [
            set multiplier 52 / 12
          ]
          some-frequency = "quarterly" [
            set multiplier 4 / 12
          ]
        )
        set minimum-income-required minimum-income-required + multiplier * [table:get standing-charge [table:get payment-name this-payment] of this-household] of heat-network-company
      ]
      if fixed-contract-length > -1 [
        ifelse setup? [
          set contract-expires fixed-contract-length
        ]
        [
          set contract-expires ticks + fixed-contract-length
        ]
      ]

    ]
  ]
  table:put uses? "gas" false
  table:put rent-includes? "gas" false
  table:put requires-maintenance? "gas" false
  table:put serviced? "gas" false
  if has-gas? and heating-system != "heat" [
    if not owns-property? and
    random-float 1.0 < probability-of-rent-including-utilities [
      table:put rent-includes? "gas" true
    ]
    if random-float 1.0 < probability-of-central-heating-installed [
      table:put uses? "gas" true
    ]
    if table:get uses? "gas" [
      set heating-system "gas"
      let gas-company one-of energy-providers with [
        member? "gas" table:values energy-type]
      let gas-tariff one-of (filter
        [some-tariff ->
        [table:get energy-type some-tariff] of gas-company = "gas"]
        [table:keys energy-type] of gas-company )
      if [table:get yearly-maintenance gas-tariff] of gas-company > 0 [
        table:put requires-maintenance? "gas" true
      ]
      let this-payment (word who "-" length table:keys payment-for)
      table:put payment-for this-payment "gas"
      table:put payment-name this-payment gas-tariff
      table:put payment-to this-payment gas-company
      informed-by gas-company
      if not table:get rent-includes? "heat" [
        let some-frequency [table:get frequency [table:get payment-name this-payment] of this-household] of gas-company
        let multiplier 1.0
        (ifelse
          some-frequency = "daily" [
            set multiplier 365 / 12
          ]
          some-frequency = "weekly" [
            set multiplier 52 / 12
          ]
          some-frequency = "quarterly" [
            set multiplier 4 / 12
          ]
        )
        set minimum-income-required minimum-income-required + multiplier * [table:get standing-charge [table:get payment-name this-payment] of this-household] of gas-company
      ]
    ]
  ]

  if heating-system = ""  [
    if random-float 1.0 < probability-of-central-heating-installed [
      set heating-system "electric"
    ]
  ]

  if heating-system != "" [
    ifelse heating-system != "heat" [
      ; @TODO - need stats on ages of system
      set heating-system-age floor( random-normal (15 * 365 / 2) (15 * 365 / 4 ) )
      ; https://www.help-link.co.uk/advice-centre/how-long-do-boilers-last/
      ; https://www.boilerguide.co.uk/sadia-challenges-title-uks-oldest-heating-system

      set boiler-size random-normal ((max-boiler-size - min-boiler-size) / 2 + min-boiler-size)
      (max-boiler-size - min-boiler-size) / 4
      ; https://accendoreliability.com/the-range-rule/#:~:text=The%20standard%20deviation%20is%20approximately,minimum%2C%20to%20find%20the%20range.
      if boiler-size < min-boiler-size [ set boiler-size min-boiler-size ]
      if boiler-size > max-boiler-size [
        set boiler-size max-boiler-size
      ]
    ]
    [
      set heating-system-age 0
      set boiler-size max-boiler-size
    ]
  ]

  ; TODO an estimate - need data to initialise this
  set last-energy-provider ""

  ; https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=3&cad=rja&uact=8&ved=2ahUKEwjTmp2ck_XhAhWTSRUIHZf_CKoQFjACegQICxAI&url=https%3A%2F%2Fwww.census.gov%2Fprod%2Fcen2010%2Fbriefs%2Fc2010br-14.pdf&usg=AOvVaw0L_MhJzeqQsdJrkBUu35FZ
  ; average family size is 2.58
  ; I really dislike the random normal distribution, but it is probably right
  ; in this case.
  ; The standard deviation will smallest is 1 largest is 15 (https://www.bbc.co.uk/news/uk-scotland-tayside-central-52426962)
  ; So the standard deviation is 7 / 2 which is 3.
  let nof-individuals int (random-normal 2.58 3.5)
  if nof-individuals < 1 [
    set nof-individuals 1
  ]
  set income 0
  ask my-all-attends [
    die
  ]
  create-a-random-set-of-values
  foreach n-values nof-individuals [i -> i ] [ i ->
    create-a-random-person this-household -1 ""
  ]
  ; Okay we need to make sure that if this household does not consist of kids, so there must be at least one adult.
  while [ [age] of max-one-of in-member-of-neighbors [age] < age-start-work ] [
    ask one-of in-member-of-neighbors [
      die
    ]
    create-a-random-person this-household -1 ""
  ]
  ifelse resolution = "person" [
    ask in-member-of-neighbors [
      let family-member self
      ask family-member [
        ask [in-member-of-neighbors] of this-household [
          if self != family-member [
            friend family-member "family"
          ]
        ]
      ]
    ]

    let loop-count 0
    set dynamic one-of family-dynamics
    if dynamic = "matriarchal" or dynamic = "patriarchal" [
      while [ (max-one-of in-member-of-neighbors with [
        (sex = "female" and [dynamic] of this-household = "matriarchal") or
        (sex = "male" and [dynamic] of this-household = "patriarchal") ]
        [age] = nobody) and (dynamic = "patriarchal" or dynamic = "matriarchal")  ] [
        ; Because this confused the hell out of me, what this is doing
        ; is looping until there is somebody who is male if the the dynamic
        ; is patriarchal is selected at random, or female is matriarchal
        ; is randomly chosen. This has to be the oldest person in
        ; the household. Which is a bit of an asummption, but hey-ho.
        ; if there is only one family dynamic and it is either matriarchal or patriachal, then we are not going to change the dynamic, we are going to change the sex of the person!
        set dynamic one-of family-dynamics
        if length family-dynamics = 1 and (dynamic = "patriarchal" or dynamic = "matriarchal") [
          ifelse dynamic = "matriarchal" [
            ask max-one-of in-member-of-neighbors [age] [
              set sex "female"
            ]
          ]
          [
            ask max-one-of in-member-of-neighbors [age] [
              set sex "male"
            ]
          ]
        ]
        set loop-count loop-count + 1
        if loop-count > 1000 [
          error "Looping here"
        ]
      ]
    ]
  ]
  [
    let loop-count 0
    while [ not any? in-member-of-neighbors with [age > age-start-work] ] [
      create-a-random-person this-household age-start-work + random (max-age - age-start-work) ""
      set loop-count loop-count + 1
      if loop-count > 1000 [
        error "Looping here"
      ]
    ]
  ]

  if consult-social-networks? and resolution = "household" [
    set trust []
    ifelse table:has-key? trust-values "*" [
      set trust table:get trust-values "*"
    ]
    [
      err "create-a-random-household: Trust requested by trust table is empty."
    ]
    add-to-network
      neighbourhood-network
      "neighbour"
      neighbourhood-network-rewire-or-connection-probability
      neighbourhood-network-degree
      neighbourhood-network-reaches-spec
    add-to-network
      social-network
      "social"
      social-network-rewire-or-connection-probability
      social-network-degree
      social-network-reaches-spec
    ask msms [
      if random-float 1.0 < listens-to-msm [
        informs this-household
      ]
    ]
    ask advisory-bodies [
      informs this-household
    ]
  ]
  if resolution = "household" [
    ifelse  use-cbr? [
      set case-base cbr:new
      cbr:lambda case-base simple-comparator
      if limit-case-base-size? [
        cbr:set-max-size case-base maximum-case-base-size
      ]
      foreach (up-to-n-of initial-cases-per-entity case-base-pool) [case ->
        let ignore cbr:add case-base
        table:get case "state"
        table:get case "decision"
        table:get case "outcome"
      ]
    ]
    [
      let some-value random 100
      (ifelse
        some-value <= innovators [
          set heuristic-type "innovator"
        ]
        some-value > innovators and some-value <= early-adopters [
          set heuristic-type "early-adopter"
        ]
        some-value > early-adopters and some-value <= majority [
          set heuristic-type "majority"
          set adoption-likelihood-threshold triangular-distribution min-adoption-likelihood max-adoption-likelihood mode-adoption-likelihood
        ]
        [
          set heuristic-type "laggard"
        ]
      )
    ]
  ]
  ; TODO no idea about the following
  ; https://www.gov.uk/government/statistics/family-food-201718/family-food-201718
  let mean-random-costs 27.54 * 52 / 12
  set ongoing-costs (count in-member-of-neighbors)  * random-normal mean-random-costs 2 * mean-random-costs / 4
  if ongoing-costs > count in-member-of-neighbors  * 2 * mean-random-costs or ongoing-costs < 0 [
    set ongoing-costs mean-random-costs * count in-member-of-neighbors / 12
  ]
  set minimum-income-required minimum-income-required + ongoing-costs
  let some-community-charge [table:get community-charge council-tax-band] of one-of in-resident-neighbors / 12
  set minimum-income-required minimum-income-required + some-community-charge

  if all? in-member-of-neighbors [ on-benefits? or age < age-start-work ] [
    ask one-of in-member-of-neighbors with [age >= age-start-work ] [
      set income income + some-community-charge
    ]
    set income income + some-community-charge
    ask one-of in-member-of-neighbors with [age >= age-start-work] [
      set income income + housing-benefit
    ]
    set income income + housing-benefit
  ]

  let loop-count 0
  while [income < minimum-income-required] [
    let some-income 0
    let some-sex ""
    let some-age 0
    ask one-of in-member-of-neighbors with [age >= age-start-work] [
      set some-income income
      set some-sex sex
      set some-age age
      die
    ]
    set income income - some-income
    create-a-random-person this-household some-age some-sex
    set loop-count loop-count + 1
      if loop-count > 1000 [
      error "Looping here"
    ]

  ]

  ; Finally if we are at household level, then transfer all the knows links to institutitions to the eldest member of the family (I know, I know: assumptions).

  if resolution = "person" [
    let the-eldest-member-of-the-household max-one-of in-member-of-neighbors [age]
    ask my-knows [
      let target-institution other-end
      let network-type network
      ask the-eldest-member-of-the-household [
        friend target-institution network-type
      ]
      die
    ]
  ]

  ; Let's set some ethnicity - I am really uncomfortable doing this, but hey-ho
  ; First uncomfortable assumnption - all members of a household are the same ethnicity.
  (ifelse
    random 100 < ethnicity-1 [
      set ethnicity 1
    ]
    random 100 < ethnicity-2 [
      set ethnicity 2
    ]
    random 100 < ethnicity-3 [
      set ethnicity 3
    ]
    random 100 < ethnicity-4 [
      set ethnicity 4
    ]
    random 100 < ethnicity-5 [
      set ethnicity 5
    ]
    [
      set ethnicity 0
    ]
  )
  ask in-member-of-neighbors [
    set ethnicity [ethnicity] of this-household
  ]


  set balance income
  ;debug (word "create-a-random-household: ...ends.")

end

; {observer} create-a-random-institution

to create-a-random-institution [ some-name some-type ]

  create-institutions 1 [
    set hidden? true
    if use-cbr? [
      set case-base cbr:new
      cbr:lambda case-base simple-comparator
    ]
    set recommendations table:make


    set name some-name
    set organization-type some-type
    set xcor min-pxcor + random (max-pxcor - min-pxcor)
    set ycor min-pycor + random (max-pycor - min-pycor)
    set catchment-radius 0
    set color lime
    if some-type = "community" or some-type = "school" [
      ; TODO - again this code is a guess, I do not know what these are in
      ; reality.
      set catchment-radius max-catchment / 4 + random (3 * max-catchment / 4 )
      ; draw-circle pxcor pycor catchment-radius
    ]
    set calendar []
    set fixed-holidays []
    set floating-holidays 0
    if organization-type = "work" [
      ; https://www.gov.scot/publications/bank-holidays/
      ; date --date YYYYMMDD "+%j"
      ; 1 January 	Tuesday 	New Year's Day
      ; 2 January 	Wednesday 	2 January
      ; 19 April 	Friday 	Good Friday
      ; 6 May 	Monday 	Early May bank holiday
      ; 27 May 	Monday 	Spring bank holiday
      ; 5 August 	Monday 	Summer bank holiday
      ; 2 December 	Monday 	St Andrew's Day
      ; 25 December 	Wednesday 	Christmas Day
      ; 26 December 	Thursday 	Boxing Day
      set fixed-holidays [1 2 109 126 147 359 217 336 359 360]
      set floating-holidays 20
      ; https://www.gov.uk/holiday-entitlement-rights/holiday-pay-the-basics
      set calendar [1 2 3 4 5]
      ; https://www.gov.scot/publications/summary-statistics-schools-scotland-8-2017-edition/pages/8/
      set probability-of-attendance 0.984
      if working-from-home? [
        ;https://www.statista.com/statistics/280749/monthly-full-time-weekly-hours-of-work-in-the-uk-by-gender-year-on-year/#:~:text=Full%2Dtime%20weekly%20hours%20of%20work%2C%20by%20gender%202000%2D2019&text=In%202019%2C%20male%20full%2Dtime,of%2034.5%20hours%20a%20week.
        set working-from-home ((minimum-wfh / 100) + random-float( 1 - (minimum-wfh / 100 ))) * ( 34.5 + 38 ) / 10
      ]
    ]
    if organization-type = "school" [
      ; https://www.aberdeencity.gov.uk/services/education-and-childcare/view-school-term-and-holiday-dates
      ;Term 3
      ;7 January 2019 to 29 March 2019
      ;
      ;    Term Starts - Monday 7 January 2019
      ;    Mid Term Holiday - Monday 11 February 2019
      ;    In-Service Day - Tuesday 12 February 2019
      ;    In-Service Day - Wednesday 13 February 2019
      ;    Term Ends - Friday 29 March 2019
      ;    Spring Holiday - Monday 1 April to Friday 12 April 2019
      ;
      ;Term 4
      ;15 April 2019 to 5 July 2019
      ;
      ;    Term Starts - Monday 15 April 2019
      ;    Good Friday Holiday - Friday 19 April 2019
      ;    May Day Holiday - Monday 6 May 2019
      ;    In-Service Day - Tuesday 7 May 2019
      ;    Term Ends - Friday 5 July 2019
      ;
      ;2019-20
      ;Term 1
      ;20 August 2019 to 11 October 2019
      ;
      ;    In-Service Day - Monday 19 August 2019
      ;    Term Starts - Tuesday 20 August 2019
      ;    September Holiday - Friday 20 September to Monday 23 September
      ;      2019
      ;    Term Ends - Friday 11 October 2019
      ;    October Holiday - Monday 14 October to Friday 25 October 2019
      ;
      ;Term 2
      ;28 October 2019 to 20 December 2019
      ;
      ;    Term Starts - Monday 28 October 2019
      ;    In-Service Day - Friday 22 November 2019
      ;    Term Ends - Friday 20 December 2019
      ;    Christmas Holiday - Monday 23 December 2019 - Friday 3 January 2020
      ;
      set fixed-holidays (list n-values 7 [ i -> i + 1]  42 43 44
        n-values 12 [i -> i + 91] 109 126 127
        n-values 39 [ i -> i + 189] 231 232
        n-values 4 [ i -> i + 263]
        n-values 12 [ i -> i + 287 ] 326
        n-values 12 [i -> i + 354])
      set calendar [1 2 3 4 5]
      set floating-holidays 0
      ; https://www.gov.scot/publications/summary-statistics-schools-scotland-8-2017-edition/pages/8/
      set probability-of-attendance 0.936
      if working-from-home? [
        ; https://www.quora.com/How-many-hours-a-day-are-UK-schools-How-many-years-of-school-do-UK-kids-have-How-old-are-they-when-they-graduate
        set working-from-home ((minimum-wfh / 100) + random-float( 1 - (minimum-wfh / 100 ))) * 6.0

      ]
    ]
    if organization-type = "community" [
      set fixed-holidays [1 2 109 126 147 359 217 336]
      set calendar (list one-of [1 2 3 4 5])
      set floating-holidays 0
      set probability-of-attendance random-float 1
      set working-from-home 0
    ]
    ; The case base will only be populated if there are cases in the case
    ; base that bear the name of this institution. So the case base will
    ; never be populated randomly.
  ]
end

; {household} create-a-random-person

to create-a-random-person [some-household some-age some-sex]

  ;debug "create-a-random-person: started..."
  hatch-persons 1 [

    let this-person self
    set name who
    create-member-of-to some-household

    set recommendations table:make

    set on-benefits? false

    ifelse some-age >= 0 [
      set age some-age
    ]
    [
      ; For standard deviations, using this estimate from here:
      ; https://www.thoughtco.com/range-rule-for-standard-deviation-3126231#:~:text=The%20range%20rule%20tells%20us,estimate%20of%20the%20standard%20deviation.

      set age random-normal mean-age (max-age / 4)

      if age < 0 [ set age 0 ] ; This is the truly problemantic thing about
                               ; normal distribution - there is a small but
                               ; definite possibility that you can have a
                               ; negative age!
      if age > max-age [ set age max-age ]
    ]

    ifelse some-sex != "" [
      set sex some-sex
    ]
    [
      ifelse random-float 1.0 < binary-gender-probability [
        set sex "male"
      ]
      [
        set sex "female"
      ]
    ]

    set income 0
    if age >= age-start-work [
      ifelse random-float 1.0 < chances-of-working [
        let employer one-of institutions with [organization-type = "work"]
        goes-to employer
        set income (minimum-monthly-wage + (random-exponential (mean-monthly-wage - minimum-monthly-wage)))
        if income > maximum-monthly-wage [
          set income maximum-monthly-wage
        ]
      ]
      [
        set on-benefits? true
        set income monthly-benefits
        if UBI? and income < ubi [
          set income ubi
        ]
      ]

      ask some-household [
        set income income + [income] of this-person
      ]
    ]
    if age >= age-start-school and age < age-start-work [
      let school one-of institutions with [organization-type = "school" and
        catchment-contains? some-household ]
      if school = nobody [
        set school one-of institutions with [organization-type = "school" ]
      ]
      goes-to school
    ]

    create-a-random-set-of-values
    if age > age-start-work [
      ask institutions with [ organization-type = "community" ] [
        if random-float 1.0 <= probability-of-joining-community-organization [
          let some-institution self
          ask this-person [
            goes-to some-institution
          ]
        ]
      ]
    ]
    if consult-social-networks? and resolution = "person" [
      set trust []
      if table:has-key? trust-values "*" [
        set trust table:get trust-values "*"
      ]
      add-to-network
        neighbourhood-network
        "neighbour"
        neighbourhood-network-rewire-or-connection-probability
        neighbourhood-network-degree
        neighbourhood-network-reaches-spec
      add-to-network
        social-network
        "social"
        social-network-rewire-or-connection-probability
        social-network-degree
        social-network-reaches-spec
      ask msms [
        if random-float 1.0 < listens-to-msm [
          informs this-person
        ]
      ]
      ask advisory-bodies [
        informs this-person
      ]
    ]
    if resolution = "person" [

      ifelse use-cbr? [
        set case-base cbr:new
        cbr:lambda case-base simple-comparator
        if limit-case-base-size? [
          cbr:set-max-size case-base maximum-case-base-size
        ]
        foreach (up-to-n-of initial-cases-per-entity case-base-pool) [case ->
          let ignore cbr:add case-base
          table:get case "state"
          table:get case "decision"
          table:get case "outcome"
        ]
        ;debug (word "Added " length cbr:all case-base " cases to " who)
      ]
      [
        let some-value random 100
        (ifelse
          some-value <= innovators [
            set heuristic-type "innovator"
          ]
          some-value > innovators and some-value <= early-adopters [
            set heuristic-type "early-adopter"
          ]
          some-value > early-adopters and some-value <= majority [
            set heuristic-type "majority"
            set adoption-likelihood-threshold triangular-distribution min-adoption-likelihood max-adoption-likelihood mode-adoption-likelihood
          ]
          [
            set heuristic-type "laggard"
          ]
        )
      ]
    ]
  ]

  ;debug "create-a-random-person: ...ended."

end

; {household|person} load-a-person-from-table



; {household | person } create-a-random-set-of-values

to create-a-random-set-of-values
  foreach surveyed-values [
    key ->
    table:put attitude key get-random-value
  ]
end

; {observer|ad-hoc} create-random-cases

to create-random-cases

  let weighted-possible-decisions (sentence
    repeat-string "install" 1; install central heating - this includes
                             ; upgrading the heating system after need for
                             ; replacement due to break-down
    repeat-string "abandon" 1
    repeat-string "repair" 1
    repeat-string "get-advice" 1
    repeat-string "follow-advice" 4
  )
  foreach weighted-possible-decisions [ some-decision ->
    if not member? some-decision possible-decisions [
      error (word "Illegal decision-context: " some-decision)
    ]
  ]

  let weighted-decision-contexts (sentence
    repeat-string "power-restored-after-regional-outage" 1
    repeat-string "power-restored-after-city-wide-outage" 1
    repeat-string "moved-in" 10
    repeat-string "replace" 10
    repeat-string "awareness-raising-event" 0
    repeat-string "yearly-maintenance" 1
    repeat-string "clean-install" 6
    repeat-string "connection" 6
    repeat-string "street-voting" 6
  )
  foreach weighted-decision-contexts [ some-context ->
    if not member? some-context decision-contexts [
      error (word "Illegal decision-context: " some-context)
    ]
  ]

  ; decisions and context are global and should go in the "setup" section, but
  ; keeping them here, until this is coded.

  ; ...household level

  ; affordability
  ; attitudes

  ; outcomes:

  ; true - do it
  ; false - don't do it

  ; sampliing from an existing pool is a logical choice made when selecting for the case-base

  ; Note the (unnest (list... )) structure here. So are building a list and then turning it
  ; into a flat list.

  foreach n-values (size-of-initial-case-base-pool - length case-base-pool) [i -> i][i ->
    let case table:make
    let this-decision one-of weighted-possible-decisions
    let this-energy-type one-of energy-types
    let this-institution nobody
    if this-decision = "get-advice" [
      set this-energy-type "heat"
      set this-institution one-of advisory-bodies with [
        member? this-energy-type table:values energy-type]
      table:put case "state" unnest (list
        this-energy-type
        one-of weighted-decision-contexts
        [name] of this-institution
        random-values)
    ]
    if this-decision = "follow-advice" [
      set this-energy-type "heat"
      ask one-of advisory-bodies [
        set this-institution one-of table:values recommended-institution
        table:put case "state" unnest (list
          this-energy-type
          one-of weighted-decision-contexts
          [name] of this-institution
        )
      ]
    ]
    if this-decision = "install" [
      set this-energy-type "heat"
      set this-institution one-of energy-providers with [
        member? this-energy-type table:values energy-type]
      table:put case "state" unnest (list
        this-energy-type
        one-of weighted-decision-contexts
        [name] of this-institution
        random-values
        random-affordability
      )
    ]
    if this-decision = "abandon" [
      set this-institution one-of energy-providers with [
        member? this-energy-type table:values energy-type]
      table:put case "state" unnest (list
        this-energy-type
        one-of weighted-decision-contexts
        [name] of this-institution
        random-affordability
      )
    ]
    if this-decision = "repair" [
      set this-institution one-of energy-providers with [
        member? this-energy-type table:values energy-type]
      table:put case "state" unnest (list
        this-energy-type "repair"
        [name] of this-institution
        random-affordability
      )
    ]
    table:put case "decision" this-decision
    table:put case "outcome" one-of [true false]
    table:put case "name" "*"
    set case-base-pool lput case case-base-pool
  ]


end

; {building} create-some-associations

to create-some-associations [ some-households ]

  if not table:get has? "heat" [
    stop
  ]
  if metering = "individual" [
    stop
  ]
  let some-energy-provider one-of energy-providers with [ member? "heat" table:values energy-type and member? "association" table:keys energy-type  ]
  if some-energy-provider = nobody [
    err "create-some-association: Trying to specify associations for payment without tariff being present."
  ]
  (ifelse
    metering = "building" [
      hatch-associations 1 [
        let this-association self
        ask some-households [
          create-associate-to this-association
        ]
        set payment-is-to some-energy-provider
        set payment-name "association"
        set payment-frequency [table:get frequency "association"] of some-energy-provider
        set surcharge truncated-normal mean-surcharge min-surcharge max-surcharge
      ]
    ]
    metering = "group" [
      let remaining-households some-households
      hatch-associations ceiling ((count some-households) / metering-group-size ) [
        let this-association self
        set payment-is-to some-energy-provider
        set payment-name "association"
        set payment-frequency [table:get frequency "association"] of some-energy-provider
        set surcharge truncated-normal mean-surcharge min-surcharge max-surcharge
        ask up-to-n-of metering-group-size remaining-households  [
            create-associate-to this-association
          let some-household self
          set remaining-households remaining-households with [ self != some-household ]
        ]
      ]
    ]
  )

end


to debug [ message ]
  if DEBUG_LEVEL = "full" [
    msg(word " DEBUG: " message)
  ]
end

to-report decision-total [some-decision]
  if is-number? decision-record or not table:has-key? decision-record some-decision [
    report 0
  ]
  report item 0 (table:get decision-record some-decision)
end

to-report decision-for [some-decision]
  if is-number? decision-record or not table:has-key? decision-record some-decision [
    report 0
  ]
  report item 1 (table:get decision-record some-decision)
end

to-report decision-against [some-decision]
  if is-number? decision-record or not table:has-key? decision-record some-decision [
    report 0
  ]
  report item 2 (table:get decision-record some-decision)
end

to-report decision-p-for [some-decision]
  if is-number? decision-record or not table:has-key? decision-record some-decision [
    report 0
  ]
  let entry table:get decision-record some-decision
  ifelse item 0 entry = 0 [
    report 0
  ] [
    report (item 1 entry) / (item 0 entry)
  ]
end

; Lambda for the case-base therefore no agent should, and nowhere in ths code
; should call this

; { person | household } delete-from-network

to delete-from-network [some-network]
  ask my-knows with [ network = some-network ] [
    die
  ]
end


to demo-movies
  ask buildings [
    (
      ifelse movie-type = "low-gas-prices" [
        ;   Low gas prices.
        if  member? (ticks mod 365) [1 31 59 90 120 151 181 212 243 273 304 334 364]  [
          let some-var random-float 1.0
          ifelse building-fuel-poverty = 1  [
            if some-var > .99 and table:get has? "gas" [
              set building-fuel-poverty 2
            ]
            if some-var > .7 and not table:get has? "gas" [
              set building-fuel-poverty 2
            ]
            if some-var > .98 and some-var <= .99  and not table:get has? "gas" [
              set building-fuel-poverty 0
            ]
            if some-var > .5 and some-var <= .7  and table:get has? "gas" [
              set building-fuel-poverty 0
            ]
          ]
          [
            ifelse building-fuel-poverty = 2  [
              if some-var > .8 and some-var <= .9  and table:get has? "gas" [
                set building-fuel-poverty 1
              ]
              if some-var > .98 and some-var <= .99  and not table:get has? "gas" [
                set building-fuel-poverty 1
              ]
            ]
            [
              if some-var > .98 and some-var <= .99  and table:get has? "gas" [
                set building-fuel-poverty 1
              ]
              if some-var > .8 and some-var <= .85  and not table:get has? "gas" [
                set building-fuel-poverty 1
              ]
            ]
          ]
        ]

      ]
      movie-type = "high-gas-prices" [
        ;   Increasing gas prices.
        if  member? (ticks mod 365) [1 31 59 90 120 151 181 212 243 273 304 334 364]  [
          let some-var random-float 1.0
          ifelse building-fuel-poverty = 1  [
            if some-var > .99 and not table:get has? "gas" [
              set building-fuel-poverty 2
            ]
            if some-var > .7 and table:get has? "gas" [
              set building-fuel-poverty 2
            ]
            if some-var > .98 and some-var <= .99  and table:get has? "gas" [
              set building-fuel-poverty 0
            ]
            if some-var > .5 and some-var <= .7  and not table:get has? "gas" [
              set building-fuel-poverty 0
            ]
          ]
          [
            ifelse building-fuel-poverty = 2  [
              if some-var > .8 and some-var <= .9  and not table:get has? "gas" [
                set building-fuel-poverty 1
              ]
              if some-var > .98 and some-var <= .99  and table:get has? "gas" [
                set building-fuel-poverty 1
              ]
            ]
            [
              if some-var > .98 and some-var <= .99  and not table:get has? "gas" [
                set building-fuel-poverty 1
              ]
              if some-var > .8 and some-var <= .85  and table:get has? "gas" [
                set building-fuel-poverty 1
              ]
            ]
          ]
        ]

      ]
      movie-type = "high-connection-costs" [
        ask energy-providers with [ name =  "Aberdeen Heat and Power" ] [
          foreach table:keys installation-cost [ key ->
            table:put installation-cost key 100000
          ]
        ]
      ]
      movie-type = "low-connection-costs" [
        ask energy-providers with [ name =  "Aberdeen Heat and Power" ] [
          foreach table:keys installation-cost [ key ->
            table:put installation-cost key 0
          ]
        ]
      ]
      movie-type = "increase-fuel-prices" [
        ;   Increasing fuel prices.
        if  member? (ticks mod 365) [1 31 59 90 120 151 181 212 243 273 304 334 364]  [
          let some-var random-float 1.0
          ifelse building-fuel-poverty = 1  [
            if some-var > .99 and table:get has? "heat" [
              set building-fuel-poverty 2
            ]
            if some-var > .7 and not table:get has? "heat" [
              set building-fuel-poverty 2
            ]
            if some-var > .98 and some-var <= .99  and not table:get has? "heat" [
              set building-fuel-poverty 0
            ]
            if some-var > .5 and some-var <= .7  and table:get has? "heat" [
              set building-fuel-poverty 0
            ]
          ]
          [
            ifelse building-fuel-poverty = 2  [
              if some-var > .8 and some-var <= .9  and table:get has? "heat" [
                set building-fuel-poverty 1
              ]
              if some-var > .98 and some-var <= .99  and not table:get has? "heat" [
                set building-fuel-poverty 1
              ]
            ]
            [
              if some-var > .98 and some-var <= .99  and table:get has? "heat" [
                set building-fuel-poverty 1
              ]
              if some-var > .8 and some-var <= .85  and not table:get has? "heat" [
                set building-fuel-poverty 1
              ]
            ]
          ]
        ]
      ]
      movie-type = "high-gas-prices-low-connection-cost" [
        ;   Increasing fuel prices.
        if  member? (ticks mod 365) [1 31 59 90 120 151 181 212 243 273 304 334 364]  [
          let some-var random-float 1.0
          (ifelse

            building-fuel-poverty = 1  [
              if some-var > .99 and table:get has? "heat" [
                set building-fuel-poverty 2
              ]
              if some-var > .7 and not table:get has? "heat" [
                set building-fuel-poverty 2
              ]
              if some-var > .98 and some-var <= .99  and not table:get has? "heat" [
                set building-fuel-poverty 0
              ]
              if some-var > .5 and some-var <= .7  and table:get has? "heat" [
                set building-fuel-poverty 0
              ]
            ]
            building-fuel-poverty = 2  [
              if some-var > .8 and some-var <= .9  and table:get has? "heat" [
                set building-fuel-poverty 1
              ]
              if some-var > .98 and some-var <= .99  and not table:get has? "heat" [
                set building-fuel-poverty 1
              ]
            ]
            [
              if some-var > .98 and some-var <= .99  and table:get has? "heat" [
                set building-fuel-poverty 1
              ]
              if some-var > .8 and some-var <= .85  and not table:get has? "heat" [
                set building-fuel-poverty 1
              ]
            ]
          )
          let me self
          ask heat-pipes [
            if distance [patch-here] of me <= proximal-qualification-distance [
              ask me [
                connect-building-to-heat-network
                set building-fuel-poverty 0
              ]

            ]
          ]
        ]
      ]
      movie-type = "low-gas-prices-high-connection-cost" [
        let me self
        if  member? (ticks mod 365) [1 31 59 90 120 151 181 212 243 273 304 334 364]  [
          let some-var random-float 1.0
          ifelse building-fuel-poverty = 1  [
            if some-var > .99 and table:get has? "gas" [
              set building-fuel-poverty 2
            ]
            if some-var > .7 and not table:get has? "gas" [
              set building-fuel-poverty 2
            ]
            if some-var > .98 and some-var <= .99  and not table:get has? "gas" [
              set building-fuel-poverty 0
            ]
            if some-var > .5 and some-var <= .7  and table:get has? "gas" [
              set building-fuel-poverty 0
            ]
          ]
          [
            ifelse building-fuel-poverty = 2  [
              if some-var > .8 and some-var <= .9  and table:get has? "gas" [
                set building-fuel-poverty 1
              ]
              if some-var > .98 and some-var <= .99  and not table:get has? "gas" [
                set building-fuel-poverty 1
              ]
            ]
            [
              if some-var > .98 and some-var <= .99  and table:get has? "gas" [
                set building-fuel-poverty 1
              ]
              if some-var > .8 and some-var <= .85  and not table:get has? "gas" [
                set building-fuel-poverty 1
              ]
            ]
          ]
        ]
        ask heat-pipes [
          if distance [patch-here] of me <= proximal-qualification-distance [
            ask me [
              connect-building-to-heat-network
              set building-fuel-poverty 2
            ]

          ]
        ]
      ]
      [
        ; Not increasing fuel prices
        if  member? (ticks mod 365) [1 31 59 90 120 151 181 212 243 273 304 334 364]  [
          let some-var random-float 1.0
          ifelse building-fuel-poverty = 1  [
            if some-var < .99 and table:get has? "heat" [
              set building-fuel-poverty 2
            ]
            if some-var < .7 and not table:get has? "heat" [
              set building-fuel-poverty 2
            ]
            if some-var < .98 and some-var >= .99  and not table:get has? "heat" [
              set building-fuel-poverty 0
            ]
            if some-var < .5 and some-var >= .7  and table:get has? "heat" [
              set building-fuel-poverty 0
            ]
          ]
          [
            ifelse building-fuel-poverty = 2  [
              if some-var < .8 and some-var >= .9  and table:get has? "heat" [
                set building-fuel-poverty 1
              ]
              if some-var < .98 and some-var >= .99  and not table:get has? "heat" [
                set building-fuel-poverty 1
              ]
            ]
            [
              if some-var < .98 and some-var >= .99  and table:get has? "heat" [
                set building-fuel-poverty 1
              ]
              if some-var < .8 and some-var >= .85  and not table:get has? "heat" [
                set building-fuel-poverty 1
              ]
            ]
          ]
        ]
      ]
    )
    calculate-fuel-poverty
  ]

  export-view (word "movies/achsium-" movie-type "-" ticks ".png")
end

; {observer|ad-hoc} draw-circle

to draw-circle [cx cy r c]
  hatch 1 [
    set heading 0
    foreach n-values 360 [ i -> i ] [ deg ->
      let x cx + (sin deg) * r
      let y cy + (cos deg) * r
      if x > max-pxcor [ set x max-pxcor ]
      if x < min-pxcor [ set x min-pxcor ]
      if y > max-pycor [ set y max-pycor ]
      if y < min-pycor [ set y min-pycor ]
      setxy x y
      pen-down
      set color c
      set heading 0
      forward 1
    ]
    die
  ]
end

; {household} determine-disposable-income

;to determine-disposable-income
;  ifelse resolution = "household" [
;    set balance balance + income - ongoing-costs
;  ]
;  [
;    let household-income 0
;    let household-ongoing-costs 0
;    ask in-member-of-neighbors [
;      set household-income household-income + income
;      set household-ongoing-costs household-ongoing-costs + ongoing-costs
;    ]
;    set income household-income
;    set ongoing-costs household-ongoing-costs
;    set balance balance + income - ongoing-costs
;
;  ]
;end

to-report energy-efficiency [ some-energy-rating ]
  if some-energy-rating = "A" [
    report 8 / 9
  ]
  if some-energy-rating = "B" [
    report 7 / 9
  ]
  if some-energy-rating = "C" [
    report 6 / 9
  ]
  if some-energy-rating = "D" [
    report 5 / 9
  ]
  if some-energy-rating = "E" [
    report 4 / 9
  ]
  if some-energy-rating = "F" [
    report 3 / 9
  ]
  if some-energy-rating = "G" [
    report 2 / 9
  ]
  error (word "Incorrect energy rating " energy-rating)
end



to err [ message ]
  output-print (word date-and-time "; " timer ": ERROR: " message)
  error (word date-and-time "; " timer ": ERROR: " message)
end

; {household|person} exceeeds-current-yearly-costs?

to-report exceeds-current-yearly-costs? [some-energy-provider some-tariff]

  let this-outcome? true
  let this-household self
  if is-person? self [
    set this-household one-of out-member-of-neighbors
  ]
  ask this-household [
    let my-new-unit-cost [table:get retail-unit-cost some-tariff] of some-energy-provider
    if heating-system != "" [
      let my-energy-provider ""
      let my-energy-tariff ""
      foreach table:keys payment-for [ agents-payment-name ->
        if table:get payment-for agents-payment-name = heating-system [
          set my-energy-provider table:get payment-to agents-payment-name
          set my-energy-tariff table:get payment-name agents-payment-name
        ]
      ]
      if my-energy-provider = "" or my-energy-tariff = "" [
        err (word "exceeds-current-yearly-costs?: Agent " this-household " has heating: " heating-system " but no energy provider: " my-energy-provider " or energy tariff: " my-energy-tariff)
      ]
      let my-mean-units ifelse-value length [history-of-units-used-for-heating] of this-household > 0 [mean [history-of-units-used-for-heating] of this-household] [0]
      let my-retail-unit-cost [table:get retail-unit-cost my-energy-tariff] of my-energy-provider
      let my-yearly-units 0
      (ifelse
        [table:get frequency my-energy-tariff] of my-energy-provider = "daily" [
          set my-yearly-units 365 * my-mean-units
        ]
        [table:get frequency my-energy-tariff] of my-energy-provider = "weekly" [
          set my-yearly-units 52 * my-mean-units
        ]
        [table:get frequency my-energy-tariff] of my-energy-provider = "monthly" [
          set my-yearly-units 12 * my-mean-units
        ]
        [table:get frequency my-energy-tariff] of my-energy-provider = "quarterly" [
          set my-yearly-units 4 * my-mean-units
        ]
        [
          set my-yearly-units my-mean-units
        ]
      )
      let my-yearly-projected-cost my-yearly-units * [table:get retail-unit-cost some-tariff] of some-energy-provider

      let my-yearly-income 12 * (income - ongoing-costs)

      if my-yearly-income >= my-yearly-projected-cost [
        set this-outcome? false
      ]
    ]
  ]
  report this-outcome?

end

; {household} forced-to-repair-heating-system

to forced-to-repair-heating-system

  repair-heating-system
  if memory? and use-cbr? [
    let trusters (turtle-set self)
    if resolution = "person" [
      (ifelse
        dynamic = "all-adults" [
          set trusters in-member-of-neighbors with [ age > age-start-work ]
        ]
        dynamic = "matriarchal" [
          set trusters max-one-of in-member-of-neighbors with [ sex = "female" ] [age]
        ]
        dynamic = "patriarchal" [
          set trusters max-one-of in-member-of-neighbors with [ sex = "male" ] [age]
        ]
        dynamic = "random" [
          set trusters one-of in-member-of-neighbors
        ]
        dynamic = "household" [
          set trusters in-member-of-neighbors
      ]
      )
    ]
    foreach table:keys payment-to [ bill ->
      if table:get payment-for bill = heating-system [
        let this-institution table:get payment-to bill
        let state (sentence
          (list heating-system "repair" [name] of this-institution)
          get-affordability this-institution heating-system
        )
        ask trusters [
          let ignore cbr:add case-base state "repair" true
        ]
      ]
    ]
  ]
  set heating-status "working"
end

; {household} forced-to-replace-heating-system

to forced-to-replace-heating-system

  if heating-system = "" [
    stop
  ]
  let this-heating-system heating-system
  uninstall-heating-system
  install-new-heating-system this-heating-system
  if memory? and use-cbr? [
    let trusters (turtle-set self)
    if resolution = "person" [
      (ifelse
        dynamic = "all-adults" [
          set trusters in-member-of-neighbors with [ age > age-start-work ]
        ]
        dynamic = "matriarchal" [
          set trusters max-one-of in-member-of-neighbors with [ sex = "female" ] [age]
        ]
        dynamic = "patriarchal" [
          set trusters max-one-of in-member-of-neighbors with [ sex = "male" ] [age]
        ]
        dynamic = "random" [
          set trusters one-of in-member-of-neighbors
        ]
        dynamic = "household" [
          set trusters in-member-of-neighbors
      ]
      )
    ]
    foreach table:keys payment-to [ bill ->
      if table:get payment-for bill = this-heating-system [
        let this-institution table:get payment-to bill
        let state (sentence
          (list this-heating-system "replace" [name] of this-institution)
          get-values
        )
        ask trusters [
          let ignore cbr:add case-base state "replace" true
        ]
      ]
    ]
  ]
  set heating-status "working"
end

; { household | person } friend


; Allowable types for some-network are:

; "social"
; "neighbour"
; "family" (if resolution is set to person).

to friend [some-person-or-household some-network ]
  let me self
  if some-person-or-household = self [
    stop
  ]
  if work-homophily? and some-network = "work" and [ethnicity] of me != [ethnicity] of some-person-or-household [
    stop
  ]
  if school-homophily? and some-network = "school" and [ethnicity] of me != [ethnicity] of some-person-or-household [
    stop
  ]
  if community-organization-homophily? and some-network = "community" and [ethnicity] of me != [ethnicity] of some-person-or-household [
    stop
  ]
  if social-media-homophily? and some-network = "social" and [ethnicity] of me != [ethnicity] of some-person-or-household [
    stop
  ]
  if neighbour-homophily? and some-network = "neighbour" and [ethnicity] of me != [ethnicity] of some-person-or-household [
    stop
  ]
  if some-network = "family" and resolution = "household" [
    error "Cannot have family trust at household resolution"
  ]
  if out-know-neighbor? some-person-or-household [
    stop
    ;error "Cannot be friends with self"
  ]
  ; Dunbar's number
  if count my-knows > dunbars-number [
    stop
  ]
  create-know-to some-person-or-household [
    set hidden? true
    set network some-network
  ]
  ask some-person-or-household [
    create-know-to me [
      set hidden? true
      set network some-network
    ]
  ]
end

; {household|person} get-values

to-report get-values
  let attitudes []
  foreach surveyed-values [
    key ->
    set attitudes lput table:get attitude key attitudes
  ]
 report attitudes
end

; {household} get-some-advice

to get-some-advice [some-state]
  let this-household self
  ;let this-energy-type item 0 some-state
  let this-energy-type "heat"
  let this-context item 1 some-state
  let this-advisory-body-name item 2 some-state
  let choices []
  let done-something? false
  if not any? out-resident-neighbors with [ table:get has? "heat" ] [
    stop
  ]
  ask advisory-bodies with [ name = this-advisory-body-name ] [
    debug  (word this-household " Consulting " this-advisory-body-name
      " with this state " some-state)
    ; Let's loop through their advice and see if we want to follow it.
    foreach table:keys energy-type [ advice-name ->
      if table:get energy-type advice-name = this-energy-type [
        ifelse table:get finance advice-name = "grant" [
          if any? grant-bodies with
            [member? this-energy-type table:values energy-type]  [
            ask grant-bodies with
              [member? this-energy-type table:values energy-type] [
              if not done-something? [
                let this-grant-body self
                foreach table:keys energy-type [grant-name ->
                  if table:get energy-type grant-name = this-energy-type [
                    let this-maximum-income table:get maximum-income grant-name
                    let this-radius table:get radius grant-name
                    let this-patch one-of patches with [ pxcor =
                      [table:get x-locus grant-name] of this-grant-body and
                      pycor = [table:get y-locus grant-name] of this-grant-body]
                    ask this-household [
                      if (income < this-maximum-income or
                          this-maximum-income <= 0) and
                        (this-radius <= 0 or distance this-patch <= this-radius) and
                        not done-something? [
                        set some-state ( sentence (list this-energy-type
                        this-context [name] of this-grant-body))
                        set done-something? consult-on? "follow-advice" some-state
                        if done-something? [
                          debug  (word
                            "DOING following advice: getting a grant from "
                            this-grant-body " under grant " grant-name
                            " with state: " some-state)
                          set balance balance +
                            [table:get amount grant-name] of this-grant-body
                          if heating-system != "" [
                            uninstall-heating-system
                          ]
                          install-new-heating-system this-energy-type
                        ]
                      ]
                    ]
                  ]
                ]
              ]
            ]
          ]
        ]
        [
          if not any? banks with[member? this-energy-type table:values purpose][
            error (word "No bank is providing loans to install "
              this-energy-type " heating system.")
          ]
          debug  (word "Seeking loan with this state " some-state)
          ask banks with [member? this-energy-type table:values purpose]  [
            let this-bank self
            if not done-something? [
              foreach table:keys purpose [ product-name ->
                if table:get purpose product-name = this-energy-type and
                  not done-something?  [
                  ask this-household [
                    set some-state ( sentence (list this-energy-type
                      this-context [name] of this-bank))
                    set done-something? consult-on? "follow-advice" some-state
                    if done-something? [
                      debug  (word
                        "DOING following advice: getting a loan from "
                        this-bank " under product " product-name
                        " with state: " some-state)
                      set balance balance +
                          [table:get principal product-name] of this-bank
                      if heating-system != "" [
                        uninstall-heating-system
                      ]
                      install-new-heating-system this-energy-type
                    ]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
end

; {household} get-state-for-install

; I have abstracted this out, because I might want to drastically simplify the
; case base selection (i.e remove virtually all the state), so these are
; picked. This will be done for the purposes of testing

to-report get-state-for-install [some-energy-type some-institution some-context]
  let this-state (sentence
    (list some-energy-type some-context [name] of some-institution)
    ;(list some-energy-type [name] of some-institution)
    get-values
    get-affordability some-institution some-energy-type
  )
  report this-state
end

; {*} get-random-value

; Give a normal distribution of values in the range
; 0 - 6, gets the floor and multiplies by 5/3

to-report get-random-value
  let some-value random-normal 3.0 1.0
  if some-value < 0 [
    set some-value 0
  ]
  if some-value > 5.0 [
    set some-value 5.0
  ]
  set some-value int some-value
  ;set some-value some-value / 0.6
  report some-value + 1.0
end

; {household|person} get-affordability

; This returns a list of
; [
;   heating-system-age / lifetime-of-heating-system  or 1 whchever is less
;   highest installation cost for the energy-type and that institution.
;   cost of termination of contract
;   yearly-maitenannce
; ]

to-report get-affordability [ some-energy-provider some-energy-type ]
  if not is-energy-provider? some-energy-provider [
    error (word "get-affordability callled with weird institutioin: "
      some-energy-provider)
  ]

  if not member? some-energy-type [table:values energy-type] of some-energy-provider[
    error (word self " is requesting " some-energy-provider " to provide "
      some-energy-type ", which it doesn't")
  ]

  let state []
  let this-household self

  if is-person? this-household [
    set this-household one-of out-member-of-neighbors
  ]

  let my-tariff ""
  let my-energy-provider ""
  ask this-household [
    if heating-system != "" [
      foreach table:keys payment-for [ some-payment ->
        if table:get payment-for some-payment = heating-system [
          set my-tariff table:get payment-name some-payment
          set my-energy-provider table:get payment-to some-payment
        ]
      ]
    ]
    ;debug  (word "energy stuff " my-tariff " " my-energy-provider)
    set state lput (1 - min (list 1 (heating-system-age /
      lifetime-of-heating-system))) state

    ; Find the chepeast rate, 'cos...

    let lowest-tariff one-of [table:keys energy-type] of some-energy-provider
    ask some-energy-provider [
      foreach table:keys energy-type [ tariff ->
        if table:get energy-type tariff = some-energy-type and
           table:get retail-unit-cost tariff < table:get retail-unit-cost lowest-tariff [
          set lowest-tariff tariff
        ]
      ]
    ]

    ifelse heating-system = "" [
      set state lput ([table:get installation-cost lowest-tariff] of some-energy-provider) state
      set state lput ([table:get disconnection-cost lowest-tariff] of some-energy-provider) state
      set state lput ([table:get yearly-maintenance lowest-tariff] of  some-energy-provider ) state
    ]
    [
      set state lput ([table:get installation-cost lowest-tariff] of some-energy-provider
        - [table:get installation-cost my-tariff] of my-energy-provider) state
      set state lput ([table:get disconnection-cost lowest-tariff] of some-energy-provider
        - [table:get disconnection-cost my-tariff] of my-energy-provider) state
      set state lput ([table:get yearly-maintenance lowest-tariff] of  some-energy-provider
        - [table:get yearly-maintenance my-tariff] of  my-energy-provider ) state
    ]

  ]
  report state

end



; {observer|ad-hoc} get-pipe-laying-schedule

to get-pipe-laying-schedule
  ; Read a file and a year and a day from a file.
  set schedule-for-laying-pipes table:make
  if not file-exists? pipe-laying-schedule-file [
    error (word pipe-laying-schedule-file
      " does not exist. I have no pipe laying schedule.")
  ]
  file-open pipe-laying-schedule-file
  let header file-read-line
  while [not file-at-end?] [
    let data csv:from-row file-read-line
    let some-year item 0 data
    if some-year < 1900 or some-year > 3000 [
      error (word "Error in " pipe-laying-schedule-file
        ": Invalid year: " some-year " on line " data)
    ]
    let some-day-of-year item 1 data
    if some-day-of-year < 0 or some-day-of-year > 364 [
      error (word "Error in " pipe-laying-schedule-file
        ": Invalid day-of-year: " some-day-of-year " on line " data)
    ]
    let some-gis-file item 2 data
    if not file-exists? some-gis-file [
      error (word "Error in " pipe-laying-schedule-file
        ": No such gis file: " some-gis-file " on line " data)
    ]
    let year-subtable table:make
    if table:has-key? schedule-for-laying-pipes some-year [
      set year-subtable table:get schedule-for-laying-pipes some-year
    ]
    if table:has-key? year-subtable some-day-of-year [
      debug  (word "Warning for " pipe-laying-schedule-file
        ": Duplicate entry for day-of-year : " some-day-of-year)
    ]
    table:put year-subtable some-day-of-year some-gis-file
    table:put schedule-for-laying-pipes some-year year-subtable
  ]
  file-close
end

; {observer|ad-hoc} get-new-build-schedule

to get-new-build-schedule
  ; Read a file and a year and a day from a file.
  set schedule-for-new-builds table:make
  if not file-exists? new-builds-schedule-file [
    error (word new-builds-schedule-file
      " does not exist. I have no new build schedule.")
  ]
  file-open new-builds-schedule-file
  let header file-read-line
  while [not file-at-end?] [
    let data csv:from-row file-read-line
    let some-year item 0 data
    if some-year < 1900 or some-year > 3000 [
      error (word "Error in " new-builds-schedule-file
        ": Invalid year: " some-year " on line " data)
    ]
    let some-day-of-year item 1 data
    if some-day-of-year < 0 or some-day-of-year > 364 [
      error (word "Error in " new-builds-schedule-file
        ": Invalid day-of-year: " some-day-of-year " on line " data)
    ]
    let some-gis-file item 2 data
    if not file-exists? some-gis-file [
      error (word "Error in " new-builds-schedule-file
        ": No such gis file: " some-gis-file " on line " data)
    ]
    let year-subtable table:make
    if table:has-key? schedule-for-new-builds some-year [
      set year-subtable table:get new-builds-schedule-file some-year
    ]
    if table:has-key? year-subtable some-day-of-year [
      debug  (word "Warning for " new-builds-schedule-file
        ": Duplicate entry for day-of-year : " some-day-of-year)
    ]
    table:put year-subtable some-day-of-year some-gis-file
    table:put schedule-for-new-builds some-year year-subtable
  ]
  file-close
end


to-report get-energy-spending-for-all-households
  let household-stats table:make
  ask households [
    let household-details table:make
    table:put household-details "xcor" xcor
    table:put household-details "ycor" ycor
    table:put household-details "income" income
    table:put household-details "balance" balance
    table:put household-details "energy-expenditure" last-bill
    table:put household-stats who household-details
  ]
  report household-stats
end

to-report get-profits-for-all-energy-supplier
  let energy-provider-stats table:make
  ask energy-providers [
    let energy-provider-details table:make
    table:put energy-provider-details "name" name
    table:put energy-provider-details "profit" profits
  ]
  report energy-provider-stats
end

to-report gis-load-dataset [ filename ]
  debug (word "loading GIS dataset from file " filename "...")
  let dataset gis:load-dataset filename
  ifelse gis:type-of dataset = "VECTOR" [
    debug (word "... " (length gis:feature-list-of dataset) "-" (gis:shape-type-of dataset) " vector dataset ")
    let properties gis:property-names dataset
    debug (word "... " (length properties) " properties: " (reduce [ [ all next ] -> (word all ", " next) ] properties))
  ] [
    debug (word "... " (gis:width-of dataset) " by " (gis:height-of dataset) " raster dataset ")
  ]
  report dataset
end

; {person} goes-to

to goes-to [some-institution]
  if not is-person? self [
    err (word "goes-to: called with " self )
  ]
  let me self
  let some-connection-probability 0
  ask some-institution [
    create-attends-from me [
      set hidden? true
      set holidays-used 0
    ]
    (ifelse organization-type = "school" [
        set some-connection-probability school-network-probability
      ]
      organization-type = "work" [
        set some-connection-probability work-network-probability
      ]
      [
        set some-connection-probability community-organization-network-probability
      ]
    )
  ]
  add-to-network "Erdős and Rényi" [organization-type] of some-institution some-connection-probability 0 ""
end

; {observer | ad-hoc } hide-networks

to hide-networks
  ask knows [
    hide-link
  ]
end

; {household} household-votes-for-installation

to-report household-votes-for-installation?
  let vote-for-install? false
  let this-household self
  ifelse owns-property? [
    let some-institution one-of energy-providers with [member? "heat" table:values energy-type ]
    set vote-for-install? consult-on? "install" get-state-for-install "heat" some-institution "connection"
  ]
  [
    if landlord-wants-to-connect? [
      set vote-for-install? true
    ]
  ]
  report vote-for-install?
end

; { bank | landlord | energy-provider | advisory-body | business } informs

to informs [ some-agent ]
  let me self
  if some-agent = me [
    error "Trying to inform self"
  ]
  if in-know-neighbor? some-agent [
    ; This is a dupe.
    stop
  ]
  create-know-from some-agent [
    set hidden? true
    (ifelse
      is-bank? me [ set network "bank" ]
      is-landlord? me [ set network "landlord" ]
      is-energy-provider? me [ set network "energy" ]
      is-advisory-body? me [ set network "advice" ]
      is-business? me [ set network "business" ]
      is-msm? me and [organization-type] of me = "national" [ set network "national" ]
      is-msm? me and [organization-type] of me = "local" [ set network "local" ]
      ;is-institution? me and [organization-type] of me = "school" [ set network "school" ]
      ;is-institution? me and [organization-type] of me = "work" [ set network "work" ]
      ;is-institution? me and [organization-type] of me = "community" [ set network "community" ]
    )
  ]
end

; { household | person } informed-by

to informed-by [ some-institution ]
  let me self
  ask some-institution [
    informs me
  ]
end

;; {observer|ad-hoc} create-neighbourhood-network
;
;to create-neighbourhood-network
;
;  debug "Starting creation of neighbourhood network..."
;
;
;  ask knows with [network = "neighbour"] [ die ]
;  debug  (word "PERSONS: " one-of knows with [network = "neighbour" and (is-person? end1 or is-person? end2)  ])
;  debug  (word "HOUSEHOLDS: " one-of knows with [network = "neighbour" and (is-household? end1 or is-household? end2)  ])
;  ask buildings [
;    add-to-network
;      neighbourhood-network
;      "neighbour"
;      neighbourhood-network-rewire-or-connection-probability
;      neighbourhood-network-degree
;      neighbourhood-network-reaches-spec
;    ; Remove any neighbour within the same household
;  ]
;  ask knows with [ network = "neighbour" ] [
;    let building-1 end1
;    ask end2 [
;      ask out-resident-neighbors [
;        ;debug  (word "household1")
;        if is-household? self [
;          let household-1 self
;          ask building-1 [
;            ask out-resident-neighbors [
;              ;debug  (word "household2")
;              if is-household? self [
;                ifelse resolution = "household" [
;                  friend household-1 "neighbour"
;                ]
;                [
;                  ask n-of (random count in-member-of-neighbors + 1) in-member-of-neighbors [
;                    let person-1 self
;                    ;debug  ("person-1")
;                    ask household-1 [
;                      ask n-of (random count in-member-of-neighbors + 1) in-member-of-neighbors [
;                        ;debug  ("person-2")
;                        friend person-1 "neighbour"
;                      ]
;                    ]
;                  ]
;                ]
;              ]
;            ]
;          ]
;        ]
;      ]
;    ]
;    ;die
;  ]
;  debug  (word "PERSONS: " one-of knows with [network = "neighbour" and (is-person? end1 or is-person? end2)  ])
;  debug  (word "HOUSEHOLDS: " one-of knows with [network = "neighbour" and (is-household? end1 or is-household? end2)  ])
;  debug "...ending creation of neighbourhood network"
;
;end
;
;; {observer|ad hoc} create-social-network
;
;to create-social-network
;
;  debug "Starting creation of social network..."
;  ask knows with [network = "social"] [ die ]
;  let pool households
;  if resolution = "person" [
;    set pool persons
;  ]
;  ask pool [
;    add-to-network
;      social-network
;      "social"
;      social-network-rewire-or-connection-probability
;      social-network-degree
;      social-network-reaches-spec
;  ]
;  debug "...ending creation of social network"
;
;end

to init-decision-record
  set decision-record table:make
  foreach [ "install" "abandon" "repair" "get-advice" "follow-advice" ] [ dec-type ->
    table:put decision-record dec-type [ 0 0 0 ]
  ]
end


to input-buildings
  debug "input-buildings: started..."
  let record-count 0
  file-open buildings-input-output-file
  while [ not file-at-end? ] [
    if limit-buildings?  and record-count >= nof-buildings [
      file-close
      debug "input-buildings: ...finished."
      stop
    ]
    set record-count record-count + 1
    if record-count mod 100 = 0 [
      debug (word "input-building: have constructeed " record-count " buildings")
    ]
    let record csv:from-row file-read-line
    let some-patch patch item 1 record item 2 record
    if some-patch = nobody [
      err (sentence " Missing patch for building (" record ")")
    ]
    ask some-patch [
      ifelse item 0 record = "business" [
        ;debug (word "input-buildings: setting up a business with " item 3 record " " item 4 record " " item 5 record)
        setup-a-business-premise item 3 record item 4 record item 5 record
      ]
      [
        ;debug (word "input-buildings: setting up a dwelling with " item 5 record " " item 3 record " " item 4 record)
        setup-a-dwelling item 5 record item 3 record item 4 record
      ]
    ]
  ]
  file-close
  debug "input-buildings: ...finished."
end

; {observer} input-possible-pipe-line

to input-possible-pipe-line
  debug "input-possible-pipe-line: started..."
  ask patches [
    set pipe-possible? false
  ]
  file-open pipe-possible-input-output-file

  let i 0
  while [not file-at-end?] [
    let line file-read-line
    foreach n-values length line [j -> j] [ j ->
      if item j line = "1" [
        let some-patch patch (min-pxcor + j) (min-pycor + i)
        if some-patch != nobody [
          ask some-patch  [
            set pipe-possible? true
            set pcolor green
          ]
        ]
      ]
    ]
    set i i + 1
  ]
  file-close
  debug "input-possible-pipe-line: ...finished."
end

; {observer} input-present-pipe-line

to input-present-pipe-line
  debug "input-present-pipe-line: started..."
  ask patches [
    set pipe-present? false
  ]
  file-open pipe-present-input-output-file

  let i 0
  while [not file-at-end?] [
    let line file-read-line
    foreach n-values length line [j -> j] [ j ->
      if item j line = "1" [
        let some-patch patch (min-pxcor + j) (min-pycor + i)
        if some-patch != nobody [
          ask some-patch  [
            set pipe-possible? true
            set pipe-present? true
            sprout-heat-pipes 1 [
              set color blue
              set size 1
              if extent = "Torry" [
                set size 2
              ]
              set shape "square"
            ]
          ]
        ]
      ]
    ]
    set i i + 1
  ]
  ask heat-pipes [
    if any? neighbors with [pipe-possible? and not pipe-present?] [
      ask neighbors with [pipe-possible? and not pipe-present?] [
        if my-roads != nobody [
          ask my-roads [
            set near-heat-network? true
          ]
        ]
      ]
    ]
  ]
  file-close
  debug "input-possible-pipe-line: ...finished."
end

; {observer} input-roads

; {observer} input-roads

to input-roads

  debug "input-roads: started..."
  file-open roads-input-output-file

  ask patches [
    set my-roads nobody
    set pipe-present? false
  ]

  while [ not file-at-end? ] [
    create-roads 1 [
      let me self
      set my-patches nobody
      set voted? false
      set last-voted -1 * random voting-gap
      set near-heat-network? false
      let record csv:from-row file-read-line
      set name item 0 record
      set xcor item 1 record
      set ycor item 2 record
      foreach n-values ((length record - 3) / 2) [ i -> 2 * i + 3 ] [ i ->
        let some-patch patch item i record item (i + 1) record
        if some-patch != nobody [
          set my-patches (patch-set my-patches some-patch)
          ask some-patch [
            set my-roads (turtle-set my-roads me)
          ]
        ]
      ]
    ]
  ]

  file-close

  if metering != "individual" [
    ask associations [
      set surcharge truncated-normal mean-surcharge min-surcharge max-surcharge
    ]
  ]

  debug "input-roads: ...finished."
end

; {household | business } install-new-heating-system

to install-new-heating-system [ some-heating-system ]
  debug  (word "install-new-heating-system: INSTALLING..." some-heating-system)
  if some-heating-system = heating-system [
    debug  (word "install-new-heating-system: TRYING TO REINSTALL " some-heating-system)
    stop
  ]
  let this-entity self
  let this-energy-provider one-of energy-providers with [
    member? some-heating-system table:values energy-type]
  if is-business? this-entity and some-heating-system = "heat" [
    set this-energy-provider one-of energy-providers with [
      name = "DEAL" or name = "Colterm"
    ]
  ]
  let this-payment-name one-of (filter
    [some-tariff -> [table:get energy-type some-tariff] of this-energy-provider
      = some-heating-system]
    [table:keys energy-type] of this-energy-provider)
  if [table:get installation-cost this-payment-name] of this-energy-provider > balance [
    debug (word "install-new-heating-system: CANNOT AFFORD " some-heating-system)
    stop
  ]
  set contract-expires 0
  if fixed-contract-length > -1 [
    ifelse setup? [
      set contract-expires fixed-contract-length
    ]
    [
      set contract-expires ticks + fixed-contract-length
    ]
  ]
  let this-payment (word who "-" length table:keys payment-for)
  table:put payment-for this-payment some-heating-system
  table:put payment-name this-payment this-payment-name
  table:put payment-to this-payment this-energy-provider

  if is-household? this-entity [
    let my-count 0
    foreach table:values payment-for [ value ->
      if value = "gas" [ set my-count my-count + 1 ]
    ]
    set balance balance -
      [table:get installation-cost this-payment-name] of this-energy-provider
    ifelse some-heating-system != "heat" [
      set boiler-size random-normal ((max-boiler-size - min-boiler-size) / 2 + min-boiler-size)
      (max-boiler-size - min-boiler-size) / 4
      ; https://accendoreliability.com/the-range-rule/#:~:text=The%20standard%20deviation%20is%20approximately,minimum%2C%20to%20find%20the%20range.
      if boiler-size < min-boiler-size [ set boiler-size min-boiler-size ]
      if boiler-size > max-boiler-size [
        set boiler-size max-boiler-size
      ]
    ]
    [
      set boiler-size max-boiler-size
    ]
    set heating-system-age 0
  ]
  set heating-system some-heating-system
  if some-heating-system = "heat" [ debug "****HEATING INSTALLED***" ]
end


to-report leading-zeroes [some-number some-length]
  if not is-number? some-number [
    error (word "Trying to add zeroes to non-number:" some-number)
  ]
  let my-answer (word some-number)
  let number-length length my-answer
  if number-length - some-length < 0 [
    report my-answer
  ]
  foreach n-values (some-length - number-length) [i -> i][i ->
    set my-answer (word "0" my-answer)
  ]
  report my-answer
end
; {household} landlord-wants-to-connect?

to-report landlord-wants-to-connect?
  ; We are going to need this later, so I do need to work out who is the
  ; landlord.
  let this-landlord nobody
  foreach table:keys payment-for [ payment-key ->
    if table:get payment-for payment-key = "rent" [
      set this-landlord table:get payment-to payment-key
    ]
  ]
  if this-landlord = nobody [
    error (word "Error on household " self
      ". Does not own house, but has no landlord.")
  ]
  if heat-network-mandatory-for-landlords? [
    report true
  ]
  report false
end

; {household|person} leaves

to leaves [some-institution]

  ; TODO This next test should not really happen. I need to investigate why this occurs
  if one-of my-all-attends with [
    other-end = some-institution] != nobody [
    ask one-of my-all-attends with [
      other-end = some-institution] [
      die
    ]
    delete-from-network [organization-type] of some-institution
  ]

end

; {observer} load-a-household-from-table

to load-a-household-from-table [some-name has-electricity? has-gas? has-heat-network?]

  debug (word "loading household " some-name " from a table")

  let data table:get household-pool some-name
  let this-household self

  set hidden? true

  set heating-system ""
  set wants-to-join? false

  ; Finance

  set income 0
  set current-temperature temperature
  set last-bill 0
  set monthly-fuel-payment 0
  set switched-heating-off? false

  set payment-for table:make
  set payment-to table:make
  set payment-name table:make

  set postcode item 0 data

  set fuel-poverty 0
  set history-of-fuel-poverty []
  set history-of-temperature []
  set history-of-units-used-for-heating []

  ifelse item 1 data = "true" [
    set owns-property? true
  ]
  [
    set owns-property? false
  ]
  ifelse item 2 data = "true" [
    set owns-outright? true
  ]
  [
    set owns-outright? false
  ]
  ifelse owns-property? [
    if not owns-outright? [
      let bank-name item 3 data
      let some-bank one-of banks with [ name = bank-name ]
      let some-payment (word who "-" length table:keys payment-for)
      table:put payment-for some-payment "mortgage"
      table:put payment-to some-payment some-bank
      let some-payment-name item 4 data
      table:put payment-name some-payment some-payment-name
      informed-by some-bank
    ]
  ]
  [
    let landlord-name item 3 data
    let some-landlord one-of landlords with [ name = landlord-name ]
    let some-payment (word who "-" length table:keys payment-for)
    table:put payment-for some-payment "rent"
    table:put payment-to some-payment some-landlord
    let some-payment-name item 4 data
    table:put payment-name some-payment some-payment-name
    informed-by some-landlord
  ]

  ; Energy consumption

  set max-units-of-energy-per-day item 5 data
  set min-units-of-energy-per-day item 6 data

  set units-of-energy-used table:make
  table:put units-of-energy-used "electric" 0
  table:put units-of-energy-used "gas" 0
  table:put units-of-energy-used "heat" 0
  if tick-new-technology >= 0 [
    table:put units-of-energy-used "new-technology" 0
    table:put rent-includes? "new-technology" false
  ]

  set heating-status "working"

  set uses? table:make

  set rent-includes? table:make
  set requires-maintenance? table:make
  set serviced? table:make

  if has-electricity? [
    ifelse item 7 data = "true" [
      table:put uses? "electricity" true
    ]
    [
      table:put uses? "electricity" false
    ]
    ifelse not owns-property? [
      ifelse item 8 data = "true" [
        table:put rent-includes? "electricity" true
      ]
      [
        table:put rent-includes? "electricity" false
      ]
    ]
    [
      table:put rent-includes? "electricity" false
    ]

    if not table:get rent-includes? "electricity" [
      let energy-provider-name item 9 data
      let some-energy-provider one-of energy-providers with [ name = energy-provider-name ]
      let some-payment (word who "-" length table:keys payment-for)
      table:put payment-for some-payment "electricity"
      table:put payment-to some-payment some-energy-provider
      let some-payment-name item 10 data
      table:put payment-name some-payment some-payment-name
      informed-by some-energy-provider
    ]
  ]

  if has-gas? [
    ifelse item 11 data = "true" [
      table:put uses? "gas" true
    ]
    [
      table:put uses? "gas" false
    ]
    ifelse not owns-property? [
      ifelse item 12 data = "true" [
        table:put rent-includes? "gas" true
      ]
      [
        table:put rent-includes? "gas" false
      ]
    ]
    [
      table:put rent-includes? "gas" false
    ]

    if not table:get rent-includes? "gas" [
      let energy-provider-name item 13 data
      let some-energy-provider one-of energy-providers with [ name = energy-provider-name ]
      let some-payment (word who "-" length table:keys payment-for)
      table:put payment-for some-payment "gas"
      table:put payment-to some-payment some-energy-provider
      let some-payment-name item 14 data
      table:put payment-name some-payment some-payment-name
      informed-by some-energy-provider
    ]
  ]

  if has-heat-network? [
    ifelse item 15 data = "true" [
      table:put uses? "heat" true
    ]
    [
      table:put uses? "heat" false
    ]
    ifelse not owns-property? [
      ifelse item 16 data = "true" [
        table:put rent-includes? "heat" true
      ]
      [
        table:put rent-includes? "heat" false
      ]
    ]
    [
      table:put rent-includes? "heat" false
    ]

    if not table:get rent-includes? "heat" [
      let energy-provider-name item 17 data
      let some-energy-provider one-of energy-providers with [ name = energy-provider-name ]
      let some-payment (word who "-" length table:keys payment-for)
      table:put payment-for some-payment "heat"
      table:put payment-to some-payment some-energy-provider
      let some-payment-name item 18 data
      table:put payment-name some-payment some-payment-name
      informed-by some-energy-provider
    ]
  ]

  table:put requires-maintenance? "electric" false
  table:put serviced? "electric" false
  table:put requires-maintenance? "gas" false
  table:put serviced? "gas" false
  table:put requires-maintenance? "heat" false
  table:put serviced? "heat" false

  (ifelse
    item 19 data = "heat" and has-heat-network?[
      set heating-system "heat"
    ]
    item 19 data = "electric" and has-electricity? [
      set heating-system "electric"
      table:put requires-maintenance? "electric" false
    ]
    item 19 data = "gas" and has-gas? [
      set heating-system "gas"
      table:put requires-maintenance? "gas" true
    ]
    [
      set heating-system ""
    ]
  )


  set degree item 20 data

  set dynamic item 21 data

  set boiler-size item 22 data



  ; Note the persons file must already be loaded for this to work.

  ifelse resolution = "person" [
    ifelse table:has-key? trust-values name [
      set trust table:get trust-values name
    ]
    [
      set trust table:get trust-values "*"
    ]

    foreach sublist data 23 (length data - 1) [
      some-person-name ->
      load-a-person-from-table some-person-name
    ]

    ask in-member-of-neighbors [
      let family-member self
      ask other in-member-of-neighbors [
        friend family-member "family"
        let other-family-member self
        ask family-member [
          friend other-family-member "family"
        ]
      ]
    ]
  ]
  [
    set attitude sublist data 23 (length data - 1)
    ; https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=3&cad=rja&uact=8&ved=2ahUKEwjTmp2ck_XhAhWTSRUIHZf_CKoQFjACegQICxAI&url=https%3A%2F%2Fwww.census.gov%2Fprod%2Fcen2010%2Fbriefs%2Fc2010br-14.pdf&usg=AOvVaw0L_MhJzeqQsdJrkBUu35FZ
    ; average family size is 2.58
    ; The standard deviation will smallest is 1 largest is 15 (https://www.bbc.co.uk/news/uk-scotland-tayside-central-52426962)
    ; So the standard deviation is 7 / 2 which is 3.
    let nof-individuals int (random-normal 2.58 3.5)
    if nof-individuals < 1 [
      set nof-individuals 1
    ]
    foreach n-values nof-individuals [i -> i ] [ i ->
      create-a-random-person this-household -1 ""
    ]
  ]

  ; Okay we need to make sure that if this household does not consist of kids, so there must be at least one adult.
  while [ [age] of max-one-of in-member-of-neighbors [age] < age-start-work ] [
    ask one-of in-member-of-neighbors [
      die
    ]
    create-a-random-person this-household -1 ""
  ]
  if consult-social-networks? and resolution = "household" [
    set trust []
    if table:has-key? trust-values "*" [
      set trust table:get trust-values "*"
    ]
    add-to-network
      neighbourhood-network
      "neighbour"
      neighbourhood-network-rewire-or-connection-probability
      neighbourhood-network-degree
      neighbourhood-network-reaches-spec
    add-to-network
      social-network
      "social"
      social-network-rewire-or-connection-probability
      social-network-degree
      social-network-reaches-spec
    ask msms [
      if random-float 1.0 < listens-to-msm [
        informs this-household
      ]
    ]
    ask advisory-bodies [
      informs this-household
    ]
  ]

  if resolution = "household" [
    ifelse use-cbr? [
      set case-base cbr:new
      cbr:lambda case-base simple-comparator
      if limit-case-base-size? [
        cbr:set-max-size case-base maximum-case-base-size
      ]
      foreach (up-to-n-of initial-cases-per-entity filter [ i -> table:get i "name" = name] case-base-pool) [case ->
        let ignore cbr:add case-base
        table:get case "state"
        table:get case "decision"
        table:get case "outcome"
      ]
    ]
    [
      let some-value random-float 100
      (ifelse
        some-value <= innovators [
          set heuristic-type "innovator"
        ]
        some-value > innovators and some-value <= early-adopters [
          set heuristic-type "early-adopter"
        ]
        some-value > early-adopters and some-value <= majority [
          set heuristic-type "majority"
          set adoption-likelihood-threshold triangular-distribution min-adoption-likelihood max-adoption-likelihood mode-adoption-likelihood
        ]
        [
          set heuristic-type "laggard"
        ]
      )
    ]
  ]

end

; {observer|adhoc} load-a-person-form-table

to load-a-person-from-table [some-name]

  let me nobody

  if member? some-name table:keys population-values [
    error (word "load-a-person-from-table: name "
      some-name " does not exist in the population-values table" )
  ]

  hatch-persons 1 [
    set me self
    set recommendations table:make
    set sex item 1 table:get population-values some-name
    set age item 2 table:get population-values some-name
    foreach read-from-string item 3 table:get population-values some-name [
      some-institution ->
      goes-to some-institution
    ]
    set income item 4 table:get population-values some-name
    if UBI? and income < ubi [
      set income ubi
    ]
    set degree item 5 table:get population-values some-name
    set income item 6 table:get population-values some-name
    set on-benefits? false
    if item 7 table:get population-values some-name = "true" [
      set on-benefits? true
    ]

    foreach n-values count surveyed-values [i -> i ] [
      i ->
      table:put attitude item i surveyed-values item (i + 7) table:get population-values some-name
    ]
    set trust []
    if resolution = "person" [
      ifelse table:has-key? trust-values name [
        set trust table:get trust-values name
      ]
      [
        set trust table:get trust-values "*"
      ]
    ]

    ifelse use-cbr? [
      set case-base cbr:new
      cbr:lambda case-base simple-comparator
      if limit-case-base-size? [
        cbr:set-max-size case-base maximum-case-base-size
      ]
      foreach (up-to-n-of initial-cases-per-entity filter [ i -> table:get i "name" = name] case-base-pool) [case ->
        let ignore cbr:add case-base
        table:get case "state"
        table:get case "decision"
        table:get case "outcome"
      ]
    ]
    [
      let some-value random-float 100
      (ifelse
        some-value <= innovators [
          set heuristic-type "innovator"
        ]
        some-value > innovators and some-value <= early-adopters [
          set heuristic-type "early-adopter"
        ]
        some-value > early-adopters and some-value <= majority [
          set heuristic-type "majority"
          set adoption-likelihood-threshold triangular-distribution min-adoption-likelihood max-adoption-likelihood mode-adoption-likelihood
        ]
        [
          set heuristic-type "laggard"
        ]
      )
    ]
  ]
end

to-report triangular-distribution [some-min some-max some-mode]

  ; https://en.wikipedia.org/wiki/Triangular_distribution
  if some-min > some-max [
    err (word "triangular-distribution: minimum: " some-min " should be less than maxiumum: " some-max)
  ]
  if some-mode > some-max [
    err (word "triangular-distribution: mode: " some-mode " should be less than maxiumum: " some-max)
  ]
  if some-mode < some-min [
    err (word "triangular-distribution: mode: " some-mode " should be greater than miniumum: " some-min)
  ]
  let u random-float 1.0
  let fc (some-mode - some-min) / (some-max - some-min)
  let X 0
  ifelse u > 0 and u < fc [
    set X some-min + sqrt(u * (some-max - some-min) * (some-mode - some-min))
  ]
  [
    set X some-max - sqrt(u * (some-max - some-min) * (some-max - some-mode))
  ]
  report X
end


; {observer|ad-hoc} load-cases-from-a-file

to load-cases-from-a-file [case-base-file]
  file-open case-base-file
  let header file-read-line
  while [not file-at-end?] [
    let case table:make
    let data csv:from-row file-read-line
    ; Cannot validate the name because the agents have not yet
    ; been loaded.
    table:put case "name" item 0 data
    if not member? item 1 data possible-decisions [
      error (word "Invalid decision in case-base-file: " item 1 data
        " in " case-base-file ", record: " data)
    ]
    table:put case "decision" item 1 data
    if item 2 data != true and item 2 data != false [
      error (word "Invalid outcome in case-base-file: " item 2 data
        " in " case-base-file ", record: " data)
    ]
    table:put case "outcome" item 2 data
    table:put case "state" sublist data 3 (length data - 1)

    set case-base-pool lput case case-base-pool
  ]

  file-close
end

; {institution} load-an-institution-from-a-file

to load-an-institution-from-a-file [ some-name some-type ]


  let data-pathname (word employers-spec-dir "/" some-name ".csv")
  (ifelse
    some-type = "school" [
      set data-pathname (word schools-spec-dir "/" some-name ".csv")
    ]
    some-type = "community" [
      set data-pathname (word community-organizations-spec-dir "/" some-name ".csv")
    ]
  )
  file-open data-pathname
  let header file-read-line
  let data csv:from-row file-read-line
  file-close
  create-institutions 1 [
    set name some-name
    set organization-type some-type
    set hidden? true
    if use-cbr? [
      set case-base cbr:new
      cbr:lambda case-base simple-comparator
    ]
    set recommendations table:make

    set xcor item 0 data
    set ycor item 1 data
    set catchment-radius item 2 data
    set calendar read-from-string item 3 data
    set floating-holidays item 4 data
    set fixed-holidays read-from-string item 5 data
    set probability-of-attendance item 6 data
    set working-from-home item 7 data
  ]


end

; {observer} load-trust-from-a-file

to load-trust-from-a-file

  ; The values in this file are name (the name of an agent).
  ;     * will indicate that all agents will have these values
  ; The class of for which the trust is being set.
  ;     This should be one of bank, landlord, energy-company, nation-main-stream-media, etc.
  set trust-values table:make

  if not consult-social-networks? [
    stop
  ]
  if not file-exists? trust-file [
    error (word "No trust file: " trust-file)
  ]
  file-open trust-file
  let header file-read-line
  while [ not file-at-end? ] [
    let data csv:from-row file-read-line
    let some-name item 0 data
    ; Now check that every class is valid
    let ranking read-from-string item 1 data
    let flatten reduce sentence ranking
    foreach flatten [
      some-class ->
      if not member? some-class possible-advisors [
        error (word "Invalid class in the trust file " trust-file)
      ]
    ]
    table:put trust-values some-name ranking
  ]
  file-close

  if not table:has-key? trust-values "*" [
    error (word trust-file " does not contain a default value *")
  ]

end

; {observer} load-households-from-a-file

to load-households-from-a-file
  if household-config-file != "" and file-exists? household-config-file [
    file-open household-config-file
    let header csv:from-row file-read-line
    let line-number 1
    while [not file-at-end?] [
      set line-number line-number + 1
      let data csv:from-row file-read-line
      let household-name item 0 data

      if not member? "AB" item 1 data or length item 1 data != 7 [
        error (word "load-households-from-a-file: postcode " item 1 data
          " invalid, on " line-number
          " in " household-config-file)
      ]
      ifelse table:has-key? household-postcodes item 1 data [
        table:put household-postcodes item 1 data
        lput household-name table:get household-postcodes item 1 data
      ]
      [
        table:put household-postcodes item 1 data (list household-name)
      ]

      if item 2 data != "true" and item 2 data != "false" [
        error (word "load-households-from-a-file: owns-property? " item 2 data
          " invalid, should be true or false on " line-number
          " in " household-config-file)
      ]
      if item 3 data != "true" and item 3 data != "false" [
        error (word "load-households-from-a-file: owns-outright? " item 3 data
          " invalid, should be true or false on " line-number
          " in " household-config-file)
      ]
      let some-name item 4 data
      let some-institution one-of (turtle-set banks landlords) with [ name = some-name ]
      if some-institution = nobody [
        error (word "load-households-from-a-file: institution " some-name
          " does not exist on line " line-number
          " in " household-config-file)
      ]
      let some-payment-name item 5 data
      if not [table:has-key? purpose some-payment-name] of some-institution [
        error (word "load-households-from-a-file: payment-name " some-payment-name
          " does not exist on line " line-number
          " for bank " some-name
          " in " household-config-file)
      ]

      ; Energy consumption

      if not is-number? item 6 data  [
        error (word "load-households-from-a-file: max-units-of-energy-per-day: "
          item 6 data
          " is not a number "
          " on line " line-number
          " in " household-config-file)
      ]

      if not is-number? item 7 data  [
        error (word "load-households-from-a-file: min-units-of-energy-per-day: "
          item 6 data
          " is not a number "
          " on line " line-number
          " in " household-config-file)
      ]

      if item 8 data != "true" and item 8 data != "false" [
        error (word "load-households-from-a-file: uses-electricity? "
          " is not true of false " item 8 data
          " on line " line-number
          " in " household-config-file)
      ]

      if item 9 data != "true" and item 9 data != "false" [
        error (word "load-households-from-a-file: electricity-included-in-rent? "
          " is not true of false " item 8 data
          " on line " line-number
          " in " household-config-file)
      ]

      let energy-provider-name item 10 data
      let some-energy-provider one-of energy-providers with [ name = energy-provider-name ]
      if some-energy-provider = nobody [
        error (word "load-households-from-a-file: energy-provider " energy-provider-name
          " does not exist on line " line-number
          " in " household-config-file)
      ]
      set some-payment-name item 11 data
      if not [table:has-key? retail-unit-cost some-payment-name] of some-energy-provider [
        error (word "load-households-from-a-file: payment-name " some-payment-name
          " does not exist on line " line-number
          " for energy-provider " energy-provider-name
          " in " household-config-file)
      ]

      if item 12 data != "true" and item 12 data != "false" [
        error (word "load-households-from-a-file: uses-gas? "
          " is not true of false " item 12 data
          " on line " line-number
          " in " household-config-file)
      ]
      if item 13 data != "true" and item 13 data != "false" [
        error (word "load-households-from-a-file: gas-included-in-rent? "
          " is not true of false " item 13 data
          " on line " line-number
          " in " household-config-file)
      ]

      set energy-provider-name item 14 data
      set some-energy-provider one-of energy-providers with [ name = energy-provider-name ]
      if some-energy-provider = nobody [
        error (word "load-households-from-a-file: energy-provider " energy-provider-name
          " does not exist on line " line-number
          " in " household-config-file)
      ]
      set some-payment-name item 15 data
      if not [table:has-key? retail-unit-cost some-payment-name] of some-energy-provider [
        error (word "load-households-from-a-file: payment-name " some-payment-name
          " does not exist on line " line-number
          " for energy-provider " energy-provider-name
          " in " household-config-file)
      ]

      if item 16 data != "true" and item 16 data != "false" [
        error (word "load-households-from-a-file: uses-heat? "
          " is not true of false " item 16 data
          " on line " line-number
          " in " household-config-file)
      ]
      if item 17 data != "true" and item 17 data != "false" [
        error (word "load-households-from-a-file: heat-included-in-rent? "
          " is not true of false " item 17 data
          " on line " line-number
          " in " household-config-file)
      ]

      set energy-provider-name item 18 data
      set some-energy-provider one-of energy-providers with [ name = energy-provider-name ]
      if some-energy-provider = nobody [
        error (word "load-households-from-a-file: energy-provider " energy-provider-name
          " does not exist on line " line-number
          " in " household-config-file)
      ]
      set some-payment-name item 19 data
      if not [table:has-key? retail-unit-cost some-payment-name] of some-energy-provider [
        error (word "load-households-from-a-file: payment-name " some-payment-name
          " does not exist on line " line-number
          " for energy-provider " energy-provider-name
          " in " household-config-file)
      ]

      if item 20 data != "heat" and
         item 20 data != "electric" and
         item 20 data != "gas" and
         item 20 data != "" [
        error (word "load-households-from-a-file: heating-system " item 20 data
          " is invalid, should be one of 'heat', 'electric', 'gas' or '', "
          " on line " line-number
          " in " household-config-file)
      ]

      if not is-number? item 21 data and
         item 21 data < 0 [
        error (word "load-households-from-a-file: degree " item 21 data
          " is invalid, should is network degree, should be greater than 0 "
          " on line " line-number
          " in " household-config-file)
      ]

      if not member? item 22 data family-dynamics [
        error (word "load-households-from-a-file: family dynamics " item 22 data
          " is invalid, should be one of " sentence family-dynamics
          " on line " line-number
          " in " household-config-file)
      ]

      if not is-number? item 23 data and item 23 data >= 16 and item 23 data <= 42 [
        error (word "load-households-from-a-file: boiler size " item 23 data
          " is invalid, should a number in the range 16 - 42 inclusive"
          " on line " line-number
          " in " household-config-file)
      ]

      if length data <= 24 and resolution = "household" [
        error (word "load-households-from-a-file: too few fields for a household resolution "
          " on line " line-number
          " should be more than 23, actually are  " length data
          " in " household-config-file)
      ]

      table:put household-pool household-name sublist data 1 (length data - 1)
    ]
    file-close
  ]
end

; {observer} load-population-from-a-file

to load-population-from-a-file

  if population-config-file != "" and file-exists? population-config-file [
    file-open population-config-file
    let header csv:from-row file-read-line
    let line-number 1
    while [not file-at-end?] [
      set line-number line-number + 1
      let data csv:from-row file-read-line
      if length data < 1 [
        error (word "load-population-from-a-file: too few fields to define an agent "
          " on line " line-number
          " should be 44 fields, actually are  " length data
          " in " population-config-file)
      ]
      foreach n-values (length data - 1) [ i -> i + 1 ]
        [ i ->

          (ifelse
            i = 1 [
              if not is-number? item i data or
              item i data >= 0 or
              item i data < 110 [
                error (word "load-population-from-a-file: age "
                  item i data " not in ]0,110[, "
                  " line no " line-number
                  "in " population-config-file)
              ]
            ]
            i = 2 [
              if item i data != "male" and
              item i data != "female" [
                error (word "load-population-from-a-file: sex "
                  item i data " not in {male,female}, "
                  " line no " line-number
                  "in " population-config-file)
              ]
            ]
            i = 3 [
              foreach read-from-string item i data [
                some-institution ->
                if not member? some-institution [name] of institutions [
                  error (word "load-population-from-a-file: institution "
                    "invalid institution " some-institution
                    " line no " line-number
                    "in " population-config-file)
                ]
              ]
            ]
            i = 4 [
              if not is-number? item i data or item i data < 0 [
                  error (word "load-population-from-a-file: income "
                    "invalid degree-of-connection " item i data
                    " line no " line-number
                    "in " population-config-file)
              ]
            ]
            i = 5 [
              if not is-number? item i data or item i data < 0 [
                  error (word "load-population-from-a-file: institution "
                    "invalid degree-of-connection " item i data
                    " line no " line-number
                    "in " population-config-file)
              ]
            ]
            i = 6 [
              if not is-number? item i data or item i data < 0 [
                  error (word "load-population-from-a-file: institution "
                    "invalid income " item i data
                    " line no " line-number
                    "in " population-config-file)
              ]
            ]
            i = 7 [
              if item i data != "true" or item i data != "false" [
                  error (word "load-population-from-a-file: institution "
                    "invalid on-benefits? " item i data
                    " line no " line-number
                    "in " population-config-file)
              ]
            ]
            [
              if not is-number? item i data or
              item i data > 1 or
              item i data < 0 [
                error (word "load-population-from-a-file: attitude "
                  item i data " not in ]0,1[, "
                  " line no " line-number
                  "in " population-config-file)
              ]
            ]
          )
      ]
      table:put population-values item 0 data sublist data 1 (length data - 1)
    ]
    file-close
  ]
end

; {observer} load-energy-ratings-from-a-file

to load-energy-ratings-from-a-file

  set energy-ratings table:make
  ; https://www.gov.scot/publications/scottish-house-condition-survey-2016-key-findings/pages/5/
  ; Carefully hidden away I note.
  table:put energy-ratings "UNKNOWN" "D"
  if energy-ratings-file = "" [
    stop
  ]
  if not file-exists?  energy-ratings-file [
    file-open energy-ratings-file
    let header file-read
    while [not file-at-end?] [
      let data csv:from-row file-read-line
      table:put energy-ratings item 0 data item 1 data
    ]
    file-close
  ]
end

; {observer} load-council-taxes-from-a-file

to load-council-taxes-from-a-file

  set council-taxes table:make
  if council-taxes-file = "" [
    stop
  ]
  if not file-exists?  council-taxes-file [
    file-open council-taxes-file
    let header file-read
    while [not file-at-end?] [
      let data csv:from-row file-read-line
      table:put council-taxes item 0 data item 1 data
    ]
    file-close
  ]
end

; {observer} load-a-grant-body-from-a-file

to load-a-grant-body-from-a-file [ some-name ]
  create-grant-bodies 1 [
    set hidden? true
    set name some-name
    if use-cbr? [
      set case-base cbr:new
      cbr:lambda case-base simple-comparator
    ]
    set recommendations table:make

    set energy-type table:make
    set amount table:make
    set maximum-income table:make
    set x-locus table:make
    set y-locus table:make
    set radius table:make
    update-grants-with (word grant-bodies-spec-dir "/" name ".csv")
  ]
end

; {observer} load-an-advisory-body-from-a-file

to load-an-advisory-body-from-a-file [ some-name ]
  if some-name != "SCARF" or not no-SCARF? [
    create-advisory-bodies 1 [
      if use-cbr? [
        set case-base cbr:new
        cbr:lambda case-base simple-comparator
      ]
      set recommendations table:make
      set color [0 0 0 0]
      set name some-name
      set action table:make
      set energy-type table:make
      set recommended-institution table:make
      set finance table:make
      set x-locus table:make
      set y-locus table:make
      set radius table:make
      set calendar table:make
      update-advice-with (word advisory-bodies-spec-dir "/" name ".csv")
    ]
  ]
end

; {observer} load-a-landlord-from-a-file

to load-a-landlord-from-a-file [ some-name is-private? ]
  create-landlords 1 [
    set hidden? true
    set name some-name
    set private? is-private?
    set rent table:make
    set frequency table:make
    if use-cbr? [
      set case-base cbr:new
      cbr:lambda case-base simple-comparator
    ]
    set recommendations table:make

    update-rents-with (word landlords-spec-dir "/" name ".csv")
  ]
end

; {observer} load-an-energy-provider-from-a-file

to  load-an-energy-provider-from-a-file [ some-name  ]
  create-energy-providers 1 [
    set hidden? true
    set name some-name
    if use-cbr? [
      set case-base cbr:new
      cbr:lambda case-base simple-comparator
    ]

    set daily-income (list 0)
    set daily-outgoings (list 0)
    set overhead truncated-normal (8500 / 365) (7200 / 365) (9100 / 365)
    ;set overhead 0

    set recommendations table:make

    set energy-type table:make
    set wholesale-unit-cost table:make
    set frequency table:make
    set retail-unit-cost table:make
    set standing-charge table:make
    set disconnection-cost table:make
    set installation-cost table:make
    set yearly-maintenance table:make
    set profitability 0
    set profits table:make
    update-energy-provider-with (word energy-providers-spec-dir "/" name ".csv")
  ]
end

; {observer} load-a-bank-from-a-file

to load-a-bank-from-a-file [ some-name ]
  create-banks 1 [
    set hidden? true
    set name some-name
    if use-cbr? [
      set case-base cbr:new
      cbr:lambda case-base simple-comparator
    ]
    set recommendations table:make

    set purpose table:make
    set principal table:make
    set frequency table:make
    set payment table:make
    set nof-payments table:make
    update-bank-with (word banks-spec-dir "/" name ".csv")
  ]
end

; {household} maybe-do-something-after

; The big decision making thing, possibly the core of the code

; When entering this code, then the status of the heating system might be

;  "working"
;  "replace"
;  "repair"
;  "building-failure"
;  "regional-failure"
;  "city-wide-failure"

; Decisions that need to made are

; "install"
; "abandon"
; "repair"
; "get-advice"
; "follow-advice"

; The some-energy-type might be "gas" "electric" "heat"

; The some-contexts can be:

;  "power-restored-after-city-wide-outage"
;  "power-restored-after-regional-outage"
;  "moved-in"
;  "repair"
;  "replace"
;  "awareness-raising-event"
;  "yearly-maintenance"

; This is a rather crude method of doing this at the moment, and probably needs
; refinining into some kind of decision tree.
; This version is basically, if it is applicable to my circumstances then
; consider it: the scatter-gun approach

to maybe-do-something-after [ some-context some-energy-type ]
  let this-household self
  let my-building one-of in-resident-neighbors

  if heating-system = "heat" and contract-expires > 0 and contract-expires < ticks [
    stop
  ]
  ; <-- Start of a policy implementation
  if heat-network-mandatory-for-new-installs? and
    some-context = "replacement" and
    some-energy-type != "heat" and
    [table:get has? "heat"] of my-building [
    if heating-system != "" [
      uninstall-heating-system
    ]
    install-new-heating-system "heat"
    if memory? and use-cbr? [
      let this-institution one-of energy-providers with
        [member? "heat" table:values energy-type]
      let case cbr:add case-base
        (get-state-for-install "heat" this-institution some-context) "install" true
    ]
    stop
  ]
  ; <-- End of a policy implementation

  let choices []
  ask advisory-bodies [
    let this-institution self
    let choice table:make
    table:put choice "decision" "get-advice"
    ask this-household [
      table:put choice "state" (sentence
        (list some-energy-type some-context [name] of this-institution)
      )
    ]
    set choices lput choice choices
  ]
  foreach energy-types [ this-energy-type ->
    ;debug  (word "Building has " this-energy-type "
    ; with " [table:get has? this-energy-type] of my-building)
    if heating-system != this-energy-type and
      [table:get has? this-energy-type] of my-building [
      ask energy-providers
        with [member? this-energy-type table:values energy-type ] [
        let this-institution self
        let this-payment-name one-of filter [
          some-payment-name ->
          table:get energy-type some-payment-name = this-energy-type ]
          table:keys energy-type
        ask this-household [
          let choice table:make
          table:put choice "decision" "install"
          table:put choice "state"
            get-state-for-install this-energy-type this-institution some-context
          set choices lput choice choices
        ]
      ]
    ]
  ]
  if heating-system = some-energy-type [
    foreach table:keys payment-for [ bill ->
      if table:get payment-for bill = some-energy-type [
        let choice table:make
        let this-institution table:get payment-to bill
        table:put choice "decision" "abandon"
        table:put choice "state" (sentence
          (list some-energy-type some-context [name] of this-institution)
          get-affordability this-institution some-energy-type
        )
        set choices lput choice choices
      ]
    ]
  ]
  if heating-system = some-energy-type and
    heating-status = "repair" and heating-system != "heat" [
    foreach table:keys payment-for [ bill ->
      if table:get payment-for bill = some-energy-type [
        let this-institution table:get payment-to bill
        let choice table:make
        table:put choice "decision" "repair"
        table:put choice "state" (sentence
          (list some-energy-type some-context [name] of this-institution)
          get-affordability this-institution some-energy-type
        )
        set choices lput choice choices
      ]
    ]
  ]
  ; Randomise the choice order and consult our brains and social network.
  let outcome? false
  foreach shuffle choices [ choice ->
    if not outcome? [
      let this-decision table:get choice "decision"
      let this-state table:get choice "state"
      ;if item 0 this-state = "heat" [
      ;  debug  (word
      ;  "trying " this-decision
      ;  " energy = " item 0 this-state
      ;  ", context = " (item 1 this-state)
      ;  " " this-state) ]
      set outcome? consult-on? this-decision this-state
      if outcome? [
        (
          ifelse this-decision = "get-advice" [
            get-some-advice this-state
          ]
          this-decision = "install" [
            if heating-system != "" [
              uninstall-heating-system
            ]
            install-new-heating-system item 0 this-state
          ]
          this-decision = "abandon" [
            uninstall-heating-system
          ]
          this-decision = "repair" [
              repair-heating-system
          ]
        )
      ]
    ]
  ]

end

; {household} maintenance

to maintenance-for [ some-energy-type ]
  foreach table:keys payment-for [ bill ->
    if table:get payment-for bill = some-energy-type [
      let this-energy-provider table:get payment-to bill
      let this-tariff table:get payment-name bill
      set balance balance -
        [table:get yearly-maintenance this-tariff] of this-energy-provider
      table:put serviced? some-energy-type true
    ]
  ]
  maybe-do-something-after "yearly-maintenance" some-energy-type
end


; {household} modify-household

to modify-household [ has-electricity? has-gas? has-heat-network?]
  ; TODO This code is not realistic as a model. Need to discuss with SEGS about
  ; how to do this properly, or at least do a good approximation.
  let this-household self
  ; Population of Scotland 2019 https://www.nrscotland.gov.uk/statistics-and-data/statistics/scotlands-facts/population-of-scotland - 5438100
  ; Let's age everbody, shuffle some old age pensioners off their coil, give
  ; birth to a few people, some people with leave and some people will marry.
  ; debug (word "modifying household " self ": asking neighbours")
  ask in-member-of-neighbors [

    let this-person self

    ; All stats from
    ; https://scotland.shinyapps.io/sg-equality-evidence-finder/
    ; https://www.nrscotland.gov.uk/statistics-and-data/statistics/scotlands-facts/life-expectancy-in-scotland
    ifelse sex = "male" [
      if age > male-age-of-death [
        die
        if [count my-in-members-of] of this-household = 0 [
          ask this-household [
            die
          ]
        ]
      ]
      ; Bit of gender bias here. If the man gets married then I assuming the
      ; woman comes to stay. This is of course an approximation, and not even
      ; meant to be realistic. It is just an aggregate, overall behaviour
      ; This structure does not exist as it is all based on averages for the
      ; Scottish government.
      ; I am also assuming that everbody will or will not marry at this age,
      ; and then not reconsider
      if age = 34 and not any? [my-in-members-of] of this-household with [age = 32]  [
        create-a-random-person this-household 32 "female"
      ]
    ]
    [
      if age > female-age-of-death [
        die
        if [count my-in-members-of] of this-household = 0 [
          ask this-household [
            die
          ]
        ]
      ]
      if age >= age-start-work and age <= age-of-menopause and random-float 1.0 < probability-of-giving-birth-that-day  [
        create-a-random-person this-household 0 ""
      ]
      if age = female-age-of-marriage [
        die; leaving home to marry
        if [count my-in-members-of] of this-household = 0 [
          ask this-household [
            die
          ]
        ]
      ]
    ]
    if age >= age-start-work [
      if random-float 1.0 < chances-of-working [
        leaves one-of my-all-attends with [
          [organization-type] of other-end = "school"]
        goes-to one-of institutions with [organization-type = "work"]
      ]
    ]

    if age > age-of-retirement [

      ifelse resolution = "household" [
        if any? out-attends-neighbors with [ organization-type = "work" ] [
          ask this-household [
            leaves one-of my-all-attends with [
              [organization-type] of other-end = "work"]
          ]
        ]
      ]
      [
        if any? out-attends-neighbors with [ organization-type = "work" ] [
          ask this-household [
            leaves one-of my-all-attends with [
              [organization-type] of other-end = "work"]
          ]
        ]
      ]
    ]
    if age > age-start-school and
    not any? out-attends-neighbors with [organization-type = "school"] [
      ; go to school
      let school one-of institutions with [organization-type = "school" and
        catchment-contains? this-household]
      if school = nobody [
        ; Do a random school anywhere, no matter how far
        set school one-of institutions with [organization-type = "school"]
        ;debug  (word "No catchment for children in household: so picking a "
        ; "random school: " school)
      ]
      goes-to school
    ]
    ; This just leaves the community-organizations and this needs reviewing
    if any? out-attends-neighbors with [
        organization-type = "community"] and
    random-float 1.0 < probability-of-leaving-community-organization [
      leaves one-of my-all-attends with [
        [organization-type] of other-end = "community"]
    ]
    ; Randomly join club with low (?) probability.
    if random-float 1.0 < probability-of-joining-community-organization [
      if any? institutions with [ organization-type =
        "community" and
        not attends-neighbor? this-person] [
        goes-to one-of institutions with [
          organization-type = "community" and
          not attends-neighbor? this-person]
      ]
    ]
  ]


  if count in-member-of-neighbors = 0 [
    die
    stop
  ]

  ; debug (word "modifying household " self ": reviewing organization")

  ; lastly review the organization of the family given the demographic changes
  if resolution = "person" [
    if dynamic = "matriarchal" or dynamic = "patriarchal" [
      ; First, let's check if there's anyone of adult age

      let household-adults in-member-of-neighbors with [age >= age-start-work]
      let hh-f-adults in-member-of-neighbors with [age >= age-start-work and sex = "female"]
      let hh-m-adults in-member-of-neighbors with [age >= age-start-work and sex = "male"]

      let dynamic-options []
      foreach family-dynamics [ family-dynamic ->
        if not ((family-dynamic = "matriarchal" and hh-f-adults = nobody)
          or (family-dynamic = "patriarchal" and hh-m-adults = nobody)) [
          set dynamic-options lput family-dynamic dynamic-options
        ]
      ]

      (ifelse household-adults = nobody [
        ; This needs to be handled better in future -- the children would go to
        ; a relative or friend, or into care if under 16. (And wouldn't be in a
        ; position to make decisions about heating technology...)

        if length dynamic-options = 0 [
          error (word "Formerly " dynamic "household with no adults cannot choose a dynamic from " family-dynamics)
        ]
        set dynamic one-of dynamic-options
      ] dynamic = "patriarchal" and hh-m-adults = nobody [
        if length dynamic-options = 0 [
          error (word "Formerly patriarchal household with no adult male cannot choose a dynamic from " family-dynamics)
        ]
        set dynamic one-of dynamic-options
      ] dynamic = "matriarchal" and hh-f-adults = nobody [
        if length dynamic-options = 0 [
          error (word "Formerly matriarchal household with no adult female cannot choose a dynamic from " family-dynamics)
        ]
        set dynamic one-of dynamic-options
      ] [
        ; Do nothing: let the matriarchy or patriarchy continue
      ])

    ]
  ]

end

to msg [ message ]
  output-print (word date-and-time "; " timer ": " message)
end

to-report n-street-votes
  ifelse is-list? street-vote-record [
    report length street-vote-record
  ] [
    report 0
  ]
end


to-report n-street-votes-for
  ifelse is-list? street-vote-record [
    let n-for 0
    foreach street-vote-record [ the-vote ->
      if item 2 the-vote [
        set n-for n-for + 1
      ]
    ]
    report n-for
  ] [
    report 0
  ]
end

to output-buildings
  debug "output-buildings: started..."
  if file-exists? buildings-input-output-file [
    err (word "output-buildings: " buildings-input-output-file " already exists")
  ]
  file-open buildings-input-output-file
  ask buildings [
    (ifelse
      not any? out-resident-neighbors [
        warn (word "A building " self " has no residents" )
      ]
      any? out-resident-neighbors with [is-household? self] [
        file-print csv:to-row (list "dwelling" xcor ycor street-name postcode count my-out-residents)
      ]
      [
        let some-name [name] of one-of out-resident-neighbors
        file-print csv:to-row (list "business" xcor ycor some-name street-name postcode)
      ]
    )
  ]
  file-close
  debug "output-buildings: ...finished."
end

;to output-cbr-metrics [ subject-score object-score some-length result ]
;  file-open "metrics.csv"
;  file-print csv:to-row (list subject-score object-score some-length result)
;  file-close
;end

; { household | person } output-decision

to output-decision [some-decision some-state outcome?]
  ifelse table:has-key? decision-record some-decision [
    let entry table:get decision-record some-decision
    ifelse outcome? [
      table:put decision-record some-decision (list (1 + item 0 entry) (1 + item 1 entry) (item 2 entry))
    ] [
      table:put decision-record some-decision (list (1 + item 0 entry) (item 1 entry) (1 + item 2 entry))
    ]
  ] [
    error (word "No entry in decision-record for decision type \"" some-decision "\"")
  ]
  if is-string? decisions and decisions != "" and decisions != "NA" [
    file-open decisions
    file-print csv:to-row (list who ticks some-decision some-state outcome?)
    file-close
  ]
end

; {observer} output-actual-pipe-line

to output-present-pipe-line
  debug "output-actual-pipe-line: started..."
  file-open pipe-present-input-output-file
  foreach n-values (max-pycor - min-pycor + 1) [ i -> i ] [ i ->
    let output-string ""
    foreach n-values (max-pxcor - min-pxcor + 1) [ j -> j ] [ j ->
      let some-patch patch (min-pxcor + j) (min-pycor + i)
      ifelse [pipe-present?] of some-patch [
        set output-string (word output-string "1")
      ]
      [
        set output-string (word output-string "0")
      ]
    ]
    file-print (output-string)
  ]
  file-close
  debug "output-present-pipe-line: ...finished."
end

; {observer} output-possible-pipe-line

to output-possible-pipe-line
  debug "output-possible-pipe-line: started..."
  file-open pipe-possible-input-output-file
  foreach n-values (max-pycor - min-pycor + 1) [ i -> i ] [ i ->
    let output-string ""
    foreach n-values (max-pxcor - min-pxcor + 1) [ j -> j ] [ j ->
      let some-patch patch (min-pxcor + j) (min-pycor + i)
      ifelse [pipe-possible?] of some-patch [
        set output-string (word output-string "1")
      ]
      [
        set output-string (word output-string "0")
      ]
    ]
    file-print (output-string)
  ]
  file-close
  debug "output-possible-pipe-line: ...finished."
end

; {observer} output-roads

to output-roads

  file-open roads-input-output-file

  ask roads [
    let record []
    set record lput name record
    set record lput xcor record
    set record lput ycor record
    ask my-patches [
      set record lput pxcor record
      set record lput pycor record
    ]
    file-print csv:to-row record
  ]
  file-close

end



; {household} pay-bank

to pay-bank [ some-bank some-payment-name ]
  set balance balance - [table:get payment some-payment-name] of some-bank
end

; {household} pay-landlord

to pay-landlord [ some-landlord some-rent-type ]
  set balance balance - [table:get rent some-rent-type] of some-landlord
end

; {household|business|association} pay-energy-provider

to pay-energy-provider-old [some-energy-provider some-tariff some-energy-type]
  let this-household self
  let bill (
    [table:get standing-charge some-tariff] of some-energy-provider +
    (table:get units-of-energy-used some-energy-type *
    [table:get retail-unit-cost some-tariff] of some-energy-provider)
  )


  if is-household? self [
    set money-spent 0
    if not table:get rent-includes? some-energy-type [
      ;show (word "bill " bill " balance " balance " " (balance - bill) " " income)
      if heating-system = some-energy-type [
        ifelse heating-system != "" [
          set history-of-units-used-for-heating lput table:get units-of-energy-used heating-system history-of-units-used-for-heating
        ]
        [
          set history-of-units-used-for-heating lput 0 history-of-units-used-for-heating
        ]
        set switched-heating-off? false
      ]
      ifelse balance - bill < 0 and bill > 0 [
        debug (word "pay-energy-provider: Household " self " cannot pay, income = " income " balance = " balance " bill = " bill)
        ; Oh dear, cannot, will pay what we can and then stick 'em on the pay as you go tariff (if one is available).
        set nof-cannot-pay-bill nof-cannot-pay-bill + 1
        ; Steal what they have
        if balance > 0 [
          set last-bill balance
          ask some-energy-provider [
            set profitability profitability + [balance] of this-household
          ]
          set balance 0
        ]
        if [table:get frequency some-tariff] of some-energy-provider != "daily" [
          foreach [table:keys energy-type] of some-energy-provider [ new-tariff ->
            if [table:get frequency new-tariff] of some-energy-provider = "daily" [
              foreach table:keys payment-for [ some-payment ->
                if (table:get payment-for some-payment = some-energy-type and
                  table:get payment-to some-payment = some-energy-provider) [
                  debug (word "pay-energy-provider: Moved " self " on to daily tariff.")
                  table:put payment-name some-payment new-tariff
                ]
              ]
            ]
          ]
        ]
        ask some-energy-provider [
          set profitability profitability + bill
        ]
        stop
      ]
      [
        set monthly-fuel-payment monthly-fuel-payment + bill
        set balance balance - bill
      ]
      if heating-system = some-energy-type [
        set last-bill bill
      ]
    ]
  ]
  table:put units-of-energy-used some-energy-type 0
  ask some-energy-provider [
    set profitability profitability + bill
  ]
  record-household-or-business-energy-consumption
end

to pay-energy-provider [some-energy-provider some-tariff some-energy-type]
  let bill 0
  (ifelse
    is-association? self and some-energy-type = "heat" and any? in-associate-neighbors [
      let this-association self
      let group-energy-consumption sum [table:get units-of-energy-used some-energy-type] of in-associate-neighbors
      set bill group-energy-consumption * [table:get retail-unit-cost payment-name] of payment-to
      let average-units group-energy-consumption / (count in-associate-neighbors )
      let average-bill (bill + surcharge) / (count in-associate-neighbors)
      ask in-associate-neighbors [
        let this-household self
        set money-spent 0
        if not table:get rent-includes? some-energy-type [
          set history-of-units-used-for-heating lput average-units history-of-units-used-for-heating
          ifelse balance - average-bill < 0 and average-bill > 0 [
            debug (word "pay-energy-provider: association " this-association " for household " self " cannot pay, income = " income " balance = " balance " bill = " bill)
            ; Oh dear, cannot, will pay what we can and then stick 'em on the pay as you go tariff (if one is available).
            set nof-cannot-pay-bill nof-cannot-pay-bill + 1
            ; Steal what they have
            if balance > 0 [
              set last-bill balance
              ask some-energy-provider [
                set profitability profitability + [balance] of this-household
              ]
              set balance 0
            ]
            ask some-energy-provider [
              set profitability profitability + average-bill
            ]
            stop
          ]
          [
            set switched-heating-off? false
            set monthly-fuel-payment monthly-fuel-payment + average-bill
            set balance balance - average-bill
          ]
          if heating-system = some-energy-type [
            set last-bill average-bill
          ]
        ]
      ]
    ]
    is-household? self [
      let this-household self
      set bill (
        [table:get standing-charge some-tariff] of some-energy-provider +
        (table:get units-of-energy-used some-energy-type *
          [table:get retail-unit-cost some-tariff] of some-energy-provider)
      )
      set money-spent 0
      if not table:get rent-includes? some-energy-type [
        ;show (word "bill " bill " balance " balance " " (balance - bill) " " income)
        if heating-system = some-energy-type [
          ifelse heating-system != "" [
            set history-of-units-used-for-heating lput table:get units-of-energy-used heating-system history-of-units-used-for-heating
          ]
          [
            set history-of-units-used-for-heating lput 0 history-of-units-used-for-heating
          ]
          set switched-heating-off? false
        ]
        ifelse balance - bill < 0 and bill > 0 [
          debug (word "pay-energy-provider: Household " self " cannot pay, income = " income " balance = " balance " bill = " bill)
          ; Oh dear, cannot, will pay what we can and then stick 'em on the pay as you go tariff (if one is available).
          set nof-cannot-pay-bill nof-cannot-pay-bill + 1
          ; Steal what they have
          if balance > 0 [
            set last-bill balance
            ask some-energy-provider [
              set profitability profitability + [balance] of this-household
            ]
            set balance 0
          ]
          if [table:get frequency some-tariff] of some-energy-provider != "daily" [
            foreach [table:keys energy-type] of some-energy-provider [ new-tariff ->
              if [table:get frequency new-tariff] of some-energy-provider = "daily" [
                foreach table:keys payment-for [ some-payment ->
                  if (table:get payment-for some-payment = some-energy-type and
                    table:get payment-to some-payment = some-energy-provider) [
                    debug (word "pay-energy-provider: Moved " self " on to daily tariff.")
                    table:put payment-name some-payment new-tariff
                  ]
                ]
              ]
            ]
          ]
          ask some-energy-provider [
            set profitability profitability + bill
          ]
          stop
        ]
        [
          set switched-heating-off? false
          set monthly-fuel-payment monthly-fuel-payment + bill
          set balance balance - bill
        ]
        if heating-system = some-energy-type [
          set last-bill bill
        ]
      ]
    ]
    is-business? self [
      set bill (
        [table:get standing-charge some-tariff] of some-energy-provider +
        (table:get units-of-energy-used some-energy-type *
          [table:get retail-unit-cost some-tariff] of some-energy-provider)
      )
    ]
  )
  table:put units-of-energy-used some-energy-type 0
  ask some-energy-provider [
    set profitability profitability + bill
  ]
  record-household-or-business-energy-consumption
end


; {household} determine-disposable-income

to-report random-values
  let attitudes []
  foreach surveyed-values [
    key ->
    set attitudes lput get-random-value attitudes
  ]
 report attitudes
end

; This returns a list of
; [
;   heating-system-age / lifetime-of-heating-system  or 1 whchever is less
;   highest installation cost for the energy-type and that institution.
;   cost of termination of contract
;   yearly-maintenance
; ]

to-report random-affordability

  let install []
  let disconnect []
  let maintenance []
  ask energy-providers [
    set install (sentence install table:values installation-cost)
    set disconnect (sentence disconnect table:values disconnection-cost)
    set maintenance (sentence maintenance table:values yearly-maintenance)
  ]
  let random-lifetime random-normal 1 0.25
  if random-lifetime < 0 [
    set random-lifetime 0
  ]
  let random-install (random-normal mean install (max install - min install) / 4)
  if random-install < 0 [
    set random-install 0
  ]
  let random-disconnect (random-normal mean disconnect (max disconnect - min disconnect) / 4)
  if random-disconnect < 0 [
    set random-disconnect 0
  ]
  let random-maintenance (random-normal mean maintenance (max maintenance - min maintenance) / 4)
  if random-maintenance < 0 [
    set random-maintenance 0
  ]
  report (list
    random-lifetime
    random-install
    random-disconnect
    random-maintenance
  )

end

to random-street-names-and-pipe-route
  debug "Started randomly naming streets and possible pipe network..."

  ask roads with [ pipe-possible? and name != ""] [
   set name ""
  ]
  debug (word "Naming streets: there are " (count patches with [pipe-possible?]) " patches that could have a pipe in")
  ask roads with [ member? true [pipe-possible?] of my-patches and name != ""] [
   set name ""
  ]
  while [ any? roads with [ member? true [pipe-possible?] of my-patches and name = "" ]  ] [
    let some-random-street-name (word "street-" random 1000000000 )
    let some-road one-of roads with [ member? true [pipe-possible?] of my-patches and name  = ""]
    if some-road = nobody [
      stop
    ]
    ask other roads with [
      member? true [pipe-possible?] of my-patches and
      name = "" and
      distance some-road < random-street-length / 2] [
      set name some-random-street-name
    ]

    let min-point min-one-of roads with [ name = some-random-street-name ] [ distance some-road  ]
    let max-point max-one-of roads with [ name = some-random-street-name ] [ distance some-road  ]

    if extent = "Torry" [
      let starting-nexus nobody
      ask min-point [
        hatch-nexuses 1 [
          set hidden? true
          set starting-nexus self
        ]
      ]
      ask max-point [
        hatch-nexuses 1 [
          set hidden? true
          create-link-with starting-nexus [
            set hidden? true
          ]
          between-nexuses starting-nexus
        ]
      ]
    ]
  ]

  if extent = "Torry" [
    debug "Handling nexuses"
    ask nexuses [
      let me self
      let my-nodes link-neighbors
      if count my-nodes <= 1 [
        ask min-n-of (2 + random 3) other nexuses with [not link-neighbor? me] [distance me] [
          let other-nexus self
          create-link-with me [
            set hidden? true
          ]
          between-nexuses me
        ]
      ]
    ]

    debug "Resetting patches' pipe-possible? and pipe-present? status"
    ask patches [
      set pipe-possible? false
      if pipe-present? [
        set pipe-possible? true
        set pipe-present? false
        ;set pcolor blue
      ]
    ]

    ask nexuses [
      die
    ]
  ]
  debug (word "...Ended randomly naming streets and possible pipe network. Now there are " (count patches with [pipe-possible?]) " patches that could have a pipe in")

end

;  advisory-body|grant-agency|business|landlord} recommends

to-report recommend [ some-decision some-outcome?]

  ; This needs to return a value in the range [0-1]
  ; We are going to sum over the relevant historical recommendations

  let nof-recommends 0
  let total-nof-requests 0
  if length table:keys recommendations = 0 [
    report 0
  ]
  let me self
  foreach table:keys recommendations [ some-agent-name ->
    let some-agent item 2 [table:get recommendations some-agent-name] of me
    if is-turtle? some-agent [
      ask some-agent [
        if item 0 [table:get recommendations some-agent-name] of me = some-decision
        and item 1 [table:get recommendations some-agent-name] of me = some-outcome? [
          ; truth table:
          ; do-it were-in-fuel-poverty now-in-fuel-poverty recommend?
          ; yes   no                   yes                 0
          ; yes   yes                  yes                 0
          ; yes   no                   no                  1
          ; yes   yes                  no                  1
          ; no    no                   yes                 0
          ; no    yes                  yes                 0
          ; no    no                   no                  1
          ; no    yes                  no                  1
          ; Fortunately this appears to be symmetric and simplifies to
          ; now-in-fuel-poverty recommend?
          ; yes                  0
          ; no                   1
          ; so seemingly we don't need the history. I don't believe this.
          ; I am leaving the history, because I can probably use it in
          ; in the trust feedback loop.

          let this-household self
          if is-person? self [
            set this-household one-of out-member-of-neighbors
          ]
          if [fuel-poverty] of this-household < 0.1 [
            ; Not in fuel poverty
            set nof-recommends nof-recommends + 1
          ]
          set total-nof-requests total-nof-requests + 1
        ]
      ]
    ]
  ]
  if total-nof-requests = 0 [
    report 0
  ]
  report nof-recommends / total-nof-requests
end

; {household|business} record-consumption


to record-household-daily-consumption [some-units]
  if actual-consumption-out != "" [
     if not file-exists? actual-consumption-out [
      file-open actual-consumption-out
      file-print "who,when,units"
      file-close
    ]
    file-open actual-consumption-out
    file-print (word who "," ticks "," some-units)
    file-close
  ]
end

; {household|business} record-household-or-businews-energy-consumption

to record-household-or-business-energy-consumption
  ; Check if we are outputting energy consumption for households
  if actual-hh-out != "" [
    ; Record energy output
    if is-household? self [
      if not file-exists?  actual-hh-out [
        file-open actual-hh-out
        file-print "when,who,type,income,balance,energy-expenditure,fuel-poverty"
        file-close
      ]
      file-open  actual-hh-out
      file-print (word ticks ","
        who "," heating-system "," precision income 3 ","
        precision balance 3 "," precision last-bill  3 ","
        precision fuel-poverty 3)
      file-close
    ]
  ]
  ; Check if we are outputting energy consumption for businesses
  if actual-bus-out != "" [
    if is-business? self [
      if not file-exists?  actual-bus-out [
        file-open actual-bus-out
        file-print "when,who,type,energy-expenditure"
        file-close
      ]
      file-open  actual-bus-out
      file-print (word ticks "," who "," heating-system "," precision last-bill  3)
      file-cLose
    ]
  ]
end

; {energy-provider} record-profits

to record-profits
  if ticks mod 365 = 0 [
    table:put profits year profitability
    set profitability 0
  ]
  if actual-nrg-out != "" [
    if not file-exists? actual-nrg-out [
      file-open actual-nrg-out
      file-print "when,who,total-profits"
      file-close
    ]
    file-open actual-nrg-out
    file-print (word ticks "," name "," precision profitability 3)
    file-close
  ]
end

to-report repeat-string [some-string some-number]
  let this-list []
  repeat some-number [
    set this-list lput some-string this-list
  ]
  report this-list
end

; {household} repair-heating-system

to repair-heating-system
  if average-repair-bill > balance [
    stop
  ]
  set balance balance - average-repair-bill
  set heating-status "working"
end

; {household|person} review-trust

to review-trust

  if ticks > 0 [
    let pool ifelse-value resolution = "person" [persons][households]
    ask pool [
      let me self
      let counts table:make
      foreach n-values length trust [ i -> i] [ i ->
        table:put counts item i trust 0
      ]
      ask my-knows [
        let advisor-type network
        if member? advisor-type [trust] of me [
          if not table:has-key? counts advisor-type [
            table:put counts advisor-type 0
          ]
          ask other-end [

            foreach table:keys recommendations [ some-agent-name ->

              let some-decision item 0 table:get recommendations some-agent-name
              let some-outcome item 1 table:get recommendations some-agent-name
              let some-agent item 2 table:get recommendations some-agent-name

              if is-turtle? some-agent [
                ask some-agent [
                  let was-in-fuel-poverty? false
                  let now-in-fuel-poverty? false
                  ifelse is-household? self [
                    set was-in-fuel-poverty? ifelse-value (length history-of-fuel-poverty = 0) [ false ] [ min history-of-fuel-poverty >= 0.1 ]
                    set now-in-fuel-poverty? fuel-poverty >= 0.1
                  ]
                  [
                    ask one-of out-member-of-neighbors [
                      ifelse length history-of-fuel-poverty = 0 [
                        set was-in-fuel-poverty? false
                      ]
                      [
                        set was-in-fuel-poverty? min history-of-fuel-poverty >= 0.1
                      ]
                      set now-in-fuel-poverty? fuel-poverty >= 0.1
                    ]
                  ]


                  ; truth table:
                  ; do-it was-in-fuel-poverty now-in-fuel-poverty nudge?
                  ; yes   no                   yes                 down big
                  ; yes   yes                  yes                 leave
                  ; yes   no                   no                  leave
                  ; yes   yes                  no                  up
                  ; no    no                   yes                 down
                  ; no    yes                  yes                 leave
                  ; no    no                   no                  leave
                  ; no    yes                  no                  up

                  ; Symmetric, so we don't really care about whether the
                  ; advice was for or against.

                  ; The nudge should be asymptotic at 0 and 1, so we don't
                  ; actually reach the edges of the closure.

                  if not was-in-fuel-poverty? and now-in-fuel-poverty? [
                    table:put counts advisor-type table:get counts advisor-type + 1
                  ]
                  if was-in-fuel-poverty? and not now-in-fuel-poverty? [
                    table:put counts advisor-type table:get counts advisor-type - 1
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
      ;show (word "Before " trust)
      ;show (word "to-list " table:to-list counts)
      let trust-tuples sort-by [ [i j] -> item 1 i > item 1 j ] table:to-list counts
      set trust []
      foreach n-values length trust-tuples [i -> i][ i ->
        set trust lput item 0 item i trust-tuples trust
      ]
      ;show (word "After " trust)
    ]
  ]
end

; {observer} setup-a-business-premise

to setup-a-business-premise [ some-name some-street-name some-postcode ]
  ;debug (word "setup-a-business-premise: starting... " some-name " " some-street-name " " some-postcode)
  sprout-buildings 1 [
    let this-building self
    ; TODO need reseaarch on the distribution of this.
    set energy-rating one-of [ "A" "B" "C" "D" "E" "F" "G" ]
    set has? table:make
    table:put has? "gas" one-of [true false]
    table:put has? "electric" true
    table:put has? "heat" false
    set street-name some-street-name
    if extent = "Timisoara" [
      ifelse eligibility = "by-proximity" [
        if any? patches with [pipe-present? and distance this-building <= proximal-qualification-distance] [
          connect-building-to-heat-network
        ]
      ]
      [
        if any? roads with [name = some-street-name and member? true [pipe-present?] of my-roads] [
          connect-building-to-heat-network
        ]
      ]
    ]
    ifelse extent = "Torry" [
      set shape "building store"
      set color violet
      set size 10
    ]
    [
      set shape "circle"
      set color violet
      set size 1
    ]
    hatch-businesses 1 [
      create-resident-from this-building [ set hidden? true ]
      create-a-random-business some-name
    ]
  ]
  ;debug "setup-a-business-premise: ...ended."
end

; {observer} setup-a-dwelling

to setup-a-dwelling [ some-nof-households some-street-name some-postcode]

  ;debug (word "setup-a-dwelling: starting... " some-nof-households " " some-street-name " " some-postcode)
  sprout-buildings 1 [

    let this-building self

    ifelse table:has-key? energy-ratings some-postcode [
      set energy-rating table:get energy-ratings some-postcode
    ]
    [
      let energy-rating-index min (list 7 max (list 1 int(random-normal 4 2))) - 1
      set energy-rating item energy-rating-index [ "A" "B" "C" "D" "E" "F" "G" ]
    ]
    ifelse table:has-key? council-taxes some-postcode [
      set council-tax-band table:get council-taxes some-postcode
    ]
    [
      let council-tax-band-index min (list 8 max (list 1 int(random-normal 4 2))) - 1
      set council-tax-band item council-tax-band-index [ "A" "B" "C" "D" "E" "F" "G" "H" ]
    ]
    ; TODO - need some stats on these
    set has? table:make
    if tick-new-technology >= 0 [
      table:put has? "new-technology" true
    ]

    table:put has? "gas" true
    table:put has? "electric" true
    table:put has? "heat" false
    if extent = "Timisoara" [
      ifelse eligibility = "by-proximity" [
        if any? patches with [pipe-present? and distance this-building <= proximal-qualification-distance] [
          connect-building-to-heat-network
        ]
      ]
      [
        if any? roads with [name = some-street-name and member? true [pipe-present?] of my-roads] [
          connect-building-to-heat-network
        ]
      ]
    ]

    if not setup? and heat-network-mandatory-for-new-builds? [
      table:put has? "heat" true
      table:put has? "gas" false
    ]
    set nof-households some-nof-households
    set street-name some-street-name
    set postcode some-postcode
    let got-nof-households 0
    if table:has-key? household-postcodes some-postcode [
      foreach up-to-n-of nof-households table:get household-postcodes some-postcode [
        some-household-name ->
        hatch-households 1 [
          load-a-household-from-table
          some-household-name
          [table:get has? "electric"] of this-building
          [table:get has? "gas"] of this-building
          [table:get has? "heat"] of this-building
          set got-nof-households got-nof-households + 1
          create-resident-from this-building [ set hidden? true ]
        ]
      ]
    ]
    let some-households (turtle-set nobody)
    hatch-households nof-households - got-nof-households [
      set some-households (turtle-set some-households self)
      create-resident-from this-building [ set hidden? true ]
      create-a-random-household
      [table:get has? "electric"] of this-building
      [table:get has? "gas"] of this-building
      [table:get has? "heat"] of this-building
    ]

    set shape "house"
    (ifelse
      extent = "Aberdeen" [
        set size 2
      ]
      extent = "Timisoara" [
        set size 3
      ]
      [
        set size 10 + count out-resident-neighbors
      ]
    )
    create-some-associations some-households
  ]

  ;debug "setup-a-dwelling: ...ended."

end

; {observer} setup-msm

to setup-msm [ some-name some-type]

  ; This is a star network with a random chance of an household or
  ; person connecting to it.

  create-msms 1 [
    set name some-name
    set organization-type some-type
    set color [0 0 0 0]
    if use-cbr? [
      set case-base cbr:new
      cbr:lambda case-base simple-comparator
    ]
    set recommendations table:make
  ]
end

; {observer | adhoc } show-networks

to show-networks

  debug "Showing netwworks..."
  ;debug (word "network " network " for " end1 " and " end2)
  ask knows [
    if network = "social" and show-social-network? [
      set hidden? false
      set color grey
    ]
    if network = "neighbour" and show-neighbour-network? [
  ;debug  (word "network " network " for " end1 " and " end2)
      set hidden? false
      set color turquoise
      show-link
    ]
    if network = "local" and show-local-media-network? [
      set hidden? false
      set color red
    ]
    if network = "national" and show-national-media-network? [
      set hidden? false
      set color orange
    ]
    if network = "bank" and show-bank-network? [
      set hidden? false
      set color yellow
    ]
    if network = "work" and show-work-network? [
      set hidden? false
      set color green
    ]
    if network = "school" and show-school-network? [
      set hidden? false
      set color sky
    ]
    if network = "community" and show-community-network? [
      set hidden? false
      set color violet
    ]
    if network = "landlord" and show-landlord-network? [
      set hidden? false
      set color pink
    ]
    if network = "advice" and show-advisory-network? [
      set hidden? false
      set color magenta
    ]
    if network = "energy" and show-energy-network? [
      set hidden? false
      set color brown
    ]
  ]
  debug "...finished showing networks"
end

to show-schools
  ask institutions with [organization-type = "school" ] [
    set hidden? false
    set shape "house"
    set color red
    set size 10
    draw-circle pxcor pycor catchment-radius red
  ]
end

to-report simple-comparator [casebase subject-case object-case reference-case ]

  ; Assumptions for default comparator
  ; State arrives in a table with key against value.
  ; If number take one from the other and store and scale to [0,1]
  ; If boolean match gives 0, 1 if not
  ; If string match gives 0 , 1 if not
  if cbr:decision casebase object-case != cbr:decision casebase subject-case [
    ;output-cbr-metrics "Oc" cbr:decision casebase object-case "Sc" cbr:decision casebase subject-case
    report cbr:invalid
  ]
  if cbr:decision casebase object-case != cbr:decision casebase reference-case [
    ;output-cbr-metrics "Oc" cbr:decision casebase object-case "Rc" cbr:decision casebase reference-case
    report cbr:invalid
  ]

  let subject-state cbr:state casebase subject-case
  let object-state cbr:state casebase object-case
  let reference-state cbr:state casebase reference-case

  if not is-list? subject-state or
    not is-list? object-state or
    not is-list? reference-state [
    ;output-cbr-metrics "N" is-list? subject-state is-list? object-state is-list? reference-state
    report cbr:invalid
  ]

  let subject-score 0
  let object-score 0
  let comparison-length min (list length subject-state length object-state length reference-state)
  foreach n-values comparison-length [ i -> i ] [ i ->
    let subject-value item i subject-state
    let object-value item i object-state
    let reference-value item i reference-state
    (ifelse
      i = 1 and not include-context? [
        ; This is the context we are ignoring...
      ]
      is-number? subject-value and is-number? object-value and is-number? reference-value [
        ifelse  abs(subject-value - reference-value) <= abs(object-value - reference-value) [
          set object-score object-score + 1
        ]
        [
          set subject-score subject-score + 1
        ]
      ]
      subject-value = reference-value and object-value != reference-value [
        set object-score object-score + 1
      ]
      subject-value != reference-value and object-value = reference-value [
        set subject-score subject-score + 1
      ]
      subject-value != reference-value and object-value != reference-value [
        set subject-score subject-score + 1
        set object-score object-score + 1
      ]
    )
  ]
  ;output-cbr-metrics (word "VALUES " cbr:decision casebase object-case "\n") (word subject-state "\n") (word object-state "\n") (word reference-state "\n")
  if abs (subject-score - object-score) / comparison-length > invalidity-scalar [
    ;output-cbr-metrics (word "INVALID-" subject-score) object-score length reference-state ((subject-score - object-score) / length reference-state)
    report cbr:invalid
  ]
  if subject-score = object-score [
    ;output-cbr-metrics (word "EQUAL-" subject-score) object-score length reference-state ((subject-score - object-score) / length reference-state)
   report cbr:equal
  ]
  if subject-score < object-score [
    ;output-cbr-metrics (word "YES-" subject-score) object-score length reference-state ((subject-score - object-score) / length reference-state)
    report cbr:yes
  ]
  ;output-cbr-metrics (word "NO-" subject-score) object-score length reference-state ((subject-score - object-score) / length reference-state)
  report cbr:no
end


; {observer} stats

to stats
  if actual-stats-out = "" [
    stop
  ]
  if not file-exists?  actual-stats-out [
    file-open actual-stats-out
    file-print (word "when,household-possible-connections,"
      "household-actual-connections,business-possible-connections,"
      "business-actual-connections")
    file-close
  ]
  let household-actual-connections count households with
    [heating-system = "heat"]
  let business-actual-connections  count businesses with
    [heating-system = "heat"]
  let household-possible-connections 0
  let business-possible-connections 0
  ask buildings  with [table:get has? "heat"] [
    ask out-resident-neighbors [
      ifelse is-business? self  [
        set business-possible-connections business-possible-connections + 1
      ]
      [
        set household-possible-connections household-possible-connections + 1
      ]
    ]
  ]
  file-open  actual-stats-out
  file-print (word ticks "," household-actual-connections ","
    household-possible-connections ","
    business-actual-connections ","
    business-possible-connections)
  file-close

end

; {observer} structures-for-aberdeen

to structures-for-aberdeen

  debug  (word date-and-time ":structures-for-aberdeen: setting up houses and businesses...")
  if display-gis? [
    err "structures-for-aberdeen: gis-display? set to false"
  ]

  let abm-map-file "roads.aberdeen"
  let abm-map-data gis-load-dataset (word gis-dir "/" abm-map-file ".shp")
  gis:set-world-envelope gis:envelope-of abm-map-data

  if not member? "PC_1" gis:property-names addresses [
    error (word date-and-time ":structures: " addresses-pathname " does not contain property PC_1 (postcode)")
  ]
  if not member? "TN" gis:property-names addresses [
    error (word date-and-time ":structures: " addresses-pathname " does not contain property TN (street name)")
  ]
  if not member? "ON_" gis:property-names addresses [
    error (word date-and-time ":structures: " addresses-pathname " does not contain property ON_ (official/business name)")
  ]
  if not member? "FREQUENCY" gis:property-names addresses [
    ; I am not entirely sure, but I suspect this is something to do with occupancy
    ; Gary tells me it is the frequency of that postcode.
    error (word date-and-time ":structures: " addresses-pathname " does not contain property FREQUENCY (occupancy?)")
  ]
  ; I strongly suspect there are duplicates in this data,
  ; I have separating them out on ID and location but there are slightly
  ; differing values. I suppose I am going to have to trust Jiaqi's data.
  ; It would be nice to know how she produced it.

  debug (word "structures-for-aberdeen: There are " length gis:feature-list-of addresses " vector featurs to process.")
  let record-count 0
  foreach gis:feature-list-of addresses [ vector-feature ->
    set record-count record-count + 1
    if record-count >= nof-buildings and limit-buildings? [
      debug (word ":structures: ...ended setting up " count buildings " buildings.")
      stop
    ]
    if record-count mod 100 = 0 [
      debug (word "structures-for-aberdeen: processed " record-count " vector features.")
    ]
    let vector-feature-coordinates gis:location-of gis:centroid-of vector-feature

    ; centroid will be an empty list if it lies outside the bounds
    ; of the current NetLogo world, as defined by our current GIS
    ; coordinate transformation
    ;debug (word "structures: in-")
    if not empty? vector-feature-coordinates [
      let vertex gis:centroid-of vector-feature
      let this-patch patch item 0 gis:location-of vertex item 1 gis:location-of vertex
      ;debug (word "structures: out-" this-patch)
      ask this-patch [
        let some-business-name gis:property-value vector-feature "ON_"
        let some-street-name gis:property-value vector-feature "TN"
        let some-postcode gis:property-value vector-feature "PC_1"
        let some-freq-of-postcode gis:property-value vector-feature "FREQUENCY"
        if (some-street-name = "" and
          random-street-naming?) [
          let target-road min-one-of
          (roads in-radius 100 with [name != ""])
          [distance myself]
          ifelse target-road = nobody [
            debug  (word "structures-for-aberdeen: building "
              " name: " some-business-name
              " street-name " some-street-name
              " postcode " some-postcode
              " have has info missing.")
          ]
          [
            set some-street-name [name] of target-road
          ]
        ]
        ifelse some-freq-of-postcode = 1 and some-business-name != "" [
;          debug  (word "structures: setting up a business "
;            " name: " some-business-name
;            " street-name " some-street-name
;            " postcode " some-postcode)

          setup-a-business-premise
            some-business-name
            some-street-name
            some-postcode
        ]
        [
          ; Firstly look for duplicate post codes
          if not any? buildings with [postcode = some-postcode] [
            ; Now the problem is that these might be the same building or they might not be the same building.
            ; We have the frequency of the postcode, so we need to split this frequency into the distribution
            ; below

            ; The distribution of types of property in Aberdeen in 2016 was
            ; https://www.aberdeencity.gov.uk/sites/default/files/2018-01/2016%20Estimates%20of%20Households%20and%20Dwellings%20in%20Aberdeen%20City.pdf
            ; + 55% flats
            ; + 18% terraced
            ; + 17% semi-detached
            ; + 11% detached
            ; This means there is 29% chance this is a single residence building
            ; 11% chance of 2 or more households
            ; Remainder is > 2. The problem is the distribution on this one.
            let nof-households-done 0
            while [ nof-households-done < some-freq-of-postcode ] [

              let number-of-households 1
              let some-scalar random 99
              (ifelse
                some-scalar < 18 [
                  set number-of-households 2
                ]
                some-scalar > 45 [
                  ; I can find no statistics on this, but the number of households is 106,749, so
                  ; I am going to use the frequency of the postcode to predicate the tower block size.
                  ; TODO justify this
                  set number-of-households 3 + random-exponential 3
                ]
              )
              if number-of-households > some-freq-of-postcode - nof-households-done [
                set number-of-households some-freq-of-postcode - nof-households-done
              ]
              if number-of-households < 1 [
                set number-of-households 1
              ]
              set nof-households-done nof-households-done + number-of-households

;              debug  (word "structures: setting up a household "
;                " nof households : " number-of-households
;                " street-name " some-street-name
;                " postcode " some-postcode)
              setup-a-dwelling
                number-of-households
                some-street-name
                some-postcode
            ]
          ]
        ]
      ]
    ]
  ]
  debug (word ":structures-for-aberdeen: ...ended setting up " count buildings " buildings.")
end

; {observer} structures-for-timisoara

to structures-for-timisoara

  debug  (word date-and-time ":structures-for-timisoar: setting up houses and businesses...")
  if display-gis? [
    err "structures-for-timisoara: gis-display? set to false"
  ]
  let abm-map-build-data gis-load-dataset   (word gis-dir "/" "buildings.timisoara" ".shp")
  debug (word "structures-for-timisoara: There are " length gis:feature-list-of abm-map-build-data " vector features to process.")
  gis:set-world-envelope gis:envelope-of abm-map-build-data
  let record-count 0
  foreach gis:feature-list-of abm-map-build-data [ vector-feature ->
    set record-count record-count + 1
    if record-count >= nof-buildings and limit-buildings? [
      debug (word ":structures: ...ended setting up " count buildings " buildings.")
      stop
    ]
    if record-count mod 100 = 0 [
      debug (word "structures-for-timisoara: processed " record-count " vector features.")
    ]
    let vector-feature-coordinates gis:location-of gis:centroid-of vector-feature

    ; centroid will be an empty list if it lies outside the bounds
    ; of the current NetLogo world, as defined by our current GIS
    ; coordinate transformation
    if not empty? vector-feature-coordinates [
      let vertex gis:centroid-of vector-feature
      let some-name gis:property-value vector-feature "name"
      let some-postcode "UNKNOWN"
      let some-street-name ""
      let this-patch patch item 0 gis:location-of vertex item 1 gis:location-of vertex
      ask this-patch [
        let target-road min-one-of
        (roads in-radius 100 with [name != ""])
        [distance myself]
        ifelse target-road = nobody [
          debug  (word "structures-for-timisoara: building "
            " name: " some-name
            " street-name " some-street-name
            " postcode " some-postcode
            " have has info missing.")
        ]
        [
          set some-street-name [name] of target-road
        ]
        let some-type gis:property-value vector-feature "type"
        ifelse some-type = "industrial" or some-type = "retail" [
          setup-a-business-premise some-name some-street-name some-postcode
        ]
        [
          let nof-dwellings floor (1.0 + random-exponential 1.0 )
          if nof-dwellings > max-households-per-building [
           set nof-dwellings max-households-per-building
          ]
          setup-a-dwelling nof-dwellings some-street-name some-postcode
        ]

      ]
    ]
  ]
  debug (word ":structures-for-timisoara: ...ended setting up " count buildings " buildings.")

end

; {observer} structures-for-torry

to structures-for-torry

  debug (word date-and-time ":structures-for-torry: setting up houses and businesses...")
  if display-gis? [
    err "structures-for-torry: gis-display? set to false"
  ]
  let abm-map-file "torry"
  let abm-map-data gis-load-dataset (word gis-dir "/" abm-map-file ".shp")
  gis:set-world-envelope gis:envelope-of abm-map-data

  let buildings-with-single-households-file "torry.buildings.single"
  let buildings-with-single-households gis-load-dataset (word gis-dir "/"
    buildings-with-single-households-file ".shp")

  ;let buildings-with-5-or-less-households-file "Minus_Block_Point_Count"
  let buildings-with-5-or-less-households-file "torry.buildings.5-or-less"
  let buildings-with-5-or-less-households gis-load-dataset (word gis-dir "/"
    buildings-with-5-or-less-households-file ".shp")

  let buildings-with-6-or-more-households-file "torry.buildings.6-or-more"
  let buildings-with-6-or-more-households gis-load-dataset (word gis-dir "/"
    buildings-with-6-or-more-households-file ".shp")

  ;let business-locations-file "businesses-(from-Network-Loads)"
  let business-locations-file "torry.businesses"
  let business-locations gis-load-dataset (word gis-dir "/"
    business-locations-file ".shp")


  ; A much, much quicker way of doing this is....
  ;ask patches gis:intersecting buildings-with-6-or-more-households [ ...]
  ; the you don't get to access the attribute of the map.

  debug "structures-for-torry: setting up buildings with 6 or more households..."
  foreach gis:feature-list-of buildings-with-6-or-more-households [
    vector-feature ->
    let some-street-name ""
    if member? "STREET_DES" gis:property-names buildings-with-6-or-more-households [
      set some-street-name gis:property-value vector-feature "STREET_DES"
    ]
    let some-postcode gis:property-value vector-feature "POSTCODE_L"
    ask patches gis:intersecting vector-feature [
      ; So in case we have no street name then get the one nearest.
      if (some-street-name = "unknown" and
        random-street-naming?) [
        let target-road min-one-of
        (roads in-radius 100 with [name != "" and name != "unknown"])
        [distance myself]
        ifelse target-road = nobody [
          debug (word "structures-for-torry: building "
            " street-name " some-street-name
            " postcode " some-postcode
            " have has info missinng.")
        ]
        [
          set some-street-name [name] of target-road
        ]
      ]
      ; TODO - random distribution is rubbish
      setup-a-dwelling 6 + random (max-households-per-building - 6)
      some-street-name
      some-postcode

    ]
  ]


  ; Error as at 31 March 2021, 16:30
  ; Patch at -301, -59 has no patches in-radius 100 with [street-name != ""
  ; error while patch -301 -59 running ERROR
  ; called by (anonymous command: [ vector-feature -> ...
  ; called by procedure SETUP
  ; called by Button 'setup'
  debug "structures-for-torry: setting up buildings with 5 and 2 households..."
  foreach gis:feature-list-of buildings-with-5-or-less-households [
    vector-feature ->
    ; This file is missing these values.
    let some-street-name "unknown"
    if member? "STREET_DES" gis:property-names buildings-with-5-or-less-households [
      set some-street-name gis:property-value vector-feature "STREET_DES"
    ]
    let some-postcode "UNKNOWN"
    if member? "POSTCODE_L" gis:property-names buildings-with-5-or-less-households [
      set some-postcode gis:property-value vector-feature "POSTCODE_L"
    ]
    ask patches gis:intersecting vector-feature [
      ; So in case we have no street name then get the one nearest.
      if (some-street-name = "unknown" and
        random-street-naming?) [
        let target-road min-one-of
        (roads in-radius 100 with [name != "" and name != "unknown"])
        [distance myself]
        ifelse target-road = nobody [
          debug (word "structures-for-torry:  building "
            " street-name " some-street-name
            " postcode " some-postcode
            " have has info missing.")
        ]
        [
          set some-street-name [name] of target-road
        ]
      ]
      ; TODO - random distribution is rubbish
      setup-a-dwelling 2 + random 4
      some-street-name
      some-postcode
    ]
    ;]
  ]

  debug "structures-for-torry: setting up buildings with single households..."
  foreach gis:feature-list-of buildings-with-single-households [
    vector-feature ->
    ;let some-street-name gis:property-value vector-feature "STREET_DES"

    let some-street-name "unknown"
    if member? "STREET_DES" gis:property-names buildings-with-single-households [
      set some-street-name gis:property-value vector-feature "STREET_DES"
    ]
    let some-postcode "UNKNOWN"
    if member? "POSTCODE_L" gis:property-names buildings-with-single-households [
      set some-postcode gis:property-value vector-feature "POSTCODE_L"
    ]
    ask patches gis:intersecting vector-feature [
      ; So in case we have no street name then get the one nearest.
      if (some-street-name = "unknown" and
        random-street-naming?) [
        let target-road min-one-of
        (roads in-radius 100 with [name != "" and name != "unknown"])
        [distance myself]
        ifelse target-road = nobody [
          debug (word "structures-for-torry:  building "
            " street-name " some-street-name
            " postcode " some-postcode
            " have has info missing.")
        ]
        [
          set some-street-name [name] of target-road
        ]
      ]
      setup-a-dwelling 1
      some-street-name
      some-postcode
    ]
  ]

  debug "setting up businesses..."
  ; GETS the properties - remember
  foreach gis:feature-list-of business-locations [ vector-feature ->
    let business-name gis:property-value vector-feature "NAME"
    let some-street-name "unknown"
    if member? "STREET_DES" gis:property-names business-locations [
      set some-street-name gis:property-value vector-feature "STREET_DES"
    ]
    let some-postcode "UNKNOWN"
    if member? "POSTCODE_L" gis:property-names business-locations [
      set some-postcode gis:property-value vector-feature "POSTCODE_L"
    ]
    ask patches gis:intersecting vector-feature [
      if (some-street-name = "unknown" and
        random-street-naming?) [
        let target-road min-one-of
        (roads in-radius 100 with [name != "" and name != "unknown"])
        [distance myself]
        ifelse target-road = nobody [
          debug (word "structures-for-torry:  building "
            " business-name " business-name
            " street-name " some-street-name
            " postcode " some-postcode
            " have has info missing.")
        ]
        [
          set some-street-name [name] of target-road
        ]
      ]
      setup-a-business-premise
      business-name
      some-street-name
      some-postcode
    ]
  ]

  debug (word ":structures-for-torry: ...ended setting up " count buildings " buildings.")
end

to-report street-votes-p-for
  let p-for []
  if not is-list? street-vote-record [
    report p-for
  ]
  foreach street-vote-record [ the-vote ->
    ifelse item 0 the-vote = 0 [
      set p-for lput 0 p-for
    ] [
      set p-for lput ((item 1 the-vote) / (item 0 the-vote)) p-for
    ]
  ]
  report p-for
end


to-report mean-street-votes-p-for
  let p-for street-votes-p-for
  report ifelse-value (length p-for = 0) [ 0 ] [ mean p-for ]
end

to-report min-street-votes-p-for
  let p-for street-votes-p-for
  report ifelse-value (length p-for = 0) [ 0 ] [ min p-for ]
end

to-report max-street-votes-p-for
  let p-for street-votes-p-for
  report ifelse-value (length p-for = 0) [ 0 ] [ max p-for ]
end

to-report median-street-votes-p-for
  let p-for street-votes-p-for
  report ifelse-value (length p-for = 0) [ 0 ] [ median p-for ]
end


to street-votes
  debug "street-votes: starting..."
  let total-profit-% []
  if street-voting != "disabled" [
    ask roads with [ member? true [pipe-possible?] of my-patches and
      near-heat-network? and
      ticks - last-voted > voting-gap and
      member? false [pipe-present?] of my-patches ] [
      set voted? false
    ]
    ; We are only going to allow a vote on those streets that are contigous to a stree with pipe already laid and
    ; have not voted in the last 5 years.

    ask roads with [
      member? true [pipe-possible?] of my-patches and
      member? false [pipe-present?] of my-patches and
      ticks - last-voted > voting-gap and
      near-heat-network? and
      not voted? ] [


      let this-road-name name
      let this-road self
      let cost-of-road count my-patches * cost-per-patch-for-pipe-line
      let nof-possible-votes 0
      let potential-profitability 0
      let votes 0
      set voted? true
      set last-voted ticks
      let historical-energy-expenditure 0
      let historical-energy-expenditure-nof-days 0
      let buildings-found? false
      ask my-patches with [pipe-possible?] [
        let some-buildings nobody
        ifelse eligibility = "by-proximity" [
          set some-buildings buildings in-radius proximal-qualification-distance
        ]
        [
          set some-buildings buildings with [street-name = this-road-name]
        ]
        if any? some-buildings  [
          ask one-of some-buildings [
            debug (word "street-votes: street " this-road-name " has " (count some-buildings))
          ]
          set buildings-found? true
          ask some-buildings  [
            let this-building self
            ask out-resident-neighbors [
              ; Remember this might be a business
              if heating-system != "heat" and is-household? self [
                set historical-energy-expenditure-nof-days min (list 365 length history-of-units-used-for-heating)
                set nof-possible-votes nof-possible-votes + 1
                let some-institution one-of energy-providers with [member? "heat" table:values energy-type ]
                if wants-to-join? or consult-on? "install" get-state-for-install "heat" some-institution "street-voting"[
                  set votes votes + 1
                  set wants-to-join? true
                  set historical-energy-expenditure  historical-energy-expenditure + sum (sublist history-of-units-used-for-heating 0 historical-energy-expenditure-nof-days)
                ]
              ]
            ]
          ]
        ]
      ]


      debug (word "street-votes: The vote for street " self " was for: " votes " out of " nof-possible-votes)
      let won? false
      (ifelse
        not buildings-found? [
        ]
        member? "offsetting-costs" street-voting  [
          let district-heating-provider ifelse-value extent = "Timisoara" [ one-of energy-providers with [name = "Colterm"]] [ one-of energy-providers with [name = "AHP"] ]
          ask district-heating-provider [
            let new-income (
              (mean table:values retail-unit-cost) * historical-energy-expenditure -
              (mean table:values wholesale-unit-cost)  * historical-energy-expenditure -
              cost-of-road - historical-energy-expenditure-nof-days * overhead
            )
            ; So by way of example we will take last years profitability and see how much this profit grows it (if at all).
            let profit-% ifelse-value new-income > 0 [ 100 ] [ -100 ]
            if table:has-key? profits (year - 1) and table:get profits (year - 1) > 0 [
              set profit-% ( 100 *
                ((profitability + new-income) - table:get profits (year - 1)) /
                table:get profits (year - 1)
              )
            ]

            set total-profit-% lput profit-% total-profit-%
            show (word "street-votes: " this-road-name " there will be " profit-% "% based on income of " new-income)
            if profit-% >=  target-profit-for-district-heating [
              debug (word "street-votes: #### A street is joining the network!")
              set won? true
              set nof-streets-voted-to-join nof-streets-voted-to-join + 1
              ask [my-patches with [pipe-possible?]] of this-road [
                let some-buildings nobody
                ifelse eligibility = "by-proximity" [
                  set some-buildings buildings in-radius proximal-qualification-distance with [not table:get has? "heat"]
                ]
                [
                  set some-buildings buildings with [street-name = this-road-name and not table:get has? "heat"]
                ]
                set pipe-present? true
                sprout-heat-pipes 1 [
                  set color blue
                  set size 2
                  set shape "square"
                ]
                ask some-buildings [
                  connect-building-to-heat-network
                ]
              ]
            ]
          ]
        ]
        ((nof-possible-votes = votes and member? "unanimous" street-voting and nof-possible-votes > 0) or
        ( 2 * votes >= nof-possible-votes and member? "majority" street-voting and nof-possible-votes > 0) or
        (nof-possible-votes = 0 and member? "empty-streets" street-voting and count buildings with [ this-road-name = street-name ] > 0)) [
        debug (word "street-votes: #### A street is joining the network!")
        set won? true
        set nof-streets-voted-to-join nof-streets-voted-to-join + 1
        ask my-patches with [pipe-possible?] [
          let some-buildings nobody
          ifelse eligibility = "by-proximity" [
            set some-buildings buildings in-radius proximal-qualification-distance with [not table:get has? "heat"]
          ]
          [
            set some-buildings buildings with [street-name = this-road-name and not table:get has? "heat"]
          ]
          set pipe-present? true
          sprout-heat-pipes 1 [
            set color blue
            set size 2
            set shape "square"
          ]
          ask some-buildings [
            connect-building-to-heat-network
          ]

        ]
      ]
     )
      set street-vote-record lput (list nof-possible-votes votes won?) street-vote-record
    ]
  ]
  ask heat-pipes [
    if any? neighbors with [pipe-possible? and not pipe-present?] [
      ask neighbors with [pipe-possible? and not pipe-present?] [
        if my-roads != nobody [
          ask my-roads [
            set near-heat-network? true
          ]
        ]
      ]
    ]
  ]
  if length total-profit-% > 0 [
    set mean-profit-% mean total-profit-%
    set lowest-profit-% min total-profit-%
    set highest-profit-% max total-profit-%
  ]
  debug "street-votes: ...ends."
end

to-report truncated-normal [ some-mean some-min some-max ]

 ; Why doesn't NetLogo have this?

  if some-mean > some-max or some-mean < some-min or some-min > some-max [
    err (word "truncated-normal: nonsensical parameters, mean = " some-mean " min = " some-min " max = " some-max)
  ]
  let sd (some-max - some-min) / 4
  let result random-normal some-mean sd
  while [result < some-min or result > some-max ] [
    set result random-normal some-mean sd
  ]
  report result
end


to-report unnest [ xs ]
  let ys reduce sentence xs
  report ifelse-value (reduce or map is-list? ys) [ unnest ys ] [ ys ]
end

; {bank} update-a-bank-with

to update-bank-with [ data-path ]
  file-open data-path
  let header file-read-line
  while [ not file-at-end? ] [
    let data csv:from-row file-read-line
    let loan-name item 0 data
    if item 1 data != "mortgage" and
      item 1 data != "electric" and
      item 1 data != "gas" and
      item 1 data != "heat" [
      error (word "Field 2 must be one of 'mortgage', 'electric', 'gas' or "
        "'heat' for bank " name " for record " data)
    ]
    table:put purpose loan-name item 1 data
    if not is-number? item 2 data [
      error (word "Field 3, principal is not a number for bank " name
        " for record " data)
    ]
    table:put principal loan-name item 2 data
    if item 3 data != "daily" and
      item 3 data != "weekly" and
      item 3 data != "monthly" and
      item 3 data != "quarterly" and
      item 3 data != "yearly" [
      error (word "Field 4 must be one of 'daily', 'weekly', 'monthly',"
        " 'quaterly' or 'yearly' for energy provider " name
        " for record " data)
    ]
    table:put frequency loan-name item 3 data
    if not is-number? item 4 data [
      error (word "Field 5, payment is not a number for bank " name
        " for record " data)
    ]
    table:put payment loan-name item 4 data
    if not is-number? item 5 data [
      error (word "Field 6, nof-payments is not a number for bank " name
        " for record " data)
    ]
    table:put nof-payments loan-name item 5 data
  ]
  file-close
  if not member? "mortgage" table:values purpose [
    error (word "Bank " name " does not offer a mortgage facility ")
  ]
  if length table:keys payment !=
    length remove-duplicates table:keys payment [
    error (word "Duplicate loan types found for bank " name)
  ]
end


to update-energy-provider-with [ data-path ]

  file-open data-path
  let header file-read-line
  let nof-tariffs 0
  while [ not file-at-end? ] [
    set nof-tariffs nof-tariffs + 1
    let data csv:from-row file-read-line
    let some-tariff item 0 data
    if item 1 data != "electric" and
      item 1 data != "gas" and
      item 1 data != "heat" and
      item 1 data != "new-technology" [
      error (word "Field 2, energy type must be one of 'electric', 'gas'"
        " or 'heat' number for energy provider " name " for record " data)
    ]
    table:put energy-type some-tariff item 1 data
    if not is-number? item 2 data [
      error (word "Field 3, wholesale-unit-cost is not a number for energy "
        "provider " name " for record " data)
    ]
    table:put wholesale-unit-cost some-tariff item 2 data
    if item 3 data != "daily" and
      item 3 data != "weekly" and
      item 3 data != "monthly" and
      item 3 data != "quarterly" and
      item 3 data != "yearly" [
      error (word "Field 4 " item 3 data " must be one of 'daily', 'weekly', 'monthly', "
        "'quarterly' or 'yearly' for energy provider " name " for record " data)
    ]
    table:put frequency some-tariff item 3 data
    if not is-number? item 4 data [
      error (word "Field 5, retail-unit-cost is not a number for energy provider "
      name " for record " data)
    ]
    ifelse AHP-price-override? and (data-path = "AHP" or data-path = "Colterm") [
      table:put retail-unit-cost some-tariff AHP-override-retail-unit-cost
    ] [
      table:put retail-unit-cost some-tariff item 4 data
    ]
    if not is-number? item 5 data [
      error (word "Field 6, period-of-tariff is not a number for "
        "energy provider " name " for record " data)
    ]
    table:put standing-charge some-tariff item 5 data
    if not is-number? item 6 data [
      error (word "Field 7, disconnection-cost is not a number for energy "
        "provider " name " for record " data)
    ]
    table:put disconnection-cost some-tariff item 6 data
    if not is-number? item 7 data [
      error (word "Field 8, installation-cost is not a number for energy "
        "provider " name " for record " data)
    ]
    ifelse AHP-price-override? and (data-path = "AHP" or data-path = "Colterm") [
      table:put installation-cost some-tariff AHP-override-installation-cost
    ] [
      table:put installation-cost some-tariff item 7 data
    ]
    if not is-number? item 8 data [
      error (word "Field 9, yearly-maintenance is not a number for energy "
        "provider " name " for record " data)
    ]
    table:put yearly-maintenance some-tariff item 8 data
    if not is-number? item 9 data [
      error (word "Field 10, overheads is not a number for daily "
        "overhead " name " for record " data)
    ]
    set overhead item 9 data
  ]

  file-close
end


to update-rents-with [ data-pathname ]
  file-open data-pathname
  let header file-read-line
  while [ not file-at-end? ] [
    let data csv:from-row file-read-line
    let some-rent-type item 0 data
    if item 1 data != "daily" and
      item 1 data != "weekly" and
      item 1 data != "monthly" and
      item 1 data != "quaterly" and
      item 1 data != "yearly" [
      error (word "Field 2 must be one of 'daily', 'weekly', 'monthly', "
        "'quaterly' or 'yearly' for landlord " name " for record " data)
    ]
    table:put frequency some-rent-type item 1 data
    if not is-number? item 2 data [
      error (word "Field 3, rent is not a number for landlord "
        name " for record " data)
    ]
    table:put rent some-rent-type item 2 data
  ]
  file-close
  if length table:keys rent != length remove-duplicates table:keys rent [
    error (word "Duplicate rents found for landlord " name)
  ]
end

to update-grants-with [ data-pathname ]
  file-open data-pathname
  let header file-read-line
  while [ not file-at-end? ] [
    let data csv:from-row file-read-line
    let some-type item 0 data
    if not member? item 1 data ["gas" "electric" "heat" "insulation"] [
      error (word "Field 2, energy-type is invalid for " name
        " for record " data)
    ]
    table:put energy-type some-type item 1 data
    if not is-number? item 2 data [
      error (word "Field 3, amount is not a number for grant body "
        name " for record " data)
    ]
    table:put amount some-type item 2 data
    if not is-number? item 3 data [
      error (word "Field 4, eligibility-maximum is not a number for grant body "
        name " for record " data)
    ]
    table:put maximum-income some-type item 3 data
    let x-coordinate item 4 data
    if not is-number? x-coordinate and
      not (x-coordinate >= min-pxcor and x-coordinate <= max-pxcor) [
      error (word "Field 5, x-coordinate is not a valid coordinate, for "
        "grant body " name " for record " data)
    ]
    table:put x-locus some-type x-coordinate
    let y-coordinate item 5 data
    if not is-number? y-coordinate and
      not (y-coordinate >= min-pycor and y-coordinate <= max-pycor) [
      error (word "Field 6, y-coordinate is not a valid coordinate, "
        "for grant body " name " for record " data)
    ]
    table:put y-locus some-type y-coordinate
    if not is-number? item 6 data [
      error (word "Field 7, eligibility-location-radius is not a number "
        "for grant body " name " for record " data)
    ]
    table:put radius some-type item 6 data
  ]
  file-close
  if length table:keys amount != length remove-duplicates table:keys amount [
    error (word "Duplicate grants found for grant body " name)
  ]
end

to update-advice-with [ data-pathname ]
  file-open data-pathname
  let header file-read-line
  while [ not file-at-end? ] [
    let data csv:from-row file-read-line
    let title item 0 data
    table:put action title item 1 data
    table:put energy-type title item 2 data
    table:put finance title item 3 data
    let who-to-ask item 4 data
    let target one-of (turtle-set grant-bodies energy-providers
      landlords banks) with [name = who-to-ask]
    if target = nobody [
      error (word "Advisory body: " name " is advising to see "
        who-to-ask " for " title)
    ]
    table:put recommended-institution title target
    table:put x-locus title item 5 data
    table:put y-locus title item 6 data
    table:put radius title item 7 data
    if length data > 8 [
      let dates sublist data 8 (length data - 1)
      foreach dates [ day ->
        if not is-number? day and not ( day >= 0 and day <= 364) [
          error (word "Advisory body: " name " awareness dates for "
            who-to-ask " for " title ": day " day " is wrong.")
        ]
      ]
      table:put calendar title dates
    ]
  ]
  file-close
end

to update-weather [ data-pathname ]
  file-open data-pathname
  set temperature table:make
  set absolute-humidity table:make
  let header file-read-line
  foreach n-values 365 [ i -> i ] [ day ->
    if file-at-end? [
      stop
    ]
    let data csv:from-row file-read-line
    table:put temperature day item 0 data
    table:put absolute-humidity day item 1 data
  ]
  file-close
end



; {household} uninstall-heating-system

to uninstall-heating-system
  debug  (word "uninstall-heating-system: DE-installing..." heating-system)
  if not member? heating-system table:values payment-for  [
    error (word self " - incorrect not paying anybody for energy type "
      heating-system)
  ]
  set contract-expires 0
  foreach table:keys payment-for [ bill ->
    if table:get payment-for bill = heating-system [
      let this-energy-provider table:get payment-to bill
      let this-tariff table:get payment-name bill
      let this-energy-type table:get payment-for bill
      if [table:get disconnection-cost this-tariff] of this-energy-provider > balance [
        debug  (word "uninstall-heating-system: CANNOT DEINSTALL " heating-system " - too expensive.")
        stop
      ]
      if is-household? self [
        set balance balance -
          ( [table:get disconnection-cost this-tariff] of this-energy-provider)
        set last-energy-provider this-energy-provider
      ]
      if this-energy-type != "electric" [
        table:remove payment-for bill
        table:remove payment-to bill
        table:remove payment-name bill
      ]
    ]
  ]
  set heating-system ""
end


; {building} visualize-fuel-poverty

to visualize-fuel-poverty
  let connected-colour-offset 2.5
  if table:has-key? has? "heat" and table:get has? "heat" = true [
    set connected-colour-offset -1.5
  ]

  ifelse nof-households = 0 or count out-resident-neighbors = 0 [
    set color white
  ] [
    let n-cold 0
    let n-ok 0
    let n-fp 0
    let n-xfp 0
    ask out-resident-neighbors with [ not is-business? self] [
      (ifelse switched-heating-off? [
        set n-cold n-cold + 1
      ] fuel-poverty >= 0.2 [
        set n-xfp n-xfp + 1
      ] fuel-poverty >= 0.1 [
        set n-fp n-fp + 1
      ] [
        set n-ok n-ok + 1
      ])
    ]

    let modal-situation max (list n-cold n-ok n-fp n-xfp)
    set color ifelse-value (modal-situation = n-cold) [ blue + connected-colour-offset ] [
      ifelse-value (modal-situation = n-xfp) [ red + connected-colour-offset ] [
        ifelse-value (modal-situation = n-fp) [ yellow + connected-colour-offset ] [ green + connected-colour-offset ]
      ]
    ]
  ]
end


to warn [ message ]
  output-print (word date-and-time "; " timer ": WARN: " message)
end
@#$#@#$#@
GRAPHICS-WINDOW
670
10
1879
870
-1
-1
1.0
1
10
1
1
1
0
0
0
1
-600
600
-425
425
1
1
1
ticks
30.0

BUTTON
9
10
64
43
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

SLIDER
8
1020
167
1053
max-households-per-building
max-households-per-building
6
26
16.0
5
1
NIL
HORIZONTAL

SLIDER
8
1053
167
1086
nof-employers
nof-employers
100
1000
600.0
100
1
NIL
HORIZONTAL

SLIDER
8
1086
167
1119
nof-community-organizations
nof-community-organizations
1
100
22.0
1
1
NIL
HORIZONTAL

BUTTON
64
10
119
43
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
0

BUTTON
119
10
174
43
go 10y
while [ticks < 3660] [go]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

INPUTBOX
175
972
287
1032
humidity-factor
0.025
1
0
Number

INPUTBOX
175
1032
286
1092
temperature-factor
0.025
1
0
Number

SLIDER
175
906
397
939
ideal-temperature
ideal-temperature
10
50
22.0
1
1
C
HORIZONTAL

INPUTBOX
2045
1105
2137
1165
start-year
2018.0
1
0
Number

MONITOR
549
10
616
55
the year
year
0
1
11

SLIDER
8
1119
167
1152
nof-schools
nof-schools
1
100
19.0
1
1
NIL
HORIZONTAL

SLIDER
1882
715
2055
748
size-of-initial-case-base-pool
size-of-initial-case-base-pool
0
100000
8000.0
1000
1
NIL
HORIZONTAL

INPUTBOX
286
1032
397
1092
combined-factor
0.01
1
0
Number

SWITCH
2052
822
2182
855
memory?
memory?
0
1
-1000

CHOOSER
1884
417
2024
462
eligibility
eligibility
"by-proximity" "by-street"
0

INPUTBOX
687
990
858
1050
initial-case-base-file
data/cases/cases.csv
1
0
String

INPUTBOX
687
930
858
990
pipe-laying-schedule-file
NIL
1
0
String

INPUTBOX
8
939
168
999
proximal-qualification-distance
30.0
1
0
Number

INPUTBOX
175
1092
286
1152
average-repair-bill
200.0
1
0
Number

INPUTBOX
286
1092
397
1152
lifetime-of-heating-system
4562.0
1
0
Number

PLOT
10
375
658
525
Heating systems
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
"none" 1.0 0 -16777216 true "" "plot count households with [heating-system = \"\"]"
"electric" 1.0 0 -7500403 true "" "plot count households with [heating-system = \"electric\" ]"
"gas" 1.0 0 -2674135 true "" "plot count households with [heating-system = \"gas\" ]"
"heat" 1.0 0 -955883 true "" "plot count households with [heating-system = \"heat\" ]"

PLOT
10
60
658
225
Profit (Energy Providers)
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"ask energy-providers [\ncreate-temporary-plot-pen [name] of self\nset-current-plot-pen [name] of self\nset-plot-pen-color [color] of self\n]" "ask energy-providers [\nset-current-plot-pen [name] of self\nplot profitability\n]"
PENS
"axis" 1.0 0 -7500403 true "" "plot 0"

INPUTBOX
399
893
535
953
probability-of-moving-in
1.25E-4
1
0
Number

INPUTBOX
535
893
674
953
probability-of-moving-out
1.25E-4
1
0
Number

TEXTBOX
406
872
594
890
https://www.housebeautiful.com/uk/lifestyle/property/a26866167/moving-house-lifetime-homeowners/\n3.6  / 80 / 365
7
0.0
1

MONITOR
374
10
469
55
temperature
table:get temperature (ticks mod 365)
17
1
11

SWITCH
2190
720
2474
753
heat-network-mandatory-for-new-installs?
heat-network-mandatory-for-new-installs?
1
1
-1000

SWITCH
2190
852
2474
885
heat-network-mandatory-for-businesses?
heat-network-mandatory-for-businesses?
1
1
-1000

SWITCH
2190
753
2474
786
heat-network-mandatory-for-new-builds?
heat-network-mandatory-for-new-builds?
1
1
-1000

SLIDER
2190
687
2474
720
discount-on-council-tax-for-installation
discount-on-council-tax-for-installation
0
100
0.0
1
1
%
HORIZONTAL

SLIDER
2190
819
2474
852
discount-on-business-rate-for-installation
discount-on-business-rate-for-installation
0
100
0.0
1
1
%
HORIZONTAL

TEXTBOX
2248
668
2398
698
Policy decisions
12
0.0
1

SWITCH
2190
885
2474
918
heat-network-mandatory-for-landlords?
heat-network-mandatory-for-landlords?
1
1
-1000

INPUTBOX
687
870
858
930
new-builds-schedule-file
NIL
1
0
String

INPUTBOX
1546
930
1704
990
household-output
household.csv
1
0
String

INPUTBOX
1547
871
1705
931
energy-provider-output-file
profits.csv
1
0
String

INPUTBOX
1703
930
1861
990
stats-output-file
stats.csv
1
0
String

INPUTBOX
287
972
397
1032
units-of-energy-per-degree
0.3
1
0
Number

CHOOSER
1881
823
2006
868
resolution
resolution
"household" "person"
0

SWITCH
1880
981
2005
1014
patriarchal?
patriarchal?
0
1
-1000

SWITCH
1880
915
2005
948
matriarchal?
matriarchal?
0
1
-1000

CHOOSER
1649
1051
1841
1096
social-network
social-network
"Erdős and Rényi" "Watts and Strogatz" "Barabási and Albert" "Hamill and Gilbert"
3

CHOOSER
1841
1050
2033
1095
neighbourhood-network
neighbourhood-network
"Erdős and Rényi" "Watts and Strogatz" "Barabási and Albert" "Hamill and Gilbert"
3

INPUTBOX
688
1110
814
1170
neighbourhood-network-degree
1.0
1
0
Number

INPUTBOX
688
1050
814
1110
social-network-degree
1.0
1
0
Number

SLIDER
973
1055
1139
1088
school-network-probability
school-network-probability
0
1
0.0928
.0001
1
NIL
HORIZONTAL

SLIDER
1414
1088
1649
1121
neighbourhood-network-rewire-or-connection-probability
neighbourhood-network-rewire-or-connection-probability
0
1
0.031
0.001
1
NIL
HORIZONTAL

SLIDER
973
1088
1139
1121
community-organization-network-probability
community-organization-network-probability
0
1
0.256
0.001
1
NIL
HORIZONTAL

SLIDER
1817
1096
1955
1129
listens-to-msm
listens-to-msm
0
1
0.517
0.001
1
NIL
HORIZONTAL

INPUTBOX
857
870
1029
930
trust-file
data/trust/trust.csv
1
0
String

INPUTBOX
1029
930
1200
990
household-config-file
NIL
1
0
String

INPUTBOX
1029
990
1200
1050
population-config-file
NIL
1
0
String

SWITCH
1880
948
2005
981
random?
random?
0
1
-1000

SLIDER
973
1121
1139
1154
work-network-probability
work-network-probability
0
1
0.326
0.001
1
NIL
HORIZONTAL

SLIDER
1414
1055
1649
1088
social-network-rewire-or-connection-probability
social-network-rewire-or-connection-probability
0
1
0.034
.0001
1
NIL
HORIZONTAL

INPUTBOX
858
990
1029
1050
energy-ratings-file
NIL
1
0
String

INPUTBOX
857
930
1029
990
council-taxes-file
NIL
1
0
String

BUTTON
2339
480
2486
513
Advice Network Visible
show-networks
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
2339
513
2486
546
Advice Network Off
hide-networks
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
814
1110
977
1170
neighbourhood-network-reaches-spec
[50 100]
1
0
String

INPUTBOX
813
1050
977
1110
social-network-reaches-spec
[50 100]
1
0
String

SWITCH
1139
1121
1325
1154
consult-social-networks?
consult-social-networks?
0
1
-1000

INPUTBOX
1029
870
1200
930
structure-network-file
NIL
1
0
String

SWITCH
1880
882
2005
915
whole-family?
whole-family?
0
1
-1000

SWITCH
1880
1014
2005
1047
all-adults?
all-adults?
0
1
-1000

TEXTBOX
1896
867
2010
885
Family Dynamics
12
0.0
1

MONITOR
469
10
538
55
humidity
table:get absolute-humidity (ticks mod 365)
17
1
11

SWITCH
2018
963
2166
996
random-street-naming?
random-street-naming?
1
1
-1000

SLIDER
2018
996
2166
1029
random-street-length
random-street-length
0
400
20.0
1
1
NIL
HORIZONTAL

SLIDER
175
939
287
972
min-boiler-size
min-boiler-size
1
max-boiler-size
12.0
1
1
NIL
HORIZONTAL

SLIDER
286
939
397
972
max-boiler-size
max-boiler-size
min-boiler-size
50
44.0
1
1
NIL
HORIZONTAL

SWITCH
2190
918
2335
951
working-from-home?
working-from-home?
1
1
-1000

SLIDER
2335
918
2474
951
minimum-wfh
minimum-wfh
0
100
63.0
1
1
NIL
HORIZONTAL

SWITCH
2190
951
2331
984
UBI?
UBI?
1
1
-1000

INPUTBOX
2331
951
2474
1011
ubi
0.0
1
0
Number

CHOOSER
2338
402
2486
447
movie-type
movie-type
"increase-fuel-prices" "high-gas-prices" "low-gas-prices" "high-connection-costs" "low-connection-costs" "status-quo" "high-gas-prices-low-connection-cost" "low-gas-prices-high-connection-cost"
0

SWITCH
2053
854
2183
887
remember-recommendations?
remember-recommendations?
0
1
-1000

SWITCH
2024
888
2162
921
trust-feedback?
trust-feedback?
1
1
-1000

SWITCH
2191
369
2339
402
show-social-network?
show-social-network?
1
1
-1000

SWITCH
2191
402
2339
435
show-neighbour-network?
show-neighbour-network?
1
1
-1000

SWITCH
2191
434
2339
467
show-school-network?
show-school-network?
0
1
-1000

SWITCH
2191
467
2339
500
show-work-network?
show-work-network?
0
1
-1000

SWITCH
2191
500
2339
533
show-community-network?
show-community-network?
1
1
-1000

SWITCH
2191
533
2339
566
show-bank-network?
show-bank-network?
1
1
-1000

SWITCH
2191
566
2339
599
show-energy-network?
show-energy-network?
0
1
-1000

SWITCH
2191
632
2339
665
show-local-media-network?
show-local-media-network?
1
1
-1000

SWITCH
2339
591
2487
624
show-national-media-network?
show-national-media-network?
1
1
-1000

SWITCH
2339
624
2487
657
show-landlord-network?
show-landlord-network?
1
1
-1000

SWITCH
2191
599
2339
632
show-advisory-network?
show-advisory-network?
1
1
-1000

SLIDER
1882
748
2055
781
initial-cases-per-entity
initial-cases-per-entity
0
100
12.0
1
1
NIL
HORIZONTAL

BUTTON
2339
447
2486
480
Ten year demo movie
  ask patches with [pxcor >= 150 and pxcor <= 550 and pycor <= -150 and pycor >= -210] [set pcolor grey + 2]\n  ask patch 500 -170 [set plabel \"DISCLAIMER: Demonstration version only\" set plabel-color black]\n  ask patch 530 -190 [set plabel \"No data used from any person living or dead\" set plabel-color black]\n  ask turtles [if not is-building? self and not is-heat-pipe? self [set hidden? true]]\n  repeat 3650 [\n    go\n    demo-movies\n  ]\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
1704
988
1862
1048
business-output
business.csv
1
0
String

CHOOSER
1884
462
2023
507
street-voting
street-voting
"unanimous" "majority" "unanimous-and-empty-streets" "majority-and-empty-streets" "disabled" "offsetting-costs"
5

SLIDER
1138
1055
1414
1088
probability-of-joining-community-organization
probability-of-joining-community-organization
0
1.0
0.025
.001
1
NIL
HORIZONTAL

SLIDER
1138
1088
1414
1121
probability-of-leaving-community-organization
probability-of-leaving-community-organization
0
1
1.051
0.001
1
NIL
HORIZONTAL

SLIDER
399
1019
675
1052
probability-of-private-rental-vs-public
probability-of-private-rental-vs-public
0
1
0.498
0.001
1
NIL
HORIZONTAL

SLIDER
399
986
675
1019
probability-of-owning-property
probability-of-owning-property
0
1
0.618
0.001
1
NIL
HORIZONTAL

SLIDER
399
953
675
986
probability-of-owning-property-outright
probability-of-owning-property-outright
0
1
0.498
.001
1
NIL
HORIZONTAL

SLIDER
399
1085
675
1118
probability-of-rent-including-utilities
probability-of-rent-including-utilities
0
1
0.1
0.001
1
NIL
HORIZONTAL

SLIDER
399
1052
675
1085
probability-of-central-heating-installed
probability-of-central-heating-installed
0
1
0.803
0.001
1
NIL
HORIZONTAL

SLIDER
399
1118
675
1151
probability-of-repair-vs-replace
probability-of-repair-vs-replace
0
1
0.7
0.001
1
NIL
HORIZONTAL

MONITOR
2339
546
2487
591
Memory
mgr:mem-str
17
1
11

SWITCH
1820
1133
1959
1166
compress-time?
compress-time?
1
1
-1000

BUTTON
1862
1165
1931
1198
go x32
repeat 32 [\n  go\n]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SWITCH
2190
1017
2331
1050
AHP-price-override?
AHP-price-override?
1
1
-1000

SLIDER
2190
1050
2475
1083
AHP-override-retail-unit-cost
AHP-override-retail-unit-cost
0
1
0.0
0.001
1
£
HORIZONTAL

SLIDER
2331
1017
2475
1050
AHP-override-installation-cost
AHP-override-installation-cost
0
10000
0.0
10
1
£
HORIZONTAL

SWITCH
8
906
168
939
pipe-in-any-street?
pipe-in-any-street?
0
1
-1000

SWITCH
8
873
168
906
start-with-pipe-present?
start-with-pipe-present?
0
1
-1000

SWITCH
2190
984
2331
1017
no-SCARF?
no-SCARF?
1
1
-1000

SLIDER
2018
931
2156
964
b
b
1
5
1.4
0.001
1
NIL
HORIZONTAL

CHOOSER
1884
372
2024
417
extent
extent
"Torry" "Aberdeen" "Timisoara"
0

INPUTBOX
1207
870
1379
930
pipe-possible-input-output-file
data/pipe-possible.torry.dat
1
0
String

INPUTBOX
1207
930
1379
990
roads-input-output-file
data/roads.torry.dat
1
0
String

INPUTBOX
1207
990
1379
1050
buildings-input-output-file
data/buildings.torry.dat
1
0
String

OUTPUT
1884
10
2486
369
8

MONITOR
188
10
302
55
Heating Installs
count households with [heating-system = \"heat\"]
17
1
11

SLIDER
1882
616
2058
649
invalidity-scalar
invalidity-scalar
0
1
0.52
0.01
1
NIL
HORIZONTAL

INPUTBOX
1704
870
1861
930
decisions
NIL
1
0
String

SLIDER
1499
1121
1649
1154
dunbars-number
dunbars-number
1
200
150.0
1
1
NIL
HORIZONTAL

SLIDER
1324
1121
1499
1154
max-nof-consultees
max-nof-consultees
0
dunbars-number
16.0
1
1
NIL
HORIZONTAL

SLIDER
2056
644
2185
677
early-adopters
early-adopters
16
60
30.0
1
1
NIL
HORIZONTAL

SLIDER
2056
677
2185
710
majority
majority
76
100
85.0
1
1
NIL
HORIZONTAL

SWITCH
1884
582
2015
615
use-cbr?
use-cbr?
1
1
-1000

SLIDER
1882
682
2055
715
maximum-case-base-size
maximum-case-base-size
0
1000
96.0
1
1
NIL
HORIZONTAL

SWITCH
1882
781
2055
814
limit-case-base-size?
limit-case-base-size?
0
1
-1000

SWITCH
1882
649
2055
682
include-context?
include-context?
1
1
-1000

SWITCH
2338
369
2486
402
display-gis?
display-gis?
0
1
-1000

MONITOR
302
10
374
55
Buildings
count buildings
17
1
11

SLIDER
2056
611
2185
644
innovators
innovators
1
15
3.0
1
1
NIL
HORIZONTAL

SLIDER
2056
710
2185
743
min-adoption-likelihood
min-adoption-likelihood
0
max-adoption-likelihood
0.0
1
1
NIL
HORIZONTAL

SLIDER
2056
743
2185
776
max-adoption-likelihood
max-adoption-likelihood
min-adoption-likelihood
100
51.0
1
1
NIL
HORIZONTAL

SLIDER
2056
776
2185
809
mode-adoption-likelihood
mode-adoption-likelihood
min-adoption-likelihood
max-adoption-likelihood
41.0
1
1
NIL
HORIZONTAL

PLOT
10
225
658
375
Fuel Poverty
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
"Not fuel poor" 1.0 0 -10899396 true "" "plot count households with [fuel-poverty < 0.1]"
"Fuel poor" 1.0 0 -1184463 true "" "plot count households with [fuel-poverty >= 0.1 and fuel-poverty < 0.2]"
"Extreme FP" 1.0 0 -2674135 true "" "plot count households with [fuel-poverty >= 0.2]"
"Cold" 1.0 0 -13791810 true "" "plot count households with [switched-heating-off? = true]"

SWITCH
2190
786
2474
819
heat-network-mandatory-for-council-tenants?
heat-network-mandatory-for-council-tenants?
0
1
-1000

PLOT
10
524
330
674
Decisions: Total
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
"install" 1.0 0 -16777216 true "" "plot decision-total \"install\""
"abandon" 1.0 0 -2674135 true "" "plot decision-total \"abandon\""
"repair" 1.0 0 -10899396 true "" "plot decision-total \"repair\""
"get-advice" 1.0 0 -8630108 true "" "plot decision-total \"get-advice\""
"follow-advice" 1.0 0 -13791810 true "" "plot decision-total \"follow-advice\""

PLOT
330
524
658
674
Decisions: Proportions For
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"install" 1.0 0 -16777216 true "" "plot decision-p-for \"install\""
"abandon" 1.0 0 -2674135 true "" "plot decision-p-for \"abandon\""
"repair" 1.0 0 -10899396 true "" "plot decision-p-for \"repair\""
"get-advice" 1.0 0 -8630108 true "" "plot decision-p-for \"get-advice\""
"follow-advice" 1.0 0 -13791810 true "" "plot decision-p-for \"follow-advice\""

PLOT
10
674
330
824
Street Votes: Total
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"streets" 1.0 0 -16777216 true "" "plot n-street-votes"
"for" 1.0 0 -2674135 true "" "plot n-street-votes-for"

PLOT
330
674
658
824
Street Votes: Proportions For
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"mean" 1.0 0 -16777216 true "" "plot mean-street-votes-p-for"
"median" 1.0 0 -7500403 true "" "plot median-street-votes-p-for"
"min" 1.0 0 -2674135 true "" "plot min-street-votes-p-for"
"max" 1.0 0 -955883 true "" "plot max-street-votes-p-for"

SLIDER
2022
419
2183
452
voting-gap
voting-gap
1
3650
730.0
1
1
days
HORIZONTAL

MONITOR
338
825
443
870
Streets joined
nof-streets-voted-to-join
0
1
11

INPUTBOX
1546
989
1703
1049
consumption-output
NIL
1
0
String

MONITOR
10
824
158
869
Bill payment failures
nof-cannot-pay-bill
17
1
11

MONITOR
157
824
338
869
Domestic units consumed
annual-units-consumed
1
1
11

SWITCH
1648
1097
1819
1130
use-most-trusted?
use-most-trusted?
0
1
-1000

SWITCH
2188
1083
2337
1116
awareness-campaign?
awareness-campaign?
1
1
-1000

SLIDER
2187
1116
2339
1149
tick-gas-illegal
tick-gas-illegal
0
3651
3651.0
1
1
NIL
HORIZONTAL

SLIDER
2338
1115
2475
1148
ramp-up-prices-per-annum
ramp-up-prices-per-annum
0
100
16.0
1
1
NIL
HORIZONTAL

SLIDER
2336
1083
2476
1116
reduce-threshold-by
reduce-threshold-by
0
100
50.0
1
1
NIL
HORIZONTAL

MONITOR
443
825
548
870
Average Units
annual-units-consumed / (ticks + 1) / count households
1
1
11

SWITCH
1676
1160
1796
1193
limit-buildings?
limit-buildings?
1
1
-1000

SLIDER
1625
1188
1797
1221
nof-buildings
nof-buildings
100
1000
404.0
1
1
NIL
HORIZONTAL

MONITOR
548
825
636
870
Households
count households
17
1
11

TEXTBOX
12
1163
162
1181
Demographic Data
12
0.0
1

SLIDER
145
1161
409
1194
binary-gender-probability
binary-gender-probability
0
1
0.4923
0.0001
1
NIL
HORIZONTAL

TEXTBOX
419
1162
1606
1197
Aberdeen: 0.493 https://countrymeters.info/en/United_Kingdom_(UK)#:~:text=Demographics%20of%20United%20Kingdom%20(UK)%202019&text=Due%20to%20external%20migration%2C%20the,000%20females%20as%20of%202019.
12
0.0
1

SLIDER
145
1195
317
1228
max-age
max-age
50
100
81.0
1
1
years
HORIZONTAL

SLIDER
318
1195
493
1228
mean-age
mean-age
0
max-age
41.0
1
1
years
HORIZONTAL

TEXTBOX
497
1201
1277
1219
Aberdeen: 41 years old www.worldometers.info/world-population/uk-population/\n\n
12
0.0
1

SLIDER
144
1228
356
1261
age-start-school
age-start-school
0
25
4.0
1
1
years
HORIZONTAL

SLIDER
357
1229
568
1262
age-start-work
age-start-work
age-start-school + 1
max-age
18.0
1
1
years
HORIZONTAL

SLIDER
143
1263
341
1296
chances-of-working
chances-of-working
0
1
0.419
0.001
1
NIL
HORIZONTAL

TEXTBOX
345
1265
1974
1296
Aberdeen: 0.419 https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/employmentandemployeetypes/bulletins/employmentintheuk/march2019\nhttps://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates
12
0.0
1

TEXTBOX
575
1236
2047
1268
Aberdeen: 4 and 18 years https://www.gov.scot/publications/growing-up-scotland-early-experiences-primary-school/pages/4/#:~:text=Children%20born%20between%20March%20and,4.5%20and%205.5%20years%20old.
12
0.0
1

INPUTBOX
143
1301
304
1361
minimum-monthly-wage
1544.4
1
0
Number

INPUTBOX
305
1302
466
1362
mean-monthly-wage
1906.08
1
0
Number

TEXTBOX
666
1304
1616
1359
 Aberdeen:  https://sp-bpr-en-prod-cdnep.azureedge.net/published/2018/11/29/Earnings-in-Scotland--2018/SB%2018-80.pdf\nThe distribution needs to be checked here. This can give a paid income of 0 which is silly set income (random-exponential 23833) / 12\nhttps://www.gov.uk/national-minimum-wage-rates
12
0.0
1

INPUTBOX
465
1301
660
1361
maximum-monthly-wage
10000.0
1
0
Number

INPUTBOX
143
1364
304
1424
monthly-benefits
323.7
1
0
Number

TEXTBOX
311
1376
626
1408
Aberdeen: 323.7 https://www.gov.uk/jobseekers-allowance
12
0.0
1

SLIDER
178
875
397
908
ideal-absolute-humidity
ideal-absolute-humidity
1.0
12.0
6.3
0.1
1
gm^(-3)
HORIZONTAL

SLIDER
142
1426
380
1459
male-age-of-death
male-age-of-death
40
100
77.0
1
1
years
HORIZONTAL

SLIDER
386
1426
637
1459
female-age-of-death
female-age-of-death
50
100
81.0
1
1
years
HORIZONTAL

TEXTBOX
1175
1424
1940
1459
Aberdeen https://scotland.shinyapps.io/sg-equality-evidence-finder/ https://www.nrscotland.gov.uk/statistics-and-data/statistics/scotlands-facts/life-expectancy-in-scotland
12
0.0
1

SLIDER
637
1426
896
1459
male-age-of-marriage
male-age-of-marriage
16
100
34.0
1
1
years
HORIZONTAL

SLIDER
896
1425
1169
1458
female-age-of-marriage
female-age-of-marriage
16
100
32.0
1
1
years
HORIZONTAL

SLIDER
142
1462
373
1495
age-of-retirement
age-of-retirement
16
100
66.0
1
1
years
HORIZONTAL

TEXTBOX
384
1471
1711
1503
Aberdeen: 66 years https://www.ageuk.org.uk/scotland/information-advice/money-matters/benefits/#:~:text=It%20used%20to%20be%2060,visit%20the%20Scottish%20Government%20website.
12
0.0
1

SLIDER
448
1501
782
1534
age-of-menopause
age-of-menopause
16
100
51.0
1
1
years
HORIZONTAL

SLIDER
141
1501
449
1534
probability-of-giving-birth-that-day
probability-of-giving-birth-that-day
.00001
0.01
0.008785899
.00001
1
NIL
HORIZONTAL

TEXTBOX
1318
1508
1468
1526
NIL
12
0.0
1

TEXTBOX
789
1492
2320
1542
Aberdeen: https://www.scotpho.org.uk/population-dynamics/pregnancy-births-and-maternity/key-points/#:~:text=In%20Scotland%2C%20as%20in%20many,aged%2040%20years%20and%20over.\nhttps://www.nrscotland.gov.uk/statistics-and-data/statistics/scotlands-facts/population-of-scotland\nhttps://www.nhsinform.scot/illnesses-and-conditions/sexual-and-reproductive/menopause#:~:text=About%20menopause,-The%20menopause%20is&text=The%20menopause%20is%20a%20natural,before%2040%20years%20of%20age.
12
0.0
1

SLIDER
2005
1219
2038
1482
ethnicity-1
ethnicity-1
0
100 - (ethnicity-2 + ethnicity-3 + ethnicity-4 + ethnicity-5)
92.0
.1
1
%
VERTICAL

SLIDER
2078
1218
2111
1483
ethnicity-3
ethnicity-3
0
100 - (ethnicity-1 + ethnicity-2 + ethnicity-4 + ethnicity-5)
1.5
.1
1
%
VERTICAL

SLIDER
2042
1218
2075
1482
ethnicity-2
ethnicity-2
0
100 - (ethnicity-1 + ethnicity-3 + ethnicity-4 + ethnicity-5)
1.0
.1
1
%
VERTICAL

SLIDER
2114
1219
2147
1483
ethnicity-4
ethnicity-4
0
100 - (ethnicity-1 + ethnicity-2 + ethnicity-3 + ethnicity-5)
2.8
.1
1
%
VERTICAL

SLIDER
2149
1220
2182
1483
ethnicity-5
ethnicity-5
0
100 - (ethnicity-1 + ethnicity-2 + ethnicity-3 + ethnicity-4)
2.6
0.1
1
NIL
VERTICAL

TEXTBOX
2203
1396
2496
1537
Aberdeen: https://worldpopulationreview.com/world-cities/aberdeen-population\n1. white 92.0%\n2. Chinese 1.0%\n3. Indian 1.5%\n4. Asian Other 2.8%\n5. Afro-Carribean 2.6%
10
0.0
1

SWITCH
2184
1220
2393
1253
neighbour-homophily?
neighbour-homophily?
0
1
-1000

SWITCH
2183
1253
2418
1286
social-media-homophily?
social-media-homophily?
0
1
-1000

SWITCH
2184
1286
2365
1319
work-homophily?
work-homophily?
0
1
-1000

SWITCH
2183
1320
2385
1353
community-organization-homophily?
community-organization-homophily?
0
1
-1000

SWITCH
2184
1355
2376
1388
school-homophily?
school-homophily?
0
1
-1000

INPUTBOX
1379
870
1536
930
pipe-present-input-output-file
data/pipe-present.torry.dat
1
0
String

SLIDER
2021
484
2186
517
target-profit-for-district-heating
target-profit-for-district-heating
0
50
0.0
.01
1
%
HORIZONTAL

INPUTBOX
2045
1036
2175
1096
cost-per-patch-for-pipe-line
500.0
1
0
Number

PLOT
1385
933
1545
1055
Profitability per street
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"mean" 1.0 0 -16777216 true "" "plot mean-profit-%"
"max" 1.0 0 -7500403 true "" "plot highest-profit-%"
"min" 1.0 0 -2674135 true "" "plot lowest-profit-%"

SLIDER
2186
1149
2338
1182
tick-new-technology
tick-new-technology
0
5000
5000.0
1
1
NIL
HORIZONTAL

CHOOSER
1884
504
2022
549
metering
metering
"building" "individual" "group"
1

SLIDER
1884
549
2015
582
metering-group-size
metering-group-size
0
20
10.0
1
1
NIL
HORIZONTAL

SLIDER
2022
517
2190
550
min-surcharge
min-surcharge
0
100
25.0
10
1
£/€
HORIZONTAL

SLIDER
2021
549
2190
582
max-surcharge
max-surcharge
0
100
75.0
1
1
£/€
HORIZONTAL

SLIDER
2020
581
2190
614
mean-surcharge
mean-surcharge
min-surcharge
max-surcharge
50.0
1
1
£/€
HORIZONTAL

SWITCH
2022
451
2181
484
building-voting?
building-voting?
1
1
-1000

SLIDER
2339
1149
2476
1182
tick-close-associations
tick-close-associations
0
5000
5000.0
1
1
tick
HORIZONTAL

SLIDER
2187
1183
2395
1216
fixed-contract-length
fixed-contract-length
-1
3650
-1.0
1
1
NIL
HORIZONTAL

MONITOR
1966
1111
2036
1156
pipe-laid
count patches with [pipe-present?]
17
1
11

TEXTBOX
1972
1165
2122
1183
This has to be here, because it is used as a metric in the runs
6
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

### Trust

#### Background and motivation

The SMARTEES (Social innovation Modelling Approaches to Realizing Transition to Energy Efficiency and Sustainability) project is funded by Horizon 2020 to support the energy transition and influence policy design through fostering transdisciplinary robust policy development that takes the local context into account. The project features case studies in Aberdeen (Scotland) and Timişoara (Romania) that are focused on issues with fuel poverty associated with domestic heating. Specifically, both case studies are concerned with engagement in local district heat networks. In Aberdeen, the costs of proposed expansion of the heat network are being weighed against anticipated uptake of the system; in Timişoara, households are disengaging with the heat network because there are issues with how they pay for it, and the system has negative associations as a legacy of the communist era. Both case studies, to some extent or another, are functions of the trust homeowners, tenants and landlords place in the physical and institutional infrastructure associated with delivery.
This extended abstract proposes a mechanism by which trust could be represented in an agent-based simulation of each case study. There is a reasonably long history of the simulation of trust in agent-based models, particularly in the context of social dilemmas. Sutcliffe and Wang [1] have a model based on Dunbar’s [2] Social Brain Hypothesis in which the dynamics of trust are influenced by the strength of the ties in a relationship, for example, but their model is focused on networks of agents of the same kind, rather than, say, householders interacting with a business. Castelfranchi and Falcone [3] elaborate a rich fuzzy-cognitive architecture for simulating trust with a claim to generality of which Elsenbroich [4] is skeptical. The particularities of our case study, in which an agent making a decision about whether to join (or remain in) a heat network, means that a significant one-off decision is made based on that agent’s knowledge about the organizations associated with running the heat network.

#### Proposed model structure

Here, our proposed trust architecture formulates trust as the knowledge an ego has about an alter based on their own experiences of the alter in their episodic memory, and those experiences of the alter shared by others in ego’s social network. Trust is therefore dynamic insofar as ego interacts with alter and updates their episodic memory, and/or receives information about alter from others (friends, extended family, colleagues, energy advisors and the media). We draw on Aamodt and Plaza’s [5] case-based reasoning architecture for representing the episodic memory and individual experiences, with a social and temporal augmentation such that each case in the episodic memory is a data structure containing:

+ a description of a situation in which an agent made a decision;
+ the action the agent took;
+ the outcome of the action; 
+ whom the case happened to; and
+ who told the agent about the case.

The description of the situation would contain relevant information about the agent’s household and living arrangements, the action would be a company the agent did business with, and the outcome would be a list of experiences the agent had, each experience being a record of utility and a timestamp.
When making a decision about what action to take, ego will gather episodes from their social network. A matching algorithm will then select from the set of episodes gathered those cases that the agent considers relevant to their situation. We then draw on Moss’s [6, pp. 291-292] refinement of Cohen’s [7] endorsement theory to derive a score for each action occurring in any case. In this system, there are a number of qualitatively distinct classes of endorsement, ordered such that the number of endorsements needed in class n to be equivalent to a single endorsement in class n + 1 is given by b (a parameter). Here, we use trust as the basis of each endorsement class. In, we show a question in a survey of residents in Aberdeen that asked respondents to rate their trust in various sources of information from informal (e.g. neighbours, family and friends) to formal (e.g. government, independent advice agencies, and the media), using a seven-point Likert scale from 0 (no trust) to 6 (a great deal of trust). A similar question was included in a survey of residents of Timişoara. Data from these surveys can be used to determine relevant trust endorsement classes of different residents; for now, we just assume there are n such classes, which may be ordered differently by different agents, but the assigned class is determined uniquely by the alter who told ego about the case. The endorsement Ea of an action a, which appears in cases Ca, is given by:


**_E\_a_** \Sigma_{**_i_**=1 .. n} \Sigma_{_**j**_ \in _**C\_{ai}**_ \Sigma_{_**k**_ \in _**U\_j**_} \in _**u\_k**_ * **_b^{i-1}_**

![Trust Summation](doc/img/trust.png)

where _**i**_ iterates over the n classes, _**C\_ai**_ is the set of cases with action _**a**_ from class _**i**_, _**U\_j**_ is the utilities recorded in case _**j**_, and _**u_k**_ is the _**k**_ th utility in _**U\_j**_. The action with the highest endorsement is the one chosen.

**_a_** = the action to be taken
**_E\_a_** is the endorsement score (the higher the better)
**_i_** = an index of an agent in the social network.
**_j_** = index of a cases for some agent indexed by **_i_**
**_C\_{ai}_**= cases containing action a for agent index by **_i_** with action **_a_**
**_k_** = is some index of Utility values in **_U\_j_**
**_u\_k_** is a utility value in the set **_U\_j_**
**_b_** is some parameter (hah!)

So the utility values, how are these calculated? This seems to be the crux to me, and the thing I was having the difficulty with, and where I got to thinking about this. Additionally for Timișoara I need a dynamic model of trust, i.e. that trust that changes - this is really important. Initially I was thinking one utility value.

So say we make trust directional (cannot remember the reference, but I seem to remember trust is a function of both dependence and need) so if we have say agent T is the truster and t is the agent we want to trust

**_trust\_{t→T}_** is how much **_t_** trusts **_T_**, i.e. the dependence of **_T_** on **_t_**. **_trust\_{T→t}_** is how much **_T_** trusts **_t_**

_**t→t**_ is always 100%.

I envisaged the outcomes of the case bases would be true/false, which is either do it or don't do it. So no measure of utility there. What I propose is some way of measuring benefit recorded into the case bases which is not used for reasoning but is used for measurement, so a case our case base is modified to become

action, conditions, outcome (true/false), effect metric set (**_E_**),

An effect metric is how well the case is currently performing, lets call this **_e\_T_** member of **_E_**.

Where this effect set is recorded in the case base but not used to evaluate the case base.

Then the utility function becomes could be

**_u\_k_** = (**_trust\_{t→T}_** + **_trust\_{T→t})_** * **_e\_T_**

This would be a bit weird, because **_e\_T_** would have to updated for each tick.

So the set **_e\_T_** might be one of:

+ rate of increase of energy bill
+ personal contentment (we have this in the questionnaire but no model on how it changes).
+ fuel poverty index

I am sure there are others.

What I decided on in the end was this truth table:

```
do-it | were-in-fuel-poverty | now-in-fuel-poverty | recommend?
------|----------------------|---------------------|-----------
yes   | no                   | yes                 | no
yes   | yes                  | yes                 | no
yes   | no                   | no                  | yes
yes   | yes                  | no                  | yes
no    | no                   | yes                 | no
no    | yes                  | yes                 | no
no    | no                   | no                  | yes
no    | yes                  | no                  | yes
```

where set **_e\_T_** is 1 for yes and 0 for no.

Fortunately this appears to be symmetric and simplifies to:

```
now-in-fuel-poverty | recommend?
--------------------|-----------
yes                 | no
no                  | yes
```

so seemingly we don't need the history. I don't believe this.
I am leaving the history, because I can probably use it in
in the trust feedback loop (see below).

So trust dynamics? How do **_trust_{t→T}_** and **_trust_{T→t}_** change? I think we need to calculate the sum of all **e** for a specific individual, and thence **t** for all people in their social network. If it has increased over a tick, then we slightly nudge up their **_trust__**. **_trust_{T→t}_** is just the same property and calculated the same way but going in the opposite direction. Obviously this is done **T→t** as trust is a personal thing, so is done as a function of the network. So the only thing left to calculate is the "nudge". So we look at somebody's decision in the case base and measure how far away it from the correct decision. Ah I am liking this. The correct decision will be 0 or 1.  

The way I have decided to do this, is based on a history of choices. Here is
the truth table:

```
do-it | was-in-fuel-poverty | now-in-fuel-poverty | nudge?
------|---------------------|---------------------|-------
yes   | no                  | yes                 | down 
yes   | yes                 | yes                 | leave
yes   | no                  | no                  | leave
yes   | yes                 | no                  | up
no    | no                  | yes                 | down
no    | yes                 | yes                 | leave
no    | no                  | no                  | leave
no    | yes                 | no                  | up
```

Symmetric: so we don't really care about whether the advice was for or against, so simplies to:

```
was-in-fuel-poverty | now-in-fuel-poverty | nudge?
--------------------|---------------------|-------
no                  | yes                 | down 
yes                 | yes                 | leave
no                  | no                  | leave
yes                 | no                  | up
```

The nudge should be asymptotic at 0 and 1, so we don't actually reach the edges of the closure.

Thus for any potential decision we have two decision, yay or nay basically. So whichever gets the highest endorsement from the social network that is the one we take. So, for each member of the social network.

1. cbr:match for true or false on a particular decision.
2. calculate the endorsement as per the formula above on each true of false decision.
3. select the the one with the highest endorsement
4. if memory is operating then record this decision in the case base
5. action the decision.

So we need a means of querying the decision on the social network. This is easy enough

There are three contexts in which the case base was orignally consulted:

1. The general case, i.e. during the normal cycle of events.
2. Street voting (this is fine)
3. Following advice from the general case in 1. This is the more complex case. 

### Networks 

We have 4 kinds of networks:

+ Erdős and Rényi (ER - random network)
+ Watts and Strogatz (WS - small world network)
+ Barabási and Albert (BA - organically grown network)
+ Hamill and Gilbert (HG - local network)

The argument is this. In setup I will establish the networks themselves.

+ Schools will be ER networks
+ Workplaces will be ER networks
+ Neighbours will be one of ER,BS, WA or HG
+ Community organizations will be ER networks
+ Social media will be one of ER, BS, WA or HG
+ Broadcast media will be an ER

So the probability measures set the connectivity of the networks.
Tony wants to place these at some point, so I need to think about this.
Tony also wants to use a vector to describe peoples attitudes as well, so bear this in mind.
So if we set up these networks at intialisation, this is easy but do they change over time? If they do, I will need the following primitives:

+ delete-from-network
+ add-to-network

This is for leaving and joining, but what about initialisation, can I use them? No I can't for a small world network, because this has a fixed degree. It will work for a WA
So this means you need to treat MSM as an agent. This is fine. (the routines are in place for this) So once I have my network, then we can ask for a judgement over that network.
You need to write this up as you are coding this. I am getting quite excited by this.
Also because of the way you have set the code up,you can ask for single cases over this network and do the necessary calculus. This is quite a sophisticated approach.

My only problem with this is how do I place people in the network. I could do this with degree, but this requires building the networks before populating them, which is not the case at the moment.

### Physical equivalent temperature (PET)

(see "Hoppe - 1999 - The physiological equivalent temperature--a universal index for the biometeorological assessment of the thermal environment"

  This is the balance equation for the human body ("Buttner - 1938 - Physikalische Bioklimatologie" - in German so I cannot read it), and the MEMI model (Gagge et al - 1971 - An effective temperature scale based on a simple model of human regularatory response")

  $M + W + R + C + E_D + E_{Re} + E_{Ws} + S = 0$ (1)

where  

+  $M$ is the metabolic rate
+  $W$ is the physical work output
+  $R$ is the net radiation of the body
+  $C$ is the convective heat flow
+  $E_D$ the latent heat flow to evaporate water
+  $E_{Re}$ the sum of heat flows for heating and humidifying the inspired air (opposite of expire in this case)
+  $E_{Ws}$ = heat-flow due to the evaporation of sweat, and
+  $S$ is the storage heat flow for heating or cooling the body mass

Given:

+ $T_{mrt}$ is the mean radiant temperature;
+ $T_a$ is the air temperature;
+ $V_a$ is the air velocity, and
+ $H_a$ is the air humidity, then:

then:

$C \propto T_a$ and $C \propto V_a$

$E_{Re}\propto H_a$, and $E_{Re} \propto T_a$ 

$E_D \propto H_a$, and

$E_{sw} \propto V_a$

$R \propto T_{mrt}$

So:

$C = k_1 T_a V_a$

$E_{Re} = k_2 T_a H_a$

$E_D = k_3 H_a$

$E_{sw} = k_4 V_a$

$R = k_5  T_{mrt}$

for constants $k_1, k_2, k_3, k_4$ and $k_5$.

We are considering a standard individual so we can assume $M$ is fixed and positive, and we assume they are doing no work, so:

$k_6 = M + W$

where, again $k_6$ is some constant.

So (1) becomes:

$k_6 + k_5 T_{mrt} + k_1  T_a  V_a + k_3  H_a + k_4 V_a + S = 0$ (2)

From The MEMI model, we obtain the following equation:

$F_{SC} = \frac{(T_c - T_{sk})}{I_{cl}}$ (3)

where

+ $F_{SC}$ is the heat flow from body core to surface
+ $I_{cl}$ is the heat resistance of the clothing.
+ $T_c$ is the mean surface temperature of the clothing
+ $T_{sk}$ is the mean skin temperature

So from (3), for a standard individual again, we can assume that 

$k_7 = S \approx F_{SC}$

So the basis of the calculation is an assumption of human comfort, and the above system of equations is solved for these values. 

+ Mean radiant temperature equals air temperature ($T_{mrt} = T_a$)
+ Air velocity is set 0.1 m/s
+ Water vapor presssure 12hPa (or 50% relative humidity)

Meaning that 

$k_6 + k_5 T_a + k_1 T_a V_a + k_3 H_a + k_4  V_a + k_7 = 0, k_8 = k_7 + k_6$

or

$k_8 + T_a (k_5 + k_1 V_a) + k_3 H_a + k_4 V_a = 0$ (4)

From the standard conditions, in (4) we have:

$k_8 + T_{PET} (k_5 + 0.1 k_1) + 12 k_3 + 0.1 k_4 = 0$

or $T_{PET} = \frac {- k_8 - 12 k_3 - 0.1 k_4}{ k_5 + 0.1 k_1}$ (5)

From (4) we have:

$k_8 = - T_a (k_5 + k_1 V_a) - k_3 H_a - k_4 V_a$

Using this in (5) gives:

$T_{PET} = \frac {T_a (k_5 + k_1 V_a) + k_3 H_a + k_4 V_a - 12 k_3 - 0.1 k_4}{ k_5 + 0.1 k_1}$

The denominator is constant, so $T_{PET} \approx  c_4 T_a V_a + c_1 T_a + c_2 H_a + c_3 V_a$ for some constants $c_1 , c_2 , c_3$ and $c_4$.

So we need daily mean temperatures, wind velocities and humidity. Now wind velocities are zero indoors, so it looks like thermal comfort in this model:

$T_{PET} \approx c_1 T_a + c_2 H_a$

`$INSERT_DIETY`, all that for that result.

This means we need data for temperature and humidity and we need to set a
standard temperature and humidity and this will determine how much energy is
required to get to this optimal temperature. So, given:

+ $t_o$ is our optimal temperature;
+ $h_o$ is out optimal humidity;
+ $e$ is the energy rating of the building;
+ $E$ is the energy efficiency function, e.g.  $E: [A,B,C,D,E,F,G] \rightarrow \left[ \frac{7}{9}, \frac{6}{9}, \frac{5}{9}, \frac{4}{9}, \frac{3}{9}, \frac{2}{9}, \frac{1}{9} \right]$
+ $t$ is the reported temperature;
+ $h$ is the reported humidity;
+ $u$ is the units of energy required to reach ideal temperature, and constants as above then:

$u = E(e) \vert (c_1 h_o + c_2 t_o) - (c_1 h + c_2 t) \vert$ 

Note the energy expenditure will only take place up to the maxium defined for that household.

This is a generalised approach that will work for too much heat as well, say for summer in Timoşoara.

### Attitudes.

Attitudes are divided into the following.

+ Q7. Level of education
+ Q15. In your daily life- how often do you do the following things? [i. Travel by bus]
+ Q15. In your daily life- how often do you do the following things? [ii. Travel by bike]
+ Q15. In your daily life- how often do you do the following things? [iii. Travel by car]
+ Q15. In your daily life- how often do you do the following things? [iv. Travel by train]
+ Q15. In your daily life- how often do you do the following things? [v. Travel on foot]
+ Q16. In your daily life- how often do you do the following things? [i. Participate in community meetings or events]
+ Q16. In your daily life- how often do you do the following things? [ii. Switch off heating unless i really need it ]
+ Q16. In your daily life- how often do you do the following things? [iii. Switch off electrical appliances that are not being used]
+ Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [i. My heating bills have increased]
+ Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [ii. could afford to keep my home warm]
+ Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [iii. I have had to choose between keeping my home warm and buying food or essentials for myself or my family]
+ Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [iv. My heating system was able to keep my home warm]
+ Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [v. My house sometimes felt uncomfortably cold in the winter]
+ Q19. Please indicate your level of agreement or disagreement with the following statements. In the past year... [vi. Insulation was installed in my home]
+ Q20. How likely are you to join the district heating scheme- if it becomes available in your area?
+ Q23. How important are the following factors to you? [i. My health]
+ Q23. How important are the following factors to you? [ii. My quality of life]
+ Q23. How important are the following factors to you? [iii. The warmth of my home]
+ Q23. How important are the following factors to you? [iv. Reliability of my household’s energy supply]
+ Q23. How important are the following factors to you? [v. The quality of my accommodation]
+ Q23. How important are the following factors to you? [vi. My financial security]
+ Q24. How concerned are you about the following? [i. Energy being too expensive for many people in Aberdeen]
+ Q24. How concerned are you about the following? [ii. Aberdeen being too dependent on fossil fuels such as oil and gas. ]
+ Q24. How concerned are you about the following? [iii. Climate change]
+ Q24. How concerned are you about the following? [iv. Power cuts in Aberdeen]
+ Q25. How important are the following factors to you? [i. Living in a society where everyone has the same opportunities to use energy for their needs.]
+ Q25. How important are the following factors to you? [ii. Being part of a community that is working together]
+ Q25. How important are the following factors to you? [iii. Being involved in decisions that affect my local area]
+ Q25. How important are the following factors to you? [iv. Availability of transparent information from Aberdeen City Council]
+ Q25. How important are the following factors to you? [v. Having opportunities to communicate with Aberdeen City Council]
+ Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [i. Protecting society’s weak and vulnerable members is important to him/her]
+ Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [ii. Tradition is important to her/him. she/he triesto follow the customs handed down by family or religion]
+ Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [iii. He/she thinks it is important to do lots of different things in life- and is always looking for new things to do]
+ Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [iv. Being very successful is important to her/him. She/he hopes that their achievements are recognised by people]
+ Q26. Here we briefly describe some people. Please read each description and think about how much each person is or is not like you. Please indicate how much the person described is like you: [v. He/she seeks every chance to have fun. Having a good time is important to him/her]

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

### (button) setup

### (button) step

### (button) go

### (input) start-year

### (output) the year

### (output) the year

### (output) temperature

### (output) humidity

### (switch) memory?

### (switch) remember-recommendations?

### (switch) street-voting?

### (switch) decision-bias?

### (drop-down) resolution

### (switch) building-voting?

### trust-feedback?


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

[1]	Sutcliffe, A. and Wang, D. (2012) Computational modelling of trust and social relationships. Journal of Artificial Societies and Social Simulation 15 (1), 3. http://jasss.soc.surrey.ac.uk/15/1/3.html
[2]	Dunbar, R. I. M. (1998) The social brain hypothesis. Evolutionary Anthropology 6, 178-190
[3]	Castelfranchi, C. and Falcone, R. (2010) Trust Theory: A Socio-Cognitive and Computational Model. Chichester, UK: John Wiley & Sons Ltd.
[4]	Elsenbroich, C. (2011) Trust Theory: A Socio-Cognitive and Computational Model (Wiley Series in Agent Technology). Journal of Artificial Societies and Social Simulation 14 (2). http://jasss.soc.surrey.ac.uk/14/2/reviews/2.html
[5]	Aamodt, A. & Plaza,E. 1994. Case-based reasoning: foundational issues, methodological variations, and system approaches. AI Communications, 7(1), 39–59
[6]	Moss, S. (1995) Control metaphors in the modelling of economic learning and decision-making behaviour. Computational Economics 8, 283-301. doi:10.1007/BF01299735
[7]	Cohen, P. R. (1985) Heuristic Reasoning About Uncertainty: An Artificial Intelligence Approach Ph. D. Thesis, Stanford University



## LICENSE

<one line to give the program's name and a brief idea of what it does.>
Copyright (C) 2019-2025, The James Hutton Institute

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
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

pipe-horizontal
true
0
Line -2674135 false 0 135 300 135
Line -2674135 false 0 165 315 165

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
  <experiment name="aberdeen-produce-buildings" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>output-buildings</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.491"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;person&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/data/pipe-possible.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="7.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="42"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0926"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Aberdeen&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="149"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;this_runs_output.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;decisions.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;majority&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;roads.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="torry-new-technology" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="0.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-death">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbour-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-5">
      <value value="2.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-benefits">
      <value value="323.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-retirement">
      <value value="66"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-1">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/pipe-present.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-profit-for-district-heating">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-work">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="365"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-buildings">
      <value value="404"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="6.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-4">
      <value value="2.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-giving-birth-that-day">
      <value value="0.008785899"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-menopause">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Torry&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-marriage">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-3">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.618"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-per-patch-for-pipe-line">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-school">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="binary-gender-probability">
      <value value="0.4923"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chances-of-working">
      <value value="0.419"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.803"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="3651"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-monthly-wage">
      <value value="1544.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-monthly-wage">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-age">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-new-technology">
      <value value="720"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-marriage">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;majority&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-media-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-death">
      <value value="77"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-monthly-wage">
      <value value="1906.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="torry-ban-gas" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="0.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="7.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.09"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Torry&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.617"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="1095"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;majority&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.506"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.0063"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/piper.present.torry.dat&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="torry-awareness" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="0.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="7.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.09"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Torry&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.617"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="3651"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;majority&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.506"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.0063"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="video-of-torry-new-technology" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go
export-interface (word "movies/achsium-new-technology-" (leading-zeroes ticks 4) ".png")</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="0.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="7.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.09"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Torry&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.617"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="3651"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;majority&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.506"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.0063"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="vidoe-of-torry-awareness" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go
export-interface (word "movies/achsium-awarenessnew-" (leading-zeroes ticks 4) ".png")</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="0.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="7.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.09"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Torry&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.617"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="3651"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;majority&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.506"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.0063"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="video-of-torry-ban-gas" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go
export-interface (word "movies/achsium-ban-gas-" (leading-zeroes ticks 4) ".png")</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="0.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="7.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.09"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Torry&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.617"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="1095"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;majority&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.506"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.0063"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="video-of-torry-ban-gas-timisoara" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go
export-interface (word "movies/timisoara-achsium-ban-gas-" (leading-zeroes ticks 4) ".png")</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="0.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/pipe-present.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="7.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.09"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Timisoara&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.617"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="1095"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;disabled&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.506"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.0063"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="video-of-timisoara-ban-gas" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go
export-interface (word "movies/timisoara-achsium-ban-gas-" (leading-zeroes ticks 4) ".png")</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="display-gis?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="0.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/pipe-present.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="7.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.09"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Timisoara&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.617"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;disabled&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.506"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.0063"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="aberdeen-ban-gas" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="0.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-death">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbour-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-5">
      <value value="2.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-benefits">
      <value value="323.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-retirement">
      <value value="66"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-1">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/pipe-present.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-profit-for-district-heating">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-work">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="365"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-buildings">
      <value value="404"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="6.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-4">
      <value value="2.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-giving-birth-that-day">
      <value value="0.008785899"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-menopause">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Aberdeen&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-marriage">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-3">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.618"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-per-patch-for-pipe-line">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-school">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="binary-gender-probability">
      <value value="0.4923"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chances-of-working">
      <value value="0.419"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.803"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="730"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-monthly-wage">
      <value value="1544.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-monthly-wage">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-age">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-new-technology">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-marriage">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;majority&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-media-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-death">
      <value value="77"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-monthly-wage">
      <value value="1906.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="aberdeen-new-technology" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="0.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-death">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbour-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-5">
      <value value="2.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-benefits">
      <value value="323.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-retirement">
      <value value="66"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-1">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/pipe-present.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-profit-for-district-heating">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-work">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="365"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-buildings">
      <value value="404"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="6.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-4">
      <value value="2.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-giving-birth-that-day">
      <value value="0.008785899"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-menopause">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Aberdeen&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-marriage">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-3">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.618"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-per-patch-for-pipe-line">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-school">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="binary-gender-probability">
      <value value="0.4923"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chances-of-working">
      <value value="0.419"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.803"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="3651"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-monthly-wage">
      <value value="1544.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-monthly-wage">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-age">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-new-technology">
      <value value="720"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-marriage">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;majority&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-media-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-death">
      <value value="77"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-monthly-wage">
      <value value="1906.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="aberdeen-awareness" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="0.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-death">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbour-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-5">
      <value value="2.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-benefits">
      <value value="323.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-retirement">
      <value value="66"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-1">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/pipe-present.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-profit-for-district-heating">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-work">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="365"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-buildings">
      <value value="404"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="6.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-4">
      <value value="2.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-giving-birth-that-day">
      <value value="0.008785899"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-menopause">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Aberdeen&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-marriage">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-3">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.618"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-per-patch-for-pipe-line">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-school">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="binary-gender-probability">
      <value value="0.4923"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chances-of-working">
      <value value="0.419"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.803"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="3651"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-monthly-wage">
      <value value="1544.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-monthly-wage">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-age">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-new-technology">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-marriage">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;majority&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-media-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-death">
      <value value="77"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-monthly-wage">
      <value value="1906.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="timisoara-ban-gas" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="0.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-death">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbour-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-5">
      <value value="2.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-benefits">
      <value value="323.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-retirement">
      <value value="66"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-1">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/pipe-present.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-profit-for-district-heating">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-work">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="365"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-buildings">
      <value value="404"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="6.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-4">
      <value value="2.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-giving-birth-that-day">
      <value value="0.008785899"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-menopause">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Timisoara&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-marriage">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-3">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.618"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-per-patch-for-pipe-line">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-school">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="binary-gender-probability">
      <value value="0.4923"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chances-of-working">
      <value value="0.419"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.803"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="730"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-monthly-wage">
      <value value="1544.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-monthly-wage">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-age">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-new-technology">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-marriage">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;disabled&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-media-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-death">
      <value value="77"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-monthly-wage">
      <value value="1906.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="timisoara-new-technology" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="0.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-death">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbour-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-5">
      <value value="2.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-benefits">
      <value value="323.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-retirement">
      <value value="66"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-1">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/pipe-present.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-profit-for-district-heating">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-work">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="365"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-buildings">
      <value value="404"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="6.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-4">
      <value value="2.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-giving-birth-that-day">
      <value value="0.008785899"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-menopause">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Timisoara&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-marriage">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-3">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.618"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-per-patch-for-pipe-line">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-school">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="binary-gender-probability">
      <value value="0.4923"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chances-of-working">
      <value value="0.419"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.803"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="3651"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-monthly-wage">
      <value value="1544.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-monthly-wage">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-age">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-new-technology">
      <value value="720"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-marriage">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;disabled&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-media-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-death">
      <value value="77"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-monthly-wage">
      <value value="1906.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="timisoara-awareness" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="0.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-death">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbour-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-5">
      <value value="2.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-benefits">
      <value value="323.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-retirement">
      <value value="66"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-1">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/pipe-present.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-profit-for-district-heating">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-work">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="365"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-buildings">
      <value value="404"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="6.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-4">
      <value value="2.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-giving-birth-that-day">
      <value value="0.008785899"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-menopause">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Timisoara&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-marriage">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-3">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.618"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-per-patch-for-pipe-line">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-school">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="binary-gender-probability">
      <value value="0.4923"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chances-of-working">
      <value value="0.419"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.803"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="3651"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-monthly-wage">
      <value value="1544.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-monthly-wage">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-age">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-new-technology">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-marriage">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;disabled&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-media-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-death">
      <value value="77"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-monthly-wage">
      <value value="1906.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="aberdeen-awareness-and-ban-gas" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="1.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-death">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbour-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-5">
      <value value="2.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-benefits">
      <value value="323.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-retirement">
      <value value="66"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-1">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/pipe-present.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-profit-for-district-heating">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-work">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="365"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-buildings">
      <value value="404"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="6.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-4">
      <value value="2.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-giving-birth-that-day">
      <value value="0.008785899"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-menopause">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Aberdeen&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-marriage">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-3">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.618"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-per-patch-for-pipe-line">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-school">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="binary-gender-probability">
      <value value="0.4923"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chances-of-working">
      <value value="0.419"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.803"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="730"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-monthly-wage">
      <value value="1544.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-monthly-wage">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-age">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-new-technology">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-marriage">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;majority&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-media-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-death">
      <value value="77"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-monthly-wage">
      <value value="1906.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="timisoara-awareness-and-ban-gas" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="0.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-death">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbour-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-5">
      <value value="2.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-benefits">
      <value value="323.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-retirement">
      <value value="66"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-1">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/pipe-present.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-profit-for-district-heating">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-work">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="365"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-buildings">
      <value value="404"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="6.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-4">
      <value value="2.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-giving-birth-that-day">
      <value value="0.008785899"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-menopause">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Timisoara&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-marriage">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-3">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.618"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-per-patch-for-pipe-line">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-school">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="binary-gender-probability">
      <value value="0.4923"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chances-of-working">
      <value value="0.419"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.803"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="730"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-monthly-wage">
      <value value="1544.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-monthly-wage">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-age">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-new-technology">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-marriage">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;disabled&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-media-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-death">
      <value value="77"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-monthly-wage">
      <value value="1906.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="aberdeen-no-scarf" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="1.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-death">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbour-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-5">
      <value value="2.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-benefits">
      <value value="323.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-retirement">
      <value value="66"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-1">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/pipe-present.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-profit-for-district-heating">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-work">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="365"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-buildings">
      <value value="404"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="6.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-4">
      <value value="2.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-giving-birth-that-day">
      <value value="0.008785899"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-menopause">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Aberdeen&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-marriage">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-3">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.618"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-per-patch-for-pipe-line">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-school">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="binary-gender-probability">
      <value value="0.4923"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chances-of-working">
      <value value="0.419"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.803"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="3651"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-monthly-wage">
      <value value="1544.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-monthly-wage">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-age">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-new-technology">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-marriage">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;majority&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-media-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-death">
      <value value="77"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-monthly-wage">
      <value value="1906.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="aberdeen-limit-profit" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="1.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-death">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbour-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-5">
      <value value="2.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-benefits">
      <value value="323.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-retirement">
      <value value="66"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-1">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/pipe-present.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-profit-for-district-heating">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-work">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="365"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-buildings">
      <value value="404"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="6.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-4">
      <value value="2.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-giving-birth-that-day">
      <value value="0.008785899"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-menopause">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Aberdeen&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-marriage">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-3">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.618"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-per-patch-for-pipe-line">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-school">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="binary-gender-probability">
      <value value="0.4923"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chances-of-working">
      <value value="0.419"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.803"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="3651"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-monthly-wage">
      <value value="1544.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-monthly-wage">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-age">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-new-technology">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-marriage">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;offsetting-costs&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-media-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-death">
      <value value="77"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.aberdeen.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-monthly-wage">
      <value value="1906.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-profit-for-district-heating">
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="timisoara-single-metering" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="0.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-death">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-close-associations">
      <value value="730"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbour-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-5">
      <value value="2.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-benefits">
      <value value="323.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-retirement">
      <value value="66"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-1">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/pipe-present.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-profit-for-district-heating">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-work">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="365"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-buildings">
      <value value="404"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="6.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-4">
      <value value="2.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-giving-birth-that-day">
      <value value="0.008785899"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-menopause">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Timisoara&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-marriage">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-3">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.618"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-per-patch-for-pipe-line">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-school">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="binary-gender-probability">
      <value value="0.4923"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chances-of-working">
      <value value="0.419"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.803"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="3651"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-monthly-wage">
      <value value="1544.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-monthly-wage">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-age">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-new-technology">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-marriage">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;disabled&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-media-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-death">
      <value value="77"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-monthly-wage">
      <value value="1906.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;building&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-close-associations">
      <value value="730"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="timisoara-fixed-contract" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="0.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-death">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-close-associations">
      <value value="730"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbour-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-5">
      <value value="2.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-benefits">
      <value value="323.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-retirement">
      <value value="66"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-1">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/pipe-present.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-profit-for-district-heating">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-work">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="365"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-buildings">
      <value value="404"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="6.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-4">
      <value value="2.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-giving-birth-that-day">
      <value value="0.008785899"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-menopause">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Timisoara&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-marriage">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-3">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.618"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-per-patch-for-pipe-line">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-school">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="binary-gender-probability">
      <value value="0.4923"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chances-of-working">
      <value value="0.419"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.803"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="3651"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-monthly-wage">
      <value value="1544.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-monthly-wage">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-age">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-new-technology">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-marriage">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;disabled&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-media-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-death">
      <value value="77"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-monthly-wage">
      <value value="1906.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;building&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-close-associations">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fixed-contract-length">
      <value value="730"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="timisoara-service-quality" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="1.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-death">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbour-homophily?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-5">
      <value value="2.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-benefits">
      <value value="323.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-retirement">
      <value value="66"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-1">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/pipe-present.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-profit-for-district-heating">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-work">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-buildings">
      <value value="404"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="6.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fixed-contract-length">
      <value value="-1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-4">
      <value value="2.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-giving-birth-that-day">
      <value value="0.008785899"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-close-associations">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-homophily?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-menopause">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Timisoara&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-homophily?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-marriage">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.618"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-3">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;building&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-per-patch-for-pipe-line">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-school">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="binary-gender-probability">
      <value value="0.4923"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chances-of-working">
      <value value="0.419"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.803"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="3651"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-monthly-wage">
      <value value="1544.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-monthly-wage">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-age">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-new-technology">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering-group-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-marriage">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;disabled&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-media-homophily?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-homophily?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-death">
      <value value="77"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.timisoara.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-monthly-wage">
      <value value="1906.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="torry-ahp-pricing" repetitions="1" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="1.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-death">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbour-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-5">
      <value value="2.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-benefits">
      <value value="323.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-retirement">
      <value value="66"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="0"/>
      <value value="1500"/>
      <value value="3000"/>
      <value value="4500"/>
      <value value="6000"/>
      <value value="7500"/>
      <value value="9000"/>
      <value value="10500"/>
      <value value="12000"/>
      <value value="13500"/>
      <value value="15000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-1">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/pipe-present.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-work">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-profit-for-district-heating">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-buildings">
      <value value="404"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="6.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fixed-contract-length">
      <value value="-1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-4">
      <value value="2.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-giving-birth-that-day">
      <value value="0.008785899"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-close-associations">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-menopause">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Torry&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.618"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-3">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-marriage">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-per-patch-for-pipe-line">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-school">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="binary-gender-probability">
      <value value="0.4923"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chances-of-working">
      <value value="0.419"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.803"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="3651"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-monthly-wage">
      <value value="1544.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-monthly-wage">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-age">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-new-technology">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering-group-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-marriage">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;majority&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-media-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0"/>
      <value value="0.05"/>
      <value value="0.1"/>
      <value value="0.15"/>
      <value value="0.2"/>
      <value value="0.25"/>
      <value value="0.3"/>
      <value value="0.35"/>
      <value value="0.4"/>
      <value value="0.45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-death">
      <value value="77"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-monthly-wage">
      <value value="1906.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="torry-limit-profit" repetitions="1" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>count patches with [pipe-present?]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [fuel-poverty &gt;= 0.2]</metric>
    <metric>count households with [heating-system = "heat"]</metric>
    <metric>count households with [heating-system = "gas" or heating-system = "electric"]</metric>
    <metric>count households with [heating-system = "heat" and fuel-poverty &gt;= 0.1]</metric>
    <metric>count households with [(heating-system = "gas" or heating-system = "electric") and fuel-poverty &gt;= 0.1]</metric>
    <metric>[profitability] of energy-providers with [name = "AHP"]</metric>
    <metric>[profitability] of energy-providers with [name = "DEAL"]</metric>
    <enumeratedValueSet variable="listens-to-msm">
      <value value="0.517"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-buildings?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-leaving-community-organization">
      <value value="1.051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-rewire-or-connection-probability">
      <value value="0.031"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-death">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-out">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbour-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ramp-up-prices-per-annum">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resolution">
      <value value="&quot;household&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-provider-output-file">
      <value value="&quot;profits.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="1.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-5">
      <value value="2.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-surcharge">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-repair-vs-replace">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="monthly-benefits">
      <value value="323.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-laying-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-retirement">
      <value value="66"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-council-tax-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-boiler-size">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-case-base-file">
      <value value="&quot;data/cases/cases.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-installation-cost">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-council-tenants?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="matriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-feedback?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-1">
      <value value="92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trust-file">
      <value value="&quot;data/trust/trust.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-present-input-output-file">
      <value value="&quot;data/pipe-present.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-local-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="combined-factor">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-most-trusted?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit-case-base-size?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-landlord-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-nof-consultees">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-work">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-profit-for-district-heating">
      <value value="0"/>
      <value value="0.15"/>
      <value value="0.3"/>
      <value value="0.45"/>
      <value value="0.6"/>
      <value value="0.75"/>
      <value value="0.9"/>
      <value value="1.05"/>
      <value value="1.2"/>
      <value value="1.35"/>
      <value value="1.5"/>
      <value value="1.65"/>
      <value value="1.8"/>
      <value value="1.95"/>
      <value value="2.1"/>
      <value value="2.25"/>
      <value value="2.4"/>
      <value value="2.55"/>
      <value value="2.7"/>
      <value value="2.85"/>
      <value value="3"/>
      <value value="3.15"/>
      <value value="3.3"/>
      <value value="3.45"/>
      <value value="3.6"/>
      <value value="3.75"/>
      <value value="3.9"/>
      <value value="4.05"/>
      <value value="4.2"/>
      <value value="4.35"/>
      <value value="4.5"/>
      <value value="4.65"/>
      <value value="4.8"/>
      <value value="4.95"/>
      <value value="5.1"/>
      <value value="5.25"/>
      <value value="5.4"/>
      <value value="5.55"/>
      <value value="5.7"/>
      <value value="5.85"/>
      <value value="6"/>
      <value value="6.15"/>
      <value value="6.3"/>
      <value value="6.45"/>
      <value value="6.6"/>
      <value value="6.75"/>
      <value value="6.9"/>
      <value value="7.05"/>
      <value value="7.2"/>
      <value value="7.35"/>
      <value value="7.5"/>
      <value value="7.65"/>
      <value value="7.8"/>
      <value value="7.95"/>
      <value value="8.1"/>
      <value value="8.25"/>
      <value value="8.4"/>
      <value value="8.55"/>
      <value value="8.7"/>
      <value value="8.85"/>
      <value value="9"/>
      <value value="9.15"/>
      <value value="9.3"/>
      <value value="9.45"/>
      <value value="9.6"/>
      <value value="9.75"/>
      <value value="9.9"/>
      <value value="10.05"/>
      <value value="10.2"/>
      <value value="10.35"/>
      <value value="10.5"/>
      <value value="10.65"/>
      <value value="10.8"/>
      <value value="10.95"/>
      <value value="11.1"/>
      <value value="11.25"/>
      <value value="11.4"/>
      <value value="11.55"/>
      <value value="11.7"/>
      <value value="11.85"/>
      <value value="12"/>
      <value value="12.15"/>
      <value value="12.3"/>
      <value value="12.45"/>
      <value value="12.6"/>
      <value value="12.75"/>
      <value value="12.9"/>
      <value value="13.05"/>
      <value value="13.2"/>
      <value value="13.35"/>
      <value value="13.5"/>
      <value value="13.65"/>
      <value value="13.8"/>
      <value value="13.95"/>
      <value value="14.1"/>
      <value value="14.25"/>
      <value value="14.4"/>
      <value value="14.55"/>
      <value value="14.7"/>
      <value value="14.85"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-network-probability">
      <value value="0.256"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UBI?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-in-any-street?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voting-gap">
      <value value="730"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-school-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="size-of-initial-case-base-pool">
      <value value="8000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-buildings">
      <value value="404"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-builds?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-repair-bill">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-output">
      <value value="&quot;household.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stats-output-file">
      <value value="&quot;stats.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pipe-possible-input-output-file">
      <value value="&quot;data/pipe-possible.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-absolute-humidity">
      <value value="6.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-output">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="compress-time?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discount-on-business-rate-for-installation">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="invalidity-scalar">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-bank-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fixed-contract-length">
      <value value="-1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-4">
      <value value="2.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-network-probability">
      <value value="0.326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode-adoption-likelihood">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-SCARF?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="building-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-boiler-size">
      <value value="44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-ratings-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-giving-birth-that-day">
      <value value="0.008785899"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-close-associations">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-community-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-landlords?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="temperature-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-of-menopause">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-households-per-building">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-builds-schedule-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="awareness-campaign?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-adults?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-community-organizations">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patriarchal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="include-context?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-new-installs?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="school-network-probability">
      <value value="0.0928"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-rent-including-utilities">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extent">
      <value value="&quot;Torry&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighbourhood-network">
      <value value="&quot;Hamill and Gilbert&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-year">
      <value value="2018"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-organization-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property">
      <value value="0.618"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-cbr?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-3">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-age-of-marriage">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering">
      <value value="&quot;individual&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-with-pipe-present?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-advisory-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-wfh">
      <value value="63"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-price-override?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-per-patch-for-pipe-line">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-adopters">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-start-school">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="binary-gender-probability">
      <value value="0.4923"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifetime-of-heating-system">
      <value value="4562"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="remember-recommendations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="structure-network-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-national-media-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movie-type">
      <value value="&quot;increase-fuel-prices&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="chances-of-working">
      <value value="0.419"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-central-heating-installed">
      <value value="0.803"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eligibility">
      <value value="&quot;by-proximity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-gis?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ideal-temperature">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dunbars-number">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-gas-illegal">
      <value value="3651"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="heat-network-mandatory-for-businesses?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-adoption-likelihood">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-rewire-or-connection-probability">
      <value value="0.034"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-monthly-wage">
      <value value="1544.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="buildings-input-output-file">
      <value value="&quot;data/buildings.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-neighbour-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-moving-in">
      <value value="1.25E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-surcharge">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-monthly-wage">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-joining-community-organization">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-adoption-likelihood">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-age">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decisions">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ethnicity-2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tick-new-technology">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metering-group-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-case-base-size">
      <value value="96"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-private-rental-vs-public">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-schools">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reduce-threshold-by">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business-output">
      <value value="&quot;business.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-degree">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-marriage">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="humidity-factor">
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-length">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="street-voting">
      <value value="&quot;offsetting-costs&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ubi">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consult-social-networks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="council-taxes-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="working-from-home?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-media-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cases-per-entity">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="work-homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-owning-property-outright">
      <value value="0.498"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nof-employers">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AHP-override-retail-unit-cost">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-street-naming?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="whole-family?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-age-of-death">
      <value value="77"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population-config-file">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proximal-qualification-distance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="roads-input-output-file">
      <value value="&quot;data/roads.torry.dat&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="units-of-energy-per-degree">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-monthly-wage">
      <value value="1906.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-network?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-work-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-surcharge">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-network-reaches-spec">
      <value value="&quot;[50 100]&quot;"/>
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
