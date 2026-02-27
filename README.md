# 🌍 ChronosHub - Remote Team Collaboration Engine

![Salesforce](https://img.shields.io/badge/Salesforce-00A1E0?style=for-the-badge&logo=salesforce&logoColor=white)
![Apex](https://img.shields.io/badge/Apex-00A1E0?style=for-the-badge&logo=salesforce&logoColor=white)
![LWC](https://img.shields.io/badge/LWC-00A1E0?style=for-the-badge&logo=salesforce&logoColor=white)
![Batch](https://img.shields.io/badge/Batch-00A1E0?style=for-the-badge&logo=salesforce&logoColor=white)

Enterprise-grade Salesforce solution for timezone-aware team collaboration across Europe, Africa, and Asia regions.

---

## 🎯 Business Case

### The Remote Work Tax

Distributed teams lose **30% productivity** due to async chaos:

- ❌ Overlapping meetings across timezones
- ❌ Missed handoffs between regions
- ❌ SLA violations
- ❌ No visibility on regional availability

### ChronosHub Solution

**Intelligent workflow synchronization** that respects regional working hours, automates escalations, and maintains SLAs across global teams.

---

## 🌍 Supported Regions

| Zone          | Timezone       | Working Hours | SLA     | Escalation Order |
| ------------- | -------------- | ------------- | ------- | ---------------- |
| 🇪🇺 **Europe** | Europe/Paris   | 09:00 - 18:00 | 4 hours | 1 (Primary)      |
| 🌍 **Africa** | Africa/Abidjan | 08:00 - 17:00 | 6 hours | 2 (Secondary)    |
| 🌏 **Asia**   | Asia/Singapore | 09:00 - 18:00 | 8 hours | 3 (Tertiary)     |

---

## 🏗️ Architecture

### Complete System Overview

```
┌─────────────────────────────────────────────────────────────┐
│  CONFIGURATION LAYER (Custom Metadata)                      │
│  • TimezonePolicy__mdt (3 regions configured)               │
│  • Working hours, SLA, escalation order per region          │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  DATA ACCESS LAYER (Selector Pattern)                       │
│  • TimezonePolicySelector: Query Custom Metadata            │
│  • Efficient data retrieval with caching                    │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  UTILITY LAYER (Timezone Helper)                            │
│  • TimezoneHelper: Timezone calculations & conversions      │
│  • Working hours detection                                  │
│  • Next available time calculation                          │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  SCHEDULING ENGINE (Apex Scheduler)                         │
│  • TimezoneAwareScheduler: Dynamic CRON scheduling          │
│  • Region-specific job execution                            │
│  • Respects working hours before execution                  │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  ESCALATION ENGINE (Queueable with Callback)                │
│  • EscalationChain: Self-chaining Queueable                 │
│  • Europe → Africa → Asia escalation flow                   │
│  • Automatic retry with region tracking                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  BATCH PROCESSING (Stateful Batch)                          │
│  • DailySummaryBatch: Aggregate daily statistics            │
│  • Database.Stateful for cross-batch data                   │
│  • Regional KPI tracking                                    │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  INTEGRATION LAYER (HTTP Callouts)                          │
│  • SlackNotificationService: External notifications         │
│  • Mock-friendly architecture for testing                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER (Lightning Web Components)              │
│  • timezoneCoordinator: Real-time dashboard                 │
│  • Auto-refresh, visual status indicators                   │
│  • Responsive 3-column grid layout                          │
└─────────────────────────────────────────────────────────────┘
```

---

## ✨ Key Features

### 1. Timezone-Aware Scheduling

- **Dynamic CRON** scheduling based on regional working hours
- **Automatic job skipping** outside working hours
- **Per-region** scheduling capability

### 2. Intelligent Escalation Chain

- **Callback Pattern**: Self-chaining Queueable jobs
- **Automatic failover**: Europe → Africa → Asia
- **Retry logic** with max attempts protection
- **Region tracking** to avoid loops

### 3. Real-Time Dashboard

- **Live timezone status** for all 3 regions
- **Visual indicators**: 🟢 OPEN / 🔴 CLOSED
- **Auto-refresh** every 60 seconds
- **Next open time** calculation
- **SLA & Escalation priority** display

### 4. Daily Summary Batch

- **Stateful processing** across all batches
- **Regional KPI aggregation**
- **Automated reporting**
- **Slack integration** ready

### 5. Slack Integration

- **HTTP Callout** patterns
- **Named Credential** support
- **Multiple notification types**:
  - Daily summaries
  - Escalation alerts
  - Timezone status updates

---

## 🚀 Technical Highlights

### Design Patterns

- ✅ **Selector Pattern** (Data Access Layer)
- ✅ **Service Layer** (Business Logic)
- ✅ **Callback Pattern** (Queueable Chaining)
- ✅ **Stateful Batch** (Cross-batch aggregation)
- ✅ **Mock HTTP Callouts** (Testable integrations)

### Apex Classes (10)

```
1. TimezonePolicySelector       → Data access
2. TimezoneHelper                → Utility functions
3. TimezoneAwareScheduler        → Schedulable
4. EscalationRequest             → Wrapper class
5. EscalationChain               → Queueable
6. TimezoneCoordinatorController → LWC controller
7. DailySummaryBatch             → Batch Apex
8. SlackNotificationService      → HTTP Callouts
9-10. Test classes               → 90%+ coverage
```

### Lightning Web Components (1)

```
timezoneCoordinator → Real-time dashboard
  ├── HTML template
  ├── JavaScript controller
  ├── CSS styling
  └── Jest tests (8 tests)
```

---

## 🧪 Test Coverage

```
╔════════════════════════════════════════════════════════════╗
║          COMPREHENSIVE TEST SUITE                          ║
╠════════════════════════════════════════════════════════════╣
║  Total Tests          : 47                                 ║
║  Apex Tests           : 36 (100% pass)                     ║
║  LWC Tests            : 11 (100% pass)                     ║
║  Pass Rate            : 100%                               ║
║  ─────────────────────────────────────────────────────     ║
║  Apex Coverage        : 90%+                               ║
║  LWC Coverage         : 100%                               ║
╚════════════════════════════════════════════════════════════╝
```

### Test Classes

- `TimezoneAwareSchedulerTest` (15 tests)
- `EscalationChainTest` (11 tests)
- `TimezoneCoordinatorControllerTest` (3 tests)
- `DailySummaryBatchTest` (5 tests)
- `SlackNotificationServiceTest` (5 tests)
- `timezoneCoordinator.test.js` (11 tests)

---

## 📸 Screenshots

### ChronosHub Dashboard

![Dashboard](docs/screenshots/dashboard.png)
_Real-time timezone status with visual indicators_

### Timezone Status Cards

![Cards](docs/screenshots/timezone-cards.png)
_Detailed information per region including SLA and escalation order_

---

## 🎯 Use Cases

### 1. Follow-the-Sun Support

**Scenario**: Global support team handling customer cases 24/7

**Solution**:

- Cases automatically escalate to available regions
- Europe handles cases during 09:00-18:00 CET
- Outside hours → escalates to Africa
- Africa closed → escalates to Asia
- Full 24/7 coverage with regional respect

### 2. Remote Team Coordination

**Scenario**: Distributed team across 3 continents

**Solution**:

- Dashboard shows who's available now
- Schedule meetings only during overlapping hours
- Automated handoffs between regions
- No more "Sorry, wrong timezone" moments

### 3. Compliance & SLA Management

**Scenario**: Company must meet 4-hour SLA globally

**Solution**:

- Each region has defined SLA targets
- Automated escalation ensures SLA met
- Daily reports track SLA performance
- Regional KPIs visible in dashboard

---

## 📦 Installation

### Prerequisites

- Salesforce org (Sandbox or Developer Edition)
- SFDX CLI installed
- Git installed

### Steps

```bash
# 1. Clone repository
git clone https://github.com/richgoh/chronoshub-remote-engine.git
cd chronoshub-remote-engine

# 2. Authenticate to Salesforce
sf org login web --alias chronoshub

# 3. Deploy metadata
sf project deploy start --source-dir force-app

# 4. Assign permission set (if created)
sf org assign permset --name ChronosHub_Admin

# 5. Create Lightning App Page
# Setup → Lightning App Builder → New → Add timezoneCoordinator component
```

---

## 🔧 Configuration

### 1. Timezone Policies (Already configured)

- Europe Zone: 09:00-18:00 CET, 4h SLA
- Africa Zone: 08:00-17:00 GMT, 6h SLA
- Asia Zone: 09:00-18:00 SGT, 8h SLA

### 2. Schedule Jobs (Optional)

```apex
// Schedule hourly check for all regions
String jobId = TimezoneAwareScheduler.scheduleForAllRegions(
    '0 0 * * * ?',  // Every hour
    'ChronosHub Hourly Check'
);

// Schedule region-specific job
String europeJob = TimezoneAwareScheduler.scheduleForRegion(
    'Europe',
    '0 0 9 * * ?',  // Every day at 9am
    'Europe Morning Job'
);
```

### 3. Run Daily Summary Batch

```apex
// Execute batch
Id batchId = DailySummaryBatch.scheduleBatch(200);
```

---

## 🎓 Learning Outcomes

### For Developers

- ✅ **Apex Schedulable** interface implementation
- ✅ **Queueable Callback Pattern** (self-chaining)
- ✅ **Stateful Batch Apex** for aggregation
- ✅ **Custom Metadata Types** for configuration
- ✅ **Lightning Web Components** with @wire
- ✅ **HTTP Callouts** with mocking
- ✅ **Selector Pattern** for clean architecture
- ✅ **Comprehensive testing** strategies

### For Businesses

- ✅ Real-world **remote work** solution
- ✅ **Timezone management** best practices
- ✅ **SLA enforcement** automation
- ✅ **Scalable architecture** for growth

---

## 👤 Author

**Richard GOH**

- 📍 Location: Abidjan, Côte d'Ivoire
- 🎯 Target Market: France, Switzerland, Luxembourg
- 💼 Role: Salesforce Administrator & Developer
- 🌍 Community: Salesforce Community Leader - Ivory Coast
- 🔗 GitHub: [@richgoh](https://github.com/richgoh)| www.linkedin.com/in/richard-goh-admin-dev-salesforce

---

## 📄 License

MIT License - See LICENSE file for details

---

## 🙏 Acknowledgments

Built as a portfolio project demonstrating:

- Enterprise Salesforce architecture
- Advanced Apex patterns
- Modern LWC development
- Production-ready testing practices
- Real-world business problem solving

---

## 🚀 Project Status

**✅ 100% COMPLETE** - Production Ready

All 5 phases completed:

1. ✅ Configuration & Selectors
2. ✅ Scheduling Engine
3. ✅ Escalation Logic
4. ✅ LWC Dashboard
5. ✅ Batch Processing & Integration

**47 tests, 100% pass rate, 90%+ coverage**

---

**🌍 ChronosHub - Making Remote Work... Work**
