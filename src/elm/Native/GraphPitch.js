Elm.Native.GraphPitch = {};
Elm.Native.GraphPitch.make = function(elm) {
    elm.Native = elm.Native || {};
    elm.Native.GraphPitch = elm.Native.GraphPitch || {};
    if(elm.Native.GraphPitch.values)
	return elm.Native.GraphPitch.values;

    var $Maybe = Elm.Maybe.make(elm);

    var lines = [];
    
    return elm.Native.GraphPitch.values = {
        lookup: function (i) {
	    var l = lines[i];
	    if(l)
		return $Maybe.Just(l);
            return $Maybe.Nothing;
        },
	save: F2(function(i, line) {
	    lines[i] = line;
            return line;
	})
    };
    
};
