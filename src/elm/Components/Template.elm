module Components.Template (Model, init, Action, update, view) where

import Html
import Signal

type alias Model =
  {
  }

init : Model
init =
  {
  }

type Action
  = NoOp

update : Action -> Model -> Model
update action model =
  case action of
    _ -> model

view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.div [] []