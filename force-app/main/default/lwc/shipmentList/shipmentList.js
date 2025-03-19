import { LightningElement, wire } from 'lwc';
import getShipments from '@salesforce/apex/ShipmentController.getShipments';

export default class ShipmentList extends LightningElement {
    shipments;
    columns = [
        { label: 'Shipment Number', fieldName: 'ShipmentNumber', type: 'text' },
        { label: 'Order Number', fieldName: 'Order__r.OrderNumber', type: 'text' },
        { label: 'Source Location', fieldName: 'SourceLocation.Name', type: 'text' },
        { label: 'Destination Location', fieldName: 'DestinationLocation.Name', type: 'text' },
        { label: 'Actual Delivery Date', fieldName: 'ActualDeliveryDate', type: 'date' }
    ];

    @wire(getShipments)
    wiredShipments({ data, error }) {
        if (data) {
            this.shipments = data;
        } else {
            console.error('Error fetching shipments:', error);
        }
    }

    handleBack() {
        this.dispatchEvent(new CustomEvent('back'));
    }
}