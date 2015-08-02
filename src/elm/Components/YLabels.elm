module Components.YLabels
  (Model
  , init
  , Action(..)
  , update
  , labelWidth
  , getNCompAndHeight
  , view
  ) where

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

import Components.Tray.ViewSelecter as VSel
import Components.YLabels.Pitch as Pitch
import Components.YLabels.Energy as Energy
import Components.Misc exposing (whStyle)

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

-- labelWidth is from $yLabel-width in style.scss
labelWidth : Int
labelWidth = 40

view : Signal.Address Action -> Model -> VSel.Model -> (Int, Int) -> Html.Html
view address model vSelModel (width, height) =
  let
    width' = toFloat width
    height' = toFloat (height - 25)
    (nComp, componentH) = getNCompAndHeight height' vSelModel
    -- TODO: fix bug in compiler where the generated program would
    -- calculate nComp before components because there was a circular dependency
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
     [ Html.style <| whStyle width height
     , Html.class "pos-absolute"
     ] (components ++ [Html.div [ Html.class "black-axis-end" ] [ ] ])
