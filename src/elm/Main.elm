module Main (main) where

import Signal
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Lazy as Html
import Window
import Graphics.Collage
import Debug

import Components.Misc exposing (..)
import Components.SongSelecter as SongSelecter
import Components.PlayControls as PlayControls
import Components.ViewSelecter as ViewSelecter
import Components.YLabels as YLabels
import Components.XLabel as XLabel
import HtmlEvents exposing (disableContextMenu)

type Action
  = NoOp
  | ToggleTray
  | SongSelecter SongSelecter.Action
  | PlayControls PlayControls.Action
  | ViewSelecter ViewSelecter.Action
  | YLabels YLabels.Action
  | XLabel XLabel.Action

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
    _ -> m


view : Signal.Address Action -> Model -> (Int, Int) -> Html
view address model (w, h) =
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
     [ Html.lazy3 (XLabel.view (Signal.forwardTo address XLabel) model.xLabel)
         model.yLabels model.viewSelecter (w-YLabels.labelWidth, h)
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
        (yLabels::menuButton::(if model.fullscreen then [] else
          [span
           [ class "glyphicon glyphicon-fullscreen y-label-icon"
           -- Function defined in ports.js, fullscreen has to come from user-generated
           -- event.
           , attribute "onclick" "goFullscreen();"
           ] []]))
     ]

main : Signal Html
main = Signal.map2 (view actions.address) model Window.dimensions

model : Signal Model
model = Signal.foldp update init actions.signal

actions : Signal.Mailbox Action
actions = Signal.mailbox NoOp