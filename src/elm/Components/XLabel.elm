module Components.XLabel (Model, model, view, playControlsAddress) where

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
import Components.Colors as Colors
import ParseFiles
import Constants

import Components.Labels.NumLabel as NumLabel
import Components.Labels.PianoLabel as PianoLabel
import Components.Plots.PlotLine as PlotLine
import Components.Plots.PianoRoll as PianoRoll
import Components.Tray.PlayControls as PlayControls


type alias Model =
  { pitch : LC.YModel
  , energy : LC.YModel
  , xModel : LC.XModel
  , sheet : ParseFiles.Sheet
  , descriptors : ParseFiles.Descriptors
  , descriptorsLive : ParseFiles.Descriptors
  , score : Maybe ParseFiles.DescriptorsScore
-- We use Int and not Time.Time because we represent the time as the current
-- sample we are writing on.
  , time : Int
  , moveXCenterIfNeeded : Bool
  }

type Action
  = NoOp
  | Pitch LC.Action
  | Energy LC.Action
  | XLabel LC.Action
  | Sheet ParseFiles.Sheet
  | Descriptors ParseFiles.Descriptors
  | MicDescriptors ParseFiles.DescriptorsOne
  | SetXCenter Float
  | PlayControls PlayControls.ExternalAction

playControlsAddress : Signal.Address PlayControls.ExternalAction
playControlsAddress = Signal.forwardTo actions.address PlayControls

-- COMPILER BUG
lcyInit : LC.YModel
lcyInit = LC.yInit

lcxInit : LC.XModel
lcxInit = LC.xInit

init : Model
init =
  { pitch = LC.yInit
  , energy = { lcyInit
             | unitWidthY <- 300
             , centerY <- 0.3
             }
  , xModel = LC.xInit
  , sheet = ParseFiles.sheetInit
  , descriptors = ParseFiles.descriptorsInit
  , descriptorsLive = ParseFiles.descriptorsLiveInit
  , score = Nothing
-- Initial time is three seconds before the start of the song
  , time = ceiling <| -3 / Constants.frameDuration
  , moveXCenterIfNeeded = False
  }

