/**
 * @description Apex Controller for timezone-coordinator LWC
 * @author      Richard GOH
 * @date        2026-02
 * @project     ChronosHub - Remote Team Collaboration Engine
 */
public with sharing class TimezoneCoordinatorController {
    
    /**
     * @description Get all timezone policies with current status
     * @return List of timezone info wrappers
     */
    @AuraEnabled(cacheable=true)
    public static List<TimezoneInfo> getTimezoneStatuses() {
        List<TimezoneInfo> timezoneInfos = new List<TimezoneInfo>();
        
        // Get all active timezone policies
        List<TimezonePolicy__mdt> policies = TimezonePolicySelector.getAllActivePolicies();
        
        Datetime now = Datetime.now();
        
        for (TimezonePolicy__mdt policy : policies) {
            TimezoneInfo info = new TimezoneInfo();
            
            // Basic info
            info.region = policy.Region__c;
            info.timezoneId = policy.TimezoneId__c;
            info.workingHoursStart = policy.WorkingHoursStart__c;
            info.workingHoursEnd = policy.WorkingHoursEnd__c;
            info.escalationOrder = Integer.valueOf(policy.EscalationOrder__c);
            info.slaHours = policy.SLAHours__c;
            
            // Current time in timezone
            info.currentTime = TimezoneHelper.formatInTimezone(now, policy.TimezoneId__c);
            
            // Working hours status
            info.isWorkingHours = TimezoneHelper.isWithinWorkingHours(
                now,
                policy.TimezoneId__c,
                policy.WorkingHoursStart__c,
                policy.WorkingHoursEnd__c
            );
            
            // Next working hour start
            Datetime nextStart = TimezoneHelper.getNextWorkingHourStart(
                policy.TimezoneId__c,
                policy.WorkingHoursStart__c
            );
            info.nextWorkingHourStart = TimezoneHelper.formatInTimezone(nextStart, policy.TimezoneId__c);
            
            timezoneInfos.add(info);
        }
        
        return timezoneInfos;
    }
    
    /**
     * @description Wrapper class for timezone information
     */
    public class TimezoneInfo {
        @AuraEnabled public String region { get; set; }
        @AuraEnabled public String timezoneId { get; set; }
        @AuraEnabled public String workingHoursStart { get; set; }
        @AuraEnabled public String workingHoursEnd { get; set; }
        @AuraEnabled public Integer escalationOrder { get; set; }
        @AuraEnabled public Decimal slaHours { get; set; }
        @AuraEnabled public String currentTime { get; set; }
        @AuraEnabled public Boolean isWorkingHours { get; set; }
        @AuraEnabled public String nextWorkingHourStart { get; set; }
    }
}