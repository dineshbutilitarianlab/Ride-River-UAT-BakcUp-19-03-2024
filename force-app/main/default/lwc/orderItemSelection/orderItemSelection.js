import { LightningElement, api, wire } from 'lwc';
import getOrderProducts from '@salesforce/apex/ShipmentController.getOrderProducts';
import createShipmentItems from '@salesforce/apex/ShipmentController.createShipmentItems';

export default class OrderItemSelection extends LightningElement {
    @api orderId;
    @api shipmentId;
    selectedOrderProductIds = [];
    orderProducts;
    columns = [
        { label: 'Product Name', fieldName: 'Product2.Name', type: 'text' },
        { label: 'Quantity', fieldName: 'Quantity', type: 'number' },
        { label: 'Unit Price', fieldName: 'UnitPrice', type: 'currency' }
    ];

    @wire(getOrderProducts, { orderId: '$orderId' })
    wiredOrderProducts({ data, error }) {
        if (data) {
            this.orderProducts = data;
        } else {
            console.error('Error fetching order products:', error);
        }
    }

    handleRowSelection(event) {
        this.selectedOrderProductIds = event.detail.selectedRows.map(row => row.Id);
    }

    handleBack() {
        this.dispatchEvent(new CustomEvent('back'));
    }

    handleSave() {
        createShipmentItems({ shipmentId: this.shipmentId, orderProductIds: this.selectedOrderProductIds })
            .then(() => {
                this.dispatchEvent(new CustomEvent('savecomplete'));
            })
            .catch(error => {
                console.error('Error creating shipment items:', error);
            });
    }
}