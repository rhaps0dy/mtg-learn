module Components.Labels.PianoLabel
  ( withoutNotes
  , withNotes
  ) where

{- Component that shows the pitch label -}

import Graphics.Collage as C
import Components.Labels.Common as LC
import Components.Labels.NumLabel as NL
import TaskUtils
import Color
import Array
import Text
import Signal

foregroundColor : Color.Color
foregroundColor = Color.white

backgroundColor : Color.Color
backgroundColor = Color.black

noteNames : Array.Array String
noteNames = Array.fromList
    ["A", "Bb", "B", "C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab"]


centerToName : Int -> String
centerToName n =
  let
    (Just name) = Array.get (n%12) noteNames
    c4Offset = n - 3
    pitchIndex = (if c4Offset >= 0 then c4Offset else c4Offset - 11) // 12 + 4
  in
    toString pitchIndex ++ " " ++ name

whiteOffsets : Array.Array Bool
whiteOffsets = Array.fromList
  [True, False, True, True, False, True, False, True, True, False, True, False]

fgbgRectangles : Bool -> Int -> Int -> List Int
fgbgRectangles isForeground first last =
  List.filter (\i -> Array.get (i%12) whiteOffsets == Just isForeground) [first..last]

withoutNotes : LC.ViewFun
withoutNotes id (width', height') _ {centerY, unitWidthY} =
  let
    width = toFloat width'
    height = toFloat height'
    (lowestNote, highestNote) =
      NL.firstLastIndices height unitWidthY centerY
    fgRect =
      C.rect width unitWidthY
       |> C.filled foregroundColor
    -- We want the pitches to be centered on their rectangles, not at the bottom
    rectangles =
      List.map
        (\i -> C.move (width/2, height - (toFloat i + centerY) * unitWidthY)
          fgRect) (fgbgRectangles True lowestNote highestNote)
  in
    TaskUtils.formsToDrawTask id rectangles width' height'
      (centerY, unitWidthY)

note : Float -> Color.Color -> Int -> C.Form
note height color i =
  Text.fromString (centerToName i)
   |> Text.height (min 14 (height-4))
   |> Text.color color
   |> C.text

withNotes : LC.ViewFun
withNotes id (width', height') _ {centerY, unitWidthY} =
  let
    width = toFloat width'
    height = toFloat height'
    (lowestNote, highestNote) =
      NL.firstLastIndices height unitWidthY centerY
    noteFg = note unitWidthY backgroundColor
    notesFg =
      List.map
        (\i -> C.move (width/2, height - (toFloat i + centerY) * unitWidthY)
          (noteFg i)) (fgbgRectangles True lowestNote highestNote)
    noteBg = note unitWidthY foregroundColor
    notesBg =
      List.map
        (\i -> C.move (width/2, height - (toFloat i + centerY) * unitWidthY)
          (noteBg i)) (fgbgRectangles False lowestNote highestNote)
  in
    TaskUtils.formsToDrawTask id (notesFg ++ notesBg) width' height'
      (centerY, unitWidthY)