module Components.Labels.NumLabel
  ( firstLastIndices
  , bidimensional
--  , vertical
--  , horizontal
  ) where

{- This component shows a numeric scale in either the X or the Y axis
-}

import Components.Labels.LabelCommon as LC
import Graphics.Collage as C exposing (defaultLine)
import Task
import TaskUtils
import Color
import Text

backgroundColor : Color.Color
backgroundColor = Color.black

foregroundColor : Color.Color
foregroundColor = Color.white


drawLine : C.Path -> Int -> C.Form
drawLine line num =
  let
    line' = C.traced { defaultLine | color <- foregroundColor } line
    text' =
      Text.fromString (toString num)
       |> Text.height (min (14 - 2) 14)
       |> Text.color foregroundColor
       |> C.text
  in
    C.group [line', text']

lines : Float -> Float -> Float -> (Float -> C.Form -> C.Form) -> C.Path
      -> (C.Path -> Int -> C.Form) -> List C.Form
lines length unitWidth center move' line drawFun =
  let
    (firstLine, lastLine) = firstLastIndices length unitWidth center
    drawMove x = 
      drawFun line x
       |> move' ((center + toFloat x) * unitWidth)
  in
    List.map drawMove [firstLine..lastLine]
   
{- Careful: conventions for float being ' or no ' are reversed here

viewOneDim : Path -> ((Float, Float) -> Float) -> (Float -> Form -> Form)
             -> ViewType
viewOneDim line tfun move' address model (width, height) =
  let
    r = rect width height
         |> filled backgroundColor
    lines' = lines (tfun (width, height)) model.unitWidth
               model.center move' line drawLine
    width' = round width
    height' = round height
  in
    Html.div
     [ Html.style <| whStyle width' height'
     , onMouseMove address MouseMove
     , onMouseDown address MouseDown
     , onMouseUp address (\_ -> MouseUp)
     , Html.onMouseOut address MouseUp
     ]
     [ Html.fromElement <| collage width' height' (r::lines') ]


type alias PlotFun =
  Float -> Float -> Float -> Float -> Float -> Float -> List Form

view : PlotFun -> Float -> Float -> Float -> Float -> Float -> Float -> Html.Html
view plotFun centerX widthX centerY widthY width height =
  let
  in
    Html.div
     [ Html.style <| whStyle width height
     ]
     [ Html.fromElement <|
         collage width' height' (r::(linesX ++ linesY) ++ plot) ]
-}

firstLastIndices : Float -> Float -> Float -> (Int, Int)
firstLastIndices width unitWidth center =
 let
   nLinesWidth = width / unitWidth
   firstLine = floor <| -center
   lastLine = ceiling <| -center + nLinesWidth
 in
   (firstLine, lastLine)

bidimensional : String -> (Int, Int) -> LC.Model -> Task.Task String ()
bidimensional id (width', height') model =
  let
    width = toFloat width'
    height = toFloat height'
    r = C.rect width height
         |> C.filled backgroundColor
         |> C.move (width/2, height/2)
    lineX = C.segment (0, 0) (0, height)
    lineY = C.segment (0, 0) (width, 0)
    drawFun p _ = C.traced { defaultLine | color <- foregroundColor } p
    linesX = lines width model.unitWidthX model.centerX C.moveX lineX drawFun
    linesY = lines height model.unitWidthY model.centerY C.moveY lineY drawFun
  in
    TaskUtils.formsToDrawTask id (r::(linesX ++ linesY))
      (model.unitWidthX, model.unitWidthY, model.centerX, model.centerY)