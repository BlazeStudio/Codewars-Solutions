-- Ranking Regional Sales Performance and Sales Positions Within Region
-- https://www.codewars.com/kata/6530eec919435304ad32fe6a

-- You are given a dataset that captures daily sales amounts from various regions. Your task is to rank the regions based on the date they achieved their highest sales and then rank the sales within each region.
--
-- The daily_sales table is structured as follows:
--
-- * id (integer): A unique identifier for each record.
-- * region_id (integer): The identifier of the region where the sales occurred.
-- * sale_date (date): The date the sales took place.
-- * sales_amount (float): The sales amount for that particular day in the given region.
--
-- Write a SQL query that produces the following output:
--
-- 1) region_id (integer): The identifier of the region.
-- 2) sale_date (date): The date the sales took place.
-- 3) sales_amount (float): The sales amount for that particular day in the given region.
-- 4) sales_rank_within_region (integer): A rank assigned to each sale amount within its specific region. The highest sales for each region receive a rank of 1. If there's a tie in sales amount, we should rank by most recent sale date.
-- 5) earliest_top_sale_rank (integer): Rank of the regions based on the earliest date they achieved their highest sales (i.e., the sales with rank 1). In case two or more regions achieve their highest sales on the same date, the region with the bigger region_id should come first
--
-- We can assume that the region_id and sale_date combination will always be unique. The final output should be ordered first by earliest_top_sale_rank, then by sales_rank_within_region - both in ascending order.
--
-- Thus, for this sample data:
--
-- | id | region_id| sale_date  | sales_amount |
-- +----+----------+------------+--------------+
-- | 1  |    2     | 2023-01-01 |   3200.50    |
-- | 2  |    2     | 2023-01-02 |   4200.75    |
-- | 3  |    2     | 2023-01-04 |   2500.30    |
-- | 4  |    3     | 2023-01-01 |   2900.90    |
-- | 5  |    1     | 2023-01-03 |   3100.80    |
--
-- The Expected Output is the following:
--
-- | region_id| sale_date  | sales_amount | sales_rank_within_region | earliest_top_sale_rank|
-- +----------+------------+--------------+--------------------------+-----------------------+
-- |    3     | 2023-01-01 |   2900.90    |            1             |          1            |
-- |    2     | 2023-01-02 |   4200.75    |            1             |          2            |
-- |    2     | 2023-01-01 |   3200.50    |            2             |          2            |
-- |    2     | 2023-01-04 |   2500.30    |            3             |          2            |
-- |    1     | 2023-01-03 |   3100.80    |            1             |          3            |

WITH ranked_sales AS (
  SELECT
    region_id,
    sale_date,
    sales_amount,
    ROW_NUMBER() OVER (
      PARTITION BY region_id
      ORDER BY sales_amount DESC, sale_date DESC
    ) AS sales_rank_within_region
  FROM daily_sales
),
top_sales AS (
  SELECT
    region_id,
    sale_date AS top_sale_date
  FROM ranked_sales
  WHERE sales_rank_within_region = 1
),
region_ranks AS (
  SELECT
    region_id,
    DENSE_RANK() OVER (
      ORDER BY top_sale_date ASC, region_id DESC
    ) AS earliest_top_sale_rank
  FROM top_sales
)
SELECT
  rs.region_id,
  rs.sale_date,
  rs.sales_amount,
  rs.sales_rank_within_region,
  rr.earliest_top_sale_rank
FROM ranked_sales rs
JOIN region_ranks rr ON rs.region_id = rr.region_id
ORDER BY rr.earliest_top_sale_rank ASC, rs.sales_rank_within_region ASC;
