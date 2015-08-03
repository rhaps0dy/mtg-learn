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
          if(!areEquals(a[k],b[k]))
            return false;
        return true;
      }
    } else {
      return a === b;
    }
  }

  window.Elm.Native.TaskUtils._cache = window.Elm.Native.TaskUtils._cache || {};
  function formsToDrawTask(id, forms, checkCache) {
    return Task.asyncFunction(function(callback) {
      var cache = window.Elm.Native.TaskUtils._cache;
      var ctx;
      try {
        ctx = document.getElementById(id).getContext('2d');
      } catch (err) {
        var errmsg = "Unable to get 2d context for id " + id;
        console.error(errmsg);
        callback(Task.fail(errmsg));
        return;
      }
      if(areEquals(cache[id], checkCache)) {
        callback(Task.succeed(Utils.Tuple0));
      } else {
        cache[id] = checkCache;
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
    { formsToDrawTask: window.F3(formsToDrawTask)
    , combineTasks: severalTasks
    };
}
