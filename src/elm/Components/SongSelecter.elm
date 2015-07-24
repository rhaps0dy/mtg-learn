module Components.SongSelecter (Model, init, Action, update, view) where

import Html as Html exposing (..)
import Bootstrap.Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (onClick)
import Signal
import Task
import Array
import String

import Components.Misc exposing (..)

type alias Model =
  { working : Bool
  , audioFile : Task.Task String URL
  , sheetFile : Task.Task String File
  }

init : Model
init =
  { working = False
  , audioFile = Task.fail "No audio file"
  , sheetFile = Task.fail "No sheet file"
  }

type Action
  = NoOp
  | WorkingStatus Bool
  | ChangeSongSelect String
  | ChangeAudio File
  | ChangeSheet File

update : Action -> Model -> Model
update a m =
  case a of
    WorkingStatus s -> { m | working <- s }
    ChangeSongSelect s ->
      case String.toInt s of
        Ok -1 -> m
        Ok i -> 
          case Array.get i songs of
            Just (u1, u2) -> { m | audioFile <- Task.succeed u1
                          , sheetFile <- urlToFile u2 }
            Nothing ->
              let failed = Task.fail "Index out of bounds"
              in  { m | audioFile <- failed, sheetFile <- failed }
        Err e ->
          { m | audioFile <- Task.fail e, sheetFile <- Task.fail e }

    ChangeAudio f -> { m | audioFile <- Task.succeed (fileToURL f) }
    ChangeSheet f -> { m | sheetFile <- Task.succeed f }
    _ -> m

view : Signal.Address Action -> Model -> Html
view address model =
  controlPanel <|
    if model.working then
      [ div [ class "text-centerer" ]
         [ p [] [ text "Working..." ]
         , Html.img [ src "images/working.gif" ] []
         ]
      ]
    else
      [ h4 [ id "song-select-label" ]
         [ text "Select song to practice" ]
      , formGroup_
         [ select
            [ class "form-control"
            , attribute "aria-describedby" "song-select-label"
            , onChange address ChangeSongSelect
            ]
            [ option [ value "-1" ] [ text "--choose a song--" ]
            , option [ value "0" ] [ text "Blue bossa" ]
            ]
         ]
      , p [] [ text "or" ]
      , h4 [] [ text "Use your own" ]
      , formGroup_
         [ label [ for "audio-upload" ] [ text "Audio file" ]
         , input
            [ type' "file"
            , accept "audio/*"
            , onChangeFile address <| listToAction ChangeAudio
            ] []
         ]
      , formGroup_
         [ label [ for "sheet-upload" ] [ text "Sheet music (.xml)" ]
         , input
            [ type' "file"
            , accept "text/xml"
            , onChangeFile address <| listToAction ChangeSheet
            ] []
         ]
      ]

listToAction : (a -> Action) -> List a -> Action
listToAction f l = case l of
                   (x::xs) -> f x
                   _ -> NoOp


songs : Array.Array (URL, URL)
songs = Array.fromList [ (URL "data/blueBossa.ogg", URL "data/blueBossa.xml") ]