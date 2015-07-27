module Components.XLabel (Model, init, Action, update, view) where

{- This component shows the time scale in the x axis
-}

import Components.NumLabel as NL
import Components.YLabels as YLs
import Components.ViewSelecter as VSel
import Graphics.Collage exposing (segment, Path, moveX)
import HtmlEvents exposing (..)
import Components.Misc exposing (whStyle)
import Html
import Html.Attributes as Html
import Html.Events as Html

type alias Model = NL.Model

init : Model
init = NL.init

type alias Action = NL.Action

update : Action -> Model -> Model
update = NL.update fst


labelHeight : Int
labelHeight = 25

topMostPosition : Float
topMostPosition = toFloat labelHeight / 2

lineLength : Float
lineLength = 4

line : Path
line = segment (0, topMostPosition) (0, topMostPosition - lineLength)

view' : NL.ViewType
view' = NL.viewOneDim line fst moveX

view : Signal.Address Action -> Model -> YLs.Model -> VSel.Model -> (Int, Int) -> Html.Html
view address model ylsModel vSelModel (width, height) =
  let
    width' = toFloat width
    height' = toFloat height
    labelHeight' = toFloat labelHeight
    adjHeight' = height' - labelHeight'
    (nComp, componentH) = YLs.getNCompAndHeight adjHeight' vSelModel
    panels =
      let
        c1 = if vSelModel.pitch then [
               NL.view
                 model.center model.unitWidth
                 -ylsModel.pitch.centerA3Offset ylsModel.pitch.semitoneHeight
                 width' componentH
             ] else []
        c2 = if vSelModel.energy then [
               NL.view
                 model.center model.unitWidth
                 ylsModel.energy.center ylsModel.energy.unitWidth
                 width' componentH
             ] else []
      in
        c1 ++ c2
  in
    Html.div
     [ Html.style <| whStyle width' height'
     , Html.class "main-canvases"
     ]
     [ view' address model (width', labelHeight')
     , Html.div
        [ Html.style <| whStyle width' adjHeight'
        ] panels
     ]