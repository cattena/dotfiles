------------------------------------------------------------------------
-- .xmonad.hs
------------------------------------------------------------------------
-- Author:
--  Alex Sánchez <kniren@gmail.com>
------------------------------------------------------------------------
-- Source:
--  https://github.com/kniren/dotfiles/blob/master/.xmonad/xmonad.hs
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Imports --¬
------------------------------------------------------------------------
import XMonad
import XMonad.Actions.CycleWS
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks (manageDocks, avoidStruts)
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Spacing
import XMonad.Layout.Gaps
import XMonad.Util.Run (spawnPipe, hPutStrLn)
import qualified Data.Map                 as M
import qualified GHC.IO.Handle.Types      as H
import qualified XMonad.Layout.Fullscreen as FS
import qualified XMonad.StackSet          as W
-- -¬
------------------------------------------------------------------------
-- Layout names and quick access keys --¬
------------------------------------------------------------------------
myWorkspaces :: [String]
myWorkspaces = clickable . map dzenEscape $ [ "                             "
                                            , "                            "
                                            , "                            "
                                            , "                            "
                                            , "                             "
                                            , "                            "
                                            , "                            "
                                            , "                            "
                                            , "                             "
                                            ]
    where clickable l = [ x ++ ws ++ "^ca()^ca()^ca()" |
                        (i,ws) <- zip "123qweasd" l,
                        let n = i
                            x =    "^ca(4,xdotool key super+Right)"
                                ++ "^ca(5,xdotool key super+Left)"
                                ++ "^ca(1,xdotool key super+" ++ show n ++ ")"]
-- -¬
------------------------------------------------------------------------
-- Key bindings --¬
------------------------------------------------------------------------
myKeys ::  XConfig l -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [
    -- Launch applications through dmenu
    ((modm,xK_r), spawn dmenuCall)
--      ((modm,xK_p), spawn "dmenu_run -i -fn '*-profont-*-*-*-*-12-*-*-*-*-*-*-*' -sb '#435d75' -nb '#000000' -h 20")
    -- Control mpd music through dmenu
    , ((modm,xK_p), spawn "/home/carlos/Scripts/dmpd")
    , ((modShift,xK_p), spawn "/home/carlos/Scripts/dmpd --control")
    -- Close focused window
    , ((modShift,xK_c), kill)
     -- Rotate through the available layout algorithms
    , ((modm,xK_space), sendMessage NextLayout)
     -- Move to workspace
    , ((modm,xK_Right), nextWS)
    , ((modm,xK_Left) , prevWS)
    -- Change Focused Windows
    , ((modm,xK_Tab), windows W.focusDown  )
    , ((modm,xK_j)  , windows W.focusDown  )
    , ((modm,xK_k)  , windows W.focusUp    )
    , ((modm,xK_m)  , windows W.focusMaster)
    -- Swap Focused Windows
    , ((modm,xK_Tab)       , windows W.focusDown )
    , ((modShift,xK_Return), windows W.swapMaster)
    , ((modShift,xK_j)     , windows W.swapDown  )
    , ((modShift,xK_k)     , windows W.swapUp    )
    -- Shrink and expand the master area
    , ((modm,xK_h), sendMessage Shrink)
    , ((modm,xK_l), sendMessage Expand)
    -- Push window back into tiling
    , ((modm,xK_t), withFocused $ windows . W.sink)
    -- Increment and decrement the number of windows in the master area
    , ((modm,xK_comma) , sendMessage (IncMasterN 1)   )
    , ((modm,xK_period), sendMessage (IncMasterN (-1)))
    -- Toggle fullscreen mode
    , ((modm,xK_f), sendMessage $ Toggle FULL)
    -- Application spawning
    , ((modm      , xK_Return) , spawn $ XMonad.terminal conf )
    , ((modm      , xK_i)      , spawn "dwb"                  )
    , ((modShift  , xK_i)      , spawn "chromium" )
    , ((modShift  , xK_n)      , spawn "pcmanfm"             )
    , ((modm      , xK_m)      , spawn "terminator -e ncmpcpp"     )
    , ((modShift  , xK_m)      , spawn "terminator -e mutt"        )
    , ((modShift  , xK_r)      , spawn "killall dzen2; xmonad --recompile; xmonad --restart")
    -- Alsa Multimedia Control
    , ((0, 0x1008ff11), spawn "/home/carlos/.xmonad/Scripts/volctl down"  )
    , ((0, 0x1008ff13), spawn "/home/carlos/.xmonad/Scripts/volctl up"    )
    , ((0, 0x1008ff12), spawn "/home/carlos/.xmonad/Scripts/volctl toggle")
    -- Brightness Control
    , ((0, 0x1008ff03), spawn "xbacklight -dec 10")
    , ((0, 0x1008ff02), spawn "xbacklight -inc 10")
    ]
    ++
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1,xK_2,xK_3,xK_q,xK_w,xK_e,xK_a,xK_s,xK_d]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_4, xK_5, xK_6] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    where modShift  = modm .|. shiftMask
          dmenuCall = "dmenu_run -i " -- -h 20 "  --'-h' no está disponible en la versión del repo.
                      ++ " -fn 'profont-8' "
                      ++ " -sb '" ++ colLook White 1 ++ "'"
                      ++ " -nb '#000000'"

