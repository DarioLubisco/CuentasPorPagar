---
name: module-report-view
description: Master standardized Module Report View creation with Glassmorphism, specific filters, and interactive logic.
---

# Module Report View - Production Standards

Instructional guide for building professional report views within the **CuentasPorPagar** ecosystem. Follow these standards to ensure visual consistency and functional reliability across all modules.

## 1. UI/UX Foundation (from AGENTS.md & ui-ux-pro-max-skill)

### Essential Tokens
- **Style**: **Glassmorphism** for all containers.
  - `background: rgba(var(--bg-rgb), 0.7);`
  - `backdrop-filter: blur(10px);`
  - `border: 1px solid rgba(255, 255, 255, 0.1);`
- **Typography**: **Inter** (Primary Font).
- **Icons**: **Lucide Icons** exclusively.
- **Theme**: **Dark Mode (Default)**.

## 2. Page & Component Structure

### Unified Report Heading
- **Title**: Standardized centered or left-aligned `<h1>` with a subtle gradient text effect.
- **Controls Row**: A single `<div class="glass-container">` containing:
  - **Date Filters**: Two `<input type="date">` (Start and End).
  - **Update Button**: A button with label **"Procesar"** or **"Actualizar"** (manual trigger for date range).
  - **Dropdown Filters**: Selective `<select>` elements (e.g., Status). These should trigger the filter logic **automatically** on `change`.
  - **Universal Search Box**: A single `<input type="text">` that searches across:
    - Control Number
    - Invoice Number
    - Provider Name
- **Action Buttons**:
  - **Configuration**: `<button id="btnConfig" class="icon-button"><i data-lucide="settings"></i></button>`
  - **Export**: `<button id="btnExport" class="primary-button"><i data-lucide="download"></i> Excel/PDF</button>`

## 3. Interactive Logic Requirements

### filtering & Processing
1. **Dropdowns**: Must invoke `fetchReportData()` immediately on selection change.
2. **Date Range**: Must wait for the user to click the **Process/Update** button before re-fetching data.
3. **Universal Search**: Implement a local or server-side filter that evaluates `query` against `num_control`, `num_factura`, and `proveedor_nombre`.

### Data Table
- **Sorting**: All table headers (`<th>`) must be clickable.
  - Add a Visual Indicator (e.g., arrow up/down) using Lucide icons.
  - Implement sorting logic that toggles between ASC/DESC.
- **Currency Formatting**: Use `Intl.NumberFormat('es-VE', { style: 'currency', currency: 'USD' })` (or BS as per app context).

## 4. Checklist for New Report Pages
- [ ] Container has `backdrop-filter: blur(10px)`.
- [ ] Icons are all from the Lucide set.
- [ ] Font-family is Inter.
- [ ] Universal search box covers "Control", "Invoice", and "Provider".
- [ ] Date filters require manual trigger; dropdowns are automatic.
- [ ] Export buttons have intuitive labels and icons.
- [ ] Clickable headers toggle table sort order.
- [ ] API calls follow `{"data": ..., "message": ...}` structure.

---
*Refer to `examples/template.html` and `examples/logic.js` in the skill folder for reference implementations.*
