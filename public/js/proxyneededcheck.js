// This check if the browser can't load pbs.twimg.com domain.
// If it can't then we force proxy on videos and pictures.
if (!document.cookie.includes("proxyPics") && !document.cookie.includes("proxyVideos")) {
    var time = Date.now();
    var img = new Image();
    img.onerror = function () {
        if ((Date.now() - time) < 100) {
            var expires = (new Date(Date.now() + 360 * 24 * 60 * 60 * 1000)).toUTCString();
            document.cookie = "proxyPics=on; path=/; expires=" + expires;
            document.cookie = "proxyVideos=on; path=/; expires=" + expires;
            location.reload();
        }
    };
    img.src = 'https://pbs.twimg.com/favicon.ico';
}