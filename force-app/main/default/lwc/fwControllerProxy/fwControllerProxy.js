import { LightningElement, track, wire, api } from 'lwc';
import getVFBaseURL from '@salesforce/apex/FW_Transformation_Controller.getVFBaseURL';

export default class FwControllerProxy extends LightningElement {

    topic = 'com.mycompany.proxy';
    invocationId = '123ddfgdfdf';

    @track vfBaseURL;
    @track error;

    @wire(getVFBaseURL) 
    wiredVFBaseURL({ error, data }) {
        if (data) {
            this.vfBaseURL = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.vfBaseURL = undefined;
        }
    }

    @api
    doInvoke(requestName, requestInput){
        let message = {
            topic: this.topic,
            invocationId: this.invocationId,
            requestName: requestName,
            requestInput: requestInput
        };
        this.template.querySelector('iframe').contentWindow.postMessage(message, this.vfBaseURL);
    }

}