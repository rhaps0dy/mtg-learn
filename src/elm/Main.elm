module Main (main) where

import Signal exposing ((<~), (~))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Lazy as Html
import Window
import Graphics.Collage
import Color
import Debug
import Task exposing (Task, andThen)

import Components.Tray as Tray
import Components.Tray.PlayControls as PlayControls
import Components.Labels.Common as LabelsCommon
import Components.Labels.NumLabel
import Components.Tray.SongSelecter as SongSelecter
import Components.XLabel as XLabel
import HtmlEvents exposing (disableContextMenu)
import ParseFiles

type Action
  = NoOp
  | Tray Tray.Action
  | AudioAnalysisLoaded Bool

type alias Model =
  { tray : Tray.Model
  }

init : Model
init =
  { tray = Tray.init
  }

update : Action -> Model -> Model
update action model =
  case action of
    Tray a -> { model |
                tray <- Tray.update a model.tray }
    _ -> model



view : Signal.Address Action -> Model -> (Int, Int) ->
       (Html, XLabel.Model -> Task String ())
view address model (w, h) =
  let
    (xLabels, yLabels, task) =
      XLabel.view model.tray.viewSelecter (toFloat model.tray.playControls.bpm)
        model.tray.playControls.offset (w, h)
    html =
      div
       [ class "fullscreen"
       , disableContextMenu ]
       [ xLabels
       , Html.lazy3 Tray.view trayAddress XLabel.playControlsAddress model.tray
       , div [ class "y-label" ]
          [ yLabels
          , Html.lazy2 Tray.viewToggleTrayButton trayAddress model.tray
          , Html.lazy2 Tray.viewFullscreenButton trayAddress model.tray
          ]
       ]
  in
    (html, task)

viewDrawTask : Signal (Html, XLabel.Model -> Task String ())
viewDrawTask =
  view actions.address <~ Signal.dropRepeats model ~ Window.dimensions

port draw : Signal (Task String ())
port draw = (\f x -> f x) <~ (snd <~ viewDrawTask) ~ XLabel.model

main : Signal Html
main = fst <~ viewDrawTask

model : Signal Model
model = Signal.foldp update init (Signal.mergeMany
                                  [ actions.signal
                                  , (Tray << Tray.SongSelecter <<
                                     SongSelecter.LoadingStatus) <~
                                       audioAnalysisLoading
                                  , (Tray << Tray.PlayControls <<
                                     PlayControls.MicRecording) <~
                                       micIsRecording
                                  ])

actions : Signal.Mailbox Action
actions = Signal.mailbox NoOp

trayAddress : Signal.Address Tray.Action
trayAddress = Signal.forwardTo actions.address Tray

port audioAnalysisLoading : Signal Bool

sheet : Signal.Mailbox ParseFiles.Sheet
sheet = ParseFiles.sheetMailbox

port sheetFiles : Signal (Task String ())
port sheetFiles =
  Signal.map (\t -> t `andThen` ParseFiles.sheet `andThen` Signal.send sheet.address)
   (Signal.dropRepeats (Signal.map (\m -> m.tray.songSelecter.sheetFile) model))

-- COMPILER BUG: ParseFiles.descriptorMailbox.address cannot be found because
-- 'The qualifier `ParseFiles.descriptorMailbox` is not in scope.'
descriptorMailbox : Signal.Mailbox ParseFiles.Descriptors
descriptorMailbox = ParseFiles.descriptorMailbox

port descriptorsFiles : Signal (Task String ())
port descriptorsFiles =
  (\t -> t `andThen`
   ParseFiles.decodeAudioFile `andThen`
   ParseFiles.descriptors `andThen`
   Signal.send descriptorMailbox.address) <~
     Signal.dropRepeats ((\m -> m.tray.songSelecter.audioFile) <~ model)

-- Necessary port plumbing for Tray.viewFullscreenButton
port fullscreen : Signal Bool

port sendFullscreen : Signal (Task x ())
port sendFullscreen =
  Tray.updateFullscreen trayAddress fullscreen

-- Descriptors calculated from what the microphone listens to
port micDescriptors : Signal ParseFiles.DescriptorsOne

micDescriptorsMailbox : Signal.Mailbox ParseFiles.DescriptorsOne
micDescriptorsMailbox = ParseFiles.micDescriptorsMailbox

port notifyNewDescriptors : Signal (Task x ())
port notifyNewDescriptors =
       Signal.send micDescriptorsMailbox.address <~ micDescriptors

port micIsRecording : Signal Bool

port calculateMicDescriptors : Signal Bool
port calculateMicDescriptors = (\m -> m.tray.playControls.playing) <~ model

-- Play metronome when a beat is passed
port playMetronome : Signal Bool
port playMetronome =
  (\m -> m.tray.playControls.metronome && m.tray.playControls.playing) <~ model

port bpm : Signal Int
port bpm = (\m -> m.tray.playControls.bpm) <~ model

port sample : Signal Int
port sample = (.time) <~ XLabel.model