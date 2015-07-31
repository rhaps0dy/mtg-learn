module ParseFiles
  ( Sheet
  , sheet
  , Descriptors
  , Buffer
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

type Buffer = Buffer

type alias Descriptors =
  { pitch : Buffer
  , energy : Buffer
  }

descriptors : DecodedAudioBuffer -> Task String Descriptors
descriptors = Native.ParseFiles.descriptors

print : a -> Task String ()
print = Native.ParseFiles.print

type DecodedAudioBuffer = DecodedAudioBuffer

decodeAudioFile : File -> Task String DecodedAudioBuffer
decodeAudioFile = Native.ParseFiles.decodeAudioFile