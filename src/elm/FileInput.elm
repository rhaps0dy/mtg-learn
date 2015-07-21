module FileInput (render) where

import Html exposing (..)
import Html.Attributes exposing (..)

leftMargin : Int
leftMargin = 20

topMargin : Int
topMargin = 5

px : Int -> String
px a = toString a ++ "px"

render : Int -> Int -> Int -> Html
render top width height =
  div
    [ class "widget"
    , style [ ("height", px height)
            , ("top", px top)
            , ("left", "0px")
            , ("background-color", "#bbb")
            , ("width", "100%")
            ]
    , hidden (height == 0)
    ]
    [
      label
        [ class "widget"
        , style [ ("left", px leftMargin)
                , ("top", px topMargin)
                ]
        , for "score-file"
        ]
        [
          text "Music score"
        ]
    , input
        [ class "widget"
        , id "score-file"
        , style [ ("left", px leftMargin)
                , ("top", px (topMargin + 20))
                ]
        , name "score"
        , type' "file"
        , accept "text/xml"
        , attribute "onChange" "window.parseScore(this.files[0]);"
        ]
        [
        ]
    ]
