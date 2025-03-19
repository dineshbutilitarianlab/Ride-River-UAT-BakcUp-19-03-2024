/*
 * @File Name          : VisualDPE.Js
 * @Description        : 
 * @Author             : Swapna Deshpande
 * @Last Modified By   : Swapna Deshpande
 * @Last Modified On   : 
 * @Modification Log   : 
 * Ver       Date            Author            Modification
 * 1.0    04/20/2022      Swapna Deshpande    Initial Version
*/
/*eslint vars-on-top: "error"*/
import { api,LightningElement } from 'lwc';
import visNetwork from '@salesforce/resourceUrl/visNetwork';
import visData from '@salesforce/resourceUrl/visData';
import getDPEMetadata from '@salesforce/apex/debugDPEController.getDPEMetadata';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
export default class VisualDPE extends LightningElement {
    @api fileData;
    showLoadingSpinner = false;

    connectedCallback() {
        this.showLoadingSpinner = true;
        Promise.all([
           loadScript(this, visData + '/esnext/umd/vis-data.js')
            , loadScript(this, visNetwork + '/peer/umd/vis-network.js')
           , loadStyle(this, visNetwork + '/styles/vis-network.min.css')
            
        ]).then(() => {
           this.resourcesLoaded = true;
            getDPEMetadata({
                dpeId: this.fileData
            })
                .then(result => {
                    if (result !== undefined) {
                        let dpeData = JSON.parse(result);
                        this.disrenderLegend();
                        this.displayRender(dpeData);

                    }

                }).catch(error => {
                    this.error = error;
                    console.log(error);
                });
           
        })
            .catch(error => {
                this.loading = false;
                console.log('Error Initializing...' + JSON.stringify(error));
            });

    }


    extractToVisFormat(dpeData) {
        let graph;
        if (dpeData !== undefined){
            graph = this.createNodesAndEdgesToVisFormat(dpeData);
        }
        return graph;
    }



    createNodesAndEdgesToVisFormat(data) {

        let nodes = [];
        let edges = [];

        const attributes = [
            { type: 'datasources', icon: 'box' },
            { type: 'filters', icon: 'triangleDown' },
            { type: 'writebacks', icon: 'database' },
            { type: 'transforms', icon: 'hexagon', path: 'transformationType' },
            { type: 'aggregates', icon: 'diamond' }

        ];

        attributes.map(attr => {
            let graph = this.extractNodesAndGraphToVisFormat(data.Metadata[attr.type], attr.type, attr.icon, attr.path);
            nodes = nodes.concat(graph.nodes);
            edges = edges.concat(graph.edges);
        });
        
        // joins nodes type handling
        if (data.Metadata.joins) {
            nodes.push(data.Metadata.joins.map(obj => {

                const node = { id: obj.name, label: obj.name, group: 'joins', title: this.getString(obj, 'join'), shape: 'star' };
                return node;
            }));

            edges.push(data.Metadata.joins.flatMap(obj => {
                const edge1 = { from: obj.primarySourceName, to: obj.name, id: obj.name + obj.primarySourceName };
                const edge2 = { from: obj.secondarySourceName, to: obj.name, id: obj.name + obj.secondarySourceName };
                return [edge1, edge2];
            }));
        }


        // appends nodes type handling
        if (data.Metadata.appends) {
            nodes.push(data.Metadata.appends.map(obj => {
                const node = { id: obj.name, label: obj.name, group: 'appends', title: this.getString(obj, 'appends'), shape: 'square' };
                return node;
            }));

            edges.push(data.Metadata.appends.flatMap(obj => {
                return obj.sources.map(src => { return { from: src, to: obj.name, id: obj.name + src } });
            }));
        }



        // parameters handling
        if (data.Metadata.parameters) {
            nodes.push(data.Metadata.parameters.map(obj => {
                const node = { id: obj.name, label: obj.name, group: 'parameter', title: this.getString(obj, 'parameter'), shape: 'ellipse' };
                return node;
            }));
        }


        nodes = nodes.flat();
        edges = edges.flat();

        return { nodes: nodes, edges: edges };
    }


    extractNodesAndGraphToVisFormat(data, groupName, shapeVal, path) {
        let nodes = [];
        let edges = [];

        if (data) {
            nodes.push(data.map(obj => {
                var node = { id: obj.name, label: obj.name, group: groupName, title: this.getString(obj, groupName), shape: shapeVal };
                return node;
            }));

            edges.push(data.map(obj => {
               
                var edge = { from: obj.sourceName, to: obj.name, id: obj.name + obj.sourceName };
                return edge;
            }));
        }

        return { nodes: nodes, edges: edges };
    }

