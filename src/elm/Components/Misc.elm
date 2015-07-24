module Components.Misc
 ( controlPanel
 , labeledCheckbox
 , onChange
 , onInput
 , File
 , onChangeFile
 , URL(..)
 , fileToURL
 , urlToFile
 , freeURL
 ) where
                      
import Html exposing (..)
import Bootstrap.Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, on, targetValue, targetChecked)

import Json.Decode exposing ((:=), string, Decoder)
import Signal
import Task

import Native.File

controlPanel : List Html -> Html
controlPanel l =
  div [ class "control-panel" ]
   [ div [ class "clearfix" ] l
   ]

labeledCheckbox : String -> String -> Signal.Address a -> (Bool -> a) -> Bool -> Html
labeledCheckbox id' l address fun isChecked =
  div [ class "checkbox" ]
   [ label [ for id' ]
      [ input [ id id'
              , type' "checkbox"
              , checked isChecked
              , on "change" targetChecked (Signal.message address << fun)
              ] []
      , text l
      ]
   ]


onX : String -> Signal.Address a -> (String -> a) -> Attribute
onX event address fun =
  on event targetValue (Signal.message address << fun)

onChange : Signal.Address a -> (String -> a) -> Attribute
onChange = onX "change"

onInput : Signal.Address a -> (String -> a) -> Attribute
onInput = onX "input"

type File = File

fileListDecoder : Decoder (List File)
fileListDecoder = Native.File.fileListDecoder

onChangeFile : Signal.Address a -> (List File -> a) -> Attribute
onChangeFile address fun =
  on "change" ("target" := ("files" := fileListDecoder)) (Signal.message address << fun)

type URL = URL String

fileToURL : File -> URL
fileToURL f = URL (Native.File.fileToURL f)

urlToFile : URL -> Task.Task String File
urlToFile (URL s) = Native.File.URLToFile s

freeURL : URL -> Task.Task String ()
freeURL (URL s) = Native.File.freeURL s