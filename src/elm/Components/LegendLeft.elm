module Components.LegendLeft (Model, init, Action(..), update, view) where

import Html exposing (fromElement, Html)
import Graphics.Collage exposing (..)
import Color exposing (..)

type alias Model =
  { vertPos : Int
  }

init : Model
init =
  { vertPos = 0
  }

type Action
  = NoOp

update : Action -> Model -> Model
update action model =
  case action of
    _ -> model

view : Signal.Address Action -> Model -> (Int, Int) -> Html
view address model (width, height) = fromElement <| collage width height <|
  [ filled orange <| rect 20 1000 ]