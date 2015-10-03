2014

#Local Movie File Browser

<!--- tags: javascript nodejs angular qt -->

Local web server written in [NodeJs](http://nodejs.org/) (using Express). It scans configured local folders for movie files and fetch information about movies from the [TheMovieDb](https://www.themoviedb.org/). Results are shown as a web page in a web browser. Clicking on a movie image on the web page will play the movie locally (in the default player application).

![](r/nodejs-local-moviebrowser/nb.png)

To start the server run node bin/www from the project folder, and then browse to default web address http://localhost:3000/. There are two similar interfaces http://localhost:3000/ (using Jade and JQuery) and http://localhost:3000/app (using AngularJS).

Before starting the server you need to edit `model/configuration.js` file to specify what local folders to scan for movie files. Additionally, you need to set `TMDB_KEY` environment variable to your **own** [TheMovieDb](https://www.themoviedb.org/) API key. That key is needed to be able to query TheMovieDb.

Movie files are played using `xdg-open` (tested on Lubuntu Linux). Edit `model/configuration.js` to specify another command in other platforms.

**Update**: Given this is a test-bed project with already two different interfaces (Jade and AngularJS/Jade), I added also a third Qt QML interface to this demo:

![](r/nodejs-local-moviebrowser/qml.png)

The Qt sources are in the `qt` folder in the updated project. The QML code uses `XMLHttpRequest` to communicate with the local NodeJs server.
