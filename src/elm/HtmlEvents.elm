module HtmlEvents
  ( onChange
  , onInput
  , onMouseMove
  , onMouseDown
  , onMouseUp
  , onMouseEnter
  , onMouseLeave
  , onTouchStart
  , onTouchMove
  , onTouchEnd
  , MouseButton(..)
  , MouseButtonSet
  , anyPressed
  , onChangeFile
  , disableContextMenu
  ) where

import Html exposing (Attribute)
import Html.Attributes as Html
import Html.Events as Events exposing (onClick, on, targetValue, targetChecked)
import Json.Decode as Decode exposing ((:=), string, Decoder, int, object2, list)
import Signal
import Debug
import File exposing (File)
import Bitwise

import Native.Touch
import Native.File

onX : String -> Signal.Address a -> (String -> a) -> Attribute
onX event address fun =
  on event targetValue (Signal.message address << fun)

onChange : Signal.Address a -> (String -> a) -> Attribute
onChange = onX "change"

onInput : Signal.Address a -> (String -> a) -> Attribute
onInput = onX "input"

mouseMoveDecoder : Decoder (Int, Int)
mouseMoveDecoder =
  object2 (,) ("layerX" := int) ("layerY" := int)

touchDecoder : Decoder (List (Int, Int))
touchDecoder = Native.Touch.touchDecoder

onMouseMove : Signal.Address a -> ((Int, Int) -> a) -> Attribute
onMouseMove address fun =
  on "mousemove" mouseMoveDecoder (Signal.message address << fun)

type MouseButton
  = Left
  | Middle
  | Right

numToButton : Int -> MouseButton
numToButton n =
  case n of
    0 -> Left
    1 -> Middle
    2 -> Right

mousePressDecoder : Decoder (MouseButton, (Int, Int))
mousePressDecoder = 
  object2 (,) (Decode.map numToButton ("button" := int)) mouseMoveDecoder

onMouseDown : Signal.Address a -> ((MouseButton, (Int, Int)) -> a) -> Attribute
onMouseDown address fun =
  on "mousedown" mousePressDecoder (Signal.message address << fun)

onMouseUp : Signal.Address a -> ((MouseButton, (Int, Int)) -> a) -> Attribute
onMouseUp address fun =
  on "mouseup" mousePressDecoder (Signal.message address << fun)


type alias MouseButtonSet = Int

anyPressed : MouseButtonSet -> Bool
anyPressed mbs = mbs /= 0

mousePressedDecoder : Decoder (MouseButtonSet, (Int, Int))
mousePressedDecoder = 
  object2 (,) ("buttons" := int) mouseMoveDecoder

onMouseEnter : Signal.Address a -> ((MouseButtonSet, (Int, Int)) -> a) -> Attribute
onMouseEnter address fun =
  on "mouseenter" mousePressedDecoder (Signal.message address << fun)

onMouseLeave : Signal.Address a -> ((MouseButtonSet, (Int, Int)) -> a) -> Attribute
onMouseLeave address fun =
  on "mouseleave" mousePressedDecoder (Signal.message address << fun)

onTouchStart : Signal.Address a -> ((List (Int, Int)) -> a) -> Attribute
onTouchStart address fun =
  on "touchstart" touchDecoder (Signal.message address << fun)

onTouchMove : Signal.Address a -> ((List (Int, Int)) -> a) -> Attribute
onTouchMove address fun =
  on "touchmove" touchDecoder (Signal.message address << fun)

onTouchEnd : Signal.Address a -> ((List (Int, Int)) -> a) -> Attribute
onTouchEnd address fun =
  on "touchend" touchDecoder (Signal.message address << fun)

fileListDecoder : Decoder (List File)
fileListDecoder = Native.File.fileListDecoder

onChangeFile : Signal.Address a -> (List File -> a) -> Attribute
onChangeFile address fun =
  on "change" ("target" := ("files" := fileListDecoder))
    (Signal.message address << fun)

disableContextMenu : Attribute
disableContextMenu = Html.attribute "oncontextmenu" "event.preventDefault();"
