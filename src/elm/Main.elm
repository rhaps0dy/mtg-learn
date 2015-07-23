import Signal

import Html exposing (..)
import Bootstrap.Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

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


labeledCheckbox : String -> String -> Html
labeledCheckbox id' l =
  div [ class "checkbox" ]
   [ label [ for id' ]
      [ input [ id id', type' "checkbox" ] []
      , text l
      ]
   ]

type Action
  = NoOp
  | ToggleTray

type alias Model =
  { trayClosed : Bool }

initModel : Model
initModel =
  { trayClosed = False }

update : Action -> Model -> Model
update a m =
  case a of
    ToggleTray -> { m | trayClosed <- not m.trayClosed }
    _ -> m

view : Signal.Address Action -> Model -> Html
view address model =
  div [ class "fullscreen" ]
   [ div
      [ classList
         [ ("controls", True)
         , ("tray-closed", model.trayClosed) ] ]
      [ div [ class "controls-panel clearfix" ]
         [ div []
            [ h4 [ id "song-select-label" ]
               [ text "Select song to practice" ]
            , formGroup_
               [ select
                  [ class "form-control"
                  , attribute "aria-describedby" "song-select-label"
                  ]
                  [ option [] [ text "Blue bossa" ]
                  , option [] [ text "Lightly row" ]
                  , option [] [ text "Red bossa" ]
                  ]
               ]
            , p [] [ text "or" ]
            , h4 [] [ text "Use your own" ]
            , formGroup_
               [ label [ for "audio-upload" ] [ text "Audio file" ]
               , input
                  [ id "audio-upload"
                  , type' "file"
                  , accept "audio/*"
                  ] []
               ]
            , formGroup_
               [ label [ for "sheet-upload" ] [ text "Sheet music (.xml)" ]
               , input
                  [ id "sheet-upload"
                  , type' "file"
                  , accept "text/xml"
                  ] []
               ]
            ]
         ]
      , div [ class "controls-panel" ]
         [ div [ class "clearfix" ]
            [ formGroup_
               [ div [ class "input-group" ]
                  [ span
                     [ class "input-group-addon"
                     , id "bpm-label" ]
                     [ text "BPM" ]
                  , input
                     [ class "form-control"
                     , id "bpm-value"
                     , type' "number"
                     , value "0"
                     , attribute "aria-describedby" "bpm-label"
                     ] []
                  ]
               ]
            , labeledCheckbox "play-metronome" "Metronome"
            , div [ class "form-group clearfix" ]
               [ label [ class "sr-only", for "jump-beginning" ] [ text "Jump to the beginning" ] 
               , label [ class "sr-only", for "play" ] [ text "Play" ] 
               , label [ class "sr-only", for "jump-end" ] [ text "Jump to the end" ] 
               , div [ class "btn-group pull-left" ]
                  [ span
                     [ class "btn btn-default glyphicon glyphicon-fast-backward"
                     , id "jump-beginning"
                     ] []
                  , span
                     [ class "btn btn-default glyphicon glyphicon-play"
                     , id "play"
                     ] []
                  , span
                     [ class "btn btn-default glyphicon glyphicon-fast-forward"
                     , id "jump-end"
                     ] []
                  ]
               , input
                  [ class "btn btn-default pull-right"
                  , type' "button"
                  , value "Get score"
                  ] []
               ]
            ]
         ]
      , div [ class "controls-panel clearfix" ]
         [ div [ class "clearfix" ]
            [ label [] [ text "View" ]
            , labeledCheckbox "view-pitch" "Pitch"
            , labeledCheckbox "view-energy" "Energy"
            ]
         ]
      ]
   , div [ class "legend" ]
      [ span
         [ class "glyphicon glyphicon-menu-hamburger menu-toggle"
         , onClick address ToggleTray
         ] []
      ]
   , div
      [ classList
         [ ("main-view", True)
         , ("tray-closed", model.trayClosed) ]
      ] [ text "&nbsp;" ]
   ]


main : Signal Html
main = Signal.map (view actions.address) model

model : Signal Model
model = Signal.foldp update initModel actions.signal

actions : Signal.Mailbox Action
actions = Signal.mailbox NoOp