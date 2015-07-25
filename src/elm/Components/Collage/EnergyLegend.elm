module Components.Collage.EnergyLegend (view) where

{- Component that shows the energy label -}

import Graphics.Collage exposing (..)
import Color exposing (..)

view : Float -> Float -> Form
view width height =
 filled blue <| rect width height