/**
 * @description Selector class for TimezonePolicy__mdt Custom Metadata
 * @author      Richard GOH
 * @date        2026-02
 * @project     ChronosHub - Remote Team Collaboration Engine
 */
public with sharing class TimezonePolicySelector {
    
    /**
     * @description Get all active timezone policies ordered by escalation order
     * @return List of active TimezonePolicy__mdt records
     */
    public static List<TimezonePolicy__mdt> getAllActivePolicies() {
        return [
            SELECT 
                Id,
                DeveloperName,
                Label,
                Region__c,
                TimezoneId__c,
                WorkingHoursStart__c,
                WorkingHoursEnd__c,
                EscalationOrder__c,
                IsActive__c,
                SLAHours__c
            FROM TimezonePolicy__mdt
            WHERE IsActive__c = true
            ORDER BY EscalationOrder__c ASC
        ];
    }
    
    /**
     * @description Get timezone policy by region
     * @param region The region name (e.g., 'Europe', 'Africa', 'Asia')
     * @return TimezonePolicy__mdt record or null if not found
     */
    public static TimezonePolicy__mdt getPolicyByRegion(String region) {
        List<TimezonePolicy__mdt> policies = [
            SELECT 
                Id,
                DeveloperName,
                Label,
                Region__c,
                TimezoneId__c,
                WorkingHoursStart__c,
                WorkingHoursEnd__c,
                EscalationOrder__c,
                IsActive__c,
                SLAHours__c
            FROM TimezonePolicy__mdt
            WHERE Region__c = :region
            AND IsActive__c = true
            LIMIT 1
        ];
        
        return policies.isEmpty() ? null : policies[0];
    }
    
    /**
     * @description Get all timezone policies as a map by region
     * @return Map<String, TimezonePolicy__mdt> with region as key
     */
    public static Map<String, TimezonePolicy__mdt> getPoliciesByRegionMap() {
        Map<String, TimezonePolicy__mdt> policyMap = new Map<String, TimezonePolicy__mdt>();
        
        for (TimezonePolicy__mdt policy : getAllActivePolicies()) {
            policyMap.put(policy.Region__c, policy);
        }
        
        return policyMap;
    }
}