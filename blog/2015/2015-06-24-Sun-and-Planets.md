#Sun and Planets

2015-06-24

<!--- tags: javascript d3 -->

To comprehend solar system planet distances, you have to plot them once on your own. Planets distances are in million of kilometers. Sun and planet radius has been scaled up to be more visible.

<div id="draw"></div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js"></script>
<style>
    .sb {
        stroke: #444444;
    }
    .sun {
        fill: #FFFF88;
    }
    .planet {
        fill: #C3D9FF;
        opacity: 0;
    }
    circle.planet:hover {
        fill: #C79810;
    }
    .text {
        font-size: 8px;
        fill: gray;
        opacity: 0;
        /* text-anchor: middle */
    }
    .axis path,
    .axis line {
        fill: none;
        stroke: gray;
        shape-rendering: crispEdges;
    }
    .axis text {
        fill: gray;
        font-family: sans-serif;
        font-size: 8px;
    }    
</style>
<script>
madebits.defer([[null, 'd3']], function (){

var radiusScale = 200;
var radiusRatioFactor = 0.0024397;
var data = [  
{r: 285.21, d: 0, t: 'Sun'},
{r: 1.00, d: 57, t: 'Mercury'}, 
{r: 2.48, d: 100, t: 'Venus'}, 
{r: 2.61, d: 150, t: 'Earth'}, 
{r: 1.39, d: 228, t: 'Mars'}, 
{r: 28.66, d: 779, t: 'Jupiter'}, 
{r: 23.87, d: 1430, t: 'Saturn'},
{r: 10.40, d: 2880, t: 'Uranus' }, 
{r: 10.09, d: 4500, t: 'Nepturne' } ];
var dataIndex = function(d, i) { return d + i; };

var dataMax = { 
    r: d3.max(data, function(d, i){ return i == 0 ? 0 : d.r }), // plannet r
    d: d3.max(data, function(d, i){ return d.d }) };

var width = 640, height = 200;
var xscale = d3.scale.linear().domain([0, dataMax.d]).range([0, width - 100]);
var rscale = function(r, scale) { 
    var t = r * radiusRatioFactor * scale; 
    return (t < 1) ? 1 : t; 
};

var svg = d3.select('#draw').append('svg')
.attr('width', width).attr('height', height);
var gsvg = svg.append('g').attr('transform', 'translate(20)');

// planets
var gp = gsvg.append('g');
gp.selectAll('circle')
.data(data, dataIndex)
.enter()
.append('circle')
.attr('class', function(d, i) { return i == 0 ? 'sun sb' : 'planet sb' })
.attr('cy', function(d, i){ return i == 0 ? height / 2 : 0; })
.attr('cx', 0)
.attr('r', function(d, i) { return rscale(d.r, i == 0 ? 0 : 200); })
.on('click', function(d) {
    d3.select(this).transition()
    .duration(500)
    .attr('r', function(d, i){ return rscale(d.r, 1); })
    .transition()
    .duration(500)
    .attr('r', function(d, i){ return rscale(d.r, radiusScale); });
});

// planet name
gp.selectAll('text').data(data, dataIndex).enter().append('text')
.attr('class', 'text')
.text(function(d, i) {
    if(i == 0) return '' 
    else return i < 3 ? d.t[0] : d.t; 
})
.attr('x', function(d) { return xscale(d.d) - 5; })
.attr('y', function(d, i) { 
    var delta = dataMax.r + 5;
    return (height / 2) + ((i % 2 != 0) ? -delta : delta); });

gsvg.append('text').attr('class', 'text').attr('x', 10).attr('y', 10).text('Sun, planets ' + radiusScale +'x');

// axis
var xaxis = d3.svg.axis()
.scale(xscale)
.orient('bottom')
.tickFormat(function(d, i){ return d; }); // d == 0 ? 0 : d + 'x10^6 km'; });
gsvg.append('g')
.attr('class', 'axis')
.attr('transform', 'translate(0,' + (height - 20) + ')')
.call(xaxis);

// animate
var duration = d3.scale.linear().domain([0, dataMax.r]).range([1000, 2000]);
var delay = d3.scale.log().domain([1, dataMax.r]).range([500, 1000]);
d3.selectAll('.sb').transition()
.ease('bounce')
.duration(function(d, i){ return duration(d.r); })
.delay(function(d, i) { return delay(d.r); })
.attr('cy', height / 2)
.attr('cx', function(d, i) { return xscale(d.d); } )
.style('opacity', 1);
d3.selectAll(".text").transition()
.duration(3000)
.style('opacity', 1);

d3.selectAll('.sb')
.transition()
.delay(3000)
.duration(1000)
.attr('r', function(d, i){ return rscale(d.r, radiusScale); });

});
</script>

