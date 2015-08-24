module Components.Tray.ViewSelecter (Model, init, Action, update, view) where

import Html as Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (onClick)
import Signal
import String

import Components.Misc exposing (labeledCheckbox, whStyle, nonBreakingSpace)
import Components.Colors as Colors

type alias Model =
  { pitch : Bool
  , energy : Bool
  }

init : Model
init =
  { pitch = True
  , energy = True
  }

type Action
  = NoOp
  | Pitch Bool
  | Energy Bool

update : Action -> Model -> Model
update action model =
 case action of
   Pitch b -> { model | pitch <- b }
   Energy b -> { model | energy <- b }
   _ -> model

colorBox : Colors.HtmlColor -> Html
colorBox col =
  div
   [ style
      ([("background-color", col)
-- the same margin the labeled checkboxes have
      , ("margin-top", "14px")
      , ("margin-right", "20px")
      , ("border", "1px solid black")
      ] ++ whStyle 15 15)
   , class "pull-left vertical-align-with-checkbox"
   ] []

label : Bool -> Colors.HtmlColor -> Colors.HtmlColor -> Html -> Html
label haveColor colorExpert colorLive checkBox =
  div [ class "row" ]
   [ div [ class "col-xs-4" ]
      [ checkBox ]
   , div [ class "col-xs-5" ]
      (if haveColor then
        [ colorBox colorExpert
        , colorBox colorLive
        ]
      else
       [ text nonBreakingSpace ])
   , div [ class "col-xs-3" ]
      [ p [ style [("margin-top", "10px")] ]
        [ text "-" ]
      ]
   ]


view : Signal.Address Action -> Model -> Html
view address model =
  div [ class "control-panel clearfix" ]
   [ div [ class "clearfix" ]
      [ div [ class "row" ]
         [ div [ class "col-xs-9" ]
            [ text nonBreakingSpace ]
         , div [ class "col-xs-3" ]
            [ p [ style [("margin-top", "10px")] ]
              [ text "Score" ]
            ]
         ]
      , label True Colors.pitchExpert Colors.pitchLive <|
          labeledCheckbox "view-pitch" "Pitch" address Pitch model.pitch
      , label True Colors.energyExpert Colors.energyLive <|
          labeledCheckbox "view-energy" "Energy" address Energy model.energy
      , label False "" "" <| p [style [("margin-top", "10px")]] [ text "Total" ]
      ]
   ]
