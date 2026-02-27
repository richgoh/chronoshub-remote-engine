/**
 * @description Test class for SlackNotificationService
 * @author      Richard GOH
 * @date        2026-02
 * @project     ChronosHub - Remote Team Collaboration Engine
 */
@isTest
private class SlackNotificationServiceTest {
  /**
   * Mock HTTP Callout for successful response
   */
  private class MockHttpResponseSuccess implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('ok');
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * Mock HTTP Callout for failed response
   */
  private class MockHttpResponseError implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('error');
      res.setStatusCode(500);
      return res;
    }
  }

  @isTest
  static void testSendDailySummary_Success() {
    // Set mock
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());

    Test.startTest();

    Boolean result = SlackNotificationService.sendDailySummary('Test summary');

    Test.stopTest();

    // Verify
    System.assertEquals(true, result, 'Should return true for successful send');
  }

  @isTest
  static void testSendDailySummary_Failure() {
    // Set mock
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseError());

    Test.startTest();

    Boolean result = SlackNotificationService.sendDailySummary('Test summary');

    Test.stopTest();

    // Verify
    System.assertEquals(false, result, 'Should return false for failed send');
  }

  @isTest
  static void testSendEscalationNotification_Success() {
    // Set mock
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());

    Test.startTest();

    Boolean result = SlackNotificationService.sendEscalationNotification(
      'Europe',
      '500000000000000AAA',
      'Outside working hours'
    );

    Test.stopTest();

    // Verify
    System.assertEquals(
      true,
      result,
      'Should return true for successful notification'
    );
  }

  @isTest
  static void testSendTimezoneStatusUpdate_Success() {
    // Set mock
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());

    Test.startTest();

    Boolean result = SlackNotificationService.sendTimezoneStatusUpdate(
      'Europe',
      true
    );

    Test.stopTest();

    // Verify
    System.assertEquals(
      true,
      result,
      'Should return true for successful status update'
    );
  }

  @isTest
  static void testFormatDailySummary() {
    Test.startTest();

    Map<String, Integer> counts = new Map<String, Integer>{
      'Europe' => 10,
      'Africa' => 5,
      'Asia' => 8
    };

    String formatted = SlackNotificationService.formatDailySummary(counts, 23);

    Test.stopTest();

    // Verify
    System.assert(formatted.contains('23'), 'Should contain total count');
    System.assert(formatted.contains('Europe'), 'Should contain Europe');
    System.assert(formatted.contains('10'), 'Should contain Europe count');
  }
}
