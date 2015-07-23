var elm_app = Elm.fullscreen(Elm.Main, {}) //{analysis: {pitch: 440}, roll: []});

(function(window, elm_app) {

    var parseXml;
    if (typeof window.DOMParser !== "undefined") {
        parseXml = function(xmlStr) {
            return (new window.DOMParser()).parseFromString(xmlStr, "text/xml");
        };
    } else if (typeof window.ActiveXObject !== "undefined" &&
           new window.ActiveXObject("Microsoft.XMLDOM")) {
        parseXml = function(xmlStr) {
            var xmlDoc = new window.ActiveXObject("Microsoft.XMLDOM");
            xmlDoc.async = "false";
            xmlDoc.loadXML(xmlStr);
            return xmlDoc;
        };
    } else {
        throw new Error("No XML parser found");
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
            notes.push({pitch: null, duration: duration});
        } else {
            var p = first_child_with_tag(note, "pitch");
            var name = first_child_with_tag(p, "step").textContent;
            var octave = parseInt(first_child_with_tag(p, "octave").textContent);
            var pitch = a3Offset(name, octave);
            var alter = first_child_with_tag(note, "alter");
            if(alter)
                pitch += parseInt(alter.textContent);
            notes.push({pitch: pitch, duration: duration});
        }
    }

    var callback = elm_app.ports.roll.send;

    window.parseScore = function(file) {
        if(!file) return;
        fr = new FileReader();
        fr.onloadend = function() {
            var score = parseXml(fr.result);
            
            var partWise = first_child_with_tag(score, "score-partwise");
            if(!partWise)
                throw new Exception("Could not parse MusicXML file. Only" +
                                    " partwise format is supported");


            var part = first_child_with_tag(partWise, "part");
            if(!part)
                throw new Exception("No part found in MusicXML file");

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
            callback(notes);
        };
        fr.readAsText(file);
    };

})(window, elm_app);

(function(window, navigator, Elm, Module, elm_app) {
    var context = new AudioContext();
    var analysis = elm_app.ports.analysis;

    navigator.mediaDevices.getUserMedia({audio: true}).then(function(stream) {
        // Prevent microphone from being garbage-collected
        window.microphone = context.createMediaStreamSource(stream);
        var scriptNode = context.createScriptProcessor(4096, 1, 1);
        microphone.connect(scriptNode);
        Module._init();

        var in_buf_idx = Module._in_buf_address() / 4;
        var out_buf_idx = Module._out_buf_address() / 4;
	var confidence_idx = Module._confidence_address() / 4;

	var prevPitch = 440;

        scriptNode.onaudioprocess = function(audioProcessingEvent) {
            var inputData = audioProcessingEvent.inputBuffer.getChannelData(0);
            Module.HEAPF32.set(inputData, in_buf_idx);
            Module._process();
	    if(Module.HEAPF32[confidence_idx] < 0.85)
		analysis.send({pitch: prevPitch});
	    else
		analysis.send({pitch: (prevPitch = Module.HEAPF32[out_buf_idx])});
        };
    }, function(error) {
        alert("You need to accept sharing the microphone to use this application.");
    });

})(window, navigator, Elm, Module, elm_app);
