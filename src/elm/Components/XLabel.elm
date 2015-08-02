module Components.XLabel (Model, init, Action, update, view) where

{- This component shows the time scale in the x axis
-}
import Components.LabelCommon as LC
import ParseFiles
import Window
import Signal
import TaskUtils
import Task
import Components.Tray.ViewSelecter as VSel
import Components.Misc exposing (whStyle)
import Html
import Html.Attributes as Html
import Html.Events as Html

import Components.YLabels.Pitch exposing (viewNoNums)
import Graphics.Collage exposing (segment, Path, moveX)
import HtmlEvents exposing (..)

import Components.Plots.PianoRoll

type alias Model = 
  { pitch : LC.Model
  , energy : LC.Model
  , sheet : Maybe ParseFiles.Sheet
  , descriptors : Maybe ParseFiles.Descriptors
  , descriptorsLive : Maybe ParseFiles.Descriptors
  }

type Action
  = NoOp
  | Pitch LC.Action
  | Energy LC.Action
  | Resize (Int, Int)

init : Model
init =
  { pitch = LC.init
  , energy = LC.init
  , sheet = Nothing
  , descriptors = Nothing
  , descriptorsLive = Nothing
  }

update : Action -> Model -> Model
update action model =
  case action of
    Pitch a ->
      { model | pitch <- LC.update a model.pitch }
    Energy a ->
      { model | energy <- LC.update a model.energy }
    _ ->
      model

actions : Signal.Mailbox Action
actions = Signal.mailbox NoOp

-- Please assign this to a port in Main
{- tasks : Signal (Int, Int) -> Signal (Task () ())
tasks =
  let
    sendSizes size =
      TaskUtils.combineDiscard
       [ Signal.send actions.address (Pitch LC.Resize size)
       , Signal.send actions.address (Energy LC.Resize size)
       ]
  in
    Signal.map sendSizes -}
             
-- yLabelWidth is from $yLabel-width in style.scss
yLabelWidth : Int
yLabelWidth = 40

xLabelHeight : Int
xLabelHeight = 25

topMostPosition : Float
topMostPosition = toFloat xLabelHeight / 2

lineLength : Float
lineLength = 4

{- line : Path
line = segment (0, topMostPosition) (0, topMostPosition - lineLength)

view' : NL.ViewType
view' = NL.viewOneDim line fst moveX -}

canvas : Int -> Int -> List (String, String) -> Bool -> String -> Html.Html
canvas width height styles isFirst id =
  Html.div
   [ Html.style (whStyle width height ++ styles ++
                (if isFirst then [] else
                  [("margin-top", toString (-height) ++ "px")]))
   ]
   [ Html.canvas
     [ Html.id id
     
                        
     , Html.attribute "width" <| toString width
     , Html.attribute "height" <| toString height
     ] [ ]
   ]

getNCompAndHeight : Float -> VSel.Model -> (Int, Float)
getNCompAndHeight height' vSelModel =
  let
    nComp = (if vSelModel.pitch then 1 else 0) + (if vSelModel.energy then 1 else 0)
    componentH = height' / toFloat nComp
  in
    (nComp, componentH)

-- | This view returns the needed Html and a function that given a Model returns a
-- rendering Task.
view : VSel.Model -> (Int, Int) -> (Html.Html, Html.Html)
view vSelModel (windowWidth, height) =
  let
    width = windowWidth - yLabelWidth
    adjHeight' = toFloat (height - xLabelHeight)
    (nComp, componentH') = getNCompAndHeight adjHeight' vSelModel
    componentH = floor componentH'
    yLabelH = componentH * nComp
    xLabelH = height - yLabelH
    canvas' = canvas width componentH []
    xLabels =
      let
        c1 = if vSelModel.pitch then
               [ canvas' True "pitch-label"
               , canvas' False "pitch-pianoroll"
               , canvas' False "pitch-expert"
               , canvas' False "pitch-live"
               ] else []
        c2 = if vSelModel.energy then
               [ canvas' True "energy-label"
               , canvas' False "energy-expert"
               , canvas' False "energy-live"
               ] else []
      in
        c1 ++ c2
    canvas'' = canvas yLabelWidth componentH [] True
    yLabels =
      let
        c1 = if vSelModel.pitch then [canvas'' "pitch-ylabel"] else []
        c2 = if vSelModel.energy then [canvas'' "energy-ylabel"] else []
      in
        c1 ++ c2
    mainView =
      Html.div
       [ Html.style <| whStyle width height
       , Html.class "main-canvases"
       ]
       (canvas width xLabelH [("position", "absolute"), ("bottom", "0px")]
           True "horizontal-label"::xLabels)
    trayView =
      Html.div
       [ Html.style <| ("position", "absolute")::whStyle yLabelWidth height
       ] (yLabels ++ [Html.div [ Html.class "black-axis-end" ] []])
  in
    (mainView, trayView)

{-
, Model -> Task.Task () ())
    taskFun -> (\_ -> Task.succeed ())
-}