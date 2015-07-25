module Components.Collage.PitchLegend (view) where

{- Component that shows the pitch label -}

import Graphics.Collage exposing (..)
import Color exposing (..)

view : Float -> Float -> Form
view width height =
 filled orange <| rect width height