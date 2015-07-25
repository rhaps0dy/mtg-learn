import Signal

import Html exposing (..)
import Bootstrap.Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Window
import Graphics.Collage


import Components.Misc exposing (..)
import Components.SongSelecter as SongSelecter
import Components.PlayControls as PlayControls
import Components.ViewSelecter as ViewSelecter
import Components.YLabels as YLabels
{- type Model = Model
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

input' : Signal Input
input' = Signal.mergeMany [ (User <~ Input.signal)
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
state = Signal.foldp update initState input'

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
      ] -}

type Action
  = NoOp
  | ToggleTray
  | Fullscreen Bool
  | SongSelecter SongSelecter.Action
  | PlayControls PlayControls.Action
  | ViewSelecter ViewSelecter.Action
  | YLabels YLabels.Action

type alias Model =
  { trayClosed : Bool
  , fullscreen : Bool
  , songSelecter : SongSelecter.Model
  , playControls : PlayControls.Model
  , viewSelecter : ViewSelecter.Model
  , yLabelLeft : YLabels.Model
  }

init : Model
init =
  { trayClosed = False
  , fullscreen = False
  , songSelecter = SongSelecter.init
  , playControls = PlayControls.init
  , viewSelecter = ViewSelecter.init
  , yLabelLeft = YLabels.init
  }

update : Action -> Model -> Model
update a m =
  case a of
    ToggleTray -> { m | trayClosed <- not m.trayClosed }
    Fullscreen b -> { m | fullscreen <- b }
    SongSelecter s -> { m | songSelecter
                          <- SongSelecter.update s m.songSelecter }
    PlayControls c -> { m | playControls
                          <- PlayControls.update c m.playControls }
    ViewSelecter s -> { m | viewSelecter
                          <- ViewSelecter.update s m.viewSelecter }
    YLabels s -> { m | yLabelLeft
                          <- YLabels.update s m.yLabelLeft }
    _ -> m


view : Signal.Address Action -> Model -> (Int, Int) -> Html
view address model (w, h) =
  let
    -- Number 40 is from $yLabel-width in style.scss
    yLabelLeft = YLabels.view (Signal.forwardTo address YLabels)
                   model.yLabelLeft model.viewSelecter (40, h)
    menuButton =
      span
       [ class "glyphicon glyphicon-menu-hamburger y-label-icon"
       , onClick address ToggleTray
       ] []
  in
    div [ class "fullscreen" ]
     [ div
        [ classList
           [ ("controls", True)
           , ("tray-closed", model.trayClosed)
           ]
        ]
        [ SongSelecter.view (Signal.forwardTo address SongSelecter) model.songSelecter
        , PlayControls.view (Signal.forwardTo address PlayControls) model.playControls
        , ViewSelecter.view (Signal.forwardTo address ViewSelecter) model.viewSelecter
        ]
     , div [ class "y-label" ]
        (yLabelLeft::menuButton::(if model.fullscreen then [] else
          [span
           [ class "glyphicon glyphicon-fullscreen y-label-icon"
           -- Function defined in ports.js, fullscreen has to come from user-generated
           -- event.
           , attribute "onclick" "goFullscreen();"
           ] []]))
     ]

dummy : Signal.Mailbox YLabels.Action
dummy = Signal.mailbox YLabels.NoOp

main : Signal Html
main = Signal.map2 (view actions.address) model Window.dimensions

model : Signal Model
model = Signal.foldp update init (Signal.merge actions.signal jsInputs)

actions : Signal.Mailbox Action
actions = Signal.mailbox NoOp

jsInputs : Signal Action
jsInputs = Signal.map Fullscreen jsFullscreen

port jsFullscreen : Signal Bool
