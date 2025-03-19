/*
 * @File Name          : showDPENode.Js
 * @Description        : 
 * @Author             : Swapna Deshpande
 * @Last Modified By   : Swapna Deshpande
 * @Last Modified On   : 
 * @Modification Log   : 
 * Ver       Date            Author            Modification
 * 1.0    04/20/2022      Swapna Deshpande    Initial Version
*/
import { LightningElement, api } from 'lwc';
import getDPEResponse from '@salesforce/apex/debugDPEController.updateDPEFile';

const COLS = [
    { label: 'Source Node', fieldName: 'from' },
    { label: 'Target Node', fieldName: 'to' }
];

export default class ShowDPENode extends LightningElement {

    searchActivity = [];
    fieldLabelActivity = 'Data Source';
    optionsActivityTemp = [];
    testoptions = [];
    testselectedValues = [];
    selectedValues = [];
    passValues = [];
    filedata;
    @api filedatav1;
    datasourcev1;
    nodesv1;
    showList = true;
    checkDebugNode = false;
    checkSize = false;
    richtext = "<h2 style=\"text-align: center; font-size: 1em;\"> Info: Debug nodes already present in selected DPE. Please verify before adding new ones</h2>";
    richtextsize = "<h2 style=\"text-align: center; font-size: 1em;\"> Less than 20 nodes should be selected </h2>";

    searchKey = '';
    contacts;
    error;
    areMapsVisible = false;
    showPicklists = false;
    get msOptions() {
        return [
            { label: 'Select Value', value: 'Select Value' },

        ];
    }
    columns = COLS;
    data;
    showLoadingSpinner = false;
    MAX_FILE_SIZE = 2000000; //Max file size 2.0 MB
    filesUploaded = [];
    filename;
    value = 'inProgress';

    @api jsonData(data, selectDPEName) {

        this.filedata = JSON.parse(data);
        this.filename = selectDPEName;
        this.checkDebugNode = false;
        let dt = this.extractToVisFormat(JSON.parse(data));

        this.data = dt.edges;

        this.showLoadingSpinner = false;
    }
    connectedCallback() {
        this.showLoadingSpinner = true;
    }
    extractToVisFormat(dpeData) {
        let graph = this.createNodesAndEdgesToVisFormat(dpeData);
        return graph;
    }

    createNodesAndEdgesToVisFormat(data) {

        let nodes = [];
        let edges = [];
        let datasouces = [];
        const attributes = [
            { type: 'datasources', icon: 'box' },
            { type: 'filters', icon: 'triangleDown' },
            { type: 'writebacks', icon: 'database' },
            { type: 'transforms', icon: 'hexagon', path: 'transformationType' },
            { type: 'aggregates', icon: 'diamond' }

        ];

        attributes.map(attr => {
            var graph = this.extractNodesAndGraphToVisFormat(data.Metadata[attr.type]);
            nodes = nodes.concat(graph.nodes);
            edges = edges.concat(graph.edges);
        });

        attributes.map(attr => {
            let graph = this.extractNodesAndGraphToVisFormat(data.Metadata[attr.type]);
            if (attr.type === 'datasources') {

                datasouces = datasouces.concat(graph.nodes);
            }

        });
        //To Check existing Debug Nodes
        nodes[4].forEach(item => {
            if (item.label.includes('Debug')) {

                this.checkDebugNode = true;
            }
        });
        this.testoptions = datasouces;
        this.datasourcev1 = datasouces;
        this.nodesv1 = nodes;

        this.template.querySelectorAll('c-dpe-debugmulti-select-combo').forEach(element => {
            if (element.label === 'Data Sources') {
                element.refreshOptions(datasouces[0]);
            }

            if (element.label === 'Filters') {
                element.refreshOptions(nodes[1]);
            }

            if (element.label === 'Joins') {
                element.refreshOptions(nodes[3]);
            }

            if (element.label === 'Groups and Aggregates') {
                element.refreshOptions(nodes[4]);
            }

            if (element.label === 'Writeback Objects') {
                element.refreshOptions(nodes[2]);
            }
        });

        nodes = nodes.flat();
        edges = edges.flat();

        return { nodes: nodes, edges: edges };
    }


    extractNodesAndGraphToVisFormat(data) {
        const nodes = [];
        const edges = [];

        if (data) {
            nodes.push(data.map(obj => {
                var node = { label: obj.label, value: obj.name };
                return node;
            }));
            edges.push(data.map(obj => {
                var edge = { from: obj.sourceName, to: obj.name };
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

    handleChange(event) {
        this.areMapsVisible = event.target.checked;

    }

    handleSelect(event) {
        
        let payload = event.detail.payload;
        console.log(payload.values);
        this.testselectedValues = payload.values;
        let pass =
        {
            Name: payload.name,
            Values: payload.values
        };
        this.passValues.push(pass);
        this.selectedValues.push(this.testselectedValues);
    }


    handleJSONUpdate() {
        const merge = this.selectedValues.flat(1);
       if(merge.length <=20 ){
       console.log(JSON.stringify(this.filedata));
        getDPEResponse({ fileData: JSON.stringify(this.filedata), dataSource: JSON.stringify(merge), fileName: this.filename })
            .then((result) => {
                this.contacts = result;
                this.error = undefined;
                const jsonData = this.contacts;
                let data = JSON.stringify(jsonData, null, 4);
                let blobLink = document.createElement('a');
                blobLink.download = this.filename + '.json';
                const blob = new Blob([data], { type: 'application/octet-stream' });
                blobLink.href = window.URL.createObjectURL(blob);
                
                blobLink.click();
            })
            .catch((error) => {
                this.error = error;
                this.contacts = undefined;
                console.log(this.error);
            });
        }else{
            this.checkSize = true;
        }

    }

}