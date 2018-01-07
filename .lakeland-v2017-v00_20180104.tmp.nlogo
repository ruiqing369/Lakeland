globals [
  FishCatchtot                 ; Total fish catch by human population
  Fish_pop                     ; Size fish population
  Gold_Resource                ; Size gold resource
  GoldTaxRate                  ; Percentage of income from gold mining incom ebeing paid as tax
  Carrying_Capacity            ; Carrying capacity of fish population
  Pollution                    ; Pollution of chemicals from gold mining in the lake
  Growth_rate                  ; Growth rate of the fish population
  WorldMFishPrice              ; Relative price paid for fish by outsiders (world market)
  FishTaxRate                  ; Pertentage of income from fishing income being paid as tax
  GoldMining_Ratetot           ; Total amount of gold collected by human population
  NumOpt                       ; Number of optimizers
  NumRep                       ; Number of repetitors
  NumInq                       ; Number of inquirers.
  NumIm                        ; Number of imitators
  Gini                         ; Gini coefficient income agents
  CumNumOpt                    ; cumulated number of times agents use optimization
  CumNumRep                    ; cumulated number of times agents use repetition
  CumNumInq                    ; cumulated number of times agents use inquiring
  CumNumIm                     ; cumulated number of times agents use imitation
  avguncertainty               ; average level of uncertainty
  agt1 agt1ft agt1mt agt1inc   ; number of agent types 1, their sum of fishing time, their sum of mining time and the sum of income
  agt2 agt2ft agt2mt agt2inc   ; same for agent types 2 - 9
  agt3 agt3ft agt3mt agt3inc   ; agent type 1: low mining skill & low fishing skill; agent type 2: low mining skill & normal fishing skill; agent type 3: low mining skill & high fishing skill
  agt4 agt4ft agt4mt agt4inc   ; agent type 4: normal mining skill & low fishing skill; agent type 5: normal mining skill& normal fishing skill; agent type 6: normal mining skill & high fishing skill
  agt5 agt5ft agt5mt agt5inc   ; agent type 7: high mining skill & low fishing skill; agent type 8: high mining skill & normal fishing skill; agent type 9: high mining skill & high fishing skill
  agt6 agt6ft agt6mt agt6inc
  agt7 agt7ft agt7mt agt7inc
  agt8 agt8ft agt8mt agt8inc
  agt9 agt9ft agt9mt agt9inc
  ]

turtles-own [
  Miningtime               ; Fraction of time allocated to mining
  Fishingtime              ; Fraction of time allocated to fishing
  MineSkill                ; Extraction rate mining per unit of time
  Fish_Catch               ; Amount fish caught
  FishSkill                ; Harvesting rate per unit of time
  FishDemand               ; Fish demand for the agent
  expcatch                 ; expected level of fish catch
  ExpFinance               ; expected accumulated income minus costs of buying food
  Finance                  ; accumulated income minus costs of buying food
  expLNS                   ; expected level of need satisfaction
  FishCom                  ; Expected level of fish caught for market
  Shortage_Cost            ; Costs of buying food on market
  Supply_Income            ; Income from selling fish on market
  Income                   ; Income during that tick
  LNS                      ; level of need satisfaction, the utility
  Uncertainty              ; level of uncertainty
  GoldMining_Rate          ; Extraction rate of gold mining
  ActFishSkill             ; Actual fish catch per unit of time
  desMiningtime            ; Desired fraction of time mining
  desFishingtime           ; Desired fraction of time fishing
  LNSmin_i                 ; Individual level of LNSmin when there is variability
  Umax_i                   ; Individual level of Umax when there is variability
  Gamma_i                  ; Individuals preference for income v. leisure time
  flockmates               ; agentset of nearby turtles
  nearest-neighbor         ; closest one of our flockmates
  career                   ; either mining or fishing
  ]
patches-own []

