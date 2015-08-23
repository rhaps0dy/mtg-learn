var elm_app = Elm.fullscreen(Elm.Main,
               { fullscreen: false
               , audioAnalysisLoading: true
               , micDescriptors: {pitch: NaN, energy: NaN}
               , micIsRecording: false
               });

// This may have pernicious side-effects if the Constants module imports something
var Constants = Elm.Constants.make({});

// defines a function that toggles fullscreen and signals the fullscreen state
// to the Elm runtime
(function(window, document, elm_app) {
  window.goFullscreen = function(state) {
    var i = document.body;
    if(state) {
      if (i.requestFullscreen) {
        i.requestFullscreen();
      } else if (i.webkitRequestFullscreen) {
        i.webkitRequestFullscreen();
      } else if (i.mozRequestFullScreen) {
        i.mozRequestFullScreen();
      } else if (i.msRequestFullscreen) {
        i.msRequestFullscreen();
      }
    } else {
      if (document.exitFullscreen) {
        document.exitFullscreen();
      } else if (document.webkitExitFullscreen) {
        document.webkitExitFullscreen();
      } else if (document.mozCancelFullScreen) {
        document.mozCancelFullScreen();
      } else if (document.msExitFullscreen) {
        document.msExitFullscreen();
      }
    }
  };

  function fsHandler() {
    if (document.fullscreenElement ||
      document.webkitFullscreenElement ||
      document.mozFullScreenElement ||
      document.msFullscreenElement) {
      elm_app.ports.fullscreen.send(true);
    } else {
      elm_app.ports.fullscreen.send(false);
    }
  }

  if('onfullscreenchange' in document) {
    document.addEventListener('fullscreenchange', fsHandler);
  } else if('onwebkitfullscreenchange' in document) {
    document.addEventListener('webkitfullscreenchange', fsHandler);
  } else if('onmozfullscreenchange' in document) {
    document.addEventListener('mozfullscreenchange', fsHandler);
  } else if('onMSFullscreenChange' in document) {
    document.addEventListener('MSFullscreenChange', fsHandler);
  } else {
    console.warn("No fullscreen support!");
  }
})(window, document, elm_app);

// Loads the audio analysis runtime and signals its completion to the Elm
// runtime and to the analyzer system
(function(window, document, elm_app) {
  var script = document.createElement('script');
  script.src = "audio_analysis.js";
  // Try to run main in intervals of 50ms
  // There is no event for after main has ran and we can use the Emscripten
  // runtime
  script.onload = function initEssentia() {
    try {
      window.Module._init();
      elm_app.ports.audioAnalysisLoading.send(false);
      window.startAnalyzer()
    } catch(err) {
      setTimeout(initEssentia, 50);
    }
  };
  document.body.appendChild(script);
})(window, document, elm_app);

(function(window, navigator, elm_app) {
  window.startAnalyzer = function() {
    var context = new AudioContext();

    var in_buf_idx = Module._in_buf_address(1) / 4;
    var pitch_idx = Module._out_buf_address(1) / 4;
    var energy_idx = pitch_idx + 1;

    var constraints = {
      audio: {
        optional: {
          googEchoCancellation: false,
          googAutoGainControl: false,
          googNoiseSuppression: false,
          googHighpassFilter: false,
        }
      }
    };
    var getUserMedia =
      navigator.webkitGetUserMedia || navigator.mozGetUserMedia;
    getUserMedia.call(navigator, {audio: true, costraints: constraints},
                      function(stream) {
      // Prevent microphone from being garbage-collected
      window.microphone = context.createMediaStreamSource(stream);
      elm_app.ports.micIsRecording.send(true);
      var scriptNode = context.createScriptProcessor(Constants.inputBufferSize, 1, 1);
      // script node connected to destination to work around bug in chrome/ium
      scriptNode.connect(context.destination);
      window.microphone.connect(scriptNode);
      elm_app.ports.calculateMicDescriptors.subscribe(function(calcp) {
        if(calcp) {
          scriptNode.onaudioprocess = function (audioProcessingEvent) {
            var inputData = audioProcessingEvent.inputBuffer.getChannelData(0);
            window.Module.HEAPF32.set(inputData, in_buf_idx);
            window.Module._process(1);
            var r = {
              pitch: Module.HEAPF32[pitch_idx],
              energy: Module.HEAPF32[energy_idx]
            };
            elm_app.ports.micDescriptors.send(r);
          };
        } else {
          scriptNode.onaudioprocess = function() {};
        }
      });
    }, function(error) {
      alert("You need to accept sharing the microphone to use this application");
    });
  };
})(window, navigator, elm_app);

// Metronome
// Based off of Chris Wilson's metronome https://github.com/cwilso/metronome
(function(document, elm_app) {
  var context = new AudioContext();
  var beepLength = (1/440) * 3;
  function strongBeat() {
    var osc = context.createOscillator();
    osc.connect(context.destination);
    osc.frequency.value = 880.0;
    return osc;
  }
  function weakBeat() {
    var osc = context.createOscillator();
    osc.connect(context.destination);
    osc.frequency.value = 440.0;
    return osc;
  }

  // We tick-tock in a separate thread for maximum setInterval accuracy
  var scheduler = new Worker('metronome_worker.js');
  scheduler.postMessage({cmd: 'options',
                         tickInterval: 0.05,
                        });
  var scheduleAhead = 0.2;
  var frameDuration = Constants.frameDuration;
  var bpm, beatDuration;
  elm_app.ports.bpm.subscribe(function(s) {
    bpm = s;
    beatDuration = 60.0 / bpm;
  });
  var frame = 0;
  elm_app.ports.sample.subscribe(function(s) {
    frame = s;
  });
  var beat, startTime;
  elm_app.ports.playMetronome.subscribe(function(s) {
    if(s) {
      var songTime = frame * frameDuration;
      beat = Math.floor(songTime / beatDuration);
      startTime = context.currentTime - songTime;
      scheduler.postMessage({cmd: 'start'});
    } else
      scheduler.postMessage({cmd: 'stop'});
  });

  scheduler.onmessage = function(e) {
    if(e.data === 'tick') {
      while(true) {
        var start = beat * beatDuration + startTime;
        if(start > context.currentTime + scheduleAhead)
          break;
        if(beat % 4 == 0)
          osc = strongBeat();
        else
          osc = weakBeat();
        osc.start(start);
        osc.stop(start + beepLength);
        beat++;
      }
    }
  };
})(document, elm_app);
