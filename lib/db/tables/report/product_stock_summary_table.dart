/**
 * 
 * CREATE TABLE product_stock_summary (
  report_date        DATE        NOT NULL,
  product_id         BIGINT      NOT NULL REFERENCES product(product_id),
  total_qty_on_hand  INT         NOT NULL,
  total_value        DECIMAL(14,2) NOT NULL,
  avg_age_days       INT         NOT NULL,      -- weighted by lot size
  PRIMARY KEY(report_date, product_id)
);
 */

//Notes on Implementation

    // ETL / Materialization

    //     Schedule a nightly job (or use a streaming/materialized-view system) to populate these tables from your base data (inventory, receipts, transfers, orders, etc.).

    // Dashboard & Alerts

    //     Build your UI against these tables for lightning-fast queries (no large joins over transactions).

    //     Trigger alerts when needs_reorder=true or qty_over_90 exceeds configurable thresholds.

    // Extensibility

        // You can add more summary tables, e.g. top_movers_report (fastest-selling products), dead_stock_report (no movement in X days), or financial KPIs like stock_turnover_ratio_report.