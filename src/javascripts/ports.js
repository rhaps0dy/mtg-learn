var elm_app = Elm.fullscreen(Elm.Main,
               { fullscreen: false
               , audioAnalysisLoading: true
               , micDescriptors: {pitch: 0, energy: 0}
               , micIsRecording: false
               });

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
    var options = {
      mandatory: {
        googEchoCancellation: false,
        googAutoGainControl: false,
        googNoiseSuppression: false,
        googHighpassFilter: false,
      },
      optional: []
    };
    function processAudio(){};
    navigator.mediaDevices.getUserMedia({audio: options}).then(function(stream) {
      // Prevent microphone from being garbage-collected
      window.microphone = context.createMediaStreamSource(stream);
      elm_app.ports.micIsRecording.send(true);
      var scriptNode = context.createScriptProcessor(4096, 1, 1);
      elm_app.ports.calculateMicDescriptors.subscribe(function(calcp) {
        if(calcp)
          scriptNode.onaudioprocess = processAudio;
        else
          scriptNode.onaudioprocess = function() {};
      });
    }, function(error) {
      alert("You need to accept sharing the microphone to use this application");
    });
  };
})(window, navigator, elm_app);
