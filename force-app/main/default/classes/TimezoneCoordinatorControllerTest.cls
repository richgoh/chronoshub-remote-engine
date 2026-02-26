/**
 * @description Test class for TimezoneCoordinatorController
 * @author      Richard GOH
 * @date        2026-02
 * @project     ChronosHub - Remote Team Collaboration Engine
 */
@isTest
private class TimezoneCoordinatorControllerTest {
    
    @isTest
    static void testGetTimezoneStatuses() {
        Test.startTest();
        
        // Execute
        List<TimezoneCoordinatorController.TimezoneInfo> timezones = 
            TimezoneCoordinatorController.getTimezoneStatuses();
        
        Test.stopTest();
        
        // Verify
        System.assertNotEquals(null, timezones, 'Timezone list should not be null');
        System.assert(timezones.size() > 0, 'Should have at least one timezone');
        
        // Verify structure of first timezone
        TimezoneCoordinatorController.TimezoneInfo firstZone = timezones[0];
        System.assertNotEquals(null, firstZone.region, 'Region should not be null');
        System.assertNotEquals(null, firstZone.timezoneId, 'Timezone ID should not be null');
        System.assertNotEquals(null, firstZone.currentTime, 'Current time should not be null');
        System.assertNotEquals(null, firstZone.isWorkingHours, 'Working hours status should not be null');
    }
    
    @isTest
    static void testTimezoneInfo_AllFields() {
        Test.startTest();
        
        List<TimezoneCoordinatorController.TimezoneInfo> timezones = 
            TimezoneCoordinatorController.getTimezoneStatuses();
        
        Test.stopTest();
        
        // Verify all fields are populated
        for (TimezoneCoordinatorController.TimezoneInfo timezone : timezones) {
            System.assertNotEquals(null, timezone.region, 'Region should be populated');
            System.assertNotEquals(null, timezone.timezoneId, 'Timezone ID should be populated');
            System.assertNotEquals(null, timezone.workingHoursStart, 'Working hours start should be populated');
            System.assertNotEquals(null, timezone.workingHoursEnd, 'Working hours end should be populated');
            System.assertNotEquals(null, timezone.escalationOrder, 'Escalation order should be populated');
            System.assertNotEquals(null, timezone.slaHours, 'SLA hours should be populated');
            System.assertNotEquals(null, timezone.currentTime, 'Current time should be populated');
            System.assertNotEquals(null, timezone.nextWorkingHourStart, 'Next working hour should be populated');
        }
    }
    
    @isTest
    static void testTimezoneStatuses_OrderedByEscalation() {
        Test.startTest();
        
        List<TimezoneCoordinatorController.TimezoneInfo> timezones = 
            TimezoneCoordinatorController.getTimezoneStatuses();
        
        Test.stopTest();
        
        // Verify ordered by escalation order
        if (timezones.size() > 1) {
            for (Integer i = 0; i < timezones.size() - 1; i++) {
                System.assert(
                    timezones[i].escalationOrder <= timezones[i + 1].escalationOrder,
                    'Timezones should be ordered by escalation order'
                );
            }
        }
    }
}