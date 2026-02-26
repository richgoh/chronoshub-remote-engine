import { LightningElement, wire } from 'lwc';
import getTimezoneStatuses from '@salesforce/apex/TimezoneCoordinatorController.getTimezoneStatuses';
import { refreshApex } from '@salesforce/apex';

export default class TimezoneCoordinator extends LightningElement {
    timezones;
    error;
    isLoading = true;
    lastUpdated;
    wiredTimezoneResult;

    // Region icons mapping
    regionIcons = {
        'Europe': '🇪🇺',
        'Africa': '🌍',
        'Asia': '🌏'
    };

    /**
     * Wire adapter to get timezone statuses
     */
    @wire(getTimezoneStatuses)
    wiredTimezones(result) {
        this.wiredTimezoneResult = result;
        
        if (result.data) {
            // Process data and add icons
            this.timezones = result.data.map(timezone => ({
                ...timezone,
                icon: this.regionIcons[timezone.region] || '🌐'
            }));
            
            this.error = undefined;
            this.isLoading = false;
            this.updateLastUpdated();
        } else if (result.error) {
            this.error = this.reduceErrors(result.error);
            this.timezones = undefined;
            this.isLoading = false;
        }
    }

    /**
     * Handle refresh button click
     */
    handleRefresh() {
        this.isLoading = true;
        
        // Refresh the wired data
        return refreshApex(this.wiredTimezoneResult)
            .then(() => {
                this.updateLastUpdated();
                this.isLoading = false;
            })
            .catch(error => {
                this.error = this.reduceErrors(error);
                this.isLoading = false;
            });
    }

    /**
     * Update last updated timestamp
     */
    updateLastUpdated() {
        const now = new Date();
        this.lastUpdated = now.toLocaleString();
    }

    /**
     * Reduce errors to a single string
     */
    reduceErrors(errors) {
        if (!Array.isArray(errors)) {
            errors = [errors];
        }

        return (
            errors
                // Remove null/undefined items
                .filter(error => !!error)
                // Extract an error message
                .map(error => {
                    // UI API read errors
                    if (Array.isArray(error.body)) {
                        return error.body.map(e => e.message);
                    }
                    // UI API DML, Apex and network errors
                    else if (error.body && typeof error.body.message === 'string') {
                        return error.body.message;
                    }
                    // JS errors
                    else if (typeof error.message === 'string') {
                        return error.message;
                    }
                    // Unknown error shape
                    return 'Unknown error';
                })
                // Flatten
                .reduce((prev, curr) => prev.concat(curr), [])
                // Remove empty strings
                .filter(message => !!message)
                // Join
                .join(', ')
        );
    }

    /**
     * Auto-refresh every 60 seconds
     */
    connectedCallback() {
        // Auto-refresh every minute
        this.refreshInterval = setInterval(() => {
            this.handleRefresh();
        }, 60000); // 60 seconds
    }

    /**
     * Clear interval on disconnect
     */
    disconnectedCallback() {
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
        }
    }
}