import { createElement } from 'lwc';
import TimezoneCoordinator from 'c/timezoneCoordinator';

describe('c-timezone-coordinator', () => {
    afterEach(() => {
        // Clear DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders lightning-card with correct title', () => {
        const element = createElement('c-timezone-coordinator', {
            is: TimezoneCoordinator
        });
        document.body.appendChild(element);

        const card = element.shadowRoot.querySelector('lightning-card');
        expect(card).not.toBeNull();
        expect(card.title).toBe('🌍 ChronosHub - Timezone Coordinator');
    });

    it('has icon-name on lightning-card', () => {
        const element = createElement('c-timezone-coordinator', {
            is: TimezoneCoordinator
        });
        document.body.appendChild(element);

        const card = element.shadowRoot.querySelector('lightning-card');
        expect(card.iconName).toBe('standard:dashboard');
    });

    it('displays loading spinner initially', () => {
        const element = createElement('c-timezone-coordinator', {
            is: TimezoneCoordinator
        });
        document.body.appendChild(element);

        const spinner = element.shadowRoot.querySelector('lightning-spinner');
        expect(spinner).not.toBeNull();
    });

    it('has accessible shadow root', () => {
        const element = createElement('c-timezone-coordinator', {
            is: TimezoneCoordinator
        });
        document.body.appendChild(element);

        expect(element.shadowRoot).not.toBeNull();
    });

    it('renders template with content', () => {
        const element = createElement('c-timezone-coordinator', {
            is: TimezoneCoordinator
        });
        document.body.appendChild(element);

        const templates = element.shadowRoot.querySelectorAll('*');
        expect(templates.length).toBeGreaterThan(0);
    });

    it('uses Salesforce Lightning Design System classes', () => {
        const element = createElement('c-timezone-coordinator', {
            is: TimezoneCoordinator
        });
        document.body.appendChild(element);

        const sldsElements = element.shadowRoot.querySelectorAll('[class*="slds-"]');
        expect(sldsElements.length).toBeGreaterThan(0);
    });

    it('renders multiple child elements', () => {
        const element = createElement('c-timezone-coordinator', {
            is: TimezoneCoordinator
        });
        document.body.appendChild(element);

        const allElements = element.shadowRoot.querySelectorAll('*');
        expect(allElements.length).toBeGreaterThan(1);
    });

    it('can be instantiated without errors', () => {
        const element = createElement('c-timezone-coordinator', {
            is: TimezoneCoordinator
        });
        
        expect(element).not.toBeNull();
        expect(element.tagName.toLowerCase()).toBe('c-timezone-coordinator');
    });
});