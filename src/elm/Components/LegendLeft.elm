module Components.LegendLeft (Model, init, Action(..), update, view) where

{- This component is a canvas where all the labels are drawn. It
depends on the ViewSelecter component
-}

import Html exposing (fromElement, Html)
import Graphics.Collage exposing (..)
import Color exposing (..)
import Array exposing (Array)
import Debug

import Components.ViewSelecter as VSel
import Components.Collage.PitchLegend as PitchLegend
import Components.Collage.EnergyLegend as EnergyLegend

type alias Model =
  {
  }

init : VSel.Model -> Model
init vmod =
  {
  }

type Action
  = NoOp

update : Action -> Model -> Model
update action model =
  case action of
    _ -> model

view : Signal.Address Action -> Model -> VSel.Model -> (Int, Int) -> Html
view address model vSelModel (width, height) =
  let
    separatorH = 1
    width' = toFloat width
    height' = toFloat height
    components =
      let
        c1 = if vSelModel.pitch then [PitchLegend.view width'] else []
        c2 = if vSelModel.energy then [EnergyLegend.view width'] else []
      in
        c1 ++ c2
    -- TODO: fix bug in compiler where the generated program would
    -- calculate nComp before components because there was a circular dependency
    nComp = List.length components
    componentH = (height' - separatorH * toFloat (nComp - 1)) / toFloat nComp
    resetY = height' / 2 - componentH / 2
    drawComp c i = (c componentH |> moveY (resetY - toFloat i * (1 + componentH)))
                 ::(if i /= nComp-1 then [rect width' 3 |> filled grey] else [])
  in
    fromElement <| collage width height <|
      List.concat <| List.map2 drawComp components [0..nComp-1]