window.Elm.Native.PlotLine = {};
window.Elm.Native.PlotLine.make = function(localRuntime) {
  localRuntime.Native = localRuntime.Native || {};
  localRuntime.Native.PlotLine = localRuntime.Native.PlotLine || {};
  if(localRuntime.Native.PlotLine.values)
    return localRuntime.Native.PlotLine.values;

  var Task = Elm.Native.Task.make(localRuntime);
  var Utils = Elm.Native.Utils.make(localRuntime);
  var Color = Elm.Color.make(localRuntime);
  var flind = Elm.Components.Labels.NumLabel.make(localRuntime).firstLastIndices;

  // This function could be curried, and the part extracting color precalculated
  function plot(color) {
    var colorRGB = Color.toRgb(color);
    var color = 'rgba(' + colorRGB.red +
        ', ' + colorRGB.green +
        ', ' + colorRGB.blue +
        ', ' + colorRGB.alpha + ')';
  return function(id) {
    window.Elm.Native.PlotLine._cache = window.Elm.Native.PlotLine._cache || {};
    var cache = window.Elm.Native.PlotLine._cache[id] =
                  window.Elm.Native.PlotLine._cache[id] || {};
  return function(size) {
    var width = size._0;
    var height = size._1;
  return function(bpm) {
  return function(values) {
  return function(model) {
    var centerX = model.centerX;
    var centerY = model.centerY;
    var unitWidthX = model.unitWidthX;
    var unitWidthY = model.unitWidthY;
    if(cache.values === values &&
       cache.centerX === centerX &&
       cache.centerY === centerY &&
       cache.unitWidthX === unitWidthX &&
       cache.unitWidthY === unitWidthY &&
       cache.bpm === bpm)
    {
      return Task.asyncFunction(function(callback) {
        callback(Task.succeed(Utils.Tuple0));
      });
    }

    cache.values = values;
    cache.centerX = centerX;
    cache.centerY = centerY;
    cache.unitWidthX = unitWidthX;
    cache.unitWidthY = unitWidthY;
    cache.bpm = bpm;

    var sampleSeconds = 2048 / 44100;
    var beatSeconds = 60/4 / bpm;
    var sampleWidth = unitWidthX / beatSeconds * sampleSeconds;

    return Task.asyncFunction(function(callback) {
      var elem = document.getElementById(id);
      if(!elem) {
        return callback(Task.fail("element with id " + id + " not found"));
      }
      var ctx = elem.getContext('2d');
      var imData = ctx.createImageData(width, height);
      var imBuf = imData.data;
      var firstIndex = Math.floor(-centerX);
      var lastIndex = Math.ceil(-centerX + width / (sampleWidth / unitWidthX));
      var res = A3(flind, height, unitWidthY, centerY);
      var firstY = res._0;
      var lastY = res._1;
      var start = Math.max(firstIndex, 0);
      var end = Math.min(values.length, lastIndex);
      var prevY = null;
      ctx.clearRect(0, 0, width, height);
      ctx.strokeStyle = color;
      ctx.lineWidth = 5;
      ctx.lineCap = 'round';
      ctx.beginPath();
      for(var i=start; i < end; i++) {
        // plot the average of values within a pixel
        var y = height - ((values[i] + centerY) * unitWidthY)|0;
        var x = (i * sampleWidth + centerX * unitWidthX - unitWidthX / 4)|0;
        if(prevY !== null && y !== null) {
          ctx.moveTo(x-sampleWidth, prevY);
          ctx.lineTo(x, y);
        }
        prevY = y;
      }
      ctx.stroke();
      callback(Task.succeed(Utils.tuple0));
    });
  }}}}}}

  function areEquals(a, b) {
    if(typeof a === "object") {
      if(typeof b !== "object") {
        return false;
      } else {
        for(k in a)
          if(!b.hasOwnProperty(k))
            return false;
        for(k in b)
          if(!areEquals(a[k],b[k]))
            return false;
        return true;
      }
    } else {
      return a === b;
    }
  }


  return localRuntime.Native.PlotLine.values =
    { plotBuffer: plot
    };
};
