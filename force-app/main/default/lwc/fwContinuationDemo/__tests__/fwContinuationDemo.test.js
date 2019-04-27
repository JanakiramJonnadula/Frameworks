import { createElement } from 'lwc';
import FwContinuationDemo from 'c/fwContinuationDemo';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/fwPubSub';
import { registerTestWireAdapter } from '@salesforce/lwc-jest';
import { CurrentPageReference } from 'lightning/navigation';

// Mock out the event firing function to verify it was called with expected parameters.
jest.mock('c/fwPubSub', () => {
    return {
        fireEvent: jest.fn(),
        registerListener: jest.fn(),
        unregisterAllListeners: jest.fn()
    };
});

// Register as a standard wire adapter because the component under test requires this adapter.
// We don't exercise this wire adapter in the tests.
registerTestWireAdapter(CurrentPageReference);

describe('c-fw-continuation-demo', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('displays latency', () => {
        const EXPECTED = '6000';
        // Create element
        const element = createElement('c-fw-continuation-demo', {
            is: FwContinuationDemo
        });
        document.body.appendChild(element);

        // Verify default greeting
        const inputEl = element.shadowRoot.querySelector('lightning-input');
        expect(inputEl.value).toBe(`${EXPECTED}`);
    });
});