# Power BI Model and Dashboard Specification

## Relationships

- DimCustomer[customer_id] 1:* FactSales[customer_id]
- DimProduct[product_id] 1:* FactSales[product_id]
- DimStore[store_id] 1:* FactSales[store_id]
- DimSupplier[supplier_id] 1:* DimProduct[supplier_id]
- DimPromotion[promotion_id] 1:* FactSales[promotion_id]
- DimDate[Date] 1:* FactSales[order_date]

## Recommended Measures

```DAX
Revenue = SUM(FactSales[net_sales])

Gross Profit = SUM(FactSales[gross_profit])

Gross Margin % = DIVIDE([Gross Profit], [Revenue])

Orders = DISTINCTCOUNT(FactSales[order_id])

Average Order Value = DIVIDE([Revenue], [Orders])

Units Sold = SUM(FactSales[quantity])

Return Units = SUM(FactReturns[quantity_returned])

Return Rate = DIVIDE([Return Units], [Units Sold])

On-Time Delivery % = AVERAGE(FactDelivery[on_time_flag])

Revenue MoM % =
VAR PriorMonth = CALCULATE([Revenue], DATEADD(DimDate[Date], -1, MONTH))
RETURN DIVIDE([Revenue] - PriorMonth, PriorMonth)
```

## Dashboard Pages

### 1. Executive Overview
KPI cards: Revenue, Gross Profit, Margin %, Orders, Return Rate, On-Time Delivery %  
Charts: monthly revenue/profit trend, store profit ranking, category margin, channel mix

### 2. Sales and Profitability
Product and category performance, promotion profitability, discount-to-margin analysis

### 3. Inventory Operations
Stockout count, reorder count, overstock value, store/category inventory matrix

### 4. Customer Analytics
Customer value segments, repeat-purchase rate, acquisition-channel profitability

### 5. Supplier and Delivery Performance
Supplier risk score, lead time, on-time rate, late-delivery trend, return reasons

## Slicers

Date, State, Store, Category, Channel, Customer Segment, Promotion, Supplier
