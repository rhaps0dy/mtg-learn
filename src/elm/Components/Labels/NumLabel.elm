module Components.Labels.NumLabel
  ( firstLastIndices
  , bidimensional
  , vertical
  , horizontal
  ) where

{- This component shows a numeric scale in either the X or the Y axis
-}

import Components.Labels.Common as LC
import Graphics.Collage as C exposing (defaultLine)
import Task
import TaskUtils
import Color
import Text

backgroundColor : Color.Color
backgroundColor = Color.black

foregroundColor : Color.Color
foregroundColor = Color.white


drawNum : C.Path -> Int -> C.Form
drawNum _ num =
  Text.fromString (toString num)
   |> Text.height 12
   |> Text.color foregroundColor
   |> C.text

drawLine : C.Path -> Int -> C.Form
drawLine p _ =
  C.traced { defaultLine | color <- foregroundColor } p

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
   
firstLastIndices : Float -> Float -> Float -> (Int, Int)
firstLastIndices width unitWidth center =
 let
   nLinesWidth = width / unitWidth
   firstLine = floor <| -center
   lastLine = ceiling <| -center + nLinesWidth
 in
   (firstLine, lastLine)

moveY : Float -> Float -> C.Form -> C.Form
moveY height offset form =
  C.moveY (height-offset) form

-- TODO: Reduce code duplication here
bidimensional : LC.ViewFun
bidimensional id (width', height') model =
  let
    width = toFloat width'
    height = toFloat height'
    lineX = C.segment (0, 0) (0, height)
    lineY = C.segment (0, 0) (width, 0)
    mvY = moveY height
    linesX = lines width model.unitWidthX model.centerX C.moveX lineX drawLine
    linesY = lines height model.unitWidthY model.centerY mvY lineY drawLine
  in
    TaskUtils.formsToDrawTask id (linesX ++ linesY) width' height'
      (model.unitWidthX, model.unitWidthY, model.centerX, model.centerY)

vertical : LC.ViewFun
vertical id (width', height') model =
  let
    width = toFloat width'
    height = toFloat height'
    r = C.rect width height
         |> C.filled backgroundColor
         |> C.move (width/2, height/2)
    lineY = C.segment (width-4, 0) (width, 0)
    mvY = moveY height
    linesY = lines height model.unitWidthY model.centerY mvY lineY drawLine
    numsY = lines height model.unitWidthY model.centerY mvY lineY
      (\a b -> C.moveX (width/2) (drawNum a b))
  in
    TaskUtils.formsToDrawTask id (r::(linesY ++ numsY)) width' height'
      (model.centerY, model.unitWidthY)

horizontal : LC.ViewFun
horizontal id (width', height') model =
  let
    width = toFloat width'
    height = toFloat height'
    lineX = C.segment (0, 0) (0, 4)
    linesX = lines width model.unitWidthX model.centerX C.moveX lineX drawLine
    numsX = lines width model.unitWidthX model.centerX C.moveX lineX
      (\a b -> C.moveY (height/2) (drawNum a b))
  in
    TaskUtils.formsToDrawTask id (linesX ++ numsX) width' height'
      (model.centerX, model.unitWidthX)