to setup
  clear-all

  set CumNumOpt 0
  set CumNumRep 0
  set CumNumInq 0
  set CumNumIm 0
  set Fish_pop 100
  set Carrying_Capacity 100
  set Gold_Resource 100
  set GoldTaxRate 15 * 0
  set Growth_rate 0.1
  set WorldMFishPrice 1

  crt num_agents [
    set FishDemand 1 / num_agents
    ifelse variability_skills [
      set MineSkill (0.05 * (1 - level_of_variability_skills) + 0.1 * level_of_variability_skills * random-float 1) / num_agents
      set FishSkill (0.1 * (1 - level_of_variability_skills) + 0.2 * level_of_variability_skills * random-float 1) / num_agents
    ][
     set MineSkill 0.05 / num_agents
     set FishSkill 0.1 / num_agents
    ]
    ifelse variability_thresholds [
      set LNSmin_i 0.1 * (1 - level_of_variability_thresholds) + 0.1 * level_of_variability_thresholds * random-float 1
      set Umax_i 0.2 * (1 - level_of_variability_thresholds) + 0.2 * level_of_variability_thresholds * random-float 1
    ][
      set LNSmin_i LNSmin
      set Umax_i Umax
    ]
    ifelse variability_gamma [
      set Gamma_i  gamma * (1 - level_of_variability_thresholds) + gamma * level_of_variability_thresholds * random-float 1][
      set Gamma_i gamma
    ]
    set agt1 0 set agt1ft 0 set agt1mt 0 set agt1inc 0
    set agt2 0 set agt2ft 0 set agt2mt 0 set agt2inc 0
    set agt3 0 set agt3ft 0 set agt3mt 0 set agt3inc 0
    set agt4 0 set agt4ft 0 set agt4mt 0 set agt4inc 0
    set agt5 0 set agt5ft 0 set agt5mt 0 set agt5inc 0
    set agt6 0 set agt6ft 0 set agt6mt 0 set agt6inc 0
    set agt7 0 set agt7ft 0 set agt7mt 0 set agt7inc 0
    set agt8 9 set agt8ft 0 set agt8mt 0 set agt8inc 0
    set agt9 0 set agt9ft 0 set agt9mt 0 set agt9inc 0
    set Miningtime 0
    set Fishingtime 0.39 ; represents a long term sustainable equilibrium solution
    set Finance 3
    ; calculate initial LNS
    let expincome 0
    let exp_supply_income 0
    ifelse ((FishingTime * FishSkill * Fish_pop) < FishDemand) [set exp_supply_income 0][set exp_supply_income ((FishingTime *  FishSkill * Fish_pop) - FishDemand) * WorldMFishPrice]
    set expincome MineSkill * MiningTime * Gold_Resource + exp_supply_income
    if (FishingTime * FishSkill * Fish_pop) < FishDemand [
         set expincome expincome - WorldMFishPrice * (FishDemand - (FishingTime * FishSkill * Fish_pop))]
    ifelse (expincome > 0) [
       set LNS (expincome ^ Gamma_i) * ((1 - FishingTime - MiningTime) ^ (1 - Gamma_i))
    ][set LNS 0]

    set expLNS LNS
    set Uncertainty 0
    set expcatch FishSkill * Fish_pop
    set Fish_Catch expcatch
    set ActFishSkill FishSkill * Fish_pop
    setxy random-xcor random-ycor
    set size 5
    set color white
    set flockmates no-turtles
  ]
  reset-ticks
end

to go
  move
  decisionmaking
  fishdynamics
  set agt1 0 set agt1ft 0 set agt1mt 0 set agt1inc 0
  set agt2 0 set agt2ft 0 set agt2mt 0 set agt2inc 0
  set agt3 0 set agt3ft 0 set agt3mt 0 set agt3inc 0
  set agt4 0 set agt4ft 0 set agt4mt 0 set agt4inc 0
  set agt5 0 set agt5ft 0 set agt5mt 0 set agt5inc 0
  set agt6 0 set agt6ft 0 set agt6mt 0 set agt6inc 0
  set agt7 0 set agt7ft 0 set agt7mt 0 set agt7inc 0
  set agt8 0 set agt8ft 0 set agt8mt 0 set agt8inc 0
  set agt9 0 set agt9ft 0 set agt9mt 0 set agt9inc 0
 ask turtles [
  ifelse inequalityaversion [
      let perceivedincome Income - beta * ABS (Income - mean [Income] of other turtles)
      ifelse perceivedincome > 0 [
         set LNS (perceivedincome ^ Gamma_i ) * ((1 - Fishingtime - Miningtime) ^ (1 - Gamma_i))][set LNS 0]
    ][
    ifelse Income > 0 [
       set LNS (Income ^ Gamma_i ) * ((1 - Fishingtime - Miningtime) ^ (1 - Gamma_i))][set LNS 0]
    ]
   set avguncertainty 0
   if ExpLNS > 0 [
      let unc abs(ExpLNS - LNS) / ExpLNS
     ifelse (unc > Umax_i)  [set Uncertainty 1][set Uncertainty 0]
      set avguncertainty avguncertainty + unc
   ]
   set avguncertainty avguncertainty / num_agents
   ifelse MineSkill <= (0.033 / num_agents) [
      ifelse FishSkill <= (0.067 / num_agents)[
        set agt1 agt1 + 1
        set agt1ft agt1ft + Fishingtime
        set agt1mt agt1mt + Miningtime
        set agt1inc agt1inc + Income
      ][
        ifelse FishSkill <= (0.133 / num_agents) [
          set agt2 agt2 + 1
          set agt2ft agt2ft + Fishingtime
          set agt2mt agt2mt + Miningtime
          set agt2inc agt2inc + Income
      ][
        set agt3 agt3 + 1
        set agt3ft agt3ft + Fishingtime
        set agt3mt agt3mt + Miningtime
        set agt3inc agt3inc + Income
        ]
      ]
    ][
      ifelse MineSkill <= (0.067 / num_agents) [
        ifelse FishSkill <= (0.067 / num_agents) [
          set agt4 agt4 + 1
          set agt4ft agt4ft + Fishingtime
          set agt4mt agt4mt + Miningtime
          set agt4inc agt4inc + Income
      ][
        ifelse FishSkill <= (0.133 / num_agents) [
          set agt5 agt5 + 1
          set agt5ft agt5ft + Fishingtime
          set agt5mt agt5mt + Miningtime
          set agt5inc agt5inc + Income
      ][
        set agt6 agt6 + 1
        set agt6ft agt6ft + Fishingtime
        set agt6mt agt6mt + Miningtime
        set agt6inc agt6inc + Income
        ]
      ]
      ][

        ifelse FishSkill <= (0.067 / num_agents) [
        set agt7 agt7 + 1
        set agt7ft agt7ft + Fishingtime
        set agt7mt agt7mt + Miningtime
        set agt7inc agt7inc + Income
      ][
        ifelse FishSkill <= (0.133 / num_agents)[
          set agt8 agt8 + 1
          set agt8ft agt8ft + Fishingtime
          set agt8mt agt8mt + Miningtime
          set agt8inc agt8inc + Income
      ][
        set agt9 agt9 + 1
        set agt9ft agt9ft + Fishingtime
        set agt9mt agt9mt + Miningtime
        set agt9inc agt9inc + Income
        ]
      ]
    ]
    ]
 ]
