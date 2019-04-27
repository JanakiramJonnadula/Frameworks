import { LightningElement, api, wire } from 'lwc';

import startLightningRequest from '@salesforce/apex/FW_Transformation_Controller.startLightningRequest';

import { CurrentPageReference } from 'lightning/navigation';

import { registerListener, unregisterAllListeners, fireEvent } from 'c/fwPubSub';

export default class FwControllerHandler extends LightningElement {

    @api isAsynchronousCallout;
    @wire(CurrentPageReference) pageRef;    

    connectedCallback() {
        registerListener('fwControllerRequest', this.onControllerRequest, this);

        window.addEventListener('message', function(event) {
            if(event.data.result){                 
                this.pageRef = (CurrentPageReference);
                fireEvent(this.pageRef, 'fwControllerResponse', event.data.result);        
            }            
        }, false);

    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    onControllerRequest(controllerRequest){
        if(this.isAsynchronousCallout){
            this.template.querySelector('c-fw-controller-proxy').doInvoke(controllerRequest.requestName, controllerRequest.requestInput);
        }
        else{
            startLightningRequest({ requestName: controllerRequest.requestName,  containerInput: controllerRequest.requestInput})
                .then(result => {
                    fireEvent(this.pageRef, 'fwControllerResponse', result);
                })
                .catch(error => {
                    fireEvent(this.pageRef, 'fwControllerResponse', error);
                });
        }
    }

}