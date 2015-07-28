module ParseFiles
  ( Sheet
  , sheet
  , Descriptors
  , descriptors
  , print
  ) where

import Native.ParseFiles
import Components.Misc exposing (File, URL(URL))
import Task exposing (Task)

type alias Sheet = List ({pitch : Maybe Int, duration : Float})

sheet : File -> Task String Sheet
sheet = Native.ParseFiles.sheet


print : a -> Task String ()
print = Native.ParseFiles.print


type alias Descriptors =
  { pitch : List Float
  , energy : List Float
  }

descriptors : URL -> Task String Descriptors
descriptors _ = Task.fail "Not implemented"
