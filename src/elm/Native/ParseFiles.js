Elm.Native.ParseFiles = {};

(function(window) {
window.Elm.Native.ParseFiles.make = function(localRuntime) {
  localRuntime.Native = localRuntime.Native || {};
  localRuntime.Native.ParseFiles = localRuntime.Native.ParseFiles || {};
  if(localRuntime.Native.ParseFiles.values)
    return localRuntime.Native.ParseFiles.values;

  var Task = Elm.Native.Task.make(localRuntime);
  var List = Elm.Native.List.make(localRuntime);
  var Utils = Elm.Native.Utils.make(localRuntime);
  var Maybe = Elm.Maybe.make(localRuntime);

  function sheet(file) {
    return Task.asyncFunction(function(callback) {
      if(!file)
        callback(Task.fail("No file to parse"));

      var parseXml;
      if (typeof window.DOMParser !== "undefined") {
        var dp = window.DOMParser;
        parseXml = function(xmlStr) {
          return (new dp()).parseFromString(xmlStr, "text/xml");
        };
      } else if (typeof window.ActiveXObject !== "undefined" &&
          new window.ActiveXObject("Microsoft.XMLDOM")) {
        var wax = window.ActiveXObject
        parseXml = function(xmlStr) {
          var xmlDoc = new wax("Microsoft.XMLDOM");
          xmlDoc.async = "false";
          xmlDoc.loadXML(xmlStr);
          return xmlDoc;
        };
      } else {
        callback(Task.fail("No XML parser found"));
      }

      function first_child_with_tag(node, tag) {
        for(i in node.children) {
          if(node.children[i].tagName === tag)
            return node.children[i];
        }
        return null;
      }

      function a3Offset(name, octave) {
        var offsets = {
          "C": -9,
          "D": -7,
          "E": -5,
          "F": -4,
          "G": -2,
          "A": 0,
          "B": 2,
        };
        return offsets[name] + (octave - 3) * 12;
      }

      // Notes is an array we add notes to
      // note is an XML DOM node
      function parse_note(note, notes) {
        var duration = parseFloat(first_child_with_tag(note, "duration").textContent);
        if(first_child_with_tag(note, "rest")) {
          notes.push({pitch: Maybe.Nothing, duration: duration});
        } else {
          var p = first_child_with_tag(note, "pitch");
          var name = first_child_with_tag(p, "step").textContent;
          var octave = parseInt(first_child_with_tag(p, "octave").textContent);
          var pitch = a3Offset(name, octave);
          var alter = first_child_with_tag(note, "alter");
          if(alter)
            pitch += parseInt(alter.textContent);
          notes.push({pitch: Maybe.Just(pitch), duration: duration});
        }
      }

      var fr = new FileReader();
      fr.onloadend = function() {
        var score = parseXml(fr.result);
        
        var partWise = first_child_with_tag(score, "score-partwise");
        if(!partWise)
          callback(Task.fail("Could not parse MusicXML file. Only" +
                                " partwise format is supported"));

        var part = first_child_with_tag(partWise, "part");
        if(!part)
          callback(Task.fail("No part found in MusicXML file"));

        var notes = [];

        for(i in part.children) {
          var measure = part.children[i];
          if(measure.tagName !== "measure")
            continue;
          for(j in measure.children) {
            var note = measure.children[j];
            if(note.tagName !== "note")
              continue;
            parse_note(note, notes);
          }
        }
        callback(Task.succeed(List.fromArray(notes)));
      };
      fr.readAsText(file);
    });
  }

  function print(what) {
    return Task.asyncFunction(function(callback) {
      console.log(what);
      callback(Task.succeed(Utils.Tuple0));
    });
  }

  return localRuntime.Native.File.values =
    { sheet: sheet
    , print: print
    };
};
})(window);