-- -¬
------------------------------------------------------------------------
-- Mouse bindings --¬
------------------------------------------------------------------------
myMouseBindings :: XConfig t -> M.Map (KeyMask, Button) (Window -> X ())
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList
    [ ((modm, button1), \w -> focus w >> mouseMoveWindow w
                                      >> windows W.shiftMaster)
    , ((modm, button2), \w -> focus w >> windows W.shiftMaster)
    , ((modm, button3), \w -> focus w >> mouseResizeWindow w
                                      >> windows W.shiftMaster)
    ]
-- -¬
------------------------------------------------------------------------
-- Window rules --¬
------------------------------------------------------------------------
-- NOTE: To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
------------------------------------------------------------------------
myManageHook ::  ManageHook
myManageHook = manageDocks <+> composeAll
    [ className =? "MPlayer"             --> doFloat
    , className =? "MPlayer"             --> doShift (myWorkspaces !! 8)
    , className =? "xbmc.bin"            --> doShift (myWorkspaces !! 8)
    , className =? "Steam"               --> doShift (myWorkspaces !! 2)
    , className =? "Gimp"                --> doFloat
    , className =? "Vlc"                 --> doFloat
    , className =? "Gimp"                --> doShift (myWorkspaces !! 5)
    , title     =? "MATLAB R2013a"       --> doShift (myWorkspaces !! 5)
    , className =? "Nautilus"            --> doShift (myWorkspaces !! 3)
    , className =? "File-roller"         --> doShift (myWorkspaces !! 3)
    , className =? "Zathura"             --> doShift (myWorkspaces !! 4)
    , className =? "Chromium"            --> doShift (myWorkspaces !! 1)
    , className =? "Firefox"             --> doShift (myWorkspaces !! 1)
    , className =? "Google-chrome-stable"--> doShift (myWorkspaces !! 1)
    , className =? "Eclipse"             --> doShift (myWorkspaces !! 5)
    , className =? "Dwarf_Fortress"      --> doShift (myWorkspaces !! 2)
    , resource  =? "desktop_window"      --> doIgnore
    , resource  =? "kdesktop"            --> doIgnore
    , isFullscreen --> doFullFloat ]
-- -¬
------------------------------------------------------------------------
-- Status bars and logging --¬
------------------------------------------------------------------------

myLogHook ::  H.Handle -> X ()
myLogHook h = dynamicLogWithPP $ defaultPP
    {
        ppCurrent           =   dzenColor (colLook White 0)
                                          (colLook White   0) . pad
      , ppVisible           =   dzenColor (colLook Blue  0)
                                          (colLook Black 1) . pad
      , ppHidden            =   dzenColor (colLook Blue  0)
                                          (colLook Black  0) . pad
      , ppHiddenNoWindows   =   dzenColor (colLook BG    0)
                                          (colLook Black 1) . pad
      , ppUrgent            =   dzenColor (colLook Red   0)
                                          (colLook BG    0) . pad
      , ppWsSep             =   ""
      , ppSep               =   " | "
      , ppOrder             =   \(ws:_:_:_) -> [ws]
      , ppLayout            =   dzenColor (colLook Cyan 0) "#000000" .
            (\x -> case x of
                "Spacing 20 Tall"        -> clickInLayout ++ icon1
                "Tall"                   -> clickInLayout ++ icon2
                "Mirror Spacing 20 Tall" -> clickInLayout ++ icon3
                "Full"                   -> clickInLayout ++ icon4
                _                        -> x
            )
      , ppTitle             =   (" " ++) . dzenColor "white" "#000000" . dzenEscape
      , ppOutput            =   hPutStrLn h
    }
    where icon1 = "^i(/home/carlos/.xmonad/dzen/icons/stlarch/tile.xbm)^ca()"
          icon2 = "^i(/home/carlos/.xmonad/dzen/icons/stlarch/monocle.xbm)^ca()"
          icon3 = "^i(/home/carlos/.xmonad/dzen/icons/stlarch/bstack.xbm)^ca()"
          icon4 = "^i(/home/carlos/.xmonad/dzen/icons/stlarch/monocle2.xbm)^ca()"

