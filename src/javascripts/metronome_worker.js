// Based off of Chris Wilson's metronome https://github.com/cwilso/metronome
var schedulerID = null;
var tickInterval;

function stopScheduler() {
  if(schedulerID)
    clearInterval(schedulerID);
  schedulerID = null;
}

function startScheduler() {
  if(!schedulerID) {
    postMessage('tick');
    schedulerID = setInterval(function() {
      postMessage('tick');
    }, tickInterval);
  }
}

self.onmessage = function(e) {
  if(e.data.cmd === 'options') {
    // convert seconds to milliseconds for setInterval
    tickInterval = e.data.tickInterval * 1000;
    if(schedulerID) {
      stopScheduler();
      startScheduler();
    }
  } else if(e.data.cmd === 'start') {
    startScheduler();
  } else if(e.data.cmd === 'stop') {
    stopScheduler();
  }
};
