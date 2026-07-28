from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
PROCESSED = ROOT / "data" / "processed"

def load(name: str) -> pd.DataFrame:
    path = RAW / f"{name}.csv"
    if not path.exists():
        raise FileNotFoundError(path)
    return pd.read_csv(path)

def main() -> None:
    orders = load("orders")
    items = load("order_items")
    products = load("products")
    customers = load("customers")
    stores = load("stores")
    shipments = load("shipments")
    returns = load("returns")

    for col in ["order_date"]:
        orders[col] = pd.to_datetime(orders[col], errors="coerce")
    for col in ["ship_date","promised_date","delivery_date"]:
        shipments[col] = pd.to_datetime(shipments[col], errors="coerce")

    fact = (
        items.merge(orders, on="order_id", validate="many_to_one")
             .merge(products[["product_id","product_name","category","subcategory","supplier_id","unit_cost"]],
                    on="product_id", validate="many_to_one")
             .merge(customers[["customer_id","segment","state"]].rename(columns={"state":"customer_state"}),
                    on="customer_id", validate="many_to_one")
             .merge(stores[["store_id","store_name","state"]].rename(columns={"state":"store_state"}),
                    on="store_id", validate="many_to_one")
    )

    fact["net_sales"] = fact["quantity"] * fact["unit_price"]
    fact["total_cost"] = fact["quantity"] * fact["unit_cost"]
    fact["gross_profit"] = fact["net_sales"] - fact["total_cost"]
    fact["margin_pct"] = fact["gross_profit"] / fact["net_sales"].replace(0, pd.NA)

    delivery = shipments.copy()
    delivery["days_late"] = (delivery["delivery_date"] - delivery["promised_date"]).dt.days
    delivery["on_time_flag"] = (delivery["days_late"] <= 0).astype(int)

    return_summary = returns.groupby("product_id", as_index=False)["quantity_returned"].sum()

    PROCESSED.mkdir(parents=True, exist_ok=True)
    fact.to_csv(PROCESSED / "fact_sales.csv", index=False)
    delivery.to_csv(PROCESSED / "fact_delivery.csv", index=False)
    return_summary.to_csv(PROCESSED / "product_returns.csv", index=False)

    print(f"fact_sales rows: {len(fact):,}")
    print(f"fact_delivery rows: {len(delivery):,}")
    print(f"products with returns: {len(return_summary):,}")

if __name__ == "__main__":
    main()
