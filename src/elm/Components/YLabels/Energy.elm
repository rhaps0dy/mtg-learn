module Components.YLabels.Energy (Model, init, Action, update, view) where

{- Component that shows the energy label -}

import Components.NumLabel as NL

import Graphics.Collage exposing (..)
import Color exposing (..)
import Html
import Html.Attributes as Html
import HtmlEvents exposing (..)
import Components.Misc exposing (whStyle)
import Signal

type alias Model = NL.Model

init : Model
init = NL.init

type alias Action = NL.Action

update : Action -> Model -> Model
update = NL.update (\x -> -(snd x))

line : Path
line = segment (13, 0) (20, 0)

view' : List (String, String) -> Signal.Address Action -> Model -> (Int, Int) -> Html.Html
view' = NL.view line snd moveY

view : Signal.Address Action -> Model -> Float -> Float -> Html.Html
view address model width height =
  Html.div
   [ Html.style <| whStyle width height ]
   [ view' [] address model (round width, round height) ]