    getString(obj, groupName) {
        if (obj)
            return JSON.stringify(obj, undefined, 6);
        return groupName;
    }

    LR = {
        randomSeed: undefined,
        improvedLayout: true,
        clusterThreshold: 150,
        hierarchical: {
            enabled: true,
            levelSeparation: 500,
            nodeSpacing: 200,
            treeSpacing: 200,
            blockShifting: false,
            edgeMinimization: false,
            parentCentralization: false,
            direction: 'LR',        // UD, DU, LR, RL
            sortMethod: 'directed',  // hubsize, directed
            shakeTowards: 'leaves'  // roots, leaves
        }
    };

    UD = {
        randomSeed: undefined,
        improvedLayout: true,
        clusterThreshold: 150,
        hierarchical: {
            enabled: true,
            levelSeparation: 200,
            nodeSpacing: 500,
            treeSpacing: 200,
            blockShifting: false,
            edgeMinimization: false,
            parentCentralization: false,
            direction: 'UD',        // UD, DU, LR, RL
            sortMethod: 'directed',  // hubsize, directed
            shakeTowards: 'leaves'  // roots, leaves
        }
    };


    displayRender(dpeData) {
        let layoutOrientation;
        layoutOrientation = this.UD;
        let dt = this.extractToVisFormat(dpeData);
       
        // create an array with nodes
        let nodes = new vis.DataSet(dt.nodes);
        // create an array with edges
        let edges = new vis.DataSet(dt.edges);
        let data = {
            nodes: nodes,
            edges: edges,
        };
        
       
        const options = {
            nodes: {
                fixed: false,
                font: {
                    size: 14, // px
                    bold: {
                        color: '#343434',
                        size: 14, // px
                        face: 'arial',
                        vadjust: 0,
                        mod: 'bold'
                    }
                },
                scaling: {
                    label: true
                },
                size: 25,
                shadow: true
            },
            edges: {
                arrows: 'to',
                shadow: false,
                smooth: true,
            },
            layout: layoutOrientation,
            physics: {
                enabled: false,
                stabilization: false
            },
            manipulation : {
                enabled: true
                , addEdge: true
                , addNode: false
            },
            interaction: {
                dragNodes: true,
                dragView: true,
                hideEdgesOnDrag: false,
                hideEdgesOnZoom: false,
                hideNodesOnDrag: false,
                hover: false,
                hoverConnectedEdges: true,
                
                multiselect: true,
                navigationButtons: true,
                selectable: true,
                selectConnectedEdges: true,
                tooltipDelay: 300,
                zoomSpeed: 1,
                zoomView: true
            }
        } 
        this.showLoadingSpinner = false;
       // eslint-disable-next-line no-unused-vars
       let network = new vis.Network(this.template.querySelector('[data-id="vis-networks"]'), data, options);
       

    }

    isJSON(str) {
        try {
            return (JSON.parse(str) && !!str);
        } catch (e) {
            return false;
        }
    }

    disrenderLegend() {
        let dt = {};

        dt.nodes = [{ id: '1', label: 'datasources', shape: 'box' },
        { id: '2', label: 'filters', shape: 'triangleDown' },
        { id: '3', label: 'writebacks', shape: 'database' },
        { id: '4', label: 'transforms', shape: 'hexagon' },
        { id: '5', label: 'aggregates', shape: 'diamond' },
        { id: '6', label: 'join', shape: 'star' },
        { id: '7', label: 'appends', shape: 'square' }
        ];
        dt.edges = [];
         // create an array with nodes
        let nodes = new vis.DataSet(dt.nodes);
         // create an array with edges
        let edges = new vis.DataSet(dt.edges);
        
        let data = {
            nodes: nodes,
            edges: edges,
        };

        const options = {
            nodes: {
                fixed: false,
                font: {
                    size: 40,
                },
                scaling: {
                    label: true
                },
                size: 35,
                shadow: true
            },
            layout: {
                randomSeed: undefined,
                improvedLayout: true,
                clusterThreshold: 150,
                hierarchical: {
                    enabled: true,
                    levelSeparation: 500,
                    nodeSpacing: 200,
                    treeSpacing: 200,
                    blockShifting: false,
                    edgeMinimization: false,
                    parentCentralization: false,
                    direction: 'LR',        // UD, DU, LR, RL
                    sortMethod: 'directed',  // hubsize, directed
                    shakeTowards: 'leaves'  // roots, leaves
                }
            }
        }
        // create a network
        // eslint-disable-next-line no-unused-vars
        let network = new vis.Network(this.template.querySelector('[data-id="vis-network"]'), data, options);
    }

    toggle() {
        // if (fileData)
        // this.render(fileData);
    }



}