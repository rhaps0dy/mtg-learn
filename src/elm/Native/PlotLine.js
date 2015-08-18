window.Elm.Native.PlotLine = {};
window.Elm.Native.PlotLine.make = function(localRuntime) {
  localRuntime.Native = localRuntime.Native || {};
  localRuntime.Native.PlotLine = localRuntime.Native.PlotLine || {};
  if(localRuntime.Native.PlotLine.values)
    return localRuntime.Native.PlotLine.values;

  var Task = Elm.Native.Task.make(localRuntime);
  var Utils = Elm.Native.Utils.make(localRuntime);
  var Color = Elm.Color.make(localRuntime);
  var Signal = Elm.Signal.make(localRuntime);
  var flind = Elm.Components.Labels.NumLabel.make(localRuntime).firstLastIndices;


  function calcSampleWidth(bpm, unitWidthX) {
    var sampleSeconds = 2048 / 44100;
    var beatSeconds = 60/2 / bpm; // Every beat in the sheet is an eighth note
    return unitWidthX / beatSeconds * sampleSeconds;
  }

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
  return function(xmodel) {
  return function(ymodel) {
    var centerX = xmodel.centerX;
    var centerY = ymodel.centerY;
    var unitWidthX = xmodel.unitWidthX;
    var unitWidthY = ymodel.unitWidthY;
    cache.values = cache.values || {};
    if(cache.values === values &&
       cache.values.length === values.length &&
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

    var drawOnlyLast = cache.values.length + 1 === values.length;

    cache.values = values;
    cache.centerX = centerX;
    cache.centerY = centerY;
    cache.unitWidthX = unitWidthX;
    cache.unitWidthY = unitWidthY;
    cache.bpm = bpm;

    var sampleWidth = calcSampleWidth(bpm, unitWidthX);

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
      var start, end;
      ctx.fillStyle = color;
      if(drawOnlyLast) {
        var ind = values.length - 1;
        if(ind >= firstIndex && ind < lastIndex) {
          start = ind;
          end = ind + 1;
        } else {
          // don't draw anything
          start = end = 0;
        }
      } else {
        start = Math.max(firstIndex, 0);
        end = Math.min(values.length, lastIndex);
        ctx.clearRect(0, 0, width, height);
      }
      for(var i=start; i < end; i++) {
        // plot the average of values within a pixel
        var value = values[i];
        if(!isNaN(value)) {
          var y = height - ((value + centerY) * unitWidthY)|0;
          var x = (i * sampleWidth + centerX * unitWidthX - unitWidthX / 4)|0;
          ctx.fillRect(x - sampleWidth, y-2, sampleWidth, 4);
        }
      }
      callback(Task.succeed(Utils.tuple0));
    });
  }}}}}}}

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

  function moveLine(id, width, bpm, time, xModel, address) {
    return Task.asyncFunction(function(callback) {
      var sampleWidth = calcSampleWidth(bpm, xModel.unitWidthX);
      var x = xModel.centerX * xModel.unitWidthX + sampleWidth * time;
      if(x > width) {
          var leftOffset = 70;
          var task = address._0((leftOffset - sampleWidth * time) / xModel.unitWidthX);
          Task.perform(task);
          x = leftOffset;
      }
      var elem = document.getElementById(id);
      if(elem) {
        elem.style.left = (x - 1) + "px";
        callback(Task.succeed(Utils.Tuple0));
      } else {
        console.error("Element " + id + " does not exist");
        callback(Task.fail("Element " + id + " does not exist"));
      }
    });
  }

  return localRuntime.Native.PlotLine.values =
    { plotBuffer: plot
    , moveLine: F6(moveLine)
    };
};
