module Components.Tray
  ( Model
  , init
  , Action(SongSelecter, PlayControls)
  , update
  , view
  , viewToggleTrayButton
  , viewFullscreenButton
  , updateFullscreen
  ) where

import Components.Tray.SongSelecter as SongSelecter
import Components.Tray.PlayControls as PlayControls
import Components.Tray.ViewSelecter as ViewSelecter

import Html
import Html.Attributes as Html
import Html.Events as Html
import Html.Lazy as Html
import Signal
import Task exposing (Task)

type alias Model =
  { trayClosed : Bool
  , fullscreen : Bool
  , songSelecter : SongSelecter.Model
  , playControls : PlayControls.Model
  , viewSelecter : ViewSelecter.Model
  }

init : Model
init =
  { trayClosed = False
  , fullscreen = False
  , songSelecter = SongSelecter.init
  , playControls = PlayControls.init
  , viewSelecter = ViewSelecter.init
  }

type Action
  = NoOp
  | ToggleTray
  | Fullscreen Bool
  | SongSelecter SongSelecter.Action
  | PlayControls PlayControls.Action
  | ViewSelecter ViewSelecter.Action

update : Action -> Model -> Model
update action m =
  case action of
    ToggleTray -> { m | trayClosed <- not m.trayClosed }
    Fullscreen b -> { m | fullscreen <- b }
    SongSelecter s -> { m | songSelecter
                          <- SongSelecter.update s m.songSelecter }
    PlayControls c -> { m | playControls
                          <- PlayControls.update c m.playControls }
    ViewSelecter s -> { m | viewSelecter
                          <- ViewSelecter.update s m.viewSelecter }
    _ -> m

view : Signal.Address Action -> Signal.Address PlayControls.ExternalAction
       -> Model -> Html.Html
view address extAddr model =
  Html.div
   [ Html.classList
      [ ("controls", True)
      , ("tray-closed", model.trayClosed)
      ]
   ]
   [ Html.lazy2 SongSelecter.view (Signal.forwardTo address SongSelecter)
       model.songSelecter
   , Html.lazy3 PlayControls.view (Signal.forwardTo address PlayControls)
       extAddr model.playControls
   , Html.lazy2 ViewSelecter.view (Signal.forwardTo address ViewSelecter)
       model.viewSelecter
   ]

viewToggleTrayButton : Signal.Address Action -> Model -> Html.Html
viewToggleTrayButton address _ =
  Html.span
   [ Html.class "glyphicon glyphicon-menu-hamburger y-label-icon"
   , Html.onClick address ToggleTray
   ] []

viewFullscreenButton : Signal.Address Action -> Model -> Html.Html
viewFullscreenButton address model =
  Html.span
   [ Html.class <| "glyphicon y-label-icon " ++
       if model.fullscreen then
         "glyphicon-resize-small"
       else
         "glyphicon-resize-full"
   -- Function defined in ports.js, fullscreen request to browser has to come
   -- from user-generated event.
   , Html.attribute "onclick" <| if model.fullscreen then
                              "goFullscreen(false);"
                            else
                              "goFullscreen(true);"
   ] []

-- The result of this, the address of the tray's model and a port named
-- "fullscreen" should be assigned to another port to be executed.
updateFullscreen : Signal.Address Action -> Signal Bool -> Signal (Task x ())
updateFullscreen address =
  Signal.map (Signal.send address << Fullscreen)