// ignore: dangling_library_doc_comments
/**
 * 
 * CREATE TABLE stock_ageing_report (
  report_date        DATE        NOT NULL,                       -- snapshot date
  shop_id            BIGINT      NOT NULL REFERENCES shop(shop_id),
  product_id         BIGINT      NOT NULL REFERENCES product(product_id),

  -- quantities by age-bucket (days since receipt)
  qty_0_30           INT         NOT NULL DEFAULT 0,
  qty_31_60          INT         NOT NULL DEFAULT 0,
  qty_61_90          INT         NOT NULL DEFAULT 0,
  qty_over_90        INT         NOT NULL DEFAULT 0,

  PRIMARY KEY(report_date, shop_id, product_id)
);

This would be done later, there is minimal use case for this table
 */