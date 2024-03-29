module Constants
  ( hopSize
  , frameDuration
  , sampleRate
  , inputBufferSize
  ) where

-- If this module suddenly needs to import something, check that its invocation
-- in ports.js does not have any pernicious side-effects
-- Meaning: This module is executed _twice_: once by the Elm runtime, and once
-- by ports.js
-- The constants here are copied from audio_analysis.cpp

hopSize : Int
hopSize = 2048

inputBufferSize : Int
inputBufferSize = 4096

sampleRate : Float
sampleRate = 44100

frameDuration : Float
frameDuration = toFloat inputBufferSize / sampleRate
