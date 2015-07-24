module Components.PlayControls (Model, init, Action, update, view) where

import Html as Html exposing (..)
import Bootstrap.Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (onClick)
import Signal
import String

import Components.Misc exposing (..)

type alias Model =
  { playing : Bool
  , metronome : Bool
  , bpm : Int
  }

init : Model
init =
  { playing = False
  , metronome = False
  , bpm = 120
  }

type Action
  = NoOp
  | JumpBeginning
  | TogglePlaying
  | JumpEnd
  | GetScore
  | ChangeBPM Int
  | Metronome Bool

update : Action -> Model -> Model
update action model =
 case action of
   TogglePlaying -> { model | playing <- not model.playing }
   ChangeBPM bpm -> { model | bpm <- bpm }
   Metronome b -> { model | metronome <- b }
   _ -> model

view : Signal.Address Action -> Model -> Html
view address model =
  div [ class "control-panel" ]
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
               , value (toString model.bpm)
               , onChange address (ChangeBPM << (\(Ok i) -> i) << String.toInt)
               , attribute "aria-describedby" "bpm-label"
               ] []
            ]
         ]
      , labeledCheckbox "play-metronome" "Metronome" address Metronome model.metronome
      , div [ class "form-group clearfix" ]
         [ label [ class "sr-only", for "jump-beginning" ]
            [ text "Jump to the beginning" ] 
         , label [ class "sr-only", for "play" ] [ text "Play" ] 
         , label [ class "sr-only", for "jump-end" ] [ text "Jump to the end" ] 
         , div [ class "btn-group pull-left" ]
            [ span
               [ class "btn btn-default glyphicon glyphicon-fast-backward"
               , onClick address JumpBeginning
               ] []
            , span
               [ class ("btn btn-default glyphicon " ++ if model.playing then
                                                         "glyphicon-pause"
                                                       else
                                                         "glyphicon-play")
               , onClick address TogglePlaying
               ] []
            , span
               [ class "btn btn-default glyphicon glyphicon-fast-forward"
               , onClick address JumpEnd
               ] []
            ]
         , input
            [ class "btn btn-default pull-right"
            , type' "button"
            , value "Get score"
            , onClick address GetScore
            ] []
         ]
      ]
   ]