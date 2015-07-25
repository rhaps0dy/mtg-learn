module Components.ViewSelecter (Model, init, Action, update, view) where

import Html as Html exposing (..)
import Bootstrap.Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (onClick)
import Signal
import String

import Components.Misc exposing (..)

type alias Model =
  { pitch : Bool
  , energy : Bool
  }

init : Model
init =
  { pitch = True
  , energy = True
  }

type Action
  = NoOp
  | Pitch Bool
  | Energy Bool

update : Action -> Model -> Model
update action model =
 case action of
   Pitch b -> { model | pitch <- b }
   Energy b -> { model | energy <- b }
   _ -> model

view : Signal.Address Action -> Model -> Html
view address model =
  div [ class "control-panel clearfix" ]
   [ div [ class "clearfix" ]
      [ label [] [ text "View" ]
      , labeledCheckbox "view-pitch" "Pitch" address Pitch model.pitch
      , labeledCheckbox "view-energy" "Energy" address Energy model.energy
      ]
   ]