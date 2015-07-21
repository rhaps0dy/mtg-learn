import GraphGrid
import GraphPitch
import GraphPianoRoll
import GraphPianoRoll exposing (Note)
import Input
import FileInput

import Html exposing (Html, div)
import Signal exposing ((<~), (~), Signal)
import Signal
import Time
import Window
import Maybe exposing (Maybe(Just,Nothing))
import Debug

type Model = Model
    { freqs : List Float
    , nfreqs : Int
    , roll : List Note
    , screenCenterA3Offset : Float
    , semitoneHeight : Float
    , startLinePosRel : Float
    , freqPointSeparation : Float
    , btnDownModel : Maybe Model
    , inputTrayOpen : Bool
    }


initState : Model
initState = Model
    { freqs = []
    , nfreqs = 0
    , roll = []
    , screenCenterA3Offset = 0
    , semitoneHeight = 12
    , startLinePosRel = 3/4
    , freqPointSeparation = 3.5
    , btnDownModel = Nothing
    , inputTrayOpen = False
    }

type Input = User Input.Input | Frame Float | Roll (List Note)

type alias Analysis =
    { pitch : Float
    }

port analysis : Signal Analysis
port roll : Signal (List Note)

input : Signal Input
input = Signal.mergeMany [ (User <~ Input.signal)
                         , (Frame << (.pitch) <~ analysis)
                         , (Roll <~ roll)
                         ]

mouseUpdate : Input.Input -> Model ->  Model
mouseUpdate i (Model m') =
  let
    m = if i.spacePressed then { m' | inputTrayOpen <- not m'.inputTrayOpen } else m'
  in
  if | not i.btnDown ->
         Model { m | btnDownModel <- Nothing }
     | Input.justWentDown i ->
         Model { m | btnDownModel <- Just (Model m) }
     | m.btnDownModel /= Nothing ->
       let
         (Just (Model m')) = m.btnDownModel
         oldX = toFloat (fst i.btnDownMouse)
         newX = toFloat (fst i.mouse)
         oldY = toFloat (snd i.btnDownMouse)
         newY = toFloat (snd i.mouse)
         newSemitoneHeight = m'.semitoneHeight / newY * oldY
         newFreqPointSeparation = m'.freqPointSeparation / newX * oldX
         newScreenCenterA3Offset = m'.screenCenterA3Offset + (newY - oldY) / m.semitoneHeight
         newStartLinePosRel = m'.startLinePosRel + (newX - oldX) / toFloat (fst i.winDims)
       in
         if i.mod
           then Model { m | semitoneHeight <- newSemitoneHeight
                          , freqPointSeparation <- newFreqPointSeparation }
           else Model { m | screenCenterA3Offset <- newScreenCenterA3Offset
                          , startLinePosRel <- newStartLinePosRel }
     | otherwise -> Model m

frameUpdate : Float -> Model -> Model
frameUpdate f (Model m) = Model { m | freqs <- f :: m.freqs
                                    , nfreqs <- m.nfreqs + 1 }

rollUpdate : List Note -> Model -> Model
rollUpdate s (Model m) = Model { m | roll <- s }

update : Input -> Model -> Model
update i m =
  case i of
    User u -> mouseUpdate u m
    Frame f -> frameUpdate f m
    Roll s -> rollUpdate s m

state : Signal Model
state = Signal.foldp update initState input

render : (Int, Int) -> Model -> Html
render (w, h) (Model m) =
  let
    h' = if m.inputTrayOpen then h - 60 else h
  in
    div []
      [
        div []
          [ GraphGrid.render h' m.screenCenterA3Offset m.semitoneHeight
          , GraphPianoRoll.render (w, h') m.startLinePosRel m.screenCenterA3Offset m.semitoneHeight m.freqPointSeparation m.roll m.nfreqs
          , GraphPitch.render (w, h') m.startLinePosRel m.screenCenterA3Offset m.semitoneHeight m.freqPointSeparation m.freqs
          ]
      , FileInput.render h' w (h-h')
      ]

main : Signal Html
main = render <~ Window.dimensions ~ state
