# mtg-learn
Learn to play music from an expert's performance. [Demo here](https://rhaps0dy.github.io/mtg-learn/)

# Installation

## Dependencies

  * [Emscripten](https://kripken.github.io/emscripten-site/)

  * [Essentia](https://github.com/MTG/essentia). Install it with Emscripten as
detailed in their [FAQ](https://github.com/MTG/essentia/blob/master/FAQ.md).

  * [Node.js](https://nodejs.org/) and its package manager. I recommend you get it
  from your distribution's package manager instead of from their page.

  * [Grunt](http://gruntjs.com/), which is installed through `npm` (Node Package
  Manager).

  * The [Elm Platform](http://elm-lang.org/install), which may be installed
  through `npm`.

## Compiling MTG-learn

Go to the base repository directory. Then run:

  * `npm install` to install the grunt module dependencies

  * `elm-package install` to install the Elm dependencies

  * `patch -p0 < package-patches/*` to patch some Elm packages that needed to be
    modified.

Finally, you can run the webpage using `grunt`. There are different tasks
defined in `Gruntfile.js`, but the important ones are the default one and
`prod`. The default one (ran by just typing `grunt`) will build a version
of MTG-learn without minification and set up a local server to let you
develop. `prod` will compile a version of MTG-learn ready to distribute to
users, available under the `dist` directory.

# Code structure explanation
This project is built with [Elm](http://elm-lang.org/). This seemed like a good
idea at first, but has proven wrong. The language's tooling is far from good,
and the language itself has some limitations that make it verbose. The
performance also needs to be better.

The most performance-intensive parts have been written in Javascript. Elm has a
"foreign function interface" that you can use by writing modules as if they had
been compiled. Such modules are under `src/elm/Native`. The other elm modules
are under `src/elm`. Other Javascript is under `src/javascripts`.

C++ code to be compiled with Emscripten can be found under `src/cpp`.

Pre-bundled songs are under `src/data`.

Images used in the application are under `src/images`.

[SCSS](http://sass-lang.com/) stylesheets using
[Compass](http://compass-style.org/) are under `src/stylesheets`.

Patches needed to the Elm core libraries to be able to reuse them to improve
performance are under `package-patches`.

Here follows an explanation of some of the Elm and Javascript source files.

##javascripts/ports.js

This file is named "ports" because it interacts with the [Elm Ports](). It
contains most javascript functionality that is not inside an Elm module. In this
file we:

  * Start the Elm app

  * Define a function to change fullscreen state of the app, and send the
    resulting state through an Elm port. The reverse (apply the output of a port
    to fullscreen state) would be desirable, but browsers restrict it

  * Load the audio analysis runtime

  * Enable the microphone and its interaction with Elm via ports
  
  * Enable the metronome scheduler and its interaction with Elm via ports

##javascripts/metronome_worker.js

This file contains a web worker that does the tick-tock to schedule the
metronome sounds to WebAudio. The tick-tock is in a separate thread to have the
setInterval be more accurate. In the end, the system the accuracy of which
matters is the WebAudio sound scheduling system. The main thread schedules the
audio upon event call from this second thread.

## File.elm, ParseFiles.elm, TaskUtils.elm,/Components/Plots/PlotLine.elm
Boilerplate for `Native/File.js`, `Native/ParseFiles.js`, `Native/TaskUtils.js`, `Native/PlotLine.js`.

## HtmlEvents.elm
Collection of different Html.Attributes that contain events not in the Elm Html
library. Also contains data types auxiliar to those events.

## Native/ParseFiles.js
Parses the score xml, and runs the sound file through the analyzer.

## Native/PlotLine.js
Draws the line graphs of pitch and sound intensity.

## Native/TaskUtils.js
Contains auxiliary functions to chain Elm tasks, and convert an Elm Form to a
drawing-to-canvas Task.

##Components/Colors.elm
Defined color constants for consistency in UI components.

##Components/Labels/Common.elm
State changes common to all labels, includinv vertical and horizontal.

##Components/Labels/NumLabel.elm
Vertical and horizontal labels with numbers and/or lines. In the application
as-is now they appear in the bottom. The label at the bottom of the page is an
horizontal NumLabel, and the label at the bottom part of the tray (in the left)
is a vertical one. In the bottom part of the application, where the intensity is
displayed, there is a vertical and horizontal NumLabel.

##Components/Labels/PianoLabel.elm
A vertical label with note names. It does not draw the underlying piano. Appears
at the top of the tray. There is also a version that only displays the
underlying piano.

##Components/Plots/PianoRoll.elm
Piano roll plot. The red rectangles you see once you load a sheet music.
##Main.elm
This file sets the overall structure of the document and contains main. Also
contains the big Model of the Elm standard architecture. It defines the ports
for executing the Task.Tasks needed

##Components/Tray/
Tray in the left side. Also defines view for the buttons that are on its
side. One manipulates whether the tray is open or closed. The other manipulates
fullscreen for the application. This second button deviates a bit from what
should be an Elm button as it manipulates the actual state of the world: it
activates and deactivates fullscreen and needs a port defined somewhere else or
it won't work. The reason for this is browsers blocking fullscreen requests
outside of direct event callbacks from user-initiated events.

##Components/Template.elm
Not really part of the project, but has the boilerplate required to create a new
Component.

##Components/Misc.elm
Miscellaneous component view functions to reuse in other components.

##Components/XLabel.elm
Component defining all of the plots and relationships between then.
