module Components.Colors
  ( HtmlColor
  , colorToHtml
  , sheet'
  , sheet
  , pitchExpert
  , pitchLive
  , energyExpert
  , energyLive
  ) where

import Color

type alias HtmlColor = String

colorToHtml : Color.Color -> HtmlColor
colorToHtml color =
  let
    c = Color.toRgb color
    r = toString c.red
    g = toString c.green
    b = toString c.blue
    a = toString c.alpha
  in
    "rgba("++r++","++g++","++b++","++a++")"

sheet' : Color.Color
sheet' = Color.red

sheet : String
sheet = colorToHtml sheet'

pitchExpert : String
pitchExpert = colorToHtml Color.lightGreen

pitchLive : String
pitchLive = colorToHtml Color.darkGreen

energyExpert : String
energyExpert = colorToHtml Color.lightBlue

energyLive : String
energyLive = colorToHtml Color.darkBlue