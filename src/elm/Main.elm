module Main (main) where

import Signal
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Window
import Graphics.Collage
import Debug


import Components.Misc exposing (..)
import Components.SongSelecter as SongSelecter
import Components.PlayControls as PlayControls
import Components.ViewSelecter as ViewSelecter
import Components.YLabels as YLabels

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
  , yLabels : YLabels.Model
  }

init : Model
init =
  { trayClosed = False
  , fullscreen = False
  , songSelecter = SongSelecter.init
  , playControls = PlayControls.init
  , viewSelecter = ViewSelecter.init
  , yLabels = YLabels.init
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
    YLabels s -> { m | yLabels
                          <- YLabels.update s m.yLabels }
    _ -> m


view : Signal.Address Action -> Model -> (Int, Int) -> Html
view address model (w, h) =
  let
    -- Number 40 is from $yLabel-width in style.scss
    yLabels = YLabels.view (Signal.forwardTo address YLabels)
                   model.yLabels model.viewSelecter (40, h)
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
        (yLabels::menuButton::(if model.fullscreen then [] else
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
