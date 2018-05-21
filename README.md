Roseric Azondekon
2/20/2018

**AuthorVis** is a co-authorship network exploration, and link prediction tool specific to the scientific collaborative research network of Malaria, Tuberculosis and HIV/AIDS in the Republic of Benin. This project is the result of an extensive study of co-authorship network entitled "Network Analysis of Scientific Collaboration and Co-authorship of the Trifecta of Malaria, Tuberculosis and HIV/AIDS in Benin." While many network visualization solutions have already been published, most of them are not specifically adapted to co-authorship network. Even those designed for visualizing co-authorship network have several limitations among others, their inability to satisfactorily display large networks, the lack of interactivity in the display, and the inability for the end user to control the display. This tool not only provides a visualization of each of the networks but allow the end user to query the network. It integrates bibliometrics information to the visualization. In the visualition interface, users can select a particular node or author to emphasize its subnetwork, hover over a node to display author's information or select an edge between two nodes/authors to display information related to materials co-authored by the two nodes defining that particular edge.

   

Related Work
------------

Various tools for the visualization of co-authorship networks have been proposed:

-   **NeL2**, a general purpose tool for the visualization of networks as a layered network diagram was proposed by [Nakazono, Misue, and Tanaka](https://dl.acm.org/citation.cfm?id=1151920 "NeL 2: Network drawing tool for handling layered structured network diagram.").

-   A Java based toolkits was proposed by [Liu and colleagues](https://dl.acm.org/citation.cfm?doid=996350.996470 "Toolkits for visualizing co-authorship graph.").

-   The **VVRC**, a Web-based tool was proposed by [Barbosa and colleagues](https://dl.acm.org/citation.cfm?id=2213975 "Web based tool for visualization and recommendation on co-authorship network").

-   **VICI**, a Python-based co-authorship tool was proposed by [Odoni and colleagues](http://www.semar.de/ws/publikationen/2017_ISI_VICI.pdf "Visualisation of Collaboration in Social Collaborative Knowledge Management Systems").

   

Design and Architecture
-----------------------

**AuthorVis** is built to a Shiny dashboard with an R based backend system that managed each co-authorship network data as an igraph object. The backend system allows the end user to query the system through the Shinyboard. It is combined to a Javascript web based frontend that displays the network graph, and handle user interactions with the network.

   

Network visualization
---------------------

The frontend network visualisation is built using the Javascript [**D3.js**](https://d3js.org/ "Data-Driven Documents"). A built-in navigation panel allows the user to interact with the network and control physics of network. A mouse hover over a vertex displays a tooltip of details on the author represented by the vertex while a double-click on a vertex highlights the subnetwork of the identified network. Edges are clickable too. Once an edge is clicked, the list of published materials co-authored by the two vertices defining the clicked edge is displayed in a panel on the right hand side. All published materials listed can be traced back to their publication page on the web via their DOI or the WOS accession number with a single click.

   

Tie prediction
--------------

We proposed two predictive models to estimate future tie probability between two authors:

 

### Exponential Random Graph model

Given a random graph ![](http://latex.codecogs.com/gif.latex?G%3D%28V%2CE%29), for two distinct nodes ![](http://latex.codecogs.com/gif.latex?i%2Cj%20%5Cin%20V), we define a random binary variable ![](http://latex.codecogs.com/gif.latex?Y_%7Bij%7D) such that ![](http://latex.codecogs.com/gif.latex?Y_%7Bij%7D%20%3D%201) if there is an edge ![](http://latex.codecogs.com/gif.latex?e%20%5Cin%20E) between ![](http://latex.codecogs.com/gif.latex?i) and ![](http://latex.codecogs.com/gif.latex?j), and ![](http://latex.codecogs.com/gif.latex?Y_%7Bij%7D%20%3D%200) otherwise.

Since co-authorship networks are by definition undirected networks, ![](http://latex.codecogs.com/gif.latex?Y_%7Bij%7D%20%3D%20Y_%7Bji%7D) and the matrix ![](http://latex.codecogs.com/gif.latex?%5Cmathbf%7BY%7D%3D%5Cleft%5B%20Y_%7Bij%7D%20%5Cright%5D) represents the random adjacency matrix for ![](http://latex.codecogs.com/gif.latex?G). The general formulation of ERGM is therefore:

![](http://latex.codecogs.com/gif.latex?Pr%28%5Cmathbf%7BY%7D%3D%5Cmathbf%7By%7D%29%3D%5Cleft%28%20%5Cfrac%7B1%7D%7B%5Ckappa%7D%20%5Cright%29%20exp%20%5C%7B%20%5Csum_%7BH%7D%20%5Ctheta_H%20g_H%28%5Cmathbf%7By%7D%29%20%5C%7D)

where each ![](http://latex.codecogs.com/gif.latex?H) is a configuration, a set of possible edges among a subset of the vertices in ![](http://latex.codecogs.com/gif.latex?G) and 

![](http://latex.codecogs.com/gif.latex?g_H%28%20%5Cmathbf%7By%7D%20%29%3D%20%5Cprod_%7B%20y_%7Bij%20%7D%20%5Cin%20H%20%7D%20y_%7Bij%7D) is the network statistic corresponding to the configuration ![](http://latex.codecogs.com/gif.latex?H); 

![](http://latex.codecogs.com/gif.latex?g_H%28%20%5Cmathbf%7By%7D%20%29%3D1) if the configuration is observed in the network ![](http://latex.codecogs.com/gif.latex?%5Cmathbf%7By%7D), and is ![](http://latex.codecogs.com/gif.latex?0) otherwise. 

![](http://latex.codecogs.com/gif.latex?%5Ctheta_H) is the parameter corresponding to the configuration ![](http://latex.codecogs.com/gif.latex?H) (and is non-zero only if all pairs of variables in ![](http://latex.codecogs.com/gif.latex?H) are assumed to be conditionally dependent); 
![](http://latex.codecogs.com/gif.latex?%5Ckappa) is a normalization constant defined as:

![](http://latex.codecogs.com/gif.latex?%5Ckappa%20%3D%20%5Csum_%7B%5Cmathbf%7By%7D%7Dexp%20%5C%7B%20%5Csum_%7BH%7D%20%5Ctheta_H%20g_H%28%5Cmathbf%7By%7D%29%20%5C%7D)

 

### Temporal Exponential Random Graph model

The Temporal Exponential Random Graph Model (TERGM) is an extension of the ERGM described above. TERGM was designed with the idea of accounting for inter-temporal dependence in longitudinally collected network data. For a full description of the TERGM, we refer the reader to [Leifeld, Cranmer, and Desmarais](http://eprints.gla.ac.uk/139203/ "Temporal exponential random graph models with btergm: estimation and bootstrap confidence intervals").

   

Deployment
----------

The visualization frontend is maintained by an Python **http-server**. The system is maintained in a [Docker container](https://hub.docker.com/r/rosericazondekon/authorvis/ "docker pull rosericazondekon/authorvis") to facilitate its use and installation.

   

Future directions
-----------------

Currently, **AuthorVis** is specifically built for Malaria, TB and HIV/AIDS in Benin. Future development will extend the tool to other research domain. We also aim at adding a general purpose module to **AuthorVis** for the visualization of any user-input co-authorship network. This will also require the integration of a data pre-processing module to facilitate the disambiguation and deduplication of co-authorship information. Finally, we will also incorporate a layered structured network visualization functionality to the visualization in order to display temporal changes in the evolution of the co-authorship network.