update_career
update_color_and_size
if flocking = true
  [flock]
tick
end

to move
  ask turtles
  [forward Speed]
end


to decisionmaking
  set CumNumOpt CumNumOpt + NumOpt
  set CumNumRep CumNumRep + NumRep
  set CumNumInq CumNumInq + NumInq
  set CumNumIm CumNumIm + NumIm
  set NumOpt 0
  set NumRep 0
  set NumInq 0
  set NumIm 0
  ask turtles [
     let bestFT 0
     let bestMT 0
     let expLNS1 0
     let expLNS2 0
     let FT 0
     let MT 0
     let maxLNS 0
     let expFish_Catch 0
     let expincome 0
     let options []
     let optionsLNS []
     let optionsFT []
     let optionsMT []
     ifelse LNS < LNSmin_i [
       ifelse Uncertainty = 0 [
         ; Optimization
         set NumOpt NumOpt + 1
         while [FT <= 1]
         [
           set MT 0
           while [(MT + FT) <= 1]
           [
             set expincome 0
             let exp_supply_income 0

             ifelse ((FT * FishSkill * Fish_pop) < FishDemand) [set exp_supply_income 0][set exp_supply_income ((FT *  FishSkill * Fish_pop) - FishDemand) * WorldMFishPrice]
             set expincome (1 - GoldTaxRate / 100) *  MineSkill * MT * Gold_Resource + (1 - FishTaxRate / 100) * exp_supply_income
             if inequalityaversion [
              set expincome expincome - beta * ABS (expincome - mean [Income] of other turtles)
            ]

             if (FT * FishSkill * Fish_pop) < FishDemand [
               set expincome expincome - WorldMFishPrice * (FishDemand - (FT * FishSkill * Fish_pop))]

              ifelse (expincome > 0) [

              set expLNS (expincome ^ Gamma_i) * ((1 - FT - MT) ^ (1 - Gamma_i))
              ][set expLNS 0]
             if expLNS >= maxLNS [
               ifelse expLNS = maxLNS [
                 set optionsFT lput FT optionsFT
                 set optionsMT lput MT optionsMT
               ][
               set maxLNS expLNS
               set optionsFT []
               set optionsMT []
               set optionsFT lput FT optionsFT
               set optionsMT lput MT optionsMT
               set bestMT MT
               set bestFT FT]
             ]
             set MT MT + 0.1
           ]
           set FT FT + 0.1
         ]
         let iter random length optionsFT
         set desMiningtime item iter optionsMT
         set desFishingtime item iter optionsFT
         if maxLNS = 0 [set desMiningtime 0 set desFishingtime 0]
         set expLNS maxLNS
         ][
           ; Inquiring
           set NumInq NumInq + 1
           let fs FishSkill
           let ms MineSkill
           let peers turtles in-radius Neighborhood_radius   ;; people only compare the people that are around them
           set desMiningtime mean [Miningtime] of peers with [abs(FishSkill - fs) <= 0.1 and abs(MineSkill - ms) <= 0.1]
           set desFishingtime mean [Fishingtime] of peers with [abs(FishSkill - fs) <= 0.1 and abs(MineSkill - ms) <= 0.1]

      ; expected utility current strategy
           set expincome 0
           let exp_supply_income 0
           ifelse ((FishingTime * FishSkill * Fish_pop) < FishDemand) [set exp_supply_income 0][set exp_supply_income ((FishingTime *  FishSkill * Fish_pop) - FishDemand) * WorldMFishPrice]
           set expincome (1 - GoldTaxRate / 100) *  MineSkill * MiningTime * Gold_Resource + (1 - FishTaxRate / 100) * exp_supply_income
           if (FT * FishSkill * Fish_pop) < FishDemand [
               set expincome expincome - WorldMFishPrice * (FishDemand - (FishingTime * FishSkill * Fish_pop))]
           if inequalityaversion [
              set expincome expincome - beta * ABS (expincome - mean [Income] of other turtles)
            ]
          ifelse (expincome > 0) [
              set expLNS1 (expincome ^ Gamma_i) * ((1 - FishingTime - MiningTime) ^ (1 - Gamma_i))
              ][set expLNS1 0]

       ; expected utility current strategy
           set expincome 0
           set exp_supply_income 0
           ifelse ((desFishingTime * FishSkill * Fish_pop) < FishDemand) [set exp_supply_income 0][set exp_supply_income ((desFishingTime *  FishSkill * Fish_pop) - FishDemand) * WorldMFishPrice]
           set expincome (1 - GoldTaxRate / 100) *  MineSkill * desMiningTime * Gold_Resource + (1 - FishTaxRate / 100) * exp_supply_income
           if (desFishingTime * FishSkill * Fish_pop) < FishDemand [
               set expincome expincome - WorldMFishPrice * (FishDemand - (desFishingTime * FishSkill * Fish_pop))]
           if inequalityaversion [
              set expincome expincome - beta * ABS (expincome - mean [Income] of other turtles)
            ]
          ifelse (expincome > 0) [
              set expLNS2 (expincome ^ Gamma_i) * ((1 - desFishingTime - desMiningTime) ^ (1 - Gamma_i))
              ][set expLNS2 0]
        ifelse expLNS1 >= expLNS2 [set desFishingTime FishingTime set desMiningTime MiningTime set expLNS expLNS1][set expLNS expLNS2]
     ]
     ][
       ifelse Uncertainty = 0 [
         ; repetition
         set NumRep NumRep + 1
         set desMiningtime Miningtime
         set desFishingtime Fishingtime
       ][
          ; imitation
          set NumIm NumIm + 1
           let fs FishSkill
           let ms MineSkill
           let peers turtles in-radius Neighborhood_radius  ;; people only imitate the people around them
           set desMiningtime mean [Miningtime] of peers with [abs(FishSkill - fs) <= 0.1 and abs(MineSkill - ms) <= 0.1]
           set desFishingtime mean [Fishingtime] of peers with [abs(FishSkill - fs) <= 0.1 and abs(MineSkill - ms) <= 0.1]
       ]
     ]
     ]
     ask turtles [
       set Miningtime desMiningtime
       set Fishingtime desFishingtime
     ]
