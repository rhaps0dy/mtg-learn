module ParseFiles
  ( Sheet
  , sheet
  , sheetMailbox
  , sheetInit
  , Descriptors
  , DescriptorsOne
  , descriptorsAssign
  , micDescriptorsMailbox
  , Buffer
  , descriptors
  , descriptorsInit
  , descriptorsLiveInit
  , descriptorMailbox
  , descriptorsLength
  , print
  , DecodedAudioBuffer
  , decodeAudioFile
  , descriptorMailbox
  , DescriptorsScore
  , calculateScore
  , showScore
  ) where

import File exposing (..)
import Task exposing (Task)

import Native.ParseFiles
-- so the native file can use Constants
import Constants

type alias Sheet = List ({pitch : Maybe Int, duration : Float})

sheet : File -> Task String Sheet
sheet = Native.ParseFiles.sheet

type Buffer = Buffer

type alias Descriptors =
  { pitch : Buffer
  , energy : Buffer
  }


type alias DescriptorsOne =
  { pitch : Float
  , energy : Float
  }

micDescriptorsMailbox : Signal.Mailbox DescriptorsOne
micDescriptorsMailbox = Signal.mailbox {pitch = 0, energy = 0}

descriptorMailbox : Signal.Mailbox Descriptors
descriptorMailbox = Signal.mailbox descriptorsInit

sheetMailbox : Signal.Mailbox Sheet
sheetMailbox = Signal.mailbox sheetInit

descriptors : DecodedAudioBuffer -> Task String Descriptors
descriptors = Native.ParseFiles.descriptors

print : a -> Task String ()
print = Native.ParseFiles.print

type DecodedAudioBuffer = DecodedAudioBuffer

decodeAudioFile : File -> Task String DecodedAudioBuffer
decodeAudioFile = Native.ParseFiles.decodeAudioFile

-- We want references to different arrays
descriptorsInit : Descriptors
descriptorsInit =
  { pitch = Native.ParseFiles.emptyBuffer ()
  , energy = Native.ParseFiles.emptyBuffer ()
  }

descriptorsLiveInit : Descriptors
descriptorsLiveInit =
  { pitch = Native.ParseFiles.emptyBuffer ()
  , energy = Native.ParseFiles.emptyBuffer ()
  }

sheetInit : Sheet
sheetInit = []

descriptorsAssign : Int -> DescriptorsOne -> Descriptors -> Descriptors
descriptorsAssign = Native.ParseFiles.descriptorsAssign

descriptorsLength : Descriptors -> Int
descriptorsLength = Native.ParseFiles.descriptorsLength

type alias DescriptorsScore =
  { pitch : Float
  , energy : Float
  , total : Float
  }

calculateScore : Descriptors -> Descriptors -> DescriptorsScore
calculateScore = Native.ParseFiles.calculateScore

showScore : Maybe DescriptorsScore -> Task x ()
showScore = Native.ParseFiles.showScore