import { LightningElement, api, wire } from 'lwc';

import startLightningRequest from '@salesforce/apex/FW_Transformation_Controller.startLightningRequest';

import { CurrentPageReference } from 'lightning/navigation';

import { registerListener, unregisterAllListeners, fireEvent } from 'c/fwPubSub';

import { getRecord } from 'lightning/uiRecordApi';

export default class FwControllerHandler extends LightningElement {

    @api isAsynchronousCallout;

    @wire(CurrentPageReference) pageRef;

    //Flexipage provides recordId and objectApiName
    @api recordId;

    //@wire(getRecord, { recordId: '$recordId', fields }) objectRecord;
    
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
        else if(controllerRequest.requestName === 'FW_GetRecordDetails'){            
            getRecord({ recordId: '$recordId', fields : controllerRequest.requestInput})
                .then(result => {
                    fireEvent(this.pageRef, 'fwControllerResponse', result);
                })
                .catch(error => {
                    fireEvent(this.pageRef, 'fwControllerResponse', error);
                });
        }
        else{
            startLightningRequest({ requestName: controllerRequest.requestName,  containerInput: JSON.stringify(controllerRequest.requestInput)})
                .then(result => {
                    fireEvent(this.pageRef, 'fwControllerResponse', JSON.parse(result));
                })
                .catch(error => {
                    fireEvent(this.pageRef, 'fwControllerResponse', error);
                });
        }
    }

}