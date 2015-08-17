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