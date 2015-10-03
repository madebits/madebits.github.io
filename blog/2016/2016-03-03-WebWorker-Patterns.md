#WebWorker Connection Patterns

2016-03-03

<!--- tags: javascript architecture -->

[WebWorkers](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Using_web_workers) are a HTML5 JavaScript [API](https://html.spec.whatwg.org/multipage/workers.html) enabling multi-threaded client side code. Dedicated workers are created per page, whereas shared workers are shared across windows. Workers can be combined in different ways. Three representative communication patterns of communication between workers and the DOM window thread are shown next to help with getting started chaining web workers in custom topologies.

##Dedicated Workers Pool

A configurable pool of dedicated workers can be used to load balance data  processing. The pool of *dedicated* workers (DW) shown in this example are randomly load balanced to process data coming from the window (W).

<br>
<svg version="1.2" baseProfile="tiny" width="129.41mm" height="48.2mm" viewBox="4311 2688 12941 4820" preserveAspectRatio="xMidYMid" fill-rule="evenodd" stroke-width="28.222" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg" xmlns:ooo="http://xml.openoffice.org/svg/export" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:presentation="http://sun.com/xmlns/staroffice/presentation" xmlns:smil="http://www.w3.org/2001/SMIL20/" xmlns:anim="urn:oasis:names:tc:opendocument:xmlns:animation:1.0" xml:space="preserve">
 <defs class="ClipPathGroup">
  <clipPath id="presentation_clip_path" clipPathUnits="userSpaceOnUse">
   <rect x="4311" y="2688" width="12941" height="4820"/>
  </clipPath>
 </defs>
 <defs>
  <font id="EmbeddedFont_1" horiz-adv-x="2048">
   <font-face font-family="Liberation Sans embedded" units-per-em="2048" font-weight="normal" font-style="normal" ascent="1852" descent="450"/>
   <missing-glyph horiz-adv-x="2048" d="M 0,0 L 2047,0 2047,2047 0,2047 0,0 Z"/>
   <glyph unicode="W" horiz-adv-x="1932" d="M 1511,0 L 1283,0 1039,895 C 1032,920 1024,950 1016,985 1007,1020 1000,1053 993,1084 985,1121 977,1158 969,1196 960,1157 952,1120 944,1083 937,1051 929,1018 921,984 913,950 905,920 898,895 L 652,0 424,0 9,1409 208,1409 461,514 C 472,472 483,430 494,389 504,348 513,311 520,278 529,239 537,203 544,168 554,214 564,259 575,304 580,323 584,342 589,363 594,384 599,404 604,424 609,444 614,463 619,482 624,500 628,517 632,532 L 877,1409 1060,1409 1305,532 C 1309,517 1314,500 1319,482 1324,463 1329,444 1334,425 1339,405 1343,385 1348,364 1353,343 1357,324 1362,305 1373,260 1383,215 1393,168 1394,168 1397,180 1402,203 1407,226 1414,254 1422,289 1430,324 1439,361 1449,402 1458,442 1468,479 1478,514 L 1727,1409 1926,1409 1511,0 Z"/>
   <glyph unicode="D" horiz-adv-x="1218" d="M 1381,719 C 1381,602 1363,498 1328,409 1293,319 1244,244 1183,184 1122,123 1049,78 966,47 882,16 792,0 695,0 L 168,0 168,1409 634,1409 C 743,1409 843,1396 935,1369 1026,1342 1105,1300 1171,1244 1237,1187 1289,1116 1326,1029 1363,942 1381,839 1381,719 Z M 1189,719 C 1189,814 1175,896 1148,964 1121,1031 1082,1087 1033,1130 984,1173 925,1205 856,1226 787,1246 712,1256 630,1256 L 359,1256 359,153 673,153 C 747,153 816,165 879,189 942,213 996,249 1042,296 1088,343 1124,402 1150,473 1176,544 1189,626 1189,719 Z"/>
  </font>
 </defs>
 <defs class="TextShapeIndex">
  <g ooo:slide="id1" ooo:id-list="id3 id4 id5 id6 id7 id8 id9"/>
 </defs>
 <defs class="EmbeddedBulletChars">
  <g id="bullet-char-template(57356)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 580,1141 L 1163,571 580,0 -4,571 580,1141 Z"/>
  </g>
  <g id="bullet-char-template(57354)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 8,1128 L 1137,1128 1137,0 8,0 8,1128 Z"/>
  </g>
  <g id="bullet-char-template(10146)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 174,0 L 602,739 174,1481 1456,739 174,0 Z M 1358,739 L 309,1346 659,739 1358,739 Z"/>
  </g>
  <g id="bullet-char-template(10132)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 2015,739 L 1276,0 717,0 1260,543 174,543 174,936 1260,936 717,1481 1274,1481 2015,739 Z"/>
  </g>
  <g id="bullet-char-template(10007)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 0,-2 C -7,14 -16,27 -25,37 L 356,567 C 262,823 215,952 215,954 215,979 228,992 255,992 264,992 276,990 289,987 310,991 331,999 354,1012 L 381,999 492,748 772,1049 836,1024 860,1049 C 881,1039 901,1025 922,1006 886,937 835,863 770,784 769,783 710,716 594,584 L 774,223 C 774,196 753,168 711,139 L 727,119 C 717,90 699,76 672,76 641,76 570,178 457,381 L 164,-76 C 142,-110 111,-127 72,-127 30,-127 9,-110 8,-76 1,-67 -2,-52 -2,-32 -2,-23 -1,-13 0,-2 Z"/>
  </g>
  <g id="bullet-char-template(10004)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 285,-33 C 182,-33 111,30 74,156 52,228 41,333 41,471 41,549 55,616 82,672 116,743 169,778 240,778 293,778 328,747 346,684 L 369,508 C 377,444 397,411 428,410 L 1163,1116 C 1174,1127 1196,1133 1229,1133 1271,1133 1292,1118 1292,1087 L 1292,965 C 1292,929 1282,901 1262,881 L 442,47 C 390,-6 338,-33 285,-33 Z"/>
  </g>
  <g id="bullet-char-template(9679)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 813,0 C 632,0 489,54 383,161 276,268 223,411 223,592 223,773 276,916 383,1023 489,1130 632,1184 813,1184 992,1184 1136,1130 1245,1023 1353,916 1407,772 1407,592 1407,412 1353,268 1245,161 1136,54 992,0 813,0 Z"/>
  </g>
  <g id="bullet-char-template(8226)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 346,457 C 273,457 209,483 155,535 101,586 74,649 74,723 74,796 101,859 155,911 209,963 273,989 346,989 419,989 480,963 531,910 582,859 608,796 608,723 608,648 583,586 532,535 482,483 420,457 346,457 Z"/>
  </g>
  <g id="bullet-char-template(8211)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M -4,459 L 1135,459 1135,606 -4,606 -4,459 Z"/>
  </g>
 </defs>
 <defs class="TextEmbeddedBitmaps"/>
 <g class="SlideGroup">
  <g>
   <g id="id1" class="Slide" clip-path="url(#presentation_clip_path)">
    <g class="Page">
     <g class="com.sun.star.drawing.CustomShape">
      <g id="id3">
       <rect class="BoundingBox" stroke="none" fill="none" x="8367" y="3188" width="4829" height="1273"/>
       <path fill="rgb(114,159,207)" stroke="none" d="M 10781,4459 L 8368,4459 8368,3189 13194,3189 13194,4459 10781,4459 Z"/>
       <path fill="none" stroke="rgb(52,101,164)" d="M 10781,4459 L 8368,4459 8368,3189 13194,3189 13194,4459 10781,4459 Z"/>
       <text class="TextShape"><tspan class="TextParagraph" font-family="Liberation Sans, sans-serif" font-size="635px" font-weight="400"><tspan class="TextPosition" x="10481" y="4045"/><tspan class="TextPosition" x="10481" y="4045"><tspan fill="rgb(0,0,0)" stroke="none">W</tspan></tspan></tspan></text>
      </g>
     </g>
     <g class="com.sun.star.drawing.CustomShape">
      <g id="id4">
       <rect class="BoundingBox" stroke="none" fill="none" x="4811" y="5982" width="4829" height="1527"/>
       <path fill="rgb(114,159,207)" stroke="none" d="M 7225,7507 L 4812,7507 4812,5983 9638,5983 9638,7507 7225,7507 Z"/>
       <path fill="none" stroke="rgb(52,101,164)" d="M 7225,7507 L 4812,7507 4812,5983 9638,5983 9638,7507 7225,7507 Z"/>
       <text class="TextShape"><tspan class="TextParagraph" font-family="Liberation Sans, sans-serif" font-size="635px" font-weight="400"><tspan class="TextPosition" x="6696" y="6966"/><tspan class="TextPosition" x="6696" y="6966"><tspan fill="rgb(0,0,0)" stroke="none">DW</tspan></tspan></tspan></text>
      </g>
     </g>
     <g class="com.sun.star.drawing.CustomShape">
      <g id="id5">
       <rect class="BoundingBox" stroke="none" fill="none" x="11923" y="5982" width="4829" height="1527"/>
       <path fill="rgb(114,159,207)" stroke="none" d="M 14337,7507 L 11924,7507 11924,5983 16750,5983 16750,7507 14337,7507 Z"/>
       <path fill="none" stroke="rgb(52,101,164)" d="M 14337,7507 L 11924,7507 11924,5983 16750,5983 16750,7507 14337,7507 Z"/>
       <text class="TextShape"><tspan class="TextParagraph" font-family="Liberation Sans, sans-serif" font-size="635px" font-weight="400"><tspan class="TextPosition" x="13808" y="6966"/><tspan class="TextPosition" x="13808" y="6966"><tspan fill="rgb(0,0,0)" stroke="none">DW</tspan></tspan></tspan></text>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id6">
       <rect class="BoundingBox" stroke="none" fill="none" x="7225" y="4458" width="3558" height="1526"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 10781,4459 L 7620,5814"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 7225,5983 L 7698,5944 7580,5668 7225,5983 Z"/>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id7">
       <rect class="BoundingBox" stroke="none" fill="none" x="10780" y="4458" width="3558" height="1526"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 10781,4459 L 13942,5814"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 14337,5983 L 13982,5668 13864,5944 14337,5983 Z"/>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id8">
       <rect class="BoundingBox" stroke="none" fill="none" x="10631" y="2687" width="6622" height="4060"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 16750,6745 L 17251,6745 17251,2688 10781,2688 10781,2759"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 10781,3189 L 10931,2739 10631,2739 10781,3189 Z"/>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id9">
       <rect class="BoundingBox" stroke="none" fill="none" x="4310" y="2687" width="6622" height="4060"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 4812,6745 L 4311,6745 4311,2688 10781,2688 10781,2759"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 10781,3189 L 10931,2739 10631,2739 10781,3189 Z"/>
      </g>
     </g>
    </g>
   </g>
  </g>
 </g>
</svg>
<br>

Setting up the pool:

```javascript
var workersPoolMax = 2; //window.navigator.hardwareConcurrency;
var workers = [];

for(var i = 0; i < workersPoolMax; i++) {
    var w = new Worker('worker.js');
    w.onmessage = function(event) {
        // data from worker 
    };
    workers.push({w: w}); // {w} ES6
}

// ...
var idx = Math.floor(Math.random() * workersPoolMax);
workers[idx].w.postMessage({cmd: 'process'}); // input from application 
```

Worker `worker.js` code:

```javascript
onmessage = function(e) {
    switch(e.data.cmd) {
        case 'process':
            var res = data;
            self.postMessage(res); // send result back to window
            break;
    }
};
```


##Nested Dedicated Workers

Nesting workers is interesting for sharing work between worker threads without having the main window deal with cross worker communication. There are some places in the Internet that will tell you that workers can be created within workers. In my understanding, creating workers within workers is not part of workers scope API and Chrome, where I tried these examples out, conforms to that. We need to create all workers in the window thread, but we can chain their messaging channels so that workers communicate directly without going through the window.

<br>
<svg version="1.2" baseProfile="tiny" width="129.41mm" height="73.59mm" viewBox="6611 5088 12941 7359" preserveAspectRatio="xMidYMid" fill-rule="evenodd" stroke-width="28.222" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg" xmlns:ooo="http://xml.openoffice.org/svg/export" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:presentation="http://sun.com/xmlns/staroffice/presentation" xmlns:smil="http://www.w3.org/2001/SMIL20/" xmlns:anim="urn:oasis:names:tc:opendocument:xmlns:animation:1.0" xml:space="preserve">
 <defs class="ClipPathGroup">
  <clipPath id="presentation_clip_path" clipPathUnits="userSpaceOnUse">
   <rect x="6611" y="5088" width="12941" height="7359"/>
  </clipPath>
 </defs>
 <defs>
  <font id="EmbeddedFont_1" horiz-adv-x="2048">
   <font-face font-family="Liberation Sans embedded" units-per-em="2048" font-weight="normal" font-style="normal" ascent="1852" descent="450"/>
   <missing-glyph horiz-adv-x="2048" d="M 0,0 L 2047,0 2047,2047 0,2047 0,0 Z"/>
   <glyph unicode="W" horiz-adv-x="1932" d="M 1511,0 L 1283,0 1039,895 C 1032,920 1024,950 1016,985 1007,1020 1000,1053 993,1084 985,1121 977,1158 969,1196 960,1157 952,1120 944,1083 937,1051 929,1018 921,984 913,950 905,920 898,895 L 652,0 424,0 9,1409 208,1409 461,514 C 472,472 483,430 494,389 504,348 513,311 520,278 529,239 537,203 544,168 554,214 564,259 575,304 580,323 584,342 589,363 594,384 599,404 604,424 609,444 614,463 619,482 624,500 628,517 632,532 L 877,1409 1060,1409 1305,532 C 1309,517 1314,500 1319,482 1324,463 1329,444 1334,425 1339,405 1343,385 1348,364 1353,343 1357,324 1362,305 1373,260 1383,215 1393,168 1394,168 1397,180 1402,203 1407,226 1414,254 1422,289 1430,324 1439,361 1449,402 1458,442 1468,479 1478,514 L 1727,1409 1926,1409 1511,0 Z"/>
   <glyph unicode="N" horiz-adv-x="1165" d="M 1082,0 L 328,1200 C 329,1167 331,1135 333,1103 334,1076 336,1047 337,1017 338,986 338,959 338,936 L 338,0 168,0 168,1409 390,1409 1152,201 C 1150,234 1148,266 1146,299 1145,327 1143,358 1142,391 1141,424 1140,455 1140,485 L 1140,1409 1312,1409 1312,0 1082,0 Z"/>
   <glyph unicode="D" horiz-adv-x="1218" d="M 1381,719 C 1381,602 1363,498 1328,409 1293,319 1244,244 1183,184 1122,123 1049,78 966,47 882,16 792,0 695,0 L 168,0 168,1409 634,1409 C 743,1409 843,1396 935,1369 1026,1342 1105,1300 1171,1244 1237,1187 1289,1116 1326,1029 1363,942 1381,839 1381,719 Z M 1189,719 C 1189,814 1175,896 1148,964 1121,1031 1082,1087 1033,1130 984,1173 925,1205 856,1226 787,1246 712,1256 630,1256 L 359,1256 359,153 673,153 C 747,153 816,165 879,189 942,213 996,249 1042,296 1088,343 1124,402 1150,473 1176,544 1189,626 1189,719 Z"/>
  </font>
 </defs>
 <defs class="TextShapeIndex">
  <g ooo:slide="id1" ooo:id-list="id3 id4 id5 id6 id7 id8 id9 id10 id11 id12 id13 id14 id15"/>
 </defs>
 <defs class="EmbeddedBulletChars">
  <g id="bullet-char-template(57356)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 580,1141 L 1163,571 580,0 -4,571 580,1141 Z"/>
  </g>
  <g id="bullet-char-template(57354)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 8,1128 L 1137,1128 1137,0 8,0 8,1128 Z"/>
  </g>
  <g id="bullet-char-template(10146)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 174,0 L 602,739 174,1481 1456,739 174,0 Z M 1358,739 L 309,1346 659,739 1358,739 Z"/>
  </g>
  <g id="bullet-char-template(10132)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 2015,739 L 1276,0 717,0 1260,543 174,543 174,936 1260,936 717,1481 1274,1481 2015,739 Z"/>
  </g>
  <g id="bullet-char-template(10007)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 0,-2 C -7,14 -16,27 -25,37 L 356,567 C 262,823 215,952 215,954 215,979 228,992 255,992 264,992 276,990 289,987 310,991 331,999 354,1012 L 381,999 492,748 772,1049 836,1024 860,1049 C 881,1039 901,1025 922,1006 886,937 835,863 770,784 769,783 710,716 594,584 L 774,223 C 774,196 753,168 711,139 L 727,119 C 717,90 699,76 672,76 641,76 570,178 457,381 L 164,-76 C 142,-110 111,-127 72,-127 30,-127 9,-110 8,-76 1,-67 -2,-52 -2,-32 -2,-23 -1,-13 0,-2 Z"/>
  </g>
  <g id="bullet-char-template(10004)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 285,-33 C 182,-33 111,30 74,156 52,228 41,333 41,471 41,549 55,616 82,672 116,743 169,778 240,778 293,778 328,747 346,684 L 369,508 C 377,444 397,411 428,410 L 1163,1116 C 1174,1127 1196,1133 1229,1133 1271,1133 1292,1118 1292,1087 L 1292,965 C 1292,929 1282,901 1262,881 L 442,47 C 390,-6 338,-33 285,-33 Z"/>
  </g>
  <g id="bullet-char-template(9679)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 813,0 C 632,0 489,54 383,161 276,268 223,411 223,592 223,773 276,916 383,1023 489,1130 632,1184 813,1184 992,1184 1136,1130 1245,1023 1353,916 1407,772 1407,592 1407,412 1353,268 1245,161 1136,54 992,0 813,0 Z"/>
  </g>
  <g id="bullet-char-template(8226)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 346,457 C 273,457 209,483 155,535 101,586 74,649 74,723 74,796 101,859 155,911 209,963 273,989 346,989 419,989 480,963 531,910 582,859 608,796 608,723 608,648 583,586 532,535 482,483 420,457 346,457 Z"/>
  </g>
  <g id="bullet-char-template(8211)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M -4,459 L 1135,459 1135,606 -4,606 -4,459 Z"/>
  </g>
 </defs>
 <defs class="TextEmbeddedBitmaps"/>
 <g class="SlideGroup">
  <g>
   <g id="id1" class="Slide" clip-path="url(#presentation_clip_path)">
    <g class="Page">
     <g class="com.sun.star.drawing.CustomShape">
      <g id="id3">
       <rect class="BoundingBox" stroke="none" fill="none" x="10667" y="5588" width="4829" height="1273"/>
       <path fill="rgb(114,159,207)" stroke="none" d="M 13081,6859 L 10668,6859 10668,5589 15494,5589 15494,6859 13081,6859 Z"/>
       <path fill="none" stroke="rgb(52,101,164)" d="M 13081,6859 L 10668,6859 10668,5589 15494,5589 15494,6859 13081,6859 Z"/>
       <text class="TextShape"><tspan class="TextParagraph" font-family="Liberation Sans, sans-serif" font-size="635px" font-weight="400"><tspan class="TextPosition" x="12781" y="6445"/><tspan class="TextPosition" x="12781" y="6445"><tspan fill="rgb(0,0,0)" stroke="none">W</tspan></tspan></tspan></text>
      </g>
     </g>
     <g class="com.sun.star.drawing.CustomShape">
      <g id="id4">
       <rect class="BoundingBox" stroke="none" fill="none" x="7111" y="8382" width="4829" height="1527"/>
       <path fill="rgb(114,159,207)" stroke="none" d="M 9525,9907 L 7112,9907 7112,8383 11938,8383 11938,9907 9525,9907 Z"/>
       <path fill="none" stroke="rgb(52,101,164)" d="M 9525,9907 L 7112,9907 7112,8383 11938,8383 11938,9907 9525,9907 Z"/>
       <text class="TextShape"><tspan class="TextParagraph" font-family="Liberation Sans, sans-serif" font-size="635px" font-weight="400"><tspan class="TextPosition" x="8996" y="9366"/><tspan class="TextPosition" x="8996" y="9366"><tspan fill="rgb(0,0,0)" stroke="none">DW</tspan></tspan></tspan></text>
      </g>
     </g>
     <g class="com.sun.star.drawing.CustomShape">
      <g id="id5">
       <rect class="BoundingBox" stroke="none" fill="none" x="14223" y="8382" width="4829" height="1527"/>
       <path fill="rgb(114,159,207)" stroke="none" d="M 16637,9907 L 14224,9907 14224,8383 19050,8383 19050,9907 16637,9907 Z"/>
       <path fill="none" stroke="rgb(52,101,164)" d="M 16637,9907 L 14224,9907 14224,8383 19050,8383 19050,9907 16637,9907 Z"/>
       <text class="TextShape"><tspan class="TextParagraph" font-family="Liberation Sans, sans-serif" font-size="635px" font-weight="400"><tspan class="TextPosition" x="16108" y="9366"/><tspan class="TextPosition" x="16108" y="9366"><tspan fill="rgb(0,0,0)" stroke="none">DW</tspan></tspan></tspan></text>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id6">
       <rect class="BoundingBox" stroke="none" fill="none" x="9525" y="6858" width="3558" height="1526"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 13081,6859 L 9920,8214"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 9525,8383 L 9998,8344 9880,8068 9525,8383 Z"/>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id7">
       <rect class="BoundingBox" stroke="none" fill="none" x="13080" y="6858" width="3558" height="1526"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 13081,6859 L 16242,8214"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 16637,8383 L 16282,8068 16164,8344 16637,8383 Z"/>
      </g>
     </g>
     <g class="com.sun.star.drawing.CustomShape">
      <g id="id8">
       <rect class="BoundingBox" stroke="none" fill="none" x="7111" y="10921" width="4829" height="1527"/>
       <path fill="rgb(114,159,207)" stroke="none" d="M 9525,12446 L 7112,12446 7112,10922 11938,10922 11938,12446 9525,12446 Z"/>
       <path fill="none" stroke="rgb(52,101,164)" d="M 9525,12446 L 7112,12446 7112,10922 11938,10922 11938,12446 9525,12446 Z"/>
       <text class="TextShape"><tspan class="TextParagraph" font-family="Liberation Sans, sans-serif" font-size="635px" font-weight="400"><tspan class="TextPosition" x="8767" y="11905"/><tspan class="TextPosition" x="8767" y="11905"><tspan fill="rgb(0,0,0)" stroke="none">NDW</tspan></tspan></tspan></text>
      </g>
     </g>
     <g class="com.sun.star.drawing.CustomShape">
      <g id="id9">
       <rect class="BoundingBox" stroke="none" fill="none" x="14223" y="10921" width="4829" height="1527"/>
       <path fill="rgb(114,159,207)" stroke="none" d="M 16637,12446 L 14224,12446 14224,10922 19050,10922 19050,12446 16637,12446 Z"/>
       <path fill="none" stroke="rgb(52,101,164)" d="M 16637,12446 L 14224,12446 14224,10922 19050,10922 19050,12446 16637,12446 Z"/>
       <text class="TextShape"><tspan class="TextParagraph" font-family="Liberation Sans, sans-serif" font-size="635px" font-weight="400"><tspan class="TextPosition" x="15879" y="11905"/><tspan class="TextPosition" x="15879" y="11905"><tspan fill="rgb(0,0,0)" stroke="none">NDW</tspan></tspan></tspan></text>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id10">
       <rect class="BoundingBox" stroke="none" fill="none" x="9375" y="9906" width="301" height="1017"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 9525,9907 L 9525,10492"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 9525,10922 L 9675,10472 9375,10472 9525,10922 Z"/>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id11">
       <rect class="BoundingBox" stroke="none" fill="none" x="16487" y="9906" width="301" height="1017"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 16637,9907 L 16637,10492"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 16637,10922 L 16787,10472 16487,10472 16637,10922 Z"/>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id12">
       <rect class="BoundingBox" stroke="none" fill="none" x="6610" y="5087" width="6622" height="4060"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 7112,9145 L 6611,9145 6611,5088 13081,5088 13081,5159"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 13081,5589 L 13231,5139 12931,5139 13081,5589 Z"/>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id13">
       <rect class="BoundingBox" stroke="none" fill="none" x="12931" y="5087" width="6622" height="4060"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 19050,9145 L 19551,9145 19551,5088 13081,5088 13081,5159"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 13081,5589 L 13231,5139 12931,5139 13081,5589 Z"/>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id14">
       <rect class="BoundingBox" stroke="none" fill="none" x="11937" y="8995" width="504" height="2691"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 11938,11684 L 12439,11684 12439,9145 12368,9145"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 11938,9145 L 12388,9295 12388,8995 11938,9145 Z"/>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id15">
       <rect class="BoundingBox" stroke="none" fill="none" x="13722" y="8995" width="504" height="2691"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 14224,11684 L 13723,11684 13723,9145 13794,9145"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 14224,9145 L 13774,8995 13774,9295 14224,9145 Z"/>
      </g>
     </g>
    </g>
   </g>
  </g>
 </g>
</svg>
<br>

I have modified the previous example to add two nested *dedicated* web workers, one per each previous load balanced worker:

```javascript
var workersPoolMax = 2;
var workers = [];

for(var i = 0; i < workersPoolMax; i++) {
    var w = new Worker('worker.js');
    w.onmessage = function(event) {
        // data from worker 
    };
    var n = new Worker('nestedWorker.js');
    var channel = new MessageChannel();
    w.postMessage({cmd: 'connect'}, [channel.port1]);
    n.postMessage({cmd: 'connect'}, [channel.port2]);
    workers.push({w: w, n: n});
}

var idx = Math.floor(Math.random() * workersPoolMax);
workers[idx].w.postMessage({cmd: 'process'}); // input from application 
```

We can use `MessageChannel` to establish a bidirectional communication pipe through workers. Currently, `MessageChannel` does [not](https://bugs.chromium.org/p/chromium/issues/detail?id=334408) support transferable types in Chrome, which can be a drawback for this kind of topology, depending on the data you have. However, understanding how this is done is still useful. The updated code of the `worker.js` is shown next. Using `cmd` as shown is just a convention. You can use any convention of choice to manage your data flow protocol.

```javascript
var nestedPort;
var me = self;

onmessage = function (e) {
    switch(e.data.cmd) {
        case 'connect':
            var nestedPort = e.ports[0];
            port.onmessage = function(event) {
                // data from nested worker comes here
                var res = event.data;
                me.postMessage(res); // send result back to window 
            };
            break;
        case 'process':
            // process and forward data to nested worker
            var res = data;
            nestedPort.postMessage(res); // no transferables in Chrome :( atm 
            break;
    }
};
```

Nested worker `nestedWorker.js` code:

```javascript
var parentPort;

onmessage = function(e) {
    var data = e.data;
    switch(data.cmd) {
        case 'connect':
            parentPort = e.ports[0];
            parentPort.onmessage = function(event) {
                // data from parent comes here, process and send back to parent
                var res = event.data;
                parentPort.postMessage(res);
            };
            break;
    }
};
```

##Nested Shared Worker

This example is similar to the previous one, but uses a nested *shared* worker (SW). SharedWorkers are shared across windows and you get access to same worker (different port) when creating instances. I use the shared worker in this example to make a diamond shaped topology, where the nested shared worker is shared between the pool workers.

<br>
<svg version="1.2" baseProfile="tiny" width="129.41mm" height="85.68mm" viewBox="6611 5089 12941 8568" preserveAspectRatio="xMidYMid" fill-rule="evenodd" stroke-width="28.222" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg" xmlns:ooo="http://xml.openoffice.org/svg/export" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:presentation="http://sun.com/xmlns/staroffice/presentation" xmlns:smil="http://www.w3.org/2001/SMIL20/" xmlns:anim="urn:oasis:names:tc:opendocument:xmlns:animation:1.0" xml:space="preserve">
 <defs class="ClipPathGroup">
  <clipPath id="presentation_clip_path" clipPathUnits="userSpaceOnUse">
   <rect x="6611" y="5089" width="12941" height="8568"/>
  </clipPath>
 </defs>
 <defs>
  <font id="EmbeddedFont_1" horiz-adv-x="2048">
   <font-face font-family="Liberation Sans embedded" units-per-em="2048" font-weight="normal" font-style="normal" ascent="1852" descent="450"/>
   <missing-glyph horiz-adv-x="2048" d="M 0,0 L 2047,0 2047,2047 0,2047 0,0 Z"/>
   <glyph unicode="W" horiz-adv-x="1932" d="M 1511,0 L 1283,0 1039,895 C 1032,920 1024,950 1016,985 1007,1020 1000,1053 993,1084 985,1121 977,1158 969,1196 960,1157 952,1120 944,1083 937,1051 929,1018 921,984 913,950 905,920 898,895 L 652,0 424,0 9,1409 208,1409 461,514 C 472,472 483,430 494,389 504,348 513,311 520,278 529,239 537,203 544,168 554,214 564,259 575,304 580,323 584,342 589,363 594,384 599,404 604,424 609,444 614,463 619,482 624,500 628,517 632,532 L 877,1409 1060,1409 1305,532 C 1309,517 1314,500 1319,482 1324,463 1329,444 1334,425 1339,405 1343,385 1348,364 1353,343 1357,324 1362,305 1373,260 1383,215 1393,168 1394,168 1397,180 1402,203 1407,226 1414,254 1422,289 1430,324 1439,361 1449,402 1458,442 1468,479 1478,514 L 1727,1409 1926,1409 1511,0 Z"/>
   <glyph unicode="S" horiz-adv-x="1192" d="M 1272,389 C 1272,330 1261,275 1238,225 1215,175 1179,132 1131,96 1083,59 1023,31 950,11 877,-10 790,-20 690,-20 515,-20 378,11 280,72 182,133 120,222 93,338 L 278,375 C 287,338 302,305 321,275 340,245 367,219 400,198 433,176 473,159 522,147 571,135 629,129 697,129 754,129 806,134 853,144 900,153 941,168 975,188 1009,208 1036,234 1055,266 1074,297 1083,335 1083,379 1083,425 1073,462 1052,491 1031,520 1001,543 963,562 925,581 880,596 827,609 774,622 716,635 652,650 613,659 573,668 534,679 494,689 456,701 420,716 383,730 349,747 317,766 285,785 257,809 234,836 211,863 192,894 179,930 166,965 159,1006 159,1053 159,1120 173,1177 200,1225 227,1272 264,1311 312,1342 360,1373 417,1395 482,1409 547,1423 618,1430 694,1430 781,1430 856,1423 918,1410 980,1396 1032,1375 1075,1348 1118,1321 1152,1287 1178,1247 1203,1206 1224,1159 1239,1106 L 1051,1073 C 1042,1107 1028,1137 1011,1164 993,1191 970,1213 941,1231 912,1249 878,1263 837,1272 796,1281 747,1286 692,1286 627,1286 572,1280 528,1269 483,1257 448,1241 421,1221 394,1201 374,1178 363,1151 351,1124 345,1094 345,1063 345,1021 356,987 377,960 398,933 426,910 462,892 498,874 540,859 587,847 634,835 685,823 738,811 781,801 825,791 868,781 911,770 952,758 991,744 1030,729 1067,712 1102,693 1136,674 1166,650 1191,622 1216,594 1236,561 1251,523 1265,485 1272,440 1272,389 Z"/>
   <glyph unicode="D" horiz-adv-x="1218" d="M 1381,719 C 1381,602 1363,498 1328,409 1293,319 1244,244 1183,184 1122,123 1049,78 966,47 882,16 792,0 695,0 L 168,0 168,1409 634,1409 C 743,1409 843,1396 935,1369 1026,1342 1105,1300 1171,1244 1237,1187 1289,1116 1326,1029 1363,942 1381,839 1381,719 Z M 1189,719 C 1189,814 1175,896 1148,964 1121,1031 1082,1087 1033,1130 984,1173 925,1205 856,1226 787,1246 712,1256 630,1256 L 359,1256 359,153 673,153 C 747,153 816,165 879,189 942,213 996,249 1042,296 1088,343 1124,402 1150,473 1176,544 1189,626 1189,719 Z"/>
  </font>
 </defs>
 <defs class="TextShapeIndex">
  <g ooo:slide="id1" ooo:id-list="id3 id4 id5 id6 id7 id8 id9 id10 id11 id12 id13 id14"/>
 </defs>
 <defs class="EmbeddedBulletChars">
  <g id="bullet-char-template(57356)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 580,1141 L 1163,571 580,0 -4,571 580,1141 Z"/>
  </g>
  <g id="bullet-char-template(57354)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 8,1128 L 1137,1128 1137,0 8,0 8,1128 Z"/>
  </g>
  <g id="bullet-char-template(10146)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 174,0 L 602,739 174,1481 1456,739 174,0 Z M 1358,739 L 309,1346 659,739 1358,739 Z"/>
  </g>
  <g id="bullet-char-template(10132)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 2015,739 L 1276,0 717,0 1260,543 174,543 174,936 1260,936 717,1481 1274,1481 2015,739 Z"/>
  </g>
  <g id="bullet-char-template(10007)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 0,-2 C -7,14 -16,27 -25,37 L 356,567 C 262,823 215,952 215,954 215,979 228,992 255,992 264,992 276,990 289,987 310,991 331,999 354,1012 L 381,999 492,748 772,1049 836,1024 860,1049 C 881,1039 901,1025 922,1006 886,937 835,863 770,784 769,783 710,716 594,584 L 774,223 C 774,196 753,168 711,139 L 727,119 C 717,90 699,76 672,76 641,76 570,178 457,381 L 164,-76 C 142,-110 111,-127 72,-127 30,-127 9,-110 8,-76 1,-67 -2,-52 -2,-32 -2,-23 -1,-13 0,-2 Z"/>
  </g>
  <g id="bullet-char-template(10004)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 285,-33 C 182,-33 111,30 74,156 52,228 41,333 41,471 41,549 55,616 82,672 116,743 169,778 240,778 293,778 328,747 346,684 L 369,508 C 377,444 397,411 428,410 L 1163,1116 C 1174,1127 1196,1133 1229,1133 1271,1133 1292,1118 1292,1087 L 1292,965 C 1292,929 1282,901 1262,881 L 442,47 C 390,-6 338,-33 285,-33 Z"/>
  </g>
  <g id="bullet-char-template(9679)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 813,0 C 632,0 489,54 383,161 276,268 223,411 223,592 223,773 276,916 383,1023 489,1130 632,1184 813,1184 992,1184 1136,1130 1245,1023 1353,916 1407,772 1407,592 1407,412 1353,268 1245,161 1136,54 992,0 813,0 Z"/>
  </g>
  <g id="bullet-char-template(8226)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M 346,457 C 273,457 209,483 155,535 101,586 74,649 74,723 74,796 101,859 155,911 209,963 273,989 346,989 419,989 480,963 531,910 582,859 608,796 608,723 608,648 583,586 532,535 482,483 420,457 346,457 Z"/>
  </g>
  <g id="bullet-char-template(8211)" transform="scale(0.00048828125,-0.00048828125)">
   <path d="M -4,459 L 1135,459 1135,606 -4,606 -4,459 Z"/>
  </g>
 </defs>
 <defs class="TextEmbeddedBitmaps"/>
 <g class="SlideGroup">
  <g>
   <g id="id1" class="Slide" clip-path="url(#presentation_clip_path)">
    <g class="Page">
     <g class="com.sun.star.drawing.CustomShape">
      <g id="id3">
       <rect class="BoundingBox" stroke="none" fill="none" x="10667" y="5589" width="4829" height="1273"/>
       <path fill="rgb(114,159,207)" stroke="none" d="M 13081,6860 L 10668,6860 10668,5590 15494,5590 15494,6860 13081,6860 Z"/>
       <path fill="none" stroke="rgb(52,101,164)" d="M 13081,6860 L 10668,6860 10668,5590 15494,5590 15494,6860 13081,6860 Z"/>
       <text class="TextShape"><tspan class="TextParagraph" font-family="Liberation Sans, sans-serif" font-size="635px" font-weight="400"><tspan class="TextPosition" x="12781" y="6446"/><tspan class="TextPosition" x="12781" y="6446"><tspan fill="rgb(0,0,0)" stroke="none">W</tspan></tspan></tspan></text>
      </g>
     </g>
     <g class="com.sun.star.drawing.CustomShape">
      <g id="id4">
       <rect class="BoundingBox" stroke="none" fill="none" x="7111" y="8383" width="4829" height="1527"/>
       <path fill="rgb(114,159,207)" stroke="none" d="M 9525,9908 L 7112,9908 7112,8384 11938,8384 11938,9908 9525,9908 Z"/>
       <path fill="none" stroke="rgb(52,101,164)" d="M 9525,9908 L 7112,9908 7112,8384 11938,8384 11938,9908 9525,9908 Z"/>
       <text class="TextShape"><tspan class="TextParagraph" font-family="Liberation Sans, sans-serif" font-size="635px" font-weight="400"><tspan class="TextPosition" x="8996" y="9367"/><tspan class="TextPosition" x="8996" y="9367"><tspan fill="rgb(0,0,0)" stroke="none">DW</tspan></tspan></tspan></text>
      </g>
     </g>
     <g class="com.sun.star.drawing.CustomShape">
      <g id="id5">
       <rect class="BoundingBox" stroke="none" fill="none" x="14223" y="8383" width="4829" height="1527"/>
       <path fill="rgb(114,159,207)" stroke="none" d="M 16637,9908 L 14224,9908 14224,8384 19050,8384 19050,9908 16637,9908 Z"/>
       <path fill="none" stroke="rgb(52,101,164)" d="M 16637,9908 L 14224,9908 14224,8384 19050,8384 19050,9908 16637,9908 Z"/>
       <text class="TextShape"><tspan class="TextParagraph" font-family="Liberation Sans, sans-serif" font-size="635px" font-weight="400"><tspan class="TextPosition" x="16108" y="9367"/><tspan class="TextPosition" x="16108" y="9367"><tspan fill="rgb(0,0,0)" stroke="none">DW</tspan></tspan></tspan></text>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id6">
       <rect class="BoundingBox" stroke="none" fill="none" x="9525" y="6859" width="3558" height="1526"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 13081,6860 L 9920,8215"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 9525,8384 L 9998,8345 9880,8069 9525,8384 Z"/>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id7">
       <rect class="BoundingBox" stroke="none" fill="none" x="13080" y="6859" width="3558" height="1526"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 13081,6860 L 16242,8215"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 16637,8384 L 16282,8069 16164,8345 16637,8384 Z"/>
      </g>
     </g>
     <g class="com.sun.star.drawing.CustomShape">
      <g id="id8">
       <rect class="BoundingBox" stroke="none" fill="none" x="10513" y="11630" width="4829" height="1527"/>
       <path fill="rgb(114,159,207)" stroke="none" d="M 12927,13155 L 10514,13155 10514,11631 15340,11631 15340,13155 12927,13155 Z"/>
       <path fill="none" stroke="rgb(52,101,164)" d="M 12927,13155 L 10514,13155 10514,11631 15340,11631 15340,13155 12927,13155 Z"/>
       <text class="TextShape"><tspan class="TextParagraph" font-family="Liberation Sans, sans-serif" font-size="635px" font-weight="400"><tspan class="TextPosition" x="12415" y="12614"/><tspan class="TextPosition" x="12415" y="12614"><tspan fill="rgb(0,0,0)" stroke="none">SW</tspan></tspan></tspan></text>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id9">
       <rect class="BoundingBox" stroke="none" fill="none" x="9524" y="9907" width="3404" height="1725"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 9525,9908 L 12543,11437"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 12927,11631 L 12593,11294 12458,11561 12927,11631 Z"/>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id10">
       <rect class="BoundingBox" stroke="none" fill="none" x="12927" y="9907" width="3712" height="1725"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 16637,9908 L 13317,11450"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 12927,11631 L 13398,11577 13272,11305 12927,11631 Z"/>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id11">
       <rect class="BoundingBox" stroke="none" fill="none" x="6610" y="5088" width="6622" height="4060"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 7112,9146 L 6611,9146 6611,5089 13081,5089 13081,5160"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 13081,5590 L 13231,5140 12931,5140 13081,5590 Z"/>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id12">
       <rect class="BoundingBox" stroke="none" fill="none" x="12931" y="5088" width="6622" height="4060"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 19050,9146 L 19551,9146 19551,5089 13081,5089 13081,5160"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 13081,5590 L 13231,5140 12931,5140 13081,5590 Z"/>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id13">
       <rect class="BoundingBox" stroke="none" fill="none" x="9375" y="9908" width="3554" height="3750"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 12927,13155 L 12927,13656 9525,13656 9525,10338"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 9525,9908 L 9375,10358 9675,10358 9525,9908 Z"/>
      </g>
     </g>
     <g class="com.sun.star.drawing.ConnectorShape">
      <g id="id14">
       <rect class="BoundingBox" stroke="none" fill="none" x="12926" y="9908" width="3862" height="3750"/>
       <path fill="none" stroke="rgb(0,0,0)" d="M 12927,13155 L 12927,13656 16637,13656 16637,10338"/>
       <path fill="rgb(0,0,0)" stroke="none" d="M 16637,9908 L 16487,10358 16787,10358 16637,9908 Z"/>
      </g>
     </g>
    </g>
   </g>
  </g>
 </g>
</svg>
<br>

Similar to above, we need to setup all code in the window, but the communication will still be direct between workers, without having the window deal with it.

```javascript
var workersPoolMax = 2;
var workers = [];

for(var i = 0; i < workersPoolMax; i++) {
    var w = new Worker('worker.js');
    w.onmessage = function(event) {
        // data from worker 
    };
    var n = new SharedWorker('sharedWorker.js');
    n.port.start();
    w.postMessage({cmd: 'sharedConnect'}, [n.port]);
    workers.push({w: w});
}

var idx = Math.floor(Math.random() * workersPoolMax);
workers[idx].w.postMessage({cmd: 'process'}); // input from application
```

The code passes the port of the shared worker to its parent worker, whose  `worker.js` is shown next. The nested shared worker `n` handles data `process` message same as before. Additionally, the shared worker also `broadcast`s some event of interest to all parents if needed.

```javascript
var nestedPort;
var me = self;

onmessage = function (e) {
    switch(e.data.cmd) {
        case 'connect':
            var nestedPort = e.ports[0];
            port.onmessage = function(event) {
                // data from nested shared worker comes here
                switch(event.data.cmd) {
                    case 'process':
                        var res = event.data;
                        me.postMessage(res); // send result back to window 
                        break;
                    case 'broadcast':
                        // if needed
                        break;    
                }   
            };
            break;
        case 'process':
            // process and forward data to nested worker
            var res = data;
            nestedPort.postMessage(res); // no transferables in Chrome :( atm 
            break;
    }
};
```

Finally, `sharedWorker.js` implementation:

```javascript
var parents = [];
var totalMessageCount = 0; // state

onconnect = function(e) {
    var parentPort = e.ports[0];
    parents.push(port);
    parentPort.onmessage = function(event) {
        // data from parent comes here, process and send back to same parent
        var res = event.data;
        parentPort.postMessage(res);

        //optional, we can broadcast to all parents too
        totalMessageCount++;
        parents.forEach(function(p) {
            p.postMessage({cmd: 'broadcast', count: totalMessageCount}); 
        });
    };
};
```

The shared worker sends the result back to the same parent. We can keep track of connected parent ports (*clients*) in order to be able broadcast to them. In this example, the clients are additive (do not go away way over time). If clients were to be removed over time, we could use `broadcast` message, for example, (along some client response protocol) to *ping* alive clients and update the clients list.

<ins class='nfooter'><a id='fnext' href='#blog/2016/2016-02-24-Key-Derivation-Functions.md'>Key Derivation Functions</a></ins>
