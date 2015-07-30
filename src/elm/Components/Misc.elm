module Components.Misc
 ( controlPanel
 , labeledCheckbox
 , whStyle
 ) where
                      
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, on, targetValue, targetChecked)

import Json.Decode exposing ((:=), string, Decoder, int, object2)
import Signal
import Task


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

whStyle : a -> a -> List (String, String)
whStyle w h = [("width", toString w ++ "px"), ("height", toString h ++ "px")]
