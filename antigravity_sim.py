import math
from datetime import datetime, timedelta

# --- MOCK DATA ---
# DolarToday History
dolar_history = [36.0 + i*0.05 for i in range(30)] # Starts at 36.0, adds 0.05 daily, ending at ~37.45
current_tc = dolar_history[-1]

# Invoices
# Tipo A: Immediate index. Tipo B: Deferred index.
invoices = [
    {"id": "INV-001", "supplier": "Distribuidora ACME", "type": "B", "nominal_bs": 150000, "t_emit": 0, "t_index": 15, "d1": 0.05, "t_d1": 7, "d2": 0.02, "t_d2": 12, "t_due": 30, "priority": "Alta"},
    {"id": "INV-002", "supplier": "Tech Supplies", "type": "A", "nominal_bs": 80000, "t_emit": -5, "t_index": -5, "d1": 0.10, "t_d1": 5, "d2": 0.0, "t_d2": 0, "t_due": 20, "priority": "Media"},
    {"id": "INV-003", "supplier": "Servicios Globales", "type": "B", "nominal_bs": 250000, "t_emit": -2, "t_index": 10, "d1": 0.04, "t_d1": 5, "d2": 0.0, "t_d2": 0, "t_due": 20, "priority": "Baja"},
    {"id": "INV-004", "supplier": "Logistica Sur", "type": "B", "nominal_bs": 120000, "t_emit": 0, "t_index": 5, "d1": 0.08, "t_d1": 3, "d2": 0.03, "t_d2": 4, "t_due": 15, "priority": "Media"},
    {"id": "INV-005", "supplier": "Consultores C.A.", "type": "A", "nominal_bs": 50000, "t_emit": -10, "t_index": -10, "d1": 0.0, "t_d1": 0, "d2": 0.0, "t_d2": 0, "t_due": 30, "priority": "Media"},
]

# Liquidity in Bs for the next 15 days
liquidity = {t: 90000 for t in range(0, 31)} # 90k Bs daily allowed

# --- ENGINE ---
def analyze_trend(history):
    # Calculate average daily return
    returns = [(history[i] - history[i-1])/history[i-1] for i in range(1, len(history))]
    avg_devaluation = sum(returns) / len(returns)
    volatility = math.sqrt(sum((r - avg_devaluation)**2 for r in returns) / len(returns))
    return avg_devaluation, volatility

r_dev, vol = analyze_trend(dolar_history)

def project_tc(t_days, base_tc=current_tc, r=r_dev):
    return base_tc * ((1 + r) ** t_days)

def calculate_amount(invoice, t_pay, r_dev):
    P = invoice["nominal_bs"]
    # Check discount
    discount = 0.0
    if t_pay <= invoice["t_d1"]:
        discount = invoice["d1"]
    elif t_pay <= invoice["t_d2"]:
        discount = invoice["d2"]
    
    amount = P * (1 - discount)
    tc_pay = project_tc(t_pay)
    
    if invoice["type"] == "A":
        # Indexed from t_emit. Nominal was based on tc_emit.
        tc_emit = project_tc(invoice["t_emit"])
        amount = amount * (tc_pay / tc_emit)
    else:
        # Type B
        if t_pay > invoice["t_index"]:
            tc_index = project_tc(invoice["t_index"])
            amount = amount * (tc_pay / tc_index)
            
    usd_cost = amount / tc_pay
    return amount, usd_cost

def recalculate(invoices, liquidity, max_weekly_bs=None):
    schedule = []
    # For each invoice, find the optimal payment day (t=0 to t_due)
    options = []
    for inv in invoices:
        best_t = None
        best_usd = float('inf')
        worst_usd = 0
        costs = []
        for t in range(0, inv["t_due"] + 1):
            amt_bs, usd_cost = calculate_amount(inv, t, r_dev)
            costs.append((t, amt_bs, usd_cost))
            if usd_cost < best_usd:
                best_usd = usd_cost
                best_t = t
            if usd_cost > worst_usd:
                worst_usd = usd_cost
        
        # Sort costs by usd_cost ascending (best paths)
        costs.sort(key=lambda x: x[2])
        options.append({
            "invoice": inv,
            "costs": costs,
            "max_savings_usd": worst_usd - best_usd
        })
    
    # Sort options by savings potential (prioritize high savings and priority)
    priority_map = {"Alta": 3, "Media": 2, "Baja": 1}
    options.sort(key=lambda x: (priority_map[x["invoice"]["priority"]], x["max_savings_usd"]), reverse=True)
    
    daily_spent = {t: 0 for t in range(0, 31)}
    weekly_spent = {w: 0 for w in range(0, 5)}
    
    scheduled_results = []
    total_savings_usd = 0
    total_cost_usd = 0
    
    for opt in options:
        inv = opt["invoice"]
        assigned = False
        for cost_option in opt["costs"]:
            t, amt_bs, usd_cost = cost_option
            w = t // 7
            if daily_spent.get(t, 0) + amt_bs <= liquidity.get(t, 90000):
                if max_weekly_bs is None or weekly_spent.get(w, 0) + amt_bs <= max_weekly_bs:
                    # Assign
                    daily_spent[t] = daily_spent.get(t, 0) + amt_bs
                    weekly_spent[w] = weekly_spent.get(w, 0) + amt_bs
                    worst_usd = max(c[2] for c in opt["costs"])
                    savings = worst_usd - usd_cost
                    total_savings_usd += savings
                    total_cost_usd += usd_cost
                    scheduled_results.append({
                        "id": inv["id"],
                        "supplier": inv["supplier"],
                        "suggested_t": t,
                        "orig_bs": inv["nominal_bs"],
                        "final_bs": amt_bs,
                        "usd_cost": usd_cost,
                        "savings_usd": savings,
                        "priority": inv["priority"],
                        "note": f"t={t}, {100*(inv['nominal_bs']-amt_bs)/inv['nominal_bs'] if amt_bs < inv['nominal_bs'] else 0:.1f}% disc/idx"
                    })
                    assigned = True
                    break
        if not assigned:
             # Force assignment on due date if liquidity failed
             t_due = inv["t_due"]
             amt_bs, usd_cost = calculate_amount(inv, t_due, r_dev)
             scheduled_results.append({
                        "id": inv["id"],
                        "supplier": inv["supplier"],
                        "suggested_t": t_due,
                        "orig_bs": inv["nominal_bs"],
                        "final_bs": amt_bs,
                        "usd_cost": usd_cost,
                        "savings_usd": 0,
                        "priority": inv["priority"],
                        "note": f"LIQUIDITY FORCED t={t_due}"
             })
             total_cost_usd += usd_cost

    return scheduled_results, total_savings_usd, total_cost_usd

# Scenario 1: Unconstrained
res1, sv1, c1 = recalculate(invoices, liquidity)

# Scenario 2: Constrained to 100k Bs per week
res2, sv2, c2 = recalculate(invoices, liquidity, max_weekly_bs=100000)

print(f"RATE: {r_dev*100:.4f}% | VOL: {vol*100:.4f}%")
print("--- SCENARIO 1: UNCONSTRAINED ---")
from pprint import pprint
pprint(res1)
print(f"Savings: {sv1:.2f} USD")

print("--- SCENARIO 2: RESTRICTED 100k Bs/Week ---")
pprint(res2)
print(f"Savings: {sv2:.2f} USD")
print(f"Loss of savings due to constraint: {sv1 - sv2:.2f} USD")
