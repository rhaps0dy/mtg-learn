Elm.Native.ParseFiles = {};

(function(window, document) {
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
        // gives duration in eighths, we want it in fourths
        var duration = parseFloat(first_child_with_tag(note, "duration").textContent) / 2;
        if(first_child_with_tag(note, "rest")) {
          notes.push({pitch: Maybe.Nothing, duration: duration});
        } else {
          var p = first_child_with_tag(note, "pitch");
          var name = first_child_with_tag(p, "step").textContent;
          var octave = parseInt(first_child_with_tag(p, "octave").textContent);
          var pitch = a3Offset(name, octave);
          var alter = first_child_with_tag(p, "alter");
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

  function getDefaultContext() {
    return (localRuntime.Native.ParseFiles.audioContext =
            localRuntime.Native.ParseFiles.audioContext || new window.AudioContext());
  }

  function decodeAudioFile(file) {
    return Task.asyncFunction(function(callback) {
      var ctx = getDefaultContext();
      var fr = new FileReader();
      fr.onloadend = function() {
        ctx.decodeAudioData(fr.result, function(decodedData) {
          var array = decodedData.getChannelData(0);
          callback(Task.succeed(array));
        });
      };
      fr.readAsArrayBuffer(file);
    });
  }

  function descriptors(buffer) {
    var IN_BUF_LEN = 2048;
    return Task.asyncFunction(function(callback) {
      var Module = window.Module;
      var in_buf_idx = Module._in_buf_address(0) / 4;
      var pitch_idx = Module._out_buf_address(0) / 4;
      var energy_idx = pitch_idx + 1;

      var pitches = [];
      var energies = [];
      for(var i=0; i<buffer.length; i+=IN_BUF_LEN) {
        Module.HEAPF32.set(buffer.subarray(i, i+IN_BUF_LEN), in_buf_idx);
        Module._process(0);
	pitches.push(Module.HEAPF32[pitch_idx]);
        energies.push(Module.HEAPF32[energy_idx]);
      }
      callback(Task.succeed(
        { pitch: pitches
        , energy: energies
        }));
    });
  }

  function assert(condition, message) {
    if(!condition)
      throw new Error(message || "Assertion failed");
  }

  var descNames = ["pitch", "energy"];
  function descriptorsAssign(idx, descriptorsOne, descriptors) {
    assert(idx >= 0);
    assert(idx < descriptors.pitch.length + 1);
    var newDesc = {};
    for(var i=0; i<descNames.length; i++) {
      // idx is the same as the array length
      var desc = descNames[i];
      // copy the array
      newDesc[desc] = descriptors[desc].slice();
      newDesc[desc].push(descriptorsOne[desc]);
    }
    return newDesc;
  }

  function descriptorsLength(d) {
    return d.pitch.length;
  }

  return localRuntime.Native.ParseFiles.values =
    { sheet: sheet
    , print: print
    , decodeAudioFile: decodeAudioFile
    , descriptors: descriptors
    , emptyBuffer: function(){return new Array();}
    , descriptorsAssign: window.F3(descriptorsAssign)
    , descriptorsLength: descriptorsLength
    };
};
})(window, document);
