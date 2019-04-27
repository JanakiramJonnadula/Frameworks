import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/fwPubSub';

export default class FwContinuationDemo extends LightningElement {
    @track latency = '6000';
    @track result = '';

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener('fwControllerResponse', this.processResponseOutput, this);
    }

    processResponseOutput(controllerResponse){
        this.result = controllerResponse;
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    getProducts(){

        const requestName = 'FW_ProductSearchREST';
        let productSearchRequest = {
            productId: null,
            larency: this.latency
        };
        let controllerRequest = {
            requestName : requestName,
            requestInput : productSearchRequest
        }
        fireEvent(this.pageRef, 'fwControllerRequest', controllerRequest);
    }
}