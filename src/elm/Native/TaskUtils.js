window.Elm.Native.TaskUtils = {};
window.Elm.Native.TaskUtils.make = function(localRuntime) {
  localRuntime.Native = localRuntime.Native || {};
  localRuntime.Native.TaskUtils = localRuntime.Native.TaskUtils || {};
  if(localRuntime.Native.TaskUtils.values)
    return localRuntime.Native.TaskUtils.values;

  var Collage = Elm.Native.Graphics.Collage.make(localRuntime);
  var Task = Elm.Native.Task.make(localRuntime);
  var Utils = Elm.Native.Utils.make(localRuntime);
  var List = Elm.Native.List.make(localRuntime);

  function areEquals(a, b) {
    if(typeof a === "object") {
      if(typeof b !== "object") {
        return false;
      } else {
        for(k in a)
          if(!b.hasOwnProperty(k))
            return false;
        for(k in b)
          // We do not want it to be recursive, comparing values at the top
          // property level is enough
          if(a[k] !== b[k])
            return false;
        return true;
      }
    } else {
      return a === b;
    }
  }

  window.Elm.Native.TaskUtils._cache = window.Elm.Native.TaskUtils._cache || {};
  function formsToDrawTask(id, forms, width, height, checkCache) {
    return Task.asyncFunction(function(callback) {
      var cache = window.Elm.Native.TaskUtils._cache;
      var elem = document.getElementById(id);
      if(!elem) {
        var errmsg = "Unable to get element with id " + id;
//        console.error(errmsg);
        callback(Task.fail(errmsg));
        return;
      }

      var ctx = elem.getContext('2d');
      function draw(maxRec) {
	if(maxRec > 5) return;
        if(elem.width !== width || elem.height !== height) {
          // Canvas is going to be resized soon, we need to defer drawing
          setTimeout(function(){draw(maxRec+1);}, 5);
	  return;
        }
        // We won't reach that screen size, right?
        ctx.clearRect(0, 0, 5000, 5000);
        var formStepper = Collage.formStepper(forms);
        while(formStepper.peekNext()) {
          var f = formStepper.next(ctx);
          if(!f) break;
          Collage.renderForm(function(){}, ctx, f);
        }
        callback(Task.succeed(Utils.Tuple0));
      }

      checkCache.width = width;
      checkCache.height = height;
      if(areEquals(cache[id], checkCache)) {
        callback(Task.succeed(Utils.Tuple0));
      } else {
        cache[id] = checkCache;
        draw(0);
      }
    });
  }

  function severalTasks(tasks) {
    return Task.asyncFunction(function(callback) {
      while(tasks.ctor == "::") {
        Task.perform(tasks._0);
        tasks = tasks._1;
      }
      callback(Utils.Tuple0);
    });
  }
  

  return localRuntime.Native.TaskUtils.values =
    { formsToDrawTask: window.F5(formsToDrawTask)
    , combineTasks: severalTasks
    };
}
