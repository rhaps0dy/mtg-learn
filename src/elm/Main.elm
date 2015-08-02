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
import Components.Tray.SongSelecter as SongSelecter
import Components.XLabel as XLabel
import HtmlEvents exposing (disableContextMenu)

import ParseFiles
import PlotLine

type Action
  = NoOp
  | YLabels YLabels.Action
  | XLabel XLabel.Action
  | Tray Tray.Action
  | AudioAnalysisLoaded Bool

type alias Model =
  { yLabels : YLabels.Model
  , xLabel : XLabel.Model
  , tray : Tray.Model
  }

init : Model
init =
  { yLabels = YLabels.init
  , xLabel = XLabel.init
  , tray = Tray.init
  }

update : Action -> Model -> Model
update action model =
  case action of
    YLabels a -> { model |
                   yLabels <- YLabels.update a model.yLabels }
    XLabel a -> { model |
                  xLabel <- XLabel.update a model.xLabel }
    Tray a -> { model |
                tray <- Tray.update a model.tray }
    _ -> model



view : Signal.Address Action -> Model -> (Int, Int) -> ParseFiles.Sheet -> Html
view address model (w, h) sheet =
  let
    (xLabels, yLabels) = Html.lazy3 XLabel.view model.tray.viewSelecter (w, h)
  in
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

main : Signal Html
main = Signal.map3 (view actions.address) (Signal.dropRepeats model)
         Window.dimensions sheet.signal

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
sheet = Signal.mailbox []

port sheetFiles : Signal (Task String ())
port sheetFiles =
  Signal.map (\t -> t `andThen` ParseFiles.sheet `andThen` Signal.send sheet.address)
   (Signal.dropRepeats (Signal.map (\m -> m.tray.songSelecter.sheetFile) model))

plotPitchAnalysis : ParseFiles.Buffer -> Float -> Float -> Float -> Float
                                      -> Int -> Int -> Task String ()
plotPitchAnalysis = PlotLine.plotBuffer Color.lightBlue "pitch-canvas"

bpm : Float
bpm = 120

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

port drawDescriptors : Signal (Task String ())
port drawDescriptors =
  (\d bpm cx cy uwx uwy (w,h) ->
   let
     xFactor = 44100 / 4096 * 60 / bpm
   in
     plotPitchAnalysis d.pitch (cx * xFactor) cy (uwx / xFactor) uwy w h) <~
      descriptorMailbox.signal ~
      Signal.dropRepeats ((\m -> toFloat m.tray.playControls.bpm) <~ model) ~
      Signal.dropRepeats ((\m -> m.xLabel.center) <~ model) ~
      Signal.dropRepeats ((\m -> -m.yLabels.pitch.centerA3Offset) <~ model) ~
      Signal.dropRepeats ((\m -> m.xLabel.unitWidth) <~ model) ~
      Signal.dropRepeats ((\m -> m.yLabels.pitch.semitoneHeight) <~ model) ~
-- This should be width and componentH in XLabel
      Window.dimensions

-- Necessary port plumbing for Tray.viewFullscreenButton
port fullscreen : Signal Bool

port sendFullscreen : Signal (Task x ())
port sendFullscreen =
  Tray.updateFullscreen trayAddress fullscreen
