module Constants
  ( hopSize
  , frameDuration
  , inputBufferSize
  ) where

-- If this module suddenly needs to import something, check that its invocation
-- in ports.js does not have any pernicious side-effects

hopSize : Int
hopSize = 128

inputBufferSize : Int
inputBufferSize = 4096

frameDuration : Float
frameDuration = toFloat inputBufferSize / 44100
