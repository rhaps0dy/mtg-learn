module File
 ( File
 , URL(..)
 , urlToFile
 ) where

import Native.File
import Task

type File = File
type URL = URL String

urlToFile : URL -> Task.Task String File
urlToFile (URL s) = Native.File.URLToFile s