JavaScript code:

```javascript
var radiusScale = 200;
var radiusRatioFactor = 0.0024397;
var data = [  
{r: 285.21, d: 0, t: 'Sun'},
{r: 1.00, d: 57, t: 'Mercury'}, 
{r: 2.48, d: 100, t: 'Venus'}, 
{r: 2.61, d: 150, t: 'Earth'}, 
{r: 1.39, d: 228, t: 'Mars'}, 
{r: 28.66, d: 779, t: 'Jupiter'}, 
{r: 23.87, d: 1430, t: 'Saturn'},
{r: 10.40, d: 2880, t: 'Uranus' }, 
{r: 10.09, d: 4500, t: 'Nepturne' } ];
var dataIndex = function(d, i) { return d + i; };

var dataMax = { 
    r: d3.max(data, function(d, i){ return i == 0 ? 0 : d.r }), // plannet r
    d: d3.max(data, function(d, i){ return d.d }) };

var width = 640, height = 200;
var xscale = d3.scale.linear().domain([0, dataMax.d]).range([0, width - 100]);
var rscale = function(r, scale) { 
    var t = r * radiusRatioFactor * scale; 
    return (t < 1) ? 1 : t; 
};

var svg = d3.select('#draw').append('svg')
.attr('width', width).attr('height', height);
var gsvg = svg.append('g').attr('transform', 'translate(20)');

// planets
var gp = gsvg.append('g');
gp.selectAll('circle')
.data(data, dataIndex)
.enter()
.append('circle')
.attr('class', function(d, i) { return i == 0 ? 'sun sb' : 'planet sb' })
.attr('cy', function(d, i){ return i == 0 ? height / 2 : 0; })
.attr('cx', 0)
.attr('r', function(d, i) { return rscale(d.r, i == 0 ? 0 : 200); })
.on('click', function(d) {
    d3.select(this).transition()
    .duration(500)
    .attr('r', function(d, i){ return rscale(d.r, 1); })
    .transition()
    .duration(500)
    .attr('r', function(d, i){ return rscale(d.r, radiusScale); });
});

// planet name
gp.selectAll('text').data(data, dataIndex).enter().append('text')
.attr('class', 'text')
.text(function(d, i) {
    if(i == 0) return '' 
    else return i < 3 ? d.t[0] : d.t; 
})
.attr('x', function(d) { return xscale(d.d) - 5; })
.attr('y', function(d, i) { 
    var delta = dataMax.r + 5;
    return (height / 2) + ((i % 2 != 0) ? -delta : delta); });

gsvg.append('text').attr('class', 'text').attr('x', 10).attr('y', 10).text('Sun, planets ' + radiusScale +'x');

// axis
var xaxis = d3.svg.axis()
.scale(xscale)
.orient('bottom')
.tickFormat(function(d, i){ return d; }); // d == 0 ? 0 : d + 'x10^6 km'; });
gsvg.append('g')
.attr('class', 'axis')
.attr('transform', 'translate(0,' + (height - 20) + ')')
.call(xaxis);

// animate
var duration = d3.scale.linear().domain([0, dataMax.r]).range([1000, 2000]);
var delay = d3.scale.log().domain([1, dataMax.r]).range([500, 1000]);
d3.selectAll('.sb').transition()
.ease('bounce')
.duration(function(d, i){ return duration(d.r); })
.delay(function(d, i) { return delay(d.r); })
.attr('cy', height / 2)
.attr('cx', function(d, i) { return xscale(d.d); } )
.style('opacity', 1);
d3.selectAll(".text").transition()
.duration(3000)
.style('opacity', 1);

d3.selectAll('.sb')
.transition()
.delay(3000)
.duration(1000)
.attr('r', function(d, i){ return rscale(d.r, radiusScale); });
```

Basically the code iterates through the data ([1](https://solarsystem.nasa.gov/planets/) [2](http://www.universetoday.com/15462/how-far-are-the-planets-from-the-sun/)) and creates the SVG elements using d3.

<ins class='nfooter'><a id='fprev' href='#blog/2015/2015-07-17-VirtualBox-Disk-Encryption.md'>VirtualBox Disk Encryption</a> <a id='fnext' href='#blog/2015/2015-06-21-Using-ProtonMail.md'>Using ProtonMail</a></ins>
