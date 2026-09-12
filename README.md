# Comm-Log Send Reconciliation

## Overview

This repository contains my submission for a data analytics assignment involving the reconciliation of a Finance `target_base` value.

The analysis focuses on:

- **Merchant:** 501
- **Period:** October 2026
- **Campaign:** Diwali
- **Communication type:** Campaign (`2`)

The Finance team provided a `target_base` of **22**. The objective was to reproduce this value from the raw campaign and communication log data and investigate why a straightforward count did not match it.

The analysis was performed using SQLite.

---

## Data

The data contains two tables:

### `campaign`

Contains one row per campaign.

Key columns used:

- `id` — Campaign ID
- `merchant_id` — Merchant owning the campaign
- `parent_id` — Identifies whether a campaign is a retry of another campaign
- `name` — Campaign name
- `creation_status` — Campaign creation/approval status
- `processing_status` — Campaign processing status

### `communication_log`

Contains one row per individual send attempt.

Key columns used:

- `communication_id` — Campaign associated with the send
- `customer_id` — Customer targeted
- `communication_type` — `2` represents Campaign
- `delivery_status` — `900` for delivered and `1100` for failed/soft failure
- `sent_time` — Time of the send

---

## Investigation

### 1. Initial Count

I started with a straightforward count of the relevant communication log records.

The initial result was:

**30 send attempts**

This was higher than the Finance target of **22**, so I investigated the difference rather than applying `DISTINCT` immediately.

### 2. Campaign Eligibility

A campaign is considered eligible for reporting when its creation workflow has a finalized status and its processing status is `processed`.

Campaign `9004` was:

```text
creation_status = approval_awaiting
processing_status = processed
```

Although communication log records existed for this campaign, it had not cleared the approval stage.

It contributed 4 send attempts, which were excluded from the reporting count.

**30 → 26**

### 3. Retry Relationships

The `parent_id` relationship showed that some campaigns were retries of earlier campaigns.

The first retry chain was:

**9001 → 9002 → 9003**

There were 13 send attempts across this chain, but only 10 distinct customers.

The second retry chain was:

**9201 → 9202**

There were 6 send attempts, but only 5 distinct customers.

For a retry chain, multiple attempts for the same customer represent the same underlying communication. Therefore, each customer is counted once across the complete retry chain.

### 4. Standalone Campaign

Campaign `9101` is a standalone campaign with no retry relationship.

It contains 7 send attempts.

One customer appears twice in this campaign. This is a legitimate repeated send within the same campaign, rather than a retry.

Therefore, all 7 send attempts are retained.

This distinction is important because applying `COUNT(DISTINCT customer_id)` across every campaign would incorrectly remove this legitimate repeated send.

---

## Reconciliation

The reconciliation from the initial count to the Finance target is:

| Step | Change | Result |
|---|---|---|
| Initial send-attempt count | — | 30 |
| Exclude ineligible campaign 9004 | -4 | 26 |
| Deduplicate repeated customers across retry chains | -4 | 22 |
| **Final target_base** | | **22** |

The final value can also be broken down by communication family:

| Communication family | Count |
|---|---|
| 9001 → 9002 → 9003 | 10 |
| 9101 standalone | 7 |
| 9201 → 9202 | 5 |
| **Total** | **22** |

Therefore:

**10 + 7 + 5 = 22**

The Finance `target_base` was successfully reproduced.

---

## Key Finding

The main issue was that `communication_log` records send attempts, while `target_base` is calculated differently depending on whether the campaign belongs to a retry family or is a standalone campaign.

Two different cases had to be separated:

- **Retry campaigns** — linked through `parent_id`, where repeated attempts for the same customer count once across the retry chain.
- **Standalone campaigns** — repeated sends to the same customer can represent separate valid events and should remain separate.

The data also showed that communication log records can exist for a campaign that has not yet cleared the approval workflow. Those records therefore cannot automatically be treated as reportable sends.

---

## Surprise Finding

The most surprising finding was that `communication_log` can contain send records for a campaign that has not yet been approved.

Campaign `9004` had `creation_status = approval_awaiting`, but it already had **4 communication log records**. This means the send records cannot be treated as automatically reportable just because they exist in the communication log.

Another important finding was that the same customer can appear multiple times in a standalone campaign without it being a retry. In campaign `9101`, customer `C20` was sent twice. Since the campaign has no retry relationship, both sends are valid events and should be counted separately.

These findings showed that the reconciliation cannot be solved by simply counting rows or applying `COUNT(DISTINCT customer_id)` across the entire dataset. The campaign status and `parent_id` relationship have to be considered when determining the final `target_base`.

---

## SQL Analysis

The `sql/` directory contains the queries used during the investigation.

- `01_naive_query.sql`
- `02_campaign_breakdown.sql`
- `03_status_check.sql`
- `04_eligible_count.sql`
- `05_retry_check.sql`
- `06_standalone_check.sql`
- `07_final_query.sql`
- `08_reconciliation.sql`

The queries are separated by investigation step to show how the initial count was examined and reconciled.

---

## Reconciliation Bridge

The step-by-step reconciliation is available in:

`outputs/reconciliation_bridge.csv`

This provides the transition from the initial count of 30 to the final `target_base` of 22.

---

## Investigation Evidence

Screenshots from the SQLite analysis are available in:

`outputs/screenshots/`

They document the database structure, initial count, campaign breakdown, eligibility investigation, retry investigation, standalone campaign investigation, and final result.

---

## Final Result

The reconciled Finance `target_base` is:

**22**
