/**
 * @description Service class for sending notifications to Slack
 *              Demonstrates HTTP Callout patterns and Named Credential usage
 * @author      Richard GOH
 * @date        2026-02
 * @project     ChronosHub - Remote Team Collaboration Engine
 */
public with sharing class SlackNotificationService {
  // Slack webhook URL (would be configured as Named Credential in production)
  private static final String SLACK_WEBHOOK_ENDPOINT = 'callout:Slack_Webhook';

  /**
   * @description Send daily summary to Slack channel
   * @param summary The summary text to send
   * @return Boolean indicating success
   */
  public static Boolean sendDailySummary(String summary) {
    try {
      // Build Slack message payload
      Map<String, Object> payload = new Map<String, Object>{
        'text' => summary,
        'username' => 'ChronosHub Bot',
        'icon_emoji' => ':robot_face:'
      };

      // Send to Slack
      HttpResponse response = sendToSlack(payload);

      // Check response
      if (response.getStatusCode() == 200) {
        System.debug('✓ Slack notification sent successfully');
        return true;
      } else {
        System.debug('✗ Slack notification failed: ' + response.getStatus());
        return false;
      }
    } catch (Exception e) {
      System.debug('ERROR sending Slack notification: ' + e.getMessage());
      return false;
    }
  }

  /**
   * @description Send escalation notification to Slack
   * @param region Region where escalation occurred
   * @param recordId ID of the escalated record
   * @param reason Escalation reason
   * @return Boolean indicating success
   */
  public static Boolean sendEscalationNotification(
    String region,
    Id recordId,
    String reason
  ) {
    try {
      String message = ':warning: *Escalation Alert*\n';
      message += '*Region:* ' + region + '\n';
      message += '*Record:* ' + recordId + '\n';
      message += '*Reason:* ' + reason + '\n';
      message += '*Time:* ' + Datetime.now().format();

      Map<String, Object> payload = new Map<String, Object>{
        'text' => message,
        'username' => 'ChronosHub Bot',
        'icon_emoji' => ':rotating_light:'
      };

      HttpResponse response = sendToSlack(payload);
      return response.getStatusCode() == 200;
    } catch (Exception e) {
      System.debug('ERROR sending escalation notification: ' + e.getMessage());
      return false;
    }
  }

  /**
   * @description Send timezone status update to Slack
   * @param region Region name
   * @param isOpen Whether region is currently open
   * @return Boolean indicating success
   */
  public static Boolean sendTimezoneStatusUpdate(
    String region,
    Boolean isOpen
  ) {
    try {
      String emoji = isOpen ? ':white_check_mark:' : ':x:';
      String status = isOpen ? 'OPEN' : 'CLOSED';

      String message = emoji + ' *' + region + '* is now *' + status + '*';

      Map<String, Object> payload = new Map<String, Object>{
        'text' => message,
        'username' => 'ChronosHub Bot',
        'icon_emoji' => ':earth_africa:'
      };

      HttpResponse response = sendToSlack(payload);
      return response.getStatusCode() == 200;
    } catch (Exception e) {
      System.debug('ERROR sending timezone status: ' + e.getMessage());
      return false;
    }
  }

  /**
   * @description Internal method to send HTTP request to Slack
   * @param payload Message payload as Map
   * @return HttpResponse
   */
  @TestVisible
  private static HttpResponse sendToSlack(Map<String, Object> payload) {
    // Build HTTP request
    HttpRequest req = new HttpRequest();
    req.setEndpoint(SLACK_WEBHOOK_ENDPOINT);
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');
    req.setBody(JSON.serialize(payload));
    req.setTimeout(10000); // 10 seconds

    // Send request
    Http http = new Http();
    HttpResponse res = http.send(req);

    return res;
  }

  /**
   * @description Format daily summary for Slack
   * @param recordCountByRegion Map of region to record count
   * @param totalRecords Total records processed
   * @return Formatted Slack message
   */
  public static String formatDailySummary(
    Map<String, Integer> recordCountByRegion,
    Integer totalRecords
  ) {
    String message = ':bar_chart: *ChronosHub Daily Summary*\n\n';
    message += '*Total Records:* ' + totalRecords + '\n\n';

    for (String region : recordCountByRegion.keySet()) {
      Integer count = recordCountByRegion.get(region);
      message +=
        ':small_blue_diamond: *' +
        region +
        ':* ' +
        count +
        ' records\n';
    }

    message +=
      '\n_Generated: ' +
      Datetime.now().format('yyyy-MM-dd HH:mm:ss') +
      '_';

    return message;
  }
}
