# Bike Store Sales Analysis (SQL)

A SQL project where I analysed the sales data of a bike retail company with three stores in the US. I used MySQL to answer business questions about revenue, products, customers, staff and delivery performance.

## Data

- **Source:** [Bike Store Sample Database (Kaggle)](https://www.kaggle.com/datasets/dillonmyrick/bike-store-sample-database)
- **Period:** January 2016 to 2018 (2018 is not complete, see the note below)
- **Tables (9):** brands, categories, products, customers, stores, staffs, orders, order_items, stocks
- **Size:** 1,445 customers, 1,615 orders, 321 products

The 9 CSV files were imported into MySQL with Workbench's Table Data Import Wizard.

## Tools

- MySQL 8.0
- MySQL Workbench

## Files

| File | Description |
|---|---|
| `bike_store_analysis.sql` | All 47 queries, grouped from basic to advanced |
| `README.md` | Project summary and findings |

## How to run

1. Download the 9 CSV files from the Kaggle link above.
2. Run the first two lines of `bike_store_analysis.sql` to create and select the `bike_store` database.
3. Import the CSV files (Table Data Import Wizard) in this order: brands, categories, stores, staffs, customers, products, orders, order_items, stocks.
4. Run the queries one by one.

## What I did

The queries go from simple to more advanced:

1. **Basic queries:** filtering and sorting (WHERE, ORDER BY, LIKE, IN, BETWEEN)
2. **Aggregation:** GROUP BY, HAVING, COUNT, AVG
3. **Joins:** INNER JOIN across 3 tables, LEFT JOIN to find unsold products, SELF JOIN for staff and managers
4. **Conditions and dates:** CASE WHEN, DATE_FORMAT, DATEDIFF, DAYNAME
5. **Advanced:** CTEs, window functions (RANK, DENSE_RANK, ROW_NUMBER, LAG, running total) and subqueries

Revenue is calculated as `quantity * list_price * (1 - discount)` from the order_items table.

## Key findings

**1. Total revenue was about $7.69 million.**

**2. One brand brings most of the money.** Trek alone made $4.60M, which is about 60% of all revenue.

| Brand | Revenue | Share |
|---|---|---|
| Trek | $4,602,754 | 59.9% |
| Electra | $1,205,321 | 15.7% |
| Surly | $949,507 | 12.3% |

**3. Mountain bikes are the top category.**

| Category | Revenue | Share |
|---|---|---|
| Mountain Bikes | $2,715,080 | 35.3% |
| Road Bikes | $1,665,098 | 21.7% |
| Cruisers Bicycles | $995,033 | 12.9% |

**4. Almost 1 in 3 orders was shipped late.** 458 of 1,445 shipped orders (31.7%) went out after the required date.

| Store | Shipped orders | Late orders | Late % |
|---|---|---|---|
| Santa Cruz Bikes | 284 | 104 | 36.6% |
| Baldwin Bikes | 1,019 | 317 | 31.1% |
| Rowlett Bikes | 142 | 37 | 26.1% |

**5. Very few customers come back.** Only 131 customers (9.1%) ordered more than once, but they brought 22% of the revenue. 1,314 customers bought only one time.

**6. Baldwin Bikes is the biggest store.** It handled most of the orders, and its top staff member, Marcelene Boyer, made $2.62M in sales. The top staff in the other stores were Genna Serrano (Santa Cruz, $853K) and Kali Vargas (Rowlett, $464K).

**Data note:** 2018 orders stop early in the year, so 2018 totals look much lower. This is because the data is incomplete, not because sales dropped. I did not compare 2018 with 2016 and 2017.

## Recommendations

- **Fix late deliveries first.** Over 30% late is high in every store. Santa Cruz has the worst rate (36.6%) and should be checked first.
- **Bring customers back.** More than 90% of customers buy only once. A loyalty offer or follow-up email after the first purchase could increase repeat orders, and repeat customers already spend more.
- **Reduce the risk of depending on one brand.** Trek brings 60% of revenue. Good stock of Trek is important, but promoting Electra and Surly more would make the business safer.
- **Keep mountain bikes well stocked**, since they are the biggest category.

## What I learned

- Joining many tables to get from a sale to a brand, store or staff name
- Using LEFT JOIN with IS NULL to find things that are missing
- Checking the data before trusting a number (the 2018 drop was a data issue, not a sales issue)
- Using window functions to rank inside groups and compare months

## Next step

Build a Power BI dashboard on top of this database to show the monthly trend, brand and category revenue, and late delivery by store.

---

**Sanzida Siddike**
