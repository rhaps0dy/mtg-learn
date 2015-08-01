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

import Components.Misc exposing (..)
import Components.SongSelecter as SongSelecter
import Components.PlayControls as PlayControls
import Components.ViewSelecter as ViewSelecter
import Components.YLabels as YLabels
import Components.XLabel as XLabel
import HtmlEvents exposing (disableContextMenu)

import ParseFiles
import PlotLine

type Action
  = NoOp
  | ToggleTray
  | SongSelecter SongSelecter.Action
  | PlayControls PlayControls.Action
  | ViewSelecter ViewSelecter.Action
  | YLabels YLabels.Action
  | XLabel XLabel.Action
  | Fullscreen Bool
  | AudioAnalysisLoaded Bool

type alias Model =
  { trayClosed : Bool
  , fullscreen : Bool
  , songSelecter : SongSelecter.Model
  , playControls : PlayControls.Model
  , viewSelecter : ViewSelecter.Model
  , yLabels : YLabels.Model
  , xLabel : XLabel.Model
  }

init : Model
init =
  { trayClosed = False
  , fullscreen = False
  , songSelecter = SongSelecter.init
  , playControls = PlayControls.init
  , viewSelecter = ViewSelecter.init
  , yLabels = YLabels.init
  , xLabel = XLabel.init
  }

update : Action -> Model -> Model
update a m =
  case a of
    ToggleTray -> { m | trayClosed <- not m.trayClosed }
    SongSelecter s -> { m | songSelecter
                          <- SongSelecter.update s m.songSelecter }
    PlayControls c -> { m | playControls
                          <- PlayControls.update c m.playControls }
    ViewSelecter s -> { m | viewSelecter
                          <- ViewSelecter.update s m.viewSelecter }
    YLabels s -> { m | yLabels
                     <- YLabels.update s m.yLabels }
    XLabel s -> { m | xLabel
                    <- XLabel.update s m.xLabel }
    Fullscreen b -> { m | fullscreen <- b }
    _ -> m


view : Signal.Address Action -> Model -> (Int, Int) -> ParseFiles.Sheet -> Html
view address model (w, h) sheet =
  let
    yLabels = Html.lazy3 (YLabels.view (Signal.forwardTo address YLabels))
                   model.yLabels model.viewSelecter (YLabels.labelWidth, h)
    menuButton =
      span
       [ class "glyphicon glyphicon-menu-hamburger y-label-icon"
       , onClick address ToggleTray
       ] []
  in
    div
     [ class "fullscreen"
     , disableContextMenu ]
     [ XLabel.view (Signal.forwardTo address XLabel) model.xLabel
         model.yLabels model.viewSelecter (w-YLabels.labelWidth, h) sheet
     , div
        [ classList
           [ ("controls", True)
           , ("tray-closed", model.trayClosed)
           ]
        ]
        [ Html.lazy2 SongSelecter.view (Signal.forwardTo address SongSelecter) model.songSelecter
        , Html.lazy2 PlayControls.view (Signal.forwardTo address PlayControls) model.playControls
        , Html.lazy2 ViewSelecter.view (Signal.forwardTo address ViewSelecter) model.viewSelecter
        ]
     , div [ class "y-label" ]
        [ yLabels
        , menuButton
        , span
           [ class <| "glyphicon y-label-icon " ++
               if model.fullscreen then
                 "glyphicon-resize-small"
               else
                 "glyphicon-resize-full"
           -- Function defined in ports.js, fullscreen has to come from user-generated
           -- event.
           , attribute "onclick" <| if model.fullscreen then
                                      "goFullscreen(false);"
                                    else
                                      "goFullscreen(true);"
           ] []
        ]
     ]

main : Signal Html
main = Signal.map3 (view actions.address) (Signal.dropRepeats model)
         Window.dimensions sheet.signal

model : Signal Model
model = Signal.foldp update init (Signal.mergeMany
                                  [ actions.signal
                                  , Fullscreen <~ fullscreen
                                  , (SongSelecter <<
                                     SongSelecter.LoadingStatus) <~
                                       audioAnalysisLoading
                                  ])

actions : Signal.Mailbox Action
actions = Signal.mailbox NoOp

port fullscreen : Signal Bool

port audioAnalysisLoading : Signal Bool

sheet : Signal.Mailbox ParseFiles.Sheet
sheet = Signal.mailbox []

port sheetFiles : Signal (Task String ())
port sheetFiles =
  Signal.map (\t -> t `andThen` ParseFiles.sheet `andThen` Signal.send sheet.address)
   (Signal.dropRepeats (Signal.map (\m -> m.songSelecter.sheetFile) model))

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
     Signal.dropRepeats ((\m -> m.songSelecter.audioFile) <~ model)

port drawDescriptors : Signal (Task String ())
port drawDescriptors =
  (\d bpm cx cy uwx uwy (w,h) ->
   let
     xFactor = 44100 / 4096 * 60 / bpm
   in
     plotPitchAnalysis d.pitch (cx * xFactor) cy (uwx / xFactor) uwy w h) <~
      descriptorMailbox.signal ~
      Signal.dropRepeats ((\m -> toFloat m.playControls.bpm) <~ model) ~
      Signal.dropRepeats ((\m -> m.xLabel.center) <~ model) ~
      Signal.dropRepeats ((\m -> -m.yLabels.pitch.centerA3Offset) <~ model) ~
      Signal.dropRepeats ((\m -> m.xLabel.unitWidth) <~ model) ~
      Signal.dropRepeats ((\m -> m.yLabels.pitch.semitoneHeight) <~ model) ~
      Window.dimensions


port sendFullscreen : Signal (Task x ())
port sendFullscreen = Signal.send actions.address <~ Signal.map Fullscreen fullscreen
