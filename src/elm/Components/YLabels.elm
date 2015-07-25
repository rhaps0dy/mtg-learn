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
import Debug

import Components.ViewSelecter as VSel
import Components.YLabels.Pitch as Pitch
import Components.YLabels.Energy as Energy

type alias Model =
  { pitchYLabel : Pitch.Model
  }

init : Model
init =
  { pitchYLabel = Pitch.init
  }

type Action
  = NoOp

update : Action -> Model -> Model
update action model =
  case action of
    _ -> model

view : Signal.Address Action -> Model -> VSel.Model -> (Int, Int) -> Html.Html
view address model vSelModel (width, height) =
  let
    separatorH = 1
    width' = toFloat width
    height' = toFloat height
    -- Be careful: if one component overdraws its boundaries, it may
    -- overdraw another component. This error should be easily visible
    -- and fixed.
    components =
      let
        c1 = if vSelModel.pitch then [Pitch.view model.pitchYLabel width'] else []
        c2 = if vSelModel.energy then [Energy.view width'] else []
      in
        c1 ++ c2
    -- TODO: fix bug in compiler where the generated program would
    -- calculate nComp before components because there was a circular dependency
    nComp = List.length components
    componentH = (height' - separatorH * toFloat (nComp - 1)) / toFloat nComp
    resetY = height' / 2 - componentH / 2
    drawComp c i = (c componentH |> moveY (resetY - toFloat i * (1 + componentH)))
                 ::(if i /= nComp-1 then [rect width' 1 |> filled grey] else [])
  in
    Html.div
     [ Html.style [ ("width", toString width ++ "px")
                  , ("height", toString height ++ "px") ]
     , Html.class "y-label-canvas"
     ]
     [ Html.fromElement <| collage width height <|
         List.concat <| List.map2 drawComp components [0..nComp-1]
     ]
