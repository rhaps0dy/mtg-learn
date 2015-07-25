module Components.YLabels (Model, init, Action(..), update, view) where

{- This component is a canvas where all the labels are drawn. It
depends on the ViewSelecter component
-}

import Html
import Html.Attributes as Html
import Html.Events as Html
import Graphics.Collage exposing (..)
import Color exposing (..)
import Array exposing (Array)
import Signal

import Components.ViewSelecter as VSel
import Components.YLabels.Pitch as Pitch
import Components.YLabels.Energy as Energy

type alias Model =
  { pitch : Pitch.Model
  , energy : Energy.Model
  }

init : Model
init =
  { pitch = Pitch.init
  , energy = Energy.init
  }

type Action
  = NoOp
  | Pitch Pitch.Action
  | Energy Energy.Action

update : Action -> Model -> Model
update action model =
  case action of
    Pitch a -> { model | pitch <- Pitch.update a model.pitch }
    Energy a -> { model | energy <- Energy.update a model.energy }
    _ -> model

view : Signal.Address Action -> Model -> VSel.Model -> (Int, Int) -> Html.Html
view address model vSelModel (width, height) =
  let
    width' = toFloat width
    height' = toFloat height
    -- TODO: fix bug in compiler where the generated program would
    -- calculate nComp before components because there was a circular dependency
    nComp = (if vSelModel.pitch then 1 else 0) + (if vSelModel.energy then 1 else 0)
    componentH = height' / toFloat nComp
    components =
      let
        c1 = if vSelModel.pitch then [
               Pitch.view (Signal.forwardTo address Pitch)
                 model.pitch width' componentH
             ] else []
        c2 = if vSelModel.energy then [
               Energy.view (Signal.forwardTo address Energy)
                 model.energy width' componentH
             ] else []
      in
        c1 ++ c2
  in
    Html.div
     [ Html.style [ ("width", toString width ++ "px")
                  , ("height", toString height ++ "px") ]
     , Html.class "pos-absolute"
     ] components