clickInLayout :: String
clickInLayout = "^ca(1,xdotool key super+space)"
-- -¬
------------------------------------------------------------------------
-- Color definitions --¬
------------------------------------------------------------------------
type Hex = String
type ColorCode = (Hex,Hex)
type ColorMap = M.Map Colors ColorCode

data Colors = Black | Red | Green | Yellow | Blue | Magenta | Cyan | White | BG
    deriving (Ord,Show,Eq)

colLook :: Colors -> Int -> Hex
colLook color n =
    case M.lookup color colors of
        Nothing -> "#000000"
        Just (c1,c2) -> if n == 0
                        then c1
                        else c2

colors :: ColorMap
colors = M.fromList
    [ (Black   , ("#393939",
                  "#121212"))
    , (Red     , ("#c90c25",
                  "#F21835"))
    , (Green   , ("#2a5b6a",
                  "#2f4c6a"))
    , (Yellow  , ("#54777d",
                  "#415D62"))
    , (Blue    , ("#5c5dad",
                  "#5063ab"))
    , (Magenta , ("#6f4484",
                  "#915eaa"))
    , (Cyan    , ("#2B7694",
                  "#47959E"))
    , (White   , ("#D6D6D6",
                  "#A3A3A3"))
    , (BG      , ("#000000",
                  "#444444"))
    ]
-- -¬
------------------------------------------------------------------------
-- Run xmonad --¬
------------------------------------------------------------------------
main :: IO ()
main = do
    d <- spawnPipe callDzen1
    spawn callDzen2
    xmonad $ defaultConfig {
        terminal                  = "terminator",
        focusFollowsMouse         = True,
        borderWidth               = 4,
        modMask                   = mod4Mask,
        normalBorderColor         = colLook Black 1,
        focusedBorderColor        = colLook White 0,
        workspaces                = myWorkspaces,
        keys                      = myKeys,
        mouseBindings             = myMouseBindings,
        logHook                   = myLogHook d,
        layoutHook                = smartBorders myLayout,
        manageHook                = myManageHook,
        handleEventHook           = FS.fullscreenEventHook,
        startupHook               = setWMName "LG3D"
    }
    where callDzen1 = "dzen2 -ta l -fn '"
                      ++ dzenFont
                      ++ "' -bg '#000000' -y 0 -w 1366 -h 19 -e 'button3='"
          callDzen2 = "sleep 1 && conky | dzen2 -x 0 -y 2 -ta c -fn '"
                     ++ dzenFont
                     ++ "' -bg '#000000' -h 18 -e 'onnewinput=;button3='"
          dzenFont  = "profont-6"
          -- | Layouts --¬
          myLayout = mkToggle (NOBORDERS ?? FULL ?? EOT) $
              onWorkspace (myWorkspaces !! 1) webLayout   $
              onWorkspace (myWorkspaces !! 8) mediaLayout $
              standardLayout
              where
                  mediaLayout    = FS.fullscreenFull Full
                  standardLayout = avoidStruts $ tiled
                                   ||| focused
                                   ||| fullTiled
                  webLayout      = avoidStruts $ fullTiled
                                   ||| tiled
                                   ||| mirrorTiled
                  fullTiled      = Tall nmaster delta (1/4)
                  mirrorTiled    = Mirror . spacing 20 $ Tall nmaster delta ratio
                  focused        = gaps [(L,385), (R,385),(U,10),(D,10)]
                                   $ noBorders (FS.fullscreenFull Full)
                  tiled          = spacing 20 $ Tall nmaster delta ratio
                  -- The default number of windows in the master pane
                  nmaster = 1
                  -- Percent of screen to increment by when resizing panes
                  delta   = 5/100
                  -- Default proportion of screen occupied by master pane
                  ratio   = 1/2
          -- -¬
-- -¬
------------------------------------------------------------------------
