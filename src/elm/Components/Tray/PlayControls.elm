module Components.Tray.PlayControls
  ( Model
  , init
  , Action(MicRecording)
  , ExternalAction(..)
  , update
  , view
  ) where

import Html as Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (onClick)
import Signal
import String

import Components.Misc exposing (labeledCheckbox)
import HtmlEvents exposing (onChange)

type alias Model =
  { playing : Bool
  , metronome : Bool
  , bpm : Int
  , micRecording : Bool
  }

init : Model
init =
  { playing = False
  , metronome = False
  , bpm = 120
  , micRecording = False
  }

type ExternalAction
  = JumpBeginning
  | JumpEnd
  | GetScore

type Action
  = NoOp
  | TogglePlaying
  | ChangeBPM Int
  | Metronome Bool
  | MicRecording Bool

update : Action -> Model -> Model
update action model =
 case action of
   TogglePlaying -> { model | playing <- not model.playing }
   ChangeBPM bpm -> { model | bpm <- bpm }
   Metronome b -> { model | metronome <- b }
   MicRecording b -> { model | micRecording <- b }
   _ -> model

view : Signal.Address Action -> Signal.Address ExternalAction -> Model -> Html
view address extAddr model =
  div [ class "control-panel" ]
   [ div [ class "clearfix" ]
      ([ div [ class "form-group" ]
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
               , onChange address (ChangeBPM << (\ (Ok i) -> i) << String.toInt)
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
               , onClick extAddr JumpBeginning
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
               , onClick extAddr JumpEnd
               ] []
            ]
         , input
            [ class "btn btn-default pull-right"
            , type' "button"
            , value "Evaluate"
            , onClick extAddr GetScore
            ] []
         ]
      ] ++ if model.micRecording then [] else [
        div [ class "alert alert-danger" ]
         [ text """Please activate the microphone. Make sure it has no
             filters on it. On Firefox, set \"media.getusermedia.aec_enabled\"
             to false in about:config."""
         ]
      ])
   ]
