module ParseFiles
  ( Sheet
  , sheet
  , sheetMailbox
  , Descriptors
  , Buffer
  , descriptors
  , descriptorMailbox
  , print
  , DecodedAudioBuffer
  , decodeAudioFile
  , descriptorMailbox
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

descriptorMailbox : Signal.Mailbox Descriptors
descriptorMailbox = Signal.mailbox {pitch = Buffer, energy = Buffer}

sheetMailbox : Signal.Mailbox Sheet
sheetMailbox = Signal.mailbox []

descriptors : DecodedAudioBuffer -> Task String Descriptors
descriptors = Native.ParseFiles.descriptors

print : a -> Task String ()
print = Native.ParseFiles.print

type DecodedAudioBuffer = DecodedAudioBuffer

decodeAudioFile : File -> Task String DecodedAudioBuffer
decodeAudioFile = Native.ParseFiles.decodeAudioFile