end




to fishdynamics
  ask turtles [
     set Expcatch Expcatch * 0.5 + 0.5 * ActFishSkill

     set GoldMining_Rate MineSkill * Miningtime * Gold_Resource

     set FishCom Fishingtime * expcatch - FishDemand
     ifelse Stochasticity [
      set Fish_Catch Fishingtime * FishSkill * Fish_pop * random-normal 1 0.05
       ][
      set Fish_Catch Fishingtime * FishSkill * Fish_pop
    ]
     if Fish_Catch < 0 [set Fish_Catch 0]

     set ActFishSkill FishSkill * Fish_pop

     ; Finance

     set ExpFinance   Finance + GoldMining_Rate * (1 - GoldTaxRate / 100) + (1 - FishTaxRate / 100) * FishCom * WorldMFishPrice

     ifelse Fish_Catch < FishDemand [
       set Supply_Income 0
        set Shortage_Cost WorldMFishPrice * (FishDemand - Fish_Catch)

       ][
       set Supply_Income (Fish_Catch - FishDemand) * WorldMFishPrice
       set Shortage_Cost 0]

     set Income  (1 - GoldTaxRate / 100) *  GoldMining_Rate + (1 - FishTaxRate / 100) * Supply_Income - Shortage_Cost

     set Finance Finance + Income
     if Finance < 0 [set Finance 0]
  ]

  set FishCatchtot sum [Fish_Catch] of turtles
  set GoldMining_Ratetot sum [GoldMining_Rate] of turtles

  set Gold_Resource Gold_Resource - GoldMining_Ratetot

  set Pollution (GoldMining_Ratetot / 100) + (1 - removalrate) * Pollution

  if Pollution_active = false [set Pollution 0]

  set Carrying_Capacity 100 * (1 - Pollution)

  set Fish_pop Fish_pop + Growth_rate * Fish_pop * ( 1 - Fish_pop / Carrying_Capacity) - FishCatchtot

  ; calculate inequality
  let sumgini 0
  ask turtles [
    let Income1 Income
    ask other turtles [
      set sumgini sumgini + abs (Income1 - Income)
    ]
  ]
  let minincome min [Income] of turtles

  ifelse minincome < 0 [
    if (sum [Income] of turtles - num_agents * minincome)!= 0 [
       set gini sumgini / (2 * num_agents * (sum [Income] of turtles - num_agents * minincome))
    ]
  ][
    if sum [Income] of turtles != 0 [
        set gini sumgini / (2 * num_agents * sum [Income] of turtles)
    ]
]
end

