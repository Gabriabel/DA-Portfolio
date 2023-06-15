WITH prevYear_order_items AS
(
  SELECT
    category,
    sum(sale_price) as total_sales_2021
  FROM
    `sql-project-376612.thelook_ecommerce.order_items` as o
  JOIN
    `sql-project-376612.thelook_ecommerce.products` as p
  ON
    o.product_id = p.id
  WHERE 1=1
    and status = "Complete"
    and extract(YEAR from created_at) = 2021
  GROUP BY
    1
),
thisYear_order_items AS
(
  SELECT
    category,
    sum(sale_price) as total_sales_2022
  FROM
    `sql-project-376612.thelook_ecommerce.order_items` as o
  JOIN
    `sql-project-376612.thelook_ecommerce.products` as p
  ON
    o.product_id = p.id
  WHERE 1=1
    and status = "Complete"
    and extract(YEAR from created_at) = 2022
  GROUP BY
    1
),
prevYear_cost AS
(
  SELECT
    product_category,
    sum(cost) as total_cost_2021
  FROM
    `sql-project-376612.thelook_ecommerce.inventory_items`
  WHERE 1=1
    and extract(YEAR from created_at) = 2021
    and sold_at is not null
  GROUP BY
    1
),
thisYear_cost AS
(
  SELECT
    product_category,
    sum(cost) as total_cost_2022
  FROM
    `sql-project-376612.thelook_ecommerce.inventory_items`
  WHERE 1=1
    and extract(YEAR from created_at) = 2022
    and sold_at is not null
  GROUP BY
    1
)
SELECT
  t.category as category,
  -- NOTES! in this case we will consider revenue as profit because the total cost is MUCH higher
  -- still need more information from the users, and datas need to be reviewed
  round(total_sales_2021, 2) as total_revenue_2021,
  round(total_sales_2022, 2) as total_revenue_2022,
  -- round(total_cost_2021, 2) as total_cost_2021,
  -- round(total_cost_2022, 2) as total_cost_2022,
  -- round(total_sales_2021 - total_cost_2021, 2) as total_profit_2021,
  -- round(total_sales_2022 - total_cost_2022, 2) as total_profit_2022,
  round((total_sales_2022 - total_sales_2021) / total_sales_2021 * 10, 2) as growth_percentage,
  -- NOTES! manualy calculated from sum(total_sales_2022)
  round(total_sales_2022 / 1400153.11 * 100, 2) as market_share_2022,
  case
    when round(total_sales_2022 / 1400153.11 * 100 / 12.37, 2) = 1 then 1.02 -- from 12.37 / 12.18
    else round(total_sales_2022 / 1400153.11 * 100 / 12.37, 2)
  end as highest_market_share_comparison,
FROM
  prevYear_order_items as po
JOIN
  thisYear_order_items as t
ON
  po.category = t.category
-- JOIN
--   prevYear_cost as pc
-- ON
--   po.category = pc.product_category
-- JOIN
--   thisYear_cost as tc
-- ON
--   po.category = tc.product_category
ORDER BY
  4 desc
;