module Constants
  ( hopSize
  , frameDuration
  ) where

-- If this module suddenly needs to import something, check that its invocation
-- in ports.js does not have any pernicious side-effects

hopSize : Int
hopSize = 2048

frameDuration : Float
frameDuration = toFloat hopSize / 44100
