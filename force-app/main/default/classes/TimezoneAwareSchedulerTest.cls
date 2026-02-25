/**
 * @description Test class for TimezoneAwareScheduler and related classes
 * @author      Richard GOH
 * @date        2026-02
 * @project     ChronosHub - Remote Team Collaboration Engine
 */
@isTest
private class TimezoneAwareSchedulerTest {
    
    // ═══════════════════════════════════════════════════
    // TEST 1: TimezonePolicySelector - getAllActivePolicies
    // ═══════════════════════════════════════════════════
    
    @isTest
    static void testGetAllActivePolicies() {
        Test.startTest();
        
        // Execute
        List<TimezonePolicy__mdt> policies = TimezonePolicySelector.getAllActivePolicies();
        
        Test.stopTest();
        
        // Verify
        System.assertNotEquals(null, policies, 'Policies should not be null');
        System.assert(policies.size() > 0, 'Should have at least one active policy');
        
        // Verify they are ordered by EscalationOrder
        if (policies.size() > 1) {
            System.assert(
                policies[0].EscalationOrder__c <= policies[1].EscalationOrder__c,
                'Policies should be ordered by EscalationOrder'
            );
        }
        
        // Verify all policies are active
        for (TimezonePolicy__mdt policy : policies) {
            System.assertEquals(true, policy.IsActive__c, 'All policies should be active');
        }
    }
    
    // ═══════════════════════════════════════════════════
    // TEST 2: TimezonePolicySelector - getPolicyByRegion
    // ═══════════════════════════════════════════════════
    
    @isTest
    static void testGetPolicyByRegion() {
        Test.startTest();
        
        // Execute - Get Europe policy
        TimezonePolicy__mdt europePolicy = TimezonePolicySelector.getPolicyByRegion('Europe');
        
        Test.stopTest();
        
        // Verify
        System.assertNotEquals(null, europePolicy, 'Europe policy should exist');
        System.assertEquals('Europe', europePolicy.Region__c, 'Should be Europe region');
        System.assertEquals(true, europePolicy.IsActive__c, 'Policy should be active');
    }
    
    @isTest
    static void testGetPolicyByRegion_NotFound() {
        Test.startTest();
        
        // Execute - Try to get non-existent region
        TimezonePolicy__mdt policy = TimezonePolicySelector.getPolicyByRegion('NonExistentRegion');
        
        Test.stopTest();
        
        // Verify
        System.assertEquals(null, policy, 'Should return null for non-existent region');
    }
    
    // ═══════════════════════════════════════════════════
    // TEST 3: TimezonePolicySelector - getPoliciesByRegionMap
    // ═══════════════════════════════════════════════════
    
    @isTest
    static void testGetPoliciesByRegionMap() {
        Test.startTest();
        
        // Execute
        Map<String, TimezonePolicy__mdt> policyMap = TimezonePolicySelector.getPoliciesByRegionMap();
        
        Test.stopTest();
        
        // Verify
        System.assertNotEquals(null, policyMap, 'Policy map should not be null');
        System.assert(policyMap.size() > 0, 'Policy map should contain entries');
        
        // Verify Europe exists in map
        System.assert(policyMap.containsKey('Europe'), 'Map should contain Europe');
        System.assertEquals('Europe', policyMap.get('Europe').Region__c, 'Map value should be correct');
    }
    
    // ═══════════════════════════════════════════════════
    // TEST 4: TimezoneHelper - isWithinWorkingHours (TRUE)
    // ═══════════════════════════════════════════════════
    
    @isTest
    static void testIsWithinWorkingHours_True() {
        Test.startTest();
        
        // Create a datetime at 14:00 UTC (15:00 Paris time)
        Datetime testTime = Datetime.newInstance(2026, 2, 24, 14, 0, 0);
        
        // Execute - Check if 15:00 Paris time is within 09:00-18:00
        Boolean isWorking = TimezoneHelper.isWithinWorkingHours(
            testTime,
            'Europe/Paris',
            '09:00',
            '18:00'
        );
        
        Test.stopTest();
        
        // Verify - 15:00 should be within working hours
        System.assertEquals(true, isWorking, '15:00 should be within 09:00-18:00');
    }
    
    @isTest
    static void testIsWithinWorkingHours_False() {
        Test.startTest();
        
        // Create a datetime at 20:00 UTC (21:00 Paris time)
        Datetime testTime = Datetime.newInstance(2026, 2, 24, 20, 0, 0);
        
        // Execute - Check if 21:00 Paris time is within 09:00-18:00
        Boolean isWorking = TimezoneHelper.isWithinWorkingHours(
            testTime,
            'Europe/Paris',
            '09:00',
            '18:00'
        );
        
        Test.stopTest();
        
        // Verify - 21:00 should NOT be within working hours
        System.assertEquals(false, isWorking, '21:00 should NOT be within 09:00-18:00');
    }
    
    // ═══════════════════════════════════════════════════
    // TEST 5: TimezoneHelper - formatInTimezone
    // ═══════════════════════════════════════════════════
    
