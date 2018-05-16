Roseric Azondekon
2/20/2018

**AuthorVis** is a co-authorship network exploration, and link prediction tool specific to the scientific collaborative research network of Malaria, Tuberculosis and HIV/AIDS in the Republic of Benin. This project is the result of an extensive study of co-authorship network entitled "Network Analysis of Scientific Collaboration and Co-authorship of the Trifecta of Malaria, Tuberculosis and HIV/AIDS in Benin." While many network visualization solutions have already been published, most of them are not specifically adapted to co-authorship network. Even those designed for visualizing co-authorship network have several limitations among others, their inability to satisfactorily display large networks, the lack of interactivity in the display, and the inability for the end user to control the display. This tool not only provides a visualization of each of the networks but allow the end user to query the network. It integrates bibliometrics information to the visualization. In the visualition interface, users can select a particular node or author to emphasize its subnetwork, hover over a node to display author's information or select an edge between two nodes/authors to display information related to materials co-authored by the two nodes defining that particular edge.

   

Related Work
------------

Various tools for the visualization of co-authorship networks have been proposed:

-   **NeL2**, a general purpose tool for the visualization of networks as a layered network diagram was proposed by [Nakazono, Misue, and Tanaka](https://dl.acm.org/citation.cfm?id=1151920 "NeL 2: Network drawing tool for handling layered structured network diagram.").

-   A Java based toolkits was proposed by [Liu and colleagues](ww.doi.org/10.1145/996350.996470 "Toolkits for visualizing co-authorship graph.").

-   The **VVRC**, a Web-based tool was proposed by [Barbosa and colleagues](www.doi.org/10.1145/2213836.2213975 "Web based tool for visualization and recommendation on co-authorship network").

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

Given a random graph \\( G=(V,E) \\), for two distinct nodes \\( i,j V \\), we define a random binary variable \\( Y\_{ij} \\) such that \\( Y\_{ij} = 1 \\) if there is an edge \\( e E \\) between \\( i \\) and \\( j \\), and \\( Y\_{ij} = 0 \\) otherwise.

Since co-authorship networks are by definition undirected networks, \\( Y\_{ij} = Y\_{ji} \\) and the matrix \\( =\\) represents the random adjacency matrix for \\( G \\). The general formulation of ERGM is therefore:

\\\[ Pr(=)=( ) exp { \_{H} \_H g\_H() } \\\]

where each \\( H \\) is a configuration, a set of possible edges among a subset of the vertices in \\( G \\) and

\\( g\_H( )= *{ y*{ij } H } y\_{ij} \\) is the network statistic corresponding to the configuration \\( H \\);

\\( g\_H( )=1 \\) if the configuration is observed in the network \\( \\), and is \\( 0 \\) otherwise.

\\( \_H \\) is the parameter corresponding to the configuration \\( H \\) (and is non-zero only if all pairs of variables in \\( H \\) are assumed to be conditionally dependent); \\( \\) is a normalization constant.

 

### Temporal Exponential Random Graph model

The Temporal Exponential Random Graph Model (TERGM) is an extension of the ERGM described above. TERGM was designed with the idea of accounting for inter-temporal dependence in longitudinally collected network data. For a full description of the TERGM, we refer the reader to [Leifeld, Cranmer, and Desmarais](http://eprints.gla.ac.uk/139203/ "Temporal exponential random graph models with btergm: estimation and bootstrap confidence intervals").

   

Deployment
----------

The visualization frontend is maintained by an Python **http-server**. The system is maintained in a [Docker container](https://hub.docker.com/r/rosericazondekon/authorvis/ "docker pull rosericazondekon/authorvis") to facilitate its use and installation.

   

Future directions
-----------------

Currently, **AuthorVis** is specifically built for Malaria, TB and HIV/AIDS in Benin. Future development will extend the tool to other research domain. We also aim at adding a general purpose module to **AuthorVis** for the visualization of any user-input co-authorship network. This will also require the integration of a data pre-processing module to facilitate the disambiguation and deduplication of co-authorship information. Finally, we will also incorporate a layered structured network visualization functionality to the visualization in order to display temporal changes in the evolution of the co-authorship network.
