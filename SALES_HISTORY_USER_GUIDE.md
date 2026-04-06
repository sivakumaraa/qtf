# Sales Recording Feature - User Guide

## ✨ New Feature: Sales History Display

Your Sales Recording page now shows **all your historical sales data from the database**. Here's how to use it:

---

## How to Use

### Step 1: Open Sales Recording

- Go to http://localhost:3001
- Click the **"📊 Sales Recording"** tab

### Step 2: Select a Rep

- Click the "Select Rep" dropdown
- Choose a rep (e.g., "Rajesh M")
- **The history automatically loads below the form!**

### Step 3: View Sales History

Below the form, you'll see a table showing:

- **Month** - When the sales were recorded
- **Sales (m³)** - Volume of material sold
- **Bonus (₹)** - Incentive earned if above target
- **Penalty (₹)** - Deduction if below target
- **Net (₹)** - Final compensation (bonus - penalty)

### Step 4: Record New Sales

- Enter sales volume (e.g., 350)
- Select month
- Click **"Calculate & Save"**
- **Your new record appears immediately in the history table!**

---

## What You'll See

### For Reps With History

```
📊 Sales History from Database
┌────────────────────────────────────────────────┐
│ Month      │ Sales │ Bonus  │ Penalty │ Net    │
├────────────┼───────┼────────┼─────────┼────────┤
│ Feb 2026   │ 500m³ │ ₹15000 │ ₹0      │ ₹15000 │
│ Jan 2026   │ 450m³ │ ₹11250 │ ₹0      │ ₹11250 │
└────────────────────────────────────────────────┘
```

### For Reps With No History

```
No sales records found for this rep in the database.
```

---

## Key Features

✅ **Automatic History Loading**

- Stop scrolling! When you select a rep, the history loads automatically
- No page refresh needed

✅ **Real-Time Updates**

- Submit a new sales record
- Watch it appear in the table instantly
- Everything stays up-to-date

✅ **Clear Data Display**

- See exactly how your compensation is calculated
- View bonuses and penalties side-by-side
- Sorted by most recent first

✅ **Session Result Persistence**

- Your current session result stays visible (right side)
- Use the ✕ button to close it
- History table shows all database records

---

## Example Workflow

**Scenario: Recording Sales for Rajesh M**

1. **Open Dashboard** → Go to Sales Recording tab
2. **Select Rep** → Choose "Rajesh M (ID: 2)"
   - Form loads
   - History appears: "500m³, ₹15,000 bonus"
3. **Enter New Sales** → Type "400" m³
4. **Submit** → Click "Calculate & Save"
5. **See Results**
   - Right side: New record with calculation
   - Below: History table updates automatically
   - Shows both old (500m³) and new (400m³) records

---

## FAQ

**Q: Where did all my past sales go?**
A: They're in the database! They now display automatically below the form when you select a rep. Previously, you only saw the current session's result.

**Q: Why does the table automatically update after I submit?**
A: The system automatically fetches the latest records from the database after you save, so you can immediately see your new entry in context with your history.

**Q: Can I see records from different months?**
A: Yes! The history shows all records for the selected rep, regardless of month. They're sorted with the most recent first.

**Q: What if a rep has no sales records yet?**
A: You'll see "No sales records found for this rep in the database." Once you record the first sale, it will appear in the table.

**Q: Is my data really saved?**
A: Absolutely! All data is saved to the MySQL database. The history table proves it's there. Even if you close the app or navigate away, your records persist permanently.

---

## Technical Details

- **Backend Endpoint**: `GET /api/admin/rep-progress-history/:rep_id`
- **Database**: All records stored in `rep_progress` table
- **Auto-Refresh**: Triggers whenever rep is selected or new record submitted
- **Sorting**: Most recent sales appear at the top

---

## Tips & Tricks

💡 **Tip 1**: Compare reps by selecting different ones to see who's performing best

💡 **Tip 2**: The "Net" column shows actual compensation (bonus minus penalty)

💡 **Tip 3**: The "How It Works" section shows the calculation logic with real examples

💡 **Tip 4**: Dates are automatically formatted to show Month + Year for easy reading

---

## Support

If you encounter any issues:

1. Make sure both services are running (Backend: 3000, Frontend: 3001)
2. Try selecting a different rep
3. Check browser console for error messages
4. Refresh the page and try again

**Everything should work seamlessly now!** ✨
