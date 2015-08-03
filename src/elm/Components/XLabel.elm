module Components.XLabel (Model, model, view) where

{- This component shows the time scale in the x axis
-}
import Components.Labels.Common as LC
import ParseFiles
import Signal exposing ((<~), (~))
import TaskUtils
import Task
import Components.Tray.ViewSelecter as VSel
import Components.Misc exposing (whStyle)
import Html
import Html.Attributes as Html
import Html.Events as Html
import HtmlEvents as HEv
import Debug

import Components.Labels.NumLabel as NumLabel
--import Components.Labels.PitchLabel as PitchLabel

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
  | XLabel LC.Action

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
    XLabel a ->
      { model | pitch <- LC.update a model.pitch
              , energy <- LC.update a model.energy }
    _ ->
      model

-- We do all this to broadcast the actions in the lower bar to all models
actionsPitch : Signal.Address LC.Action
actionsPitch = Signal.forwardTo actions.address Pitch

actionsEnergy : Signal.Address LC.Action
actionsEnergy = Signal.forwardTo actions.address Energy

actionsXLabel : Signal.Address LC.Action
actionsXLabel = Signal.forwardTo actions.address XLabel

actions : Signal.Mailbox Action
actions = Signal.mailbox NoOp

model : Signal Model
model =
  Signal.foldp update init actions.signal

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

canvas : Int -> Int -> List (String, String) -> Bool -> String ->
         Maybe (Signal.Address LC.Action) -> Html.Html
canvas width height styles isFirst id address =
  Html.div
   (Html.style (whStyle width height ++ styles ++
                (if isFirst then [] else
                  [("margin-top", toString (-height) ++ "px")]))::
   case address of
      Nothing -> []
      Just a ->
        [ HEv.onMouseMove a LC.MouseMove
        , HEv.onMouseDown a LC.MouseDown
        , HEv.onMouseUp a (\_ -> LC.MouseUp)
        , HEv.onMouseEnter a LC.MouseEnter
        , HEv.onMouseLeave a (\_ -> LC.MouseUp)
        ]) 
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
view : VSel.Model -> (Int, Int) -> (Html.Html, Html.Html, Model -> Task.Task String ())
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
               [ canvas' True "pitch-label" Nothing
               , canvas' False "pitch-pianoroll" Nothing
               , canvas' False "pitch-expert" Nothing
               , canvas' False "pitch-live" (Just actionsPitch)
               ] else []
        c2 = if vSelModel.energy then
               [ canvas' True "energy-label" Nothing
               , canvas' False "energy-expert" Nothing
               , canvas' False "energy-live" (Just actionsEnergy)
               ] else []
      in
        c1 ++ c2
    canvas'' = canvas yLabelWidth componentH [] True
    yLabels =
      let
        c1 = if vSelModel.pitch then [canvas'' "pitch-ylabel"
                                      (Just actionsPitch)] else []
        c2 = if vSelModel.energy then [canvas'' "energy-ylabel"
                                       (Just actionsEnergy)] else []
      in
        c1 ++ c2
    mainView =
      Html.div
       [ Html.style <| whStyle width height
       , Html.class "main-canvases"
       ]
       (canvas width xLabelH [("position", "absolute"), ("bottom", "0px")]
           True "horizontal-label" (Just actionsXLabel)::xLabels)
    trayView =
      Html.div
       [ Html.style <| ("position", "absolute")::whStyle yLabelWidth height
       ] (yLabels ++ [Html.div [ Html.class "black-axis-end" ] []])
    drawTask m = 
      TaskUtils.sequence
       [ NumLabel.bidimensional "energy-label" (width, componentH) m.energy
       ]
{-       [ PitchLabel.withoutNotes "pitch-label" size model.pitch
       , NumLabel.bidimensional "energy-label" size model.energy
       , PitchLabel.vertical "pitch-ylabel" size model.pitch
       , NumLabel.vertical "energy-ylabel" size model.energy
       , NumLabel.horizontal "horizontal-label" size model.pitch
       ] -}

  in
    (mainView, trayView, drawTask)