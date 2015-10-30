Elm.Native.Touch = {};
Elm.Native.Touch.make = function(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Touch = localRuntime.Native.Touch || {};
    if(localRuntime.Native.Touch.values)
    return localRuntime.Native.Touch.values;

    var List = Elm.Native.List.make(localRuntime);
	var Utils = Elm.Native.Utils.make(localRuntime);

    function touchDecoder(value) {
	  var list = List.Nil;
	  var t = value.touches;
	  var len = t.len;
	  var offsx = value.target.offsetLeft, offsy = value.target.offsetTop;
	  for(var i=len; i--; ) {
		list = List.cons(Utils.Tuple2(t[i].pageX - offsx, t[i].pageY - offsy), list);
	  }
	  console.log(list);
	  return list;
	}

    return localRuntime.Native.Touch.values =
      { touchDecoder: touchDecoder
      };
};
