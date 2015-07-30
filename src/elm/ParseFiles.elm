module ParseFiles
  ( Sheet
  , sheet
  , Descriptors
  , descriptors
  , print
  , Audio
  , fileToAudio
  ) where

import File exposing (..)
import Task exposing (Task)

import Native.ParseFiles

type alias Sheet = List ({pitch : Maybe Int, duration : Float})

sheet : File -> Task String Sheet
sheet = Native.ParseFiles.sheet

type alias Descriptors =
  { pitch : List Float
  , energy : List Float
  }

descriptors : Audio -> Task String Descriptors
descriptors = Native.ParseFiles.descriptors

print : a -> Task String ()
print = Native.ParseFiles.print

type Audio = Audio

fileToAudio : File -> Task String Audio
fileToAudio = Native.ParseFiles.fileToAudio