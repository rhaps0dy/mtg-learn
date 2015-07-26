var elm_app = Elm.fullscreen(Elm.Main, {});

(function(window, document, elm_app) {
    window.goFullscreen = function() {
        var i = document.body;
        if (i.requestFullscreen) {
            i.requestFullscreen();
        } else if (i.webkitRequestFullscreen) {
            i.webkitRequestFullscreen();
        } else if (i.mozRequestFullScreen) {
            i.mozRequestFullScreen();
        } else if (i.msRequestFullscreen) {
            i.msRequestFullscreen();
        }
    };
})(window, document, elm_app);
