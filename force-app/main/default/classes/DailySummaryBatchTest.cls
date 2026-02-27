/**
 * @description Test class for DailySummaryBatch
 * @author      Richard GOH
 * @date        2026-02
 * @project     ChronosHub - Remote Team Collaboration Engine
 */
@isTest
private class DailySummaryBatchTest {
  @testSetup
  static void setupTestData() {
    // Create test accounts in different regions
    List<Account> testAccounts = new List<Account>();

    // Europe accounts
    testAccounts.add(
      new Account(Name = 'Europe Test 1', BillingCountry = 'France')
    );
    testAccounts.add(
      new Account(Name = 'Europe Test 2', BillingCountry = 'Germany')
    );
    testAccounts.add(
      new Account(Name = 'Europe Test 3', BillingCountry = 'Spain')
    );

    // Africa accounts
    testAccounts.add(
      new Account(Name = 'Africa Test 1', BillingCountry = 'Nigeria')
    );
    testAccounts.add(
      new Account(Name = 'Africa Test 2', BillingCountry = 'South Africa')
    );
    testAccounts.add(
      new Account(Name = 'Africa Test 3', BillingCountry = 'Ivory Coast')
    );

    // Asia accounts
    testAccounts.add(
      new Account(Name = 'Asia Test 1', BillingCountry = 'Singapore')
    );
    testAccounts.add(
      new Account(Name = 'Asia Test 2', BillingCountry = 'Japan')
    );

    // Accounts with no country
    testAccounts.add(
      new Account(Name = 'No Country Test', BillingCountry = null)
    );

    // Accounts with unknown country
    testAccounts.add(
      new Account(Name = 'Unknown Country Test', BillingCountry = 'Antarctica')
    );

    insert testAccounts;
  }

  @isTest
  static void testBatchExecution() {
    Test.startTest();

    // Execute batch
    DailySummaryBatch batch = new DailySummaryBatch();
    Id batchId = Database.executeBatch(batch, 200);

    Test.stopTest();

    // Verify batch job was created
    System.assertNotEquals(null, batchId, 'Batch job should be created');

    // Verify batch completed successfully
    AsyncApexJob job = [
      SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
      FROM AsyncApexJob
      WHERE Id = :batchId
    ];

    System.assertEquals(
      'Completed',
      job.Status,
      'Batch should complete successfully'
    );
    System.assertEquals(0, job.NumberOfErrors, 'Should have no errors');
  }

  @isTest
  static void testScheduleBatch() {
    Test.startTest();

    // Schedule batch with custom batch size
    Id batchId = DailySummaryBatch.scheduleBatch(100);

    Test.stopTest();

    // Verify
    System.assertNotEquals(null, batchId, 'Batch should be scheduled');
  }

  @isTest
  static void testScheduleBatch_DefaultSize() {
    Test.startTest();

    // Schedule batch with default size (null)
    Id batchId = DailySummaryBatch.scheduleBatch(null);

    Test.stopTest();

    // Verify
    System.assertNotEquals(
      null,
      batchId,
      'Batch should be scheduled with default size'
    );
  }

  @isTest
  static void testBatchProcessesAccounts() {
    // Get account count before batch
    Integer accountCount = [
      SELECT COUNT()
      FROM Account
      WHERE BillingCountry != NULL
    ];

    Test.startTest();

    DailySummaryBatch batch = new DailySummaryBatch();
    Database.executeBatch(batch, 200);

    Test.stopTest();

    // Verify accounts were processed (batch completed without error)
    AsyncApexJob job = [
      SELECT Id, Status, NumberOfErrors
      FROM AsyncApexJob
      WHERE ApexClass.Name = 'DailySummaryBatch'
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];

    System.assertEquals('Completed', job.Status, 'Batch should complete');
    System.assertEquals(0, job.NumberOfErrors, 'Should have no errors');
  }

  @isTest
  static void testBatchWithNoAccounts() {
    // Delete all accounts
    delete [SELECT Id FROM Account];

    Test.startTest();

    DailySummaryBatch batch = new DailySummaryBatch();
    Id batchId = Database.executeBatch(batch, 200);

    Test.stopTest();

    // Verify batch completes even with no records
    AsyncApexJob job = [
      SELECT Id, Status, NumberOfErrors
      FROM AsyncApexJob
      WHERE Id = :batchId
    ];

    System.assertEquals(
      'Completed',
      job.Status,
      'Batch should complete even with no accounts'
    );
    System.assertEquals(0, job.NumberOfErrors, 'Should have no errors');
  }
}
