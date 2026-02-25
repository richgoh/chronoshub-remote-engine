/**
 * @description Wrapper class to hold escalation request data
 * @author      Richard GOH
 * @date        2026-02
 * @project     ChronosHub - Remote Team Collaboration Engine
 */
public class EscalationRequest {
    
    // Case or Work Item to escalate
    public Id recordId { get; set; }
    
    // Current region attempting to handle the request
    public String currentRegion { get; set; }
    
    // Number of retry attempts
    public Integer retryCount { get; set; }
    
    // Maximum number of retries before giving up
    public Integer maxRetries { get; set; }
    
    // Reason for escalation
    public String escalationReason { get; set; }
    
    // Original request timestamp
    public Datetime requestTime { get; set; }
    
    // List of regions already attempted
    public List<String> attemptedRegions { get; set; }
    
    /**
     * @description Constructor
     * @param recordId ID of the record to escalate
     * @param initialRegion Starting region
     */
    public EscalationRequest(Id recordId, String initialRegion) {
        this.recordId = recordId;
        this.currentRegion = initialRegion;
        this.retryCount = 0;
        this.maxRetries = 3;
        this.requestTime = Datetime.now();
        this.attemptedRegions = new List<String>();
        this.escalationReason = 'Outside working hours';
    }
    
    /**
     * @description Check if max retries reached
     * @return True if max retries reached
     */
    public Boolean hasReachedMaxRetries() {
        return this.retryCount >= this.maxRetries;
    }
    
    /**
     * @description Increment retry count
     */
    public void incrementRetry() {
        this.retryCount++;
    }
    
    /**
     * @description Add region to attempted list
     * @param region Region name
     */
    public void addAttemptedRegion(String region) {
        if (!this.attemptedRegions.contains(region)) {
            this.attemptedRegions.add(region);
        }
    }
    
    /**
     * @description Get remaining regions to try
     * @param allRegions All available regions
     * @return List of regions not yet attempted
     */
    public List<String> getRemainingRegions(List<String> allRegions) {
        List<String> remaining = new List<String>();
        for (String region : allRegions) {
            if (!this.attemptedRegions.contains(region)) {
                remaining.add(region);
            }
        }
        return remaining;
    }
}