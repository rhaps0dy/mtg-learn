Elm.Native.File = {};
Elm.Native.File.make = function(localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.File = localRuntime.Native.File || {};
    if(localRuntime.Native.File.values)
	return localRuntime.Native.File.values;

    var ElmJsonDecode = Elm.Json.Decode.make(localRuntime);
    var Task = Elm.Native.Task.make(localRuntime);

    function crash(expected, actual) {
        throw new Error(
            'expecting ' + expected + ' but got ' + JSON.stringify(actual)
        );
    }

    function fileDecoder(value) {
        if (value instanceof File)
            return value;
        crash('a File', value);
    }

    function fileListDecoder(value) {
        if (value.length !== undefined) {
            arr = [];
            for(var i = value.length - 1; i >= 0; i--)
                arr.push(value[i]);
            return A2(ElmJsonDecode.list, fileDecoder, arr);
        }
        crash('something with a "length" property', value);
    }
    
    function URLToFile(url) {
        return Task.asyncFunction(function(callback) {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", url);
            xhr.responseType = "blob";
            xhr.onload = function() {
                callback(Task.succeed(xhr.response));
            }
            xhr.send();
        });
    }

    function freeURL(url) {
        return Task.asyncFunction(function(callback) {
            URL.revokeObjectURL(url);
            callback(Task.succeed())
        });
    }

    return localRuntime.Native.File.values =
      { fileListDecoder: fileListDecoder
      , fileToURL: URL.createObjectURL
      , URLToFile: URLToFile
      , freeURL: freeURL
      };
};