to update_career
  ask turtles
    [ifelse Miningtime > fishingtime
     [set career 1 ]
      [set career 0 ]
  ]
end

to update_color_and_size
ask turtles
  [ifelse (Miningtime < Fishingtime)
    [set color blue
    set size Fishingtime * 5
    ]
    [set color yellow
    set size Miningtime * 5
    ]
  ]
end

to flock
 ask turtles
   [find-flockmates
     if any? flockmates
    [ find-nearest-neighbor
       ifelse distance nearest-neighbor < minimum-separation
        [ separate  ]
        [ align
          cohere  ]
      ]
  ]
end

to find-flockmates
    let c  [career] of self
       let same-career other turtles with  [ career = c ]
      set flockmates same-career in-radius neighborhood_radius

end

to find-nearest-neighbor ;; turtle procedure
  set nearest-neighbor min-one-of flockmates [distance myself]
end

;;; SEPARATE

to separate  ;; turtle procedure
  turn-away ([heading] of nearest-neighbor ) max-separate-turn
end

;;; ALIGN

to align  ;;turtle procedure
  turn-towards average-flockmate-heading max-align-turn
end

to-report average-flockmate-heading  ;; turtle procedure
  ;; We can't just average the heading variables here.
  ;; For example, the average of 1 and 359 should be 0,
  ;; not 180.  So we have to use trigonometry.
  let x-component sum [dx] of flockmates
  let y-component sum [dy] of flockmates
  ifelse x-component = 0 and y-component = 0
    [ report heading ]
    [ report atan x-component y-component ]
end

;;; COHERE

to cohere  ;; turtle procedure
  turn-towards average-heading-towards-flockmates max-cohere-turn
end

to-report average-heading-towards-flockmates  ;; turtle procedure
  ;; "towards myself" gives us the heading from the other turtle
  ;; to me, but we want the heading from me to the other turtle,
  ;; so we add 180
  let x-component mean [sin (towards myself + 180)] of flockmates
  let y-component mean [cos (towards myself + 180)] of flockmates
  ifelse x-component = 0 and y-component = 0
    [ report heading ]
    [ report atan x-component y-component ]
end

;;; HELPER PROCEDURES

to turn-towards [new-heading max-turn]  ;; turtle procedure
  turn-at-most (subtract-headings new-heading heading) max-turn
end

to turn-away [new-heading max-turn]  ;; turtle procedure
  turn-at-most (subtract-headings heading new-heading) max-turn
end

;; turn right by "turn" degrees (or left if "turn" is negative),
;; but never turn more than "max-turn" degrees
to turn-at-most [turn max-turn]  ;; turtle procedure
  ifelse abs turn > max-turn
    [ ifelse turn > 0
        [ rt max-turn ]
        [ lt max-turn ] ]
    [ rt turn ]
end
@#$#@#$#@
GRAPHICS-WINDOW
355
10
578
234
-1
-1
2.13433
1
1
1
1
1
0
1
1
1
-50
50
-50
50
1
1
1
ticks
1.0

BUTTON
10
18
79
51
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
92
18
159
51
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
8
55
125
88
num_agents
num_agents
0
200
100.0
1
1
NIL
HORIZONTAL

PLOT
839
10
1078
196
Pollution
NIL
NIL
0.0
10.0
0.0
1.0E-5
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot Pollution"

BUTTON
169
17
232
50
NIL
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

PLOT
601
10
835
195
Fishcatch
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
"default" 1.0 0 -16777216 true "" "if ticks > 0 [plot Fishcatchtot]"

PLOT
591
202
841
350
Time
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
"Fishing" 1.0 0 -14454117 true "" "plot mean [Fishingtime] of turtles"
"Mining" 1.0 0 -16777216 true "" "plot mean [Miningtime] of turtles"

PLOT
1092
203
1326
351
LNS
NIL
NIL
0.0
100.0
0.0
0.01
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [LNS] of turtles"
"pen-1" 1.0 0 -7500403 true "" "plot mean [expLNS] of turtles"

SLIDER
8
125
126
158
LNSmin
LNSmin
0
0.2
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
8
158
126
191
Umax
Umax
0
1
0.2
0.01
1
NIL
HORIZONTAL