    @isTest
    static void testFormatInTimezone() {
        Test.startTest();
        
        // Create a specific datetime
        Datetime testTime = Datetime.newInstance(2026, 2, 24, 12, 30, 45);
        
        // Execute
        String formatted = TimezoneHelper.formatInTimezone(testTime, 'Europe/Paris');
        
        Test.stopTest();
        
        // Verify - Should contain date and time
        System.assert(formatted.contains('2026'), 'Should contain year');
        System.assert(formatted.contains('02'), 'Should contain month');
        System.assert(formatted.contains('24'), 'Should contain day');
    }
    
    // ═══════════════════════════════════════════════════
    // TEST 6: TimezoneHelper - parseTime
    // ═══════════════════════════════════════════════════
    
    @isTest
    static void testParseTime() {
        Test.startTest();
        
        // Execute
        Map<String, Integer> parsedTime = TimezoneHelper.parseTime('14:30');
        
        Test.stopTest();
        
        // Verify
        System.assertEquals(14, parsedTime.get('hour'), 'Hour should be 14');
        System.assertEquals(30, parsedTime.get('minute'), 'Minute should be 30');
    }
    
    // ═══════════════════════════════════════════════════
    // TEST 7: TimezoneAwareScheduler - Constructor
    // ═══════════════════════════════════════════════════
    
    @isTest
    static void testSchedulerConstructor() {
        Test.startTest();
        
        // Test default constructor
        TimezoneAwareScheduler scheduler1 = new TimezoneAwareScheduler();
        System.assertNotEquals(null, scheduler1, 'Default scheduler should be created');
        
        // Test constructor with region filter
        TimezoneAwareScheduler scheduler2 = new TimezoneAwareScheduler('Europe');
        System.assertNotEquals(null, scheduler2, 'Scheduler with region filter should be created');
        
        Test.stopTest();
    }
    
    // ═══════════════════════════════════════════════════
    // TEST 8: TimezoneAwareScheduler - execute (All Regions)
    // ═══════════════════════════════════════════════════
    
    @isTest
    static void testSchedulerExecute_AllRegions() {
        Test.startTest();
        
        // Create scheduler
        TimezoneAwareScheduler scheduler = new TimezoneAwareScheduler();
        
        // Execute
        scheduler.execute(null);
        
        Test.stopTest();
        
        // Verify - No exceptions thrown
        System.assert(true, 'Scheduler should execute without errors');
    }
    
    // ═══════════════════════════════════════════════════
    // TEST 9: TimezoneAwareScheduler - execute (Single Region)
    // ═══════════════════════════════════════════════════
    
    @isTest
    static void testSchedulerExecute_SingleRegion() {
        Test.startTest();
        
        // Create scheduler for Europe only
        TimezoneAwareScheduler scheduler = new TimezoneAwareScheduler('Europe');
        
        // Execute
        scheduler.execute(null);
        
        Test.stopTest();
        
        // Verify - No exceptions thrown
        System.assert(true, 'Scheduler should execute for single region without errors');
    }
    
    // ═══════════════════════════════════════════════════
    // TEST 10: TimezoneAwareScheduler - scheduleForRegion
    // ═══════════════════════════════════════════════════
    
    @isTest
    static void testScheduleForRegion() {
        Test.startTest();
        
        // Schedule job for Europe
        String jobId = TimezoneAwareScheduler.scheduleForRegion(
            'Europe',
            '0 0 9 * * ?',
            'Test Europe Job'
        );
        
        Test.stopTest();
        
        // Verify
        System.assertNotEquals(null, jobId, 'Job ID should not be null');
        System.assert(jobId.length() > 0, 'Job ID should not be empty');
        
        // Clean up - Abort the scheduled job
        System.abortJob(jobId);
    }
    
    // ═══════════════════════════════════════════════════
    // TEST 11: TimezoneAwareScheduler - scheduleForAllRegions
    // ═══════════════════════════════════════════════════
    
    @isTest
    static void testScheduleForAllRegions() {
        Test.startTest();
        
        // Schedule job for all regions
        String jobId = TimezoneAwareScheduler.scheduleForAllRegions(
            '0 0 * * * ?',
            'Test All Regions Job'
        );
        
        Test.stopTest();
        
        // Verify
        System.assertNotEquals(null, jobId, 'Job ID should not be null');
        System.assert(jobId.length() > 0, 'Job ID should not be empty');
        
        // Clean up - Abort the scheduled job
        System.abortJob(jobId);
    }
    
    // ═══════════════════════════════════════════════════
    // TEST 12: TimezoneAwareScheduler - getNextExecutionTime
    // ═══════════════════════════════════════════════════
    
    @isTest
    static void testGetNextExecutionTime() {
        Test.startTest();
        
        // Execute
        Datetime nextExecution = TimezoneAwareScheduler.getNextExecutionTime('Europe');
        
        Test.stopTest();
        
        // Verify
        System.assertNotEquals(null, nextExecution, 'Next execution time should not be null');
        System.assert(nextExecution > Datetime.now(), 'Next execution should be in the future');
    }
    
    @isTest
    static void testGetNextExecutionTime_InvalidRegion() {
        Test.startTest();
        
        // Execute with invalid region
        Datetime nextExecution = TimezoneAwareScheduler.getNextExecutionTime('InvalidRegion');
        
        Test.stopTest();
        
        // Verify
        System.assertEquals(null, nextExecution, 'Should return null for invalid region');
    }
}