module Components.YLabels.Energy  where

{- Component that shows the energy label -}


import Graphics.Collage exposing (..)
import Color exposing (..)
import Html
import Html.Attributes as Html
import HtmlEvents exposing (..)
import Components.Misc exposing (whStyle)
import Signal

line : Path
line = segment (20-4, 0) (20, 0)