PLOT
844
203
1092
350
Resources
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
"Fish" 1.0 0 -14070903 true "" "plot Fish_pop"
"Gold" 1.0 0 -14737633 true "" "plot Gold_Resource"

SLIDER
149
275
321
308
removalrate
removalrate
0
1
0.01
0.01
1
NIL
HORIZONTAL

PLOT
590
356
845
497
Cognitive Process
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
"Optimization" 1.0 0 -13791810 true "" "plot NumOpt"
"Repetition" 1.0 0 -13840069 true "" "plot NumRep"
"Inquiring" 1.0 0 -5298144 true "" "plot NumInq"
"Imitation" 1.0 0 -1184463 true "" "plot NumIm"

PLOT
1083
37
1283
187
Uncertainty
NIL
NIL
0.0
10.0
0.0
1.0E-4
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot avguncertainty"

SWITCH
137
55
302
88
variability_skills
variability_skills
0
1
-1000

SLIDER
7
90
126
123
gamma
gamma
0
1
0.75
0.01
1
NIL
HORIZONTAL

PLOT
846
357
1091
494
Income
NIL
NIL
0.0
10.0
0.0
0.1
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [Income] of turtles"

SWITCH
5
197
130
230
Pollution_active
Pollution_active
0
1
-1000

SWITCH
7
278
133
311
Stochasticity
Stochasticity
0
1
-1000

PLOT
1094
356
1328
494
Gini
NIL
NIL
0.0
1000.0
0.0
0.4
false
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot Gini"

SLIDER
135
90
324
123
level_of_variability_skills
level_of_variability_skills
0
1
0.5
0.01
1
NIL
HORIZONTAL

SWITCH
134
126
307
159
variability_thresholds
variability_thresholds
1
1
-1000

SLIDER
134
159
331
192
level_of_variability_thresholds
level_of_variability_thresholds
0
1
0.0
0.01
1
NIL
HORIZONTAL

SWITCH
7
241
146
274
inequalityaversion
inequalityaversion
0
1
-1000

SLIDER
254
346
410
379
beta
beta
0
1
1.0
0.01
1
NIL
HORIZONTAL

TEXTBOX
252
10
402
52
If variability thresholds is on, LNSmin and Umax sliders cannot be used.
11
0.0
1

TEXTBOX
171
321
321
349
Is there variability of fish catch among agents/
11
0.0
1

SLIDER
20
317
155
350
Speed
Speed
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
18
364
209
397
Neighborhood_radius
Neighborhood_radius
0
50
50.0
1
1
NIL
HORIZONTAL

SWITCH
140
196
309
229
variability_gamma
variability_gamma
1
1
-1000

SLIDER
156
239
379
272
level_of_variability_gamma
level_of_variability_gamma
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
5
407
177
440
minimum-separation
minimum-separation
0
5
1.0
0.25
1
NIL
HORIZONTAL

SLIDER
4
474
176
507
max-align-turn
max-align-turn
0
20
6.0
0.25
1
NIL
HORIZONTAL

SLIDER
5
442
177
475
max-separate-turn
max-separate-turn
0
20
1.5
0.25
1
NIL
HORIZONTAL

SLIDER
4
507
176
540
max-cohere-turn
max-cohere-turn
0
20
5.75
0.25
1
NIL
HORIZONTAL

SWITCH
191
410
294
443
flocking
flocking
0
1
-1000

@#$#@#$#@
This is a Netlogo implementation of a simplified version of the model described in Jager W., M.A. Janssen, H.J.M. De Vries, J. De Greef and C.A.J. Vlek (2000) Behaviour in commons dilemmas: Homo Economicus and Homo Psychologicus in an ecological-economic model, Ecological Economics 35(3): 357-380

The original model was implemented in 1999 in Vensim, a system dynamics language. 

