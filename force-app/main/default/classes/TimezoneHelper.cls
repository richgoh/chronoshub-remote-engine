/**
 * @description Helper class for timezone calculations and conversions
 * @author      Richard GOH
 * @date        2026-02
 * @project     ChronosHub - Remote Team Collaboration Engine
 */
public with sharing class TimezoneHelper {
    
    /**
     * @description Check if a datetime is within working hours for a timezone
     * @param dt The datetime to check
     * @param timezoneId Salesforce timezone ID (e.g., 'Europe/Paris')
     * @param workStart Working hours start (e.g., '09:00')
     * @param workEnd Working hours end (e.g., '18:00')
     * @return True if within working hours, false otherwise
     */
    public static Boolean isWithinWorkingHours(
        Datetime dt, 
        String timezoneId, 
        String workStart, 
        String workEnd
    ) {
        // Convert datetime to the target timezone
        TimeZone tz = TimeZone.getTimeZone(timezoneId);
        Datetime localTime = dt;
        
        // Get hour and minute from the datetime in the timezone
        String timeStr = localTime.format('HH:mm', timezoneId);
        
        // Compare with working hours
        return timeStr >= workStart && timeStr < workEnd;
    }
    
    /**
     * @description Convert a datetime to a specific timezone
     * @param dt The datetime to convert
     * @param timezoneId Target timezone ID
     * @return Formatted datetime string in target timezone
     */
    public static String formatInTimezone(Datetime dt, String timezoneId) {
        return dt.format('yyyy-MM-dd HH:mm:ss z', timezoneId);
    }
    
    /**
     * @description Get the next working hour start for a timezone
     * @param timezoneId Salesforce timezone ID
     * @param workStart Working hours start (e.g., '09:00')
     * @return Datetime of next working hour start
     */
    public static Datetime getNextWorkingHourStart(String timezoneId, String workStart) {
        Datetime now = Datetime.now();
        
        // Get current time in target timezone
        String currentTime = now.format('HH:mm', timezoneId);
        
        // If before work start today, return today's start
        if (currentTime < workStart) {
            return getDatetimeAtTime(now, timezoneId, workStart);
        } else {
            // Otherwise, return tomorrow's start
            Datetime tomorrow = now.addDays(1);
            return getDatetimeAtTime(tomorrow, timezoneId, workStart);
        }
    }
    
    /**
     * @description Create a datetime at a specific time in a timezone
     * @param baseDate The base date
     * @param timezoneId Target timezone
     * @param timeStr Time string (e.g., '09:00')
     * @return Datetime at the specified time
     */
    public static Datetime getDatetimeAtTime(Datetime baseDate, String timezoneId, String timeStr) {
        // Parse the time string (format: HH:MM)
        List<String> timeParts = timeStr.split(':');
        Integer hour = Integer.valueOf(timeParts[0]);
        Integer minute = Integer.valueOf(timeParts[1]);
        
        // Get the date portion in the target timezone
        String dateStr = baseDate.format('yyyy-MM-dd', timezoneId);
        
        // Construct datetime string
        String datetimeStr = dateStr + ' ' + timeStr + ':00';
        
        // Parse back to Datetime (this is in the timezone's local time)
        // We need to convert it to UTC
        return Datetime.valueOfGmt(datetimeStr);
    }
    
    /**
     * @description Parse time string to hour and minute
     * @param timeStr Time in format HH:MM
     * @return Map with 'hour' and 'minute' keys
     */
    public static Map<String, Integer> parseTime(String timeStr) {
        List<String> parts = timeStr.split(':');
        return new Map<String, Integer>{
            'hour' => Integer.valueOf(parts[0]),
            'minute' => Integer.valueOf(parts[1])
        };
    }
}