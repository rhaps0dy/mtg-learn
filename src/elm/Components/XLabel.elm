module Components.XLabel (Model, init, Action, update, view) where

{- This component shows the time scale in the x axis
-}

import Components.NumLabel as NL
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
lineLength = 7

line : Path
line = segment (0, topMostPosition) (0, topMostPosition - lineLength)

view' : List (String, String) -> Signal.Address Action -> Model -> (Int, Int) -> Html.Html
view' = NL.view line fst moveX

view : Signal.Address Action -> Model -> (Int, Int) -> Html.Html
view address model (width, height) =
  Html.div
   [ Html.style <| whStyle width height
   , Html.class "main-canvases"
   ]
   [ view' [ ("margin-top", toString (height - labelHeight) ++ "px")
           , ("position", "absolute")
           ]
       address model (width, labelHeight)
   ]