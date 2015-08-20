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
  var Constants = Elm.Constants.make(localRuntime);

  function calcSampleWidth(bpm, unitWidthX) {
    var beatSeconds = 60/2 / bpm; // Every beat in the sheet is an eighth note
    return unitWidthX / beatSeconds * Constants.frameDuration;
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
    var drawOnlyLast = false;
    cache.values = cache.values || {};
    if(!cache.lastFailed &&
       cache.centerX === centerX &&
       cache.centerY === centerY &&
       cache.unitWidthX === unitWidthX &&
       cache.unitWidthY === unitWidthY &&
       cache.bpm === bpm &&
       cache.width === width &&
       cache.height === height)
    {
      if(cache.values === values &&
         cache.values.length === values.length) {
        return Task.asyncFunction(function(callback) {
          callback(Task.succeed(Utils.Tuple0));
        });
      } else {
        drawOnlyLast = cache.values.length + 1 === values.length;
      }
    }

    cache.values = values;
    cache.centerX = centerX;
    cache.centerY = centerY;
    cache.unitWidthX = unitWidthX;
    cache.unitWidthY = unitWidthY;
    cache.bpm = bpm;
    cache.width = width;
    cache.height = height;

    var sampleWidth = calcSampleWidth(bpm, unitWidthX);

    return Task.asyncFunction(function(callback) {
      var elem = document.getElementById(id);
      if(!elem) {
        cache.lastFailed = true;
        return callback(Task.fail("element with id " + id + " not found"));
      } else {
        cache.lastFailed = false;
      }
//      console.log(cache.lastFailed);
      var ctx = elem.getContext('2d');
      var imData = ctx.createImageData(width, height);
      var imBuf = imData.data;
      var firstIndex = Math.floor(-centerX);
      var lastIndex = Math.ceil(-centerX + width / (sampleWidth / unitWidthX));
      var start, end;
      function draw(maxRec) {
        if(maxRec > 5) return;
        if(elem.width !== width || elem.height !== height) {
          // Canvas is going to be resized soon, we need to defer drawing
          setTimeout(function(){draw(maxRec+1);}, 5);
	  return;
        }
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
            var x = (i * sampleWidth + centerX * unitWidthX)|0;
            ctx.fillRect(x, y-2, sampleWidth, 4);
          }
        }
      }
      draw(0);
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

  function moveLine(id, width, bpm, time, xModel, moveXCenterIfNeeded, address) {
    return Task.asyncFunction(function(callback) {
      var sampleWidth = calcSampleWidth(bpm, xModel.unitWidthX);
      var x = xModel.centerX * xModel.unitWidthX + sampleWidth * time;

      if(moveXCenterIfNeeded && x > width) {
        // Only move back if time is changing and we are out of the screen
        var leftOffset = 320;
        var task = address._0((leftOffset - sampleWidth * time) / xModel.unitWidthX);
        Task.perform(task);
        x = leftOffset;
      }

      var elem = document.getElementById(id);
      if(elem) {
	if(x >= 0 && x < width) {
	  elem.style.display = 'block';
          elem.style.left = (x - 1) + "px";
	} else {
	  elem.style.display = 'none';
	}
        callback(Task.succeed(Utils.Tuple0));
      } else {
        callback(Task.fail("Element " + id + " does not exist"));
      }
    });
  }

  return localRuntime.Native.PlotLine.values =
    { plotBuffer: plot
    , moveLine: F7(moveLine)
    };
};
