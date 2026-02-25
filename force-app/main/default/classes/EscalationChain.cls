/**
 * @description Queueable class for escalating work across timezone regions
 *              Implements callback pattern to chain escalations
 * @author      Richard GOH
 * @date        2026-02
 * @project     ChronosHub - Remote Team Collaboration Engine
 */
public class EscalationChain implements Queueable {
    
    private EscalationRequest request;
    
    /**
     * @description Constructor
     * @param request The escalation request wrapper
     */
    public EscalationChain(EscalationRequest request) {
        this.request = request;
    }
    
    /**
     * @description Execute method called by Salesforce
     * @param ctx QueueableContext provided by Salesforce
     */
    public void execute(QueueableContext ctx) {
        System.debug('═══ EscalationChain Started ═══');
        System.debug('Record ID: ' + request.recordId);
        System.debug('Current Region: ' + request.currentRegion);
        System.debug('Retry Count: ' + request.retryCount);
        System.debug('Attempted Regions: ' + request.attemptedRegions);
        
        // Check if max retries reached
        if (request.hasReachedMaxRetries()) {
            handleMaxRetriesReached();
            return;
        }
        
        // Get timezone policy for current region
        TimezonePolicy__mdt policy = TimezonePolicySelector.getPolicyByRegion(request.currentRegion);
        
        if (policy == null) {
            System.debug('ERROR: Policy not found for region: ' + request.currentRegion);
            escalateToNextRegion();
            return;
        }
        
        // Check if current region is within working hours
        Datetime now = Datetime.now();
        Boolean isWorkingHours = TimezoneHelper.isWithinWorkingHours(
            now,
            policy.TimezoneId__c,
            policy.WorkingHoursStart__c,
            policy.WorkingHoursEnd__c
        );
        
        String localTime = TimezoneHelper.formatInTimezone(now, policy.TimezoneId__c);
        System.debug('Local Time in ' + request.currentRegion + ': ' + localTime);
        System.debug('Working Hours: ' + policy.WorkingHoursStart__c + ' - ' + policy.WorkingHoursEnd__c);
        System.debug('Is Working Hours: ' + isWorkingHours);
        
        if (isWorkingHours) {
            // Region is available - handle the request
            handleRequest(policy);
        } else {
            // Region is not available - escalate to next region
            System.debug('Region unavailable - escalating to next region');
            escalateToNextRegion();
        }
        
        System.debug('═══ EscalationChain Finished ═══');
    }
    
    /**
     * @description Handle the request in the current region
     * @param policy The timezone policy for current region
     */
    private void handleRequest(TimezonePolicy__mdt policy) {
        System.debug('✓ Handling request in region: ' + request.currentRegion);
        
        // TODO: Add actual business logic here
        // Examples:
        // - Assign Case to region-specific queue
        // - Send notification to regional team
        // - Update Case status
        // - Log escalation history
        
        // For now, just log success
        System.debug('SUCCESS: Request handled by ' + request.currentRegion);
        System.debug('SLA: ' + policy.SLAHours__c + ' hours');
        
        // Mark region as attempted
        request.addAttemptedRegion(request.currentRegion);
    }
    
    /**
     * @description Escalate to the next available region (Callback Pattern)
     */
    private void escalateToNextRegion() {
        // Mark current region as attempted
        request.addAttemptedRegion(request.currentRegion);
        
        // Get next region based on escalation order
        String nextRegion = getNextRegion();
        
        if (nextRegion == null) {
            System.debug('ERROR: No more regions available for escalation');
            handleNoRegionsAvailable();
            return;
        }
        
        // Update request for next region
        request.currentRegion = nextRegion;
        request.incrementRetry();
        
        System.debug('→ Escalating to: ' + nextRegion);
        
        // CALLBACK: Enqueue new job for next region
        EscalationChain nextChain = new EscalationChain(request);
        System.enqueueJob(nextChain);
    }
    
    /**
     * @description Get the next region in escalation order
     * @return Next region name or null if none available
     */
    private String getNextRegion() {
        // Get all policies ordered by escalation order
        List<TimezonePolicy__mdt> policies = TimezonePolicySelector.getAllActivePolicies();
        
        // Find current region index
        Integer currentIndex = -1;
        for (Integer i = 0; i < policies.size(); i++) {
            if (policies[i].Region__c == request.currentRegion) {
                currentIndex = i;
                break;
            }
        }
        
        // Try next regions in order
        for (Integer i = currentIndex + 1; i < policies.size(); i++) {
            String region = policies[i].Region__c;
            if (!request.attemptedRegions.contains(region)) {
                return region;
            }
        }
        
        // If no next region found, try from beginning (wrap around)
        for (Integer i = 0; i < currentIndex; i++) {
            String region = policies[i].Region__c;
            if (!request.attemptedRegions.contains(region)) {
                return region;
            }
        }
        
        return null;
    }
    
    /**
     * @description Handle case when max retries reached
     */
    private void handleMaxRetriesReached() {
        System.debug('ERROR: Max retries reached (' + request.maxRetries + ')');
        System.debug('Attempted regions: ' + request.attemptedRegions);
        
        // TODO: Add fallback logic
        // Examples:
        // - Escalate to management
        // - Send urgent notification
        // - Update Case with error status
        // - Log to monitoring system
    }
    
    /**
     * @description Handle case when no regions available
     */
    private void handleNoRegionsAvailable() {
        System.debug('ERROR: No regions available for escalation');
        System.debug('All regions attempted: ' + request.attemptedRegions);
        
        // TODO: Add fallback logic
        // Examples:
        // - Escalate to global support
        // - Queue for next available region
        // - Send alert to management
    }
    
    /**
     * @description Static method to start an escalation chain
     * @param recordId ID of the record to escalate
     * @param initialRegion Starting region (optional - defaults to first in escalation order)
     * @return Job ID
     */
    public static Id startEscalation(Id recordId, String initialRegion) {
        // If no initial region specified, start with first in escalation order
        if (String.isBlank(initialRegion)) {
            List<TimezonePolicy__mdt> policies = TimezonePolicySelector.getAllActivePolicies();
            if (policies.isEmpty()) {
                throw new EscalationException('No active timezone policies found');
            }
            initialRegion = policies[0].Region__c;
        }
        
        // Create escalation request
        EscalationRequest request = new EscalationRequest(recordId, initialRegion);
        
        // Start the chain
        EscalationChain chain = new EscalationChain(request);
        return System.enqueueJob(chain);
    }
    
    /**
     * @description Custom exception for escalation errors
     */
    public class EscalationException extends Exception {}
}