Copyright (C) 2017 MarcoA. Janssen and Wander Jager

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.  
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.  
You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
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
NetLogo 6.0.2
@#$#@#$#@
setup
set grass? true
repeat 75 [ go ]
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment_3" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>Fish_pop</metric>
    <metric>Gold_Resource</metric>
    <metric>mean [Finance] of turtles</metric>
    <metric>mean [LNS] of turtles</metric>
    <metric>Pollution</metric>
    <metric>Gini</metric>
    <metric>CumNumOpt / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>CumNumRep / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>CumNumInq / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>CumNumIm / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>agt1</metric>
    <metric>agt2</metric>
    <metric>agt3</metric>
    <metric>agt4</metric>
    <metric>agt5</metric>
    <metric>agt6</metric>
    <metric>agt7</metric>
    <metric>agt8</metric>
    <metric>agt9</metric>
    <metric>agt1ft</metric>
    <metric>agt2ft</metric>
    <metric>agt3ft</metric>
    <metric>agt4ft</metric>
    <metric>agt5ft</metric>
    <metric>agt6ft</metric>
    <metric>agt7ft</metric>
    <metric>agt8ft</metric>
    <metric>agt9ft</metric>
    <metric>agt1mt</metric>
    <metric>agt2mt</metric>
    <metric>agt3mt</metric>
    <metric>agt4mt</metric>
    <metric>agt5mt</metric>
    <metric>agt6mt</metric>
    <metric>agt7mt</metric>
    <metric>agt8mt</metric>
    <metric>agt9mt</metric>
    <metric>agt1inc</metric>
    <metric>agt2inc</metric>
    <metric>agt3inc</metric>
    <metric>agt4inc</metric>
    <metric>agt5inc</metric>
    <metric>agt6inc</metric>
    <metric>agt7inc</metric>
    <metric>agt8inc</metric>
    <metric>agt9inc</metric>
    <metric>CumNumInq / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <enumeratedValueSet variable="variability_skills">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="variability_thresholds">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="removalrate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_agents">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LNSmin">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Umax">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level_of_variability_skills">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level_of_variability_thresholds">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Stochasticity">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inequalityaversion">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta">
      <value value="0"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="flocking">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="speed">
      <value value="0"/>
      <value value="3"/>
      <value value="7"/>
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="gamma variability" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>Fish_pop</metric>
    <metric>Gold_Resource</metric>
    <metric>mean [Finance] of turtles</metric>
    <metric>mean [LNS] of turtles</metric>
    <metric>Pollution</metric>
    <metric>Gini</metric>
    <metric>CumNumOpt / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>CumNumRep / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>CumNumInq / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>CumNumIm / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>agt1</metric>
    <metric>agt2</metric>
    <metric>agt3</metric>
    <metric>agt4</metric>
    <metric>agt5</metric>
    <metric>agt6</metric>
    <metric>agt7</metric>
    <metric>agt8</metric>
    <metric>agt9</metric>
    <metric>agt1ft</metric>
    <metric>agt2ft</metric>
    <metric>agt3ft</metric>
    <metric>agt4ft</metric>
    <metric>agt5ft</metric>
    <metric>agt6ft</metric>
    <metric>agt7ft</metric>
    <metric>agt8ft</metric>
    <metric>agt9ft</metric>
    <metric>agt1mt</metric>
    <metric>agt2mt</metric>
    <metric>agt3mt</metric>
    <metric>agt4mt</metric>
    <metric>agt5mt</metric>
    <metric>agt6mt</metric>
    <metric>agt7mt</metric>
    <metric>agt8mt</metric>
    <metric>agt9mt</metric>
    <metric>agt1inc</metric>
    <metric>agt2inc</metric>
    <metric>agt3inc</metric>
    <metric>agt4inc</metric>
    <metric>agt5inc</metric>
    <metric>agt6inc</metric>
    <metric>agt7inc</metric>
    <metric>agt8inc</metric>
    <metric>agt9inc</metric>
    <enumeratedValueSet variable="variability_skills">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="variability_thresholds">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="variability_gamma">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="removalrate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_agents">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LNSmin">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Umax">
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gamma">
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level_of_variability_skills">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level_of_variability_thresholds">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level_of_variability_gamma">
      <value value="0"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Stochasticity">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inequalityaversion">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="steps">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vicinity_distance">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="baseline_test" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>Fish_pop</metric>
    <metric>Gold_Resource</metric>
    <metric>mean [Finance] of turtles</metric>
    <metric>mean [LNS] of turtles</metric>
    <metric>Pollution</metric>
    <metric>Gini</metric>
    <metric>CumNumOpt / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>CumNumRep / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>CumNumInq / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>CumNumIm / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>agt1</metric>
    <metric>agt2</metric>
    <metric>agt3</metric>
    <metric>agt4</metric>
    <metric>agt5</metric>
    <metric>agt6</metric>
    <metric>agt7</metric>
    <metric>agt8</metric>
    <metric>agt9</metric>
    <metric>agt1ft</metric>
    <metric>agt2ft</metric>
    <metric>agt3ft</metric>
    <metric>agt4ft</metric>
    <metric>agt5ft</metric>
    <metric>agt6ft</metric>
    <metric>agt7ft</metric>
    <metric>agt8ft</metric>
    <metric>agt9ft</metric>
    <metric>agt1mt</metric>
    <metric>agt2mt</metric>
    <metric>agt3mt</metric>
    <metric>agt4mt</metric>
    <metric>agt5mt</metric>
    <metric>agt6mt</metric>
    <metric>agt7mt</metric>
    <metric>agt8mt</metric>
    <metric>agt9mt</metric>
    <metric>agt1inc</metric>
    <metric>agt2inc</metric>
    <metric>agt3inc</metric>
    <metric>agt4inc</metric>
    <metric>agt5inc</metric>
    <metric>agt6inc</metric>
    <metric>agt7inc</metric>
    <metric>agt8inc</metric>
    <metric>agt9inc</metric>
    <enumeratedValueSet variable="variability_skills">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="variability_thresholds">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="variability_gamma">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="removalrate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_agents">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LNSmin">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Umax">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gamma">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level_of_variability_skills">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level_of_variability_thresholds">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level_of_variability_gamma">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Stochasticity">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inequalityaversion">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="steps">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="neighborhood_radius">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-separation">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-separate-turn">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-align-turn">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-cohere-turn">
      <value value="5.75"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="radius" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>Fish_pop</metric>
    <metric>Gold_Resource</metric>
    <metric>mean [Finance] of turtles</metric>
    <metric>mean [LNS] of turtles</metric>
    <metric>Pollution</metric>
    <metric>Gini</metric>
    <metric>CumNumOpt / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>CumNumRep / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>CumNumInq / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>CumNumIm / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>agt1</metric>
    <metric>agt2</metric>
    <metric>agt3</metric>
    <metric>agt4</metric>
    <metric>agt5</metric>
    <metric>agt6</metric>
    <metric>agt7</metric>
    <metric>agt8</metric>
    <metric>agt9</metric>
    <metric>agt1ft</metric>
    <metric>agt2ft</metric>
    <metric>agt3ft</metric>
    <metric>agt4ft</metric>
    <metric>agt5ft</metric>
    <metric>agt6ft</metric>
    <metric>agt7ft</metric>
    <metric>agt8ft</metric>
    <metric>agt9ft</metric>
    <metric>agt1mt</metric>
    <metric>agt2mt</metric>
    <metric>agt3mt</metric>
    <metric>agt4mt</metric>
    <metric>agt5mt</metric>
    <metric>agt6mt</metric>
    <metric>agt7mt</metric>
    <metric>agt8mt</metric>
    <metric>agt9mt</metric>
    <metric>agt1inc</metric>
    <metric>agt2inc</metric>
    <metric>agt3inc</metric>
    <metric>agt4inc</metric>
    <metric>agt5inc</metric>
    <metric>agt6inc</metric>
    <metric>agt7inc</metric>
    <metric>agt8inc</metric>
    <metric>agt9inc</metric>
    <enumeratedValueSet variable="variability_skills">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="variability_thresholds">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="variability_gamma">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="removalrate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_agents">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LNSmin">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Umax">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gamma">
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level_of_variability_skills">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level_of_variability_thresholds">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level_of_variability_gamma">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Stochasticity">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inequalityaversion">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="steps">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vicinity_distance">
      <value value="0"/>
      <value value="2"/>
      <value value="4"/>
      <value value="6"/>
      <value value="8"/>
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="radius plus steps" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>Fish_pop</metric>
    <metric>Gold_Resource</metric>
    <metric>mean [Finance] of turtles</metric>
    <metric>mean [LNS] of turtles</metric>
    <metric>Pollution</metric>
    <metric>Gini</metric>
    <metric>CumNumOpt / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>CumNumRep / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>CumNumInq / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>CumNumIm / (CumNumOpt + CumNumRep + CumNumInq + CumNumIm)</metric>
    <metric>agt1</metric>
    <metric>agt2</metric>
    <metric>agt3</metric>
    <metric>agt4</metric>
    <metric>agt5</metric>
    <metric>agt6</metric>
    <metric>agt7</metric>
    <metric>agt8</metric>
    <metric>agt9</metric>
    <metric>agt1ft</metric>
    <metric>agt2ft</metric>
    <metric>agt3ft</metric>
    <metric>agt4ft</metric>
    <metric>agt5ft</metric>
    <metric>agt6ft</metric>
    <metric>agt7ft</metric>
    <metric>agt8ft</metric>
    <metric>agt9ft</metric>
    <metric>agt1mt</metric>
    <metric>agt2mt</metric>
    <metric>agt3mt</metric>
    <metric>agt4mt</metric>
    <metric>agt5mt</metric>
    <metric>agt6mt</metric>
    <metric>agt7mt</metric>
    <metric>agt8mt</metric>
    <metric>agt9mt</metric>
    <metric>agt1inc</metric>
    <metric>agt2inc</metric>
    <metric>agt3inc</metric>
    <metric>agt4inc</metric>
    <metric>agt5inc</metric>
    <metric>agt6inc</metric>
    <metric>agt7inc</metric>
    <metric>agt8inc</metric>
    <metric>agt9inc</metric>
    <enumeratedValueSet variable="variability_skills">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="variability_thresholds">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="variability_gamma">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="removalrate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_agents">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LNSmin">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Umax">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gamma">
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level_of_variability_skills">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level_of_variability_thresholds">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level_of_variability_gamma">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Stochasticity">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inequalityaversion">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="steps">
      <value value="0"/>
      <value value="3"/>
      <value value="7"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vicinity_distance">
      <value value="0"/>
      <value value="3"/>
      <value value="7"/>
      <value value="10"/>
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
