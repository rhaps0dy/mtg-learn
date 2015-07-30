module ParseFiles
  ( Sheet
  , sheet
  , Descriptors
  , descriptors
  , print
  , DecodedAudioBuffer
  , decodeAudioFile
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

descriptors : DecodedAudioBuffer -> Task String Descriptors
descriptors = Native.ParseFiles.descriptors

print : a -> Task String ()
print = Native.ParseFiles.print

type DecodedAudioBuffer = DecodedAudioBuffer

decodeAudioFile : File -> Task String DecodedAudioBuffer
decodeAudioFile = Native.ParseFiles.decodeAudioFile