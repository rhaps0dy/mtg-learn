module Input
    ( justWentDown
    , dragOffset
    , signal
    , Input
    ) where
   
import Signal
import Signal exposing ((<~), (~), Signal)
-- import Time
-- import Time exposing (Time)
import Maybe exposing (Maybe(Just, Nothing))
import Mouse
import Keyboard
import Window

type alias Input =
    {
    mouse : (Int, Int)
    , btnDown : Bool
    , prevBtnDown : Bool
    , mod : Bool
    , btnDownMouse : (Int, Int)
    , winDims : (Int, Int)
    , spaceDown : Bool
    , spacePressed : Bool
    }

justWentDown : Input -> Bool
justWentDown { btnDown, prevBtnDown } = btnDown && not prevBtnDown

dragOffset : Input -> Maybe (Int, Int)
dragOffset { mouse, btnDown, btnDownMouse } =
  case btnDown of
    False -> Nothing
    True -> Just (fst btnDownMouse - fst mouse, snd btnDownMouse - snd mouse)

inputFun : ((Int, Int), Bool, Bool, (Int, Int), Bool) -> Input -> Input
inputFun (mouse, btnDown, shiftDown, dims, spaceDown) i =
    { mouse = mouse
    , btnDown = btnDown
    , prevBtnDown = i.btnDown
    , mod = shiftDown
    , winDims = dims
    , btnDownMouse = if justWentDown i then mouse else i.btnDownMouse
    , spaceDown = spaceDown
    , spacePressed = spaceDown && not i.spaceDown
    }

signal : Signal Input
signal =
  let
    initInput = {
--      time = 0
                 mouse = (0, 0)
                , btnDown = False
                , prevBtnDown = False
                , mod = False
                , winDims = (0, 0)
                , btnDownMouse = (0, 0)
                , spaceDown = False
                , spacePressed = False
--                , btnDownTime = 0
                }
--    frameSignal = Time.fps fps
    combination = (\a b c d e -> (a,b,c,d,e))
        <~ Mouse.position ~ Mouse.isDown ~ Keyboard.shift ~ Window.dimensions ~ Keyboard.space
  in Signal.foldp inputFun initInput combination