update : Action -> Model -> Model
update action model =
  case action of
    Pitch a ->
      { model | pitch <- LC.yUpdate a model.pitch
              , xModel <- LC.xUpdate a model.xModel
              , moveXCenterIfNeeded <- False
              }
    Energy a ->
      { model | energy <- LC.yUpdate a model.energy
              , xModel <- LC.xUpdate a model.xModel
              , moveXCenterIfNeeded <- False
              }
    XLabel a ->
      { model | xModel <- LC.xUpdate a model.xModel
              , moveXCenterIfNeeded <- False
              }
    Descriptors d ->
      { model | descriptors <- d
              , moveXCenterIfNeeded <- False
              }
    Sheet s ->
      { model | sheet <- s
              , moveXCenterIfNeeded <- False
              }
    MicDescriptors d ->
      { model | descriptorsLive <-
                  ParseFiles.descriptorsAssign model.time d model.descriptorsLive
              , time <- model.time + 1
              , moveXCenterIfNeeded <- True
              }
    SetXCenter c ->
      let
        xModel = model.xModel
        xModel' = { xModel | centerX <- c }
      in
        { model | xModel <- xModel'
                }
    PlayControls pc ->
      case pc of
        PlayControls.JumpBeginning ->
          let
            xModel = model.xModel
            xModel' = { xModel | centerX <- lcxInit.centerX }
          in
            { model | time <- init.time, xModel <- xModel' }
        PlayControls.JumpEnd ->
          let
            descLen = ParseFiles.descriptorsLength model.descriptors
            lastTime =
              if descLen == 0 then
                ParseFiles.descriptorsLength model.descriptorsLive
              else
                descLen
          in
            { model | time <- lastTime
                    , moveXCenterIfNeeded <- True
                    }
        PlayControls.GetScore ->
          { model | score <- Just (ParseFiles.calculateScore
                               model.descriptors model.descriptorsLive) }
        _ ->
          model
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

sheetMailbox = ParseFiles.sheetMailbox

descriptorMailbox = ParseFiles.descriptorMailbox

micDescriptorsMailbox = ParseFiles.micDescriptorsMailbox

model : Signal Model
model =
  Signal.foldp update init <|
    Signal.mergeMany
     [ actions.signal
     , Sheet <~ sheetMailbox.signal
     , Descriptors <~ descriptorMailbox.signal
     , MicDescriptors <~ micDescriptorsMailbox.signal
     ]

-- yLabelWidth is from $yLabel-width in style.scss
yLabelWidth : Int
yLabelWidth = 40

xLabelHeightCanonical : Int
xLabelHeightCanonical = 25

headWithDefault : List (Int, Int) -> (Int, Int)
headWithDefault l =
  case (List.head l) of
    Nothing -> (0, 0)

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
        , HEv.onTouchStart a (\l -> LC.MouseDown (HEv.Right, headWithDefault l))
        , HEv.onTouchMove a (\l -> LC.MouseMove (headWithDefault l))
        , HEv.onTouchEnd a (\_ -> LC.MouseUp)
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
    componentH = if nComp /= 0 then height' / toFloat nComp else height'
  in
    (nComp, componentH)

-- | This view returns the needed Html and a function that given a Model returns a
-- rendering Task.
view : VSel.Model -> Float -> Int -> (Int, Int) ->
       (Html.Html, Html.Html, Model -> Task.Task String ())
view vSelModel bpm offset (width, height) =
  let
    adjHeight' = toFloat (height - xLabelHeightCanonical)
    (nComp, componentH') = getNCompAndHeight adjHeight' vSelModel
    componentH = floor componentH'
    yLabelH =
      if nComp /= 0 then componentH * nComp else height - xLabelHeightCanonical
    xLabelHeight =
      if nComp /= 0 then height - yLabelH else xLabelHeightCanonical
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
       ([canvas width xLabelHeight
         [ ("position", "absolute")
         , ("bottom", "0px")
         , ("overflow", "hidden")
         ] True "horizontal-label" (Just actionsXLabel)
-- Time cursor, moved by a draw task
       , Html.div
          [ Html.id "time-cursor"
          , Html.style <|
             [("position", "absolute")
             ,("background-color", "yellow")
             ,("top", "0px")
             ] ++ whStyle 2 height
          ] []
       ] ++ xLabels)
    trayView =
      Html.div
       [ Html.style <| ("position", "absolute")::whStyle yLabelWidth height
       ] (yLabels ++ [Html.div [ Html.class "black-axis-end" ] []])
    panelSize = (width, componentH)
    yLabelSize = (yLabelWidth, componentH)
    drawTask m =
      TaskUtils.sequence
       [ NumLabel.bidimensional "energy-label" panelSize m.xModel m.energy
       , PianoLabel.withoutNotes "pitch-label" panelSize m.xModel m.pitch
       , NumLabel.vertical "energy-ylabel" yLabelSize m.xModel m.energy
       , PianoLabel.withNotes "pitch-ylabel" yLabelSize m.xModel m.pitch
       , NumLabel.horizontal "horizontal-label" (width, xLabelHeight) m.xModel m.energy
       , PianoRoll.plot Colors.sheet' "pitch-pianoroll" panelSize
           m.sheet m.xModel m.pitch
       , PlotLine.plotBuffer Colors.pitchExpert "pitch-expert" panelSize bpm offset
           m.descriptors.pitch m.xModel m.pitch
       , PlotLine.plotBuffer Colors.energyExpert "energy-expert" panelSize bpm offset
           m.descriptors.energy m.xModel m.energy
       , PlotLine.moveLine "time-cursor" width bpm offset m.time m.xModel
           m.moveXCenterIfNeeded (Signal.forwardTo actions.address SetXCenter)
       , PlotLine.plotBuffer Colors.pitchLive "pitch-live" panelSize bpm offset
           m.descriptorsLive.pitch m.xModel m.pitch
       , PlotLine.plotBuffer Colors.energyLive "energy-live" panelSize bpm offset
           m.descriptorsLive.energy m.xModel m.energy
       , ParseFiles.showScore m.score
       ]
  in
    (mainView, trayView, drawTask)
