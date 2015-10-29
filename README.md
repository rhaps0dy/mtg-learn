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

##/Main.elm
This file sets the overall structure of the document and contains main. Also
contains the big Model of the Elm standard architecture. It defines the ports
for executing the Task.Tasks needed

##/Components/Tray.elm
Tray in the left side. Also defines view for the buttons that are on its
side. One manipulates whether the tray is open or closed. The other manipulates
fullscreen for the application. This second button deviates a bit from what
should be an Elm button as it manipulates the actual state of the world: it
activates and deactivates fullscreen and needs a port defined somewhere else or
it won't work. The reason for this is browsers blocking fullscreen requests
outside of direct event callbacks from user-initiated events.

##/Components/GenericLabel.elm
Functions and data structures common to all labels, such as the Actions and
Models.

##/Components/Template.elm
Not really part of the project, but has the boilerplate required to create a new
Component.

##/Components/Misc.elm
Miscellaneous component view functions to reuse in other components.
