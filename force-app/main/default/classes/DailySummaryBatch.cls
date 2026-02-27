/**
 * @description Batch job to generate daily timezone activity summary
 *              Uses Database.Stateful to maintain state across batches
 * @author      Richard GOH
 * @date        2026-02
 * @project     ChronosHub - Remote Team Collaboration Engine
 */
public class DailySummaryBatch implements Database.Batchable<sObject>, Database.Stateful {
  // Stateful variables - maintained across all batches
  private Map<String, Integer> recordCountByRegion;
  private Map<String, Decimal> totalSLAHours;
  private Integer totalRecordsProcessed;
  private Datetime batchStartTime;

  /**
   * @description Constructor
   */
  public DailySummaryBatch() {
    this.recordCountByRegion = new Map<String, Integer>();
    this.totalSLAHours = new Map<String, Decimal>();
    this.totalRecordsProcessed = 0;
    this.batchStartTime = Datetime.now();
  }

  /**
   * @description Start method - get records to process
   * @param bc BatchableContext
   * @return Database.QueryLocator
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    System.debug('═══ DailySummaryBatch Started ═══');
    System.debug('Start Time: ' + batchStartTime);

    // Initialize counters for each region
    List<TimezonePolicy__mdt> policies = TimezonePolicySelector.getAllActivePolicies();
    for (TimezonePolicy__mdt policy : policies) {
      recordCountByRegion.put(policy.Region__c, 0);
      totalSLAHours.put(policy.Region__c, 0);
    }

    // Query all accounts (or any object you want to summarize)
    // For demo, we'll query accounts with BillingCountry
    return Database.getQueryLocator(
      [
        SELECT Id, Name, BillingCountry, CreatedDate
        FROM Account
        WHERE BillingCountry != NULL
        LIMIT 10000
      ]
    );
  }

  /**
   * @description Execute method - process each batch
   * @param bc BatchableContext
   * @param scope List of records in this batch
   */
  public void execute(Database.BatchableContext bc, List<Account> scope) {
    System.debug('Processing batch of ' + scope.size() + ' records');

    // Get timezone policies map for efficient lookup
    Map<String, TimezonePolicy__mdt> policiesMap = TimezonePolicySelector.getPoliciesByRegionMap();

    // Process each account
    for (Account acc : scope) {
      // Determine region based on country
      String region = determineRegion(acc.BillingCountry);

      if (
        String.isNotBlank(region) && recordCountByRegion.containsKey(region)
      ) {
        // Increment count for this region
        Integer currentCount = recordCountByRegion.get(region);
        recordCountByRegion.put(region, currentCount + 1);

        // Add SLA hours
        TimezonePolicy__mdt policy = policiesMap.get(region);
        if (policy != null) {
          Decimal currentSLA = totalSLAHours.get(region);
          totalSLAHours.put(region, currentSLA + policy.SLAHours__c);
        }

        totalRecordsProcessed++;
      }
    }

    System.debug('Total records processed so far: ' + totalRecordsProcessed);
  }

  /**
   * @description Finish method - generate summary and send notification
   * @param bc BatchableContext
   */
  public void finish(Database.BatchableContext bc) {
    System.debug('═══ DailySummaryBatch Finished ═══');
    System.debug('Finish Time: ' + Datetime.now());

    Datetime batchEndTime = Datetime.now();
    Long executionTime =
      (batchEndTime.getTime() - batchStartTime.getTime()) / 1000; // seconds

    // Build summary report
    String summary = buildSummaryReport(executionTime);

    System.debug(summary);

    // TODO: Send summary via email or Slack
    // For now, just log it
    System.debug('Summary report generated successfully');

    // Optional: Create a custom object record to store the summary
    // createSummaryRecord(summary);
  }

  /**
   * @description Build the summary report
   * @param executionTime Batch execution time in seconds
   * @return Formatted summary string
   */
  private String buildSummaryReport(Long executionTime) {
    String summary = '\n';
    summary += '╔════════════════════════════════════════════════════════════╗\n';
    summary += '║        CHRONOSHUB - DAILY SUMMARY REPORT                   ║\n';
    summary += '╠════════════════════════════════════════════════════════════╣\n';
    summary +=
      '║  Date: ' +
      Datetime.now().format('yyyy-MM-dd HH:mm:ss') +
      '                     ║\n';
    summary +=
      '║  Execution Time: ' +
      executionTime +
      ' seconds                             ║\n';
    summary +=
      '║  Total Records: ' +
      totalRecordsProcessed +
      '                                      ║\n';
    summary += '╠════════════════════════════════════════════════════════════╣\n';

    // Add region-specific data
    for (String region : recordCountByRegion.keySet()) {
      Integer count = recordCountByRegion.get(region);
      Decimal slaTotal = totalSLAHours.get(region);
      Decimal avgSLA = count > 0 ? slaTotal / count : 0;

      summary +=
        '║  ' +
        region.rightPad(20) +
        '                                    ║\n';
      summary +=
        '║    Records: ' +
        String.valueOf(count).leftPad(10) +
        '                              ║\n';
      summary +=
        '║    Avg SLA: ' +
        String.valueOf(avgSLA.setScale(1)).leftPad(10) +
        ' hours                      ║\n';
      summary += '║                                                            ║\n';
    }

    summary += '╚════════════════════════════════════════════════════════════╝\n';

    return summary;
  }

  /**
   * @description Determine region based on country
   * @param country Billing country
   * @return Region name (Europe, Africa, or Asia)
   */
  private String determineRegion(String country) {
    if (String.isBlank(country)) {
      return null;
    }

    // European countries
    Set<String> europeCountries = new Set<String>{
      'France',
      'Germany',
      'United Kingdom',
      'Spain',
      'Italy',
      'Netherlands',
      'Belgium',
      'Switzerland',
      'Austria',
      'Sweden'
    };

    // African countries
    Set<String> africaCountries = new Set<String>{
      'Nigeria',
      'South Africa',
      'Kenya',
      'Ghana',
      'Ivory Coast',
      'Côte d\'Ivoire',
      'Egypt',
      'Morocco',
      'Tunisia',
      'Senegal'
    };

    // Asian countries
    Set<String> asiaCountries = new Set<String>{
      'Singapore',
      'China',
      'Japan',
      'India',
      'South Korea',
      'Malaysia',
      'Thailand',
      'Vietnam',
      'Indonesia',
      'Philippines'
    };

    if (europeCountries.contains(country)) {
      return 'Europe';
    } else if (africaCountries.contains(country)) {
      return 'Africa';
    } else if (asiaCountries.contains(country)) {
      return 'Asia';
    }

    return null;
  }

  /**
   * @description Static method to schedule the batch
   * @param batchSize Batch size (default 200)
   * @return Job ID
   */
  public static Id scheduleBatch(Integer batchSize) {
    if (batchSize == null || batchSize <= 0) {
      batchSize = 200;
    }

    DailySummaryBatch batch = new DailySummaryBatch();
    return Database.executeBatch(batch, batchSize);
  }
}
