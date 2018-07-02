/*-------------------------------------------------------------------------
  Roseric Azondekon,
  February 20th, 2018
  Last Update: July 2nd, 2018
  Milwaukee, WI, USA
-------------------------------------------------------------------------*/

var svg = d3.select("svg"),
    width = +svg.node().getBoundingClientRect().width,
    height = +svg.node().getBoundingClientRect().height;

// svg objects
var links;
var nodes;
// the data - an object with nodes and links
var graph;
var toggle = 0;
var ltoggle = 0;
var tiptoggle = 0;
var linkedByIndex = [];
var nodeIndexName = [];


// load the data
// var filename = $('#net_select').val()
var filename = "net.json"
load(filename)

//d3.json("miserables.json", function(error, _graph) {
// d3.json($('#net_select').val(), function(error, _graph) {
//   if (error) throw error;
//   graph = _graph;
//   initializeDisplay();
//   initializeSimulation();
// });
//////////// TOOLTIP ////////////
var tooltip = new Tooltip("vis-tooltip", 230)

//////////// FORCE SIMULATION ////////////

// force simulator
var simulation = d3.forceSimulation();

//////////// ADD ZOOM ////////////

//add encompassing group for the zoom
var g = svg.append("g")
    .attr("class", "everything");

//add zoom capabilities ===> not working
var zoom_handler = d3.zoom()
    .on("zoom", zoom_actions);

zoom_handler(svg);

console.log(nodes);
console.log(nodeIndexName);
console.log(linkedByIndex);

// values for all forces
forceProperties = {
    center: {
        x: 0.5,
        y: 0.5
    },
    charge: {
        enabled: true,
        strength: -30,
        distanceMin: 1,
        distanceMax: 2000
    },
    collide: {
        enabled: true,
        strength: .7,
        iterations: 1,
        radius: 5
    },
    forceX: {
        enabled: false,
        strength: .1,
        x: .5
    },
    forceY: {
        enabled: false,
        strength: .1,
        y: .5
    },
    link: {
        enabled: true,
        distance: 30,
        iterations: 1
    }
}
var radius = 5;


//////////// FUNCTIONS ////////////
// set up the simulation and event to update locations after each tick
function load(file){
  d3.json(file, reInit);
}

function initializeSimulation() {
  simulation.nodes(graph.nodes);
  initializeForces();
  simulation.on("tick", ticked);
}

// add forces to the simulation
function initializeForces() {
    // add forces and associate each with a name
    simulation
        .force("link", d3.forceLink())
        .force("charge", d3.forceManyBody())
        .force("collide", d3.forceCollide())
        .force("center", d3.forceCenter())
        .force("forceX", d3.forceX())
        .force("forceY", d3.forceY());
    // apply properties to each of the forces
    updateForces();
}

// apply new force properties
function updateForces() {
    // get each force by name and update the properties
    simulation.force("center")
        .x(width * forceProperties.center.x)
        .y(height * forceProperties.center.y);
    simulation.force("charge")
        .strength(forceProperties.charge.strength * forceProperties.charge.enabled)
        .distanceMin(forceProperties.charge.distanceMin)
        .distanceMax(forceProperties.charge.distanceMax);
    simulation.force("collide")
        .strength(forceProperties.collide.strength * forceProperties.collide.enabled)
        .radius(forceProperties.collide.radius)
        .iterations(forceProperties.collide.iterations);
    simulation.force("forceX")
        .strength(forceProperties.forceX.strength * forceProperties.forceX.enabled)
        .x(width * forceProperties.forceX.x);
    simulation.force("forceY")
        .strength(forceProperties.forceY.strength * forceProperties.forceY.enabled)
        .y(height * forceProperties.forceY.y);
    simulation.force("link")
        .id(function(d) {return d.id;})
        .distance(forceProperties.link.distance)
        .iterations(forceProperties.link.iterations)
        .links(forceProperties.link.enabled ? graph.links : []);

    // updates ignored until this is run
    // restarts the simulation (important if simulation has already slowed down)
    simulation.alpha(1).restart();
}



//////////// DISPLAY ////////////

// generate the svg objects and force simulation
function initializeDisplay() {
  // set the data and properties of link lines
  link = svg.append("g")
        .attr("class", "links")
    .selectAll("line")
    .data(graph.links)
    .enter().append("line");

  // set the data and properties of node circles
  node = svg.append("g")
        .attr("class", "nodes")
    .selectAll("circle")
    .data(graph.nodes)
    .enter().append("circle")
        .call(d3.drag()
            .on("start", dragstarted)
            .on("drag", dragged)
            .on("end", dragended));

  // node tooltip
  node.append("title")
//      .text(function(d) { return d.id; });
        .text(function(d) { return d.id + "-" + d.name; });

  // Display Node information on click
  // node.on("mouseover", showDetails)
      // .on("mouseout", hideDetails)

  node.exit().remove();


  // visualize the graph
  updateDisplay();
}

// update the display based on the forces (but not positions)
function updateDisplay() {
    node
        .attr("r", forceProperties.collide.radius)
        .attr("stroke", forceProperties.charge.strength > 0 ? "blue" : "red")
        .attr("stroke-width", forceProperties.charge.enabled==false ? 0 : Math.abs(forceProperties.charge.strength)/15);

    link
        .attr("stroke-width", forceProperties.link.enabled ? 1 : .5)
        .attr("opacity", forceProperties.link.enabled ? 1 : 0);
}

// update the display positions after each simulation tick
function ticked() {
    link
        .attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; })
        .on("click",showLinkDetails)
        // .on("mouseout",hideDetails)
        // .on("click",showLinkDetails)
        ;

    node
        // .attr("cx", function(d) { return d.x; })
        // .attr("cy", function(d) { return d.y; });
        .attr("cx", function(d) { return d.x = Math.max(radius, Math.min(width - radius, d.x)); })
        .attr("cy", function(d) { return d.y = Math.max(radius, Math.min(height - radius, d.y)); })
        .on("click",showNodeInfo)
        .on("dblclick", showNodeDetails)
        .on("mouseout", hideDetails);
    d3.select('#alpha_value').style('flex-basis', (simulation.alpha()*100) + '%'); 

}

// $(document).click(function() {
//     alert('clicked outside');
// });
