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
       (Html, XLabel.Model -> Task String (List ()))
view address model (w, h) =
  let
    (xLabels, yLabels, task) =
      XLabel.view model.tray.viewSelecter (toFloat model.tray.playControls.bpm)
        (w, h)
    html =
      div
       [ class "fullscreen"
       , disableContextMenu ]
       [ xLabels
       , Html.lazy2 Tray.view trayAddress model.tray
       , div [ class "y-label" ]
          [ yLabels
          , Html.lazy2 Tray.viewToggleTrayButton trayAddress model.tray
          , Html.lazy2 Tray.viewFullscreenButton trayAddress model.tray
          ]
       ]
  in
    (html, task)

viewDrawTask : Signal (Html, XLabel.Model -> Task String (List ()))
viewDrawTask =
  view actions.address <~ Signal.dropRepeats model ~ Window.dimensions

port draw : Signal (Task String (List ()))
port draw = (\f x -> f x) <~ (snd <~ viewDrawTask) ~ XLabel.model

main : Signal Html
main = fst <~ viewDrawTask

model : Signal Model
model = Signal.foldp update init (Signal.mergeMany
                                  [ actions.signal
                                  , (Tray << Tray.SongSelecter <<
                                     SongSelecter.LoadingStatus) <~
                                       audioAnalysisLoading
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
