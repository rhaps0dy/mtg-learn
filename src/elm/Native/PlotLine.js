window.Elm.Native.PlotLine = {};
window.Elm.Native.PlotLine.make = function(localRuntime) {
  localRuntime.Native = localRuntime.Native || {};
  localRuntime.Native.PlotLine = localRuntime.Native.PlotLine || {};
  if(localRuntime.Native.PlotLine.values)
    return localRuntime.Native.PlotLine.values;

  var Task = Elm.Native.Task.make(localRuntime);
  var Utils = Elm.Native.Utils.make(localRuntime);
  var Color = Elm.Color.make(localRuntime);
  var flind = Elm.Components.NumLabel.make(localRuntime).firstLastIndices;

  // This function could be curried, and the part extracting color precalculated
  function plot(color) {
    var colorRGB = Color.toRgb(color);
    var color = 'rgb(' + colorRGB.red/255 +
        ', ' + colorRGB.green/255 +
        ', ' + colorRGB.blue/255 +
        ', ' + colorRGB.alpha + ')';
  return function(id) {
  return function(values) {
  return function(centerX) {
  return function(centerY) {
  return function(unitWidthX) {
  return function(unitWidthY) {
  return function(width) {
  return function(height) {
    return Task.asyncFunction(function(callback) {
      var ctx = document.getElementById(id).getContext('2d');
      var imData = ctx.createImageData(width, height);
      var imBuf = imData.data;
      var res = A3(flind, width, unitWidthX, centerX);
      var firstIndex = res._0;
      var lastIndex = res._1;
      var res = A3(flind, height, unitWidthY, centerY);
      var firstY = res._0;
      var lastY = res._1;
      var start = Math.max(firstIndex, 0);
      var end = Math.min(values.length, lastIndex);
      var pixelSkip = (1/unitWidthX)|0 + 1; // ceiling
      ctx.fillStyle = color;
      for(var i=start; i < end; i += pixelSkip) {
        // plot the average of values within a pixel
        var avg = 0;
        var count = 0;
        for(var j=0; j<pixelSkip && i+j < end; j++) {
          var v = values[i+j]; 
          if(v !== null) {
            avg += v;
            count++;
          }
        }
        avg = ((avg / count + centerY) * unitWidthY)|0;
        console.log(avg);
        ctx.fillRect(((i-start)/pixelSkip)|0, -avg, 3, 3);
      }
      callback(Task.succeed(Utils.tuple0));
    });
  }}}}}}}}}

  return localRuntime.Native.PlotLine.values =
    { plotBuffer: plot
    };
};
