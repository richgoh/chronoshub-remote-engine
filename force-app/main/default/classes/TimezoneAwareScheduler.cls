/**
 * @description Schedulable class for timezone-aware job execution
 *              Executes jobs only during working hours of each region
 * @author      Richard GOH
 * @date        2026-02
 * @project     ChronosHub - Remote Team Collaboration Engine
 */
public with sharing class TimezoneAwareScheduler implements Schedulable {
    
    private String regionFilter;
    
    /**
     * @description Constructor
     * @param regionFilter Optional region filter (e.g., 'Europe', 'Africa', 'Asia')
     */
    public TimezoneAwareScheduler(String regionFilter) {
        this.regionFilter = regionFilter;
    }
    
    /**
     * @description Default constructor (processes all regions)
     */
    public TimezoneAwareScheduler() {
        this.regionFilter = null;
    }
    
    /**
     * @description Execute method called by Salesforce scheduler
     * @param sc SchedulableContext provided by Salesforce
     */
    public void execute(SchedulableContext sc) {
        System.debug('═══ TimezoneAwareScheduler Started ═══');
        System.debug('Region Filter: ' + (regionFilter != null ? regionFilter : 'ALL'));
        
        // Get timezone policies
        List<TimezonePolicy__mdt> policies;
        if (String.isNotBlank(regionFilter)) {
            // Get specific region
            TimezonePolicy__mdt policy = TimezonePolicySelector.getPolicyByRegion(regionFilter);
            policies = policy != null ? new List<TimezonePolicy__mdt>{policy} : new List<TimezonePolicy__mdt>();
        } else {
            // Get all active policies
            policies = TimezonePolicySelector.getAllActivePolicies();
        }
        
        // Process each timezone policy
        Datetime now = Datetime.now();
        Integer jobsExecuted = 0;
        
        for (TimezonePolicy__mdt policy : policies) {
            System.debug('─── Processing Region: ' + policy.Region__c + ' ───');
            
            // Check if current time is within working hours for this timezone
            Boolean isWorkingHours = TimezoneHelper.isWithinWorkingHours(
                now,
                policy.TimezoneId__c,
                policy.WorkingHoursStart__c,
                policy.WorkingHoursEnd__c
            );
            
            // Get local time for logging
            String localTime = TimezoneHelper.formatInTimezone(now, policy.TimezoneId__c);
            
            System.debug('Local Time: ' + localTime);
            System.debug('Working Hours: ' + policy.WorkingHoursStart__c + ' - ' + policy.WorkingHoursEnd__c);
            System.debug('Is Working Hours: ' + isWorkingHours);
            
            if (isWorkingHours) {
                // Execute region-specific job logic here
                executeRegionJob(policy);
                jobsExecuted++;
            } else {
                System.debug('Outside working hours - skipping execution');
            }
        }
        
        System.debug('═══ TimezoneAwareScheduler Finished ═══');
        System.debug('Total Jobs Executed: ' + jobsExecuted);
    }
    
    /**
     * @description Execute job logic for a specific region
     * @param policy The timezone policy for this region
     */
    private void executeRegionJob(TimezonePolicy__mdt policy) {
        System.debug('✓ Executing job for region: ' + policy.Region__c);
        
        // TODO: Add your actual job logic here
        // Examples:
        // - Process Cases for this region
        // - Send notifications
        // - Update records
        // - Trigger escalations
        
        // For now, just log the execution
        System.debug('Job executed successfully for ' + policy.Region__c);
    }
    
    /**
     * @description Schedule this job for a specific region
     * @param region Region name (e.g., 'Europe')
     * @param cronExpression CRON expression for scheduling
     * @param jobName Friendly name for the scheduled job
     * @return Job ID
     */
    public static String scheduleForRegion(String region, String cronExpression, String jobName) {
        TimezoneAwareScheduler scheduler = new TimezoneAwareScheduler(region);
        return System.schedule(jobName, cronExpression, scheduler);
    }
    
    /**
     * @description Schedule this job for all regions
     * @param cronExpression CRON expression for scheduling
     * @param jobName Friendly name for the scheduled job
     * @return Job ID
     */
    public static String scheduleForAllRegions(String cronExpression, String jobName) {
        TimezoneAwareScheduler scheduler = new TimezoneAwareScheduler();
        return System.schedule(jobName, cronExpression, scheduler);
    }
    
    /**
     * @description Get next execution time for a region
     * @param region Region name
     * @return Datetime of next execution
     */
    public static Datetime getNextExecutionTime(String region) {
        TimezonePolicy__mdt policy = TimezonePolicySelector.getPolicyByRegion(region);
        if (policy == null) {
            return null;
        }
        
        return TimezoneHelper.getNextWorkingHourStart(
            policy.TimezoneId__c,
            policy.WorkingHoursStart__c
        );
    }
}