# نظام احتساب الإجازات — Leaves Calculator v1.3

> A fully client-side, Arabic-first **employee leave management system** built as a single HTML file.  
> Tracks annual leave accrual, compensatory hours, taken leaves, and generates Excel reports — all powered by `localStorage` with no backend required.

---

## Table of Contents

- [Overview](#overview)
- [Live Demo \& Screenshots](#live-demo--screenshots)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Features](#features)
  - [1. Dashboard (الواجهة الرئيسية)](#1-dashboard-الواجهة-الرئيسية)
  - [2. Employee Management (بيانات الموظفين)](#2-employee-management-بيانات-الموظفين)
  - [3. Compensatory Hours (ساعات تعويضية)](#3-compensatory-hours-ساعات-تعويضية)
  - [4. Calculated Balances & Taken Leaves (الإجازات والرصيد)](#4-calculated-balances--taken-leaves-الإجازاتوالرصيد)
  - [5. Statistics (إحصائيات)](#5-statistics-إحصائيات)
  - [6. Guidelines (إرشادات)](#6-guidelines-إرشادات)
- [Business Logic](#business-logic)
  - [Annual Leave Entitlement Rules](#annual-leave-entitlement-rules)
  - [Balance Calculation Algorithm](#balance-calculation-algorithm)
  - [Leave Deduction Priority](#leave-deduction-priority)
  - [Carry-Over & Forfeiture](#carry-over--forfeiture)
- [Data Model](#data-model)
  - [localStorage Keys](#localstorage-keys)
  - [Object Schemas](#object-schemas)
- [PWA Support](#pwa-support)
- [Backup & Restore](#backup--restore)
- [Excel Import / Export](#excel-import--export)
- [UI / UX Design System](#ui--ux-design-system)
- [Getting Started](#getting-started)
- [Configuration & Constants](#configuration--constants)
- [Key Functions Reference](#key-functions-reference)
- [Known Limitations](#known-limitations)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This application is a **self-contained, zero-dependency-server leave management system** designed for organizations that need to:

- Track employee annual leave accrual based on years of service
- Manage compensatory (overtime) hours that convert into leave balance
- Record leaves taken and automatically deduct from the correct balance pool
- Generate per-employee and bulk Excel reports
- Work 100% offline — all data lives in the browser's `localStorage`

The entire application ships as a **single HTML file** (`Leaves Calculator Version 1.3.html`) with inline CSS and JavaScript.

---

## Tech Stack

| Layer        | Technology                                                                 |
| ------------ | -------------------------------------------------------------------------- |
| **Markup**   | HTML5, RTL-first (`dir="rtl"`, `lang="ar"`)                                |
| **Styling**  | [Tailwind CSS](https://tailwindcss.com/) (CDN) + custom inline `<style>`  |
| **Logic**    | Vanilla JavaScript (ES6+), no framework                                   |
| **Storage**  | Browser `localStorage`                                                    |
| **Fonts**    | [Noto Sans Arabic](https://fonts.google.com/noto/specimen/Noto+Sans+Arabic) + [Inter](https://fonts.google.com/specimen/Inter) (Google Fonts) |
| **Excel**    | [SheetJS (xlsx)](https://sheetjs.com/) v0.18.5 (CDN) for import/export    |
| **PWA**      | Inline `manifest.json` via `data:` URI for installability                  |

---

## Project Structure

```
leaves-calculator/
├── Leaves Calculator Version 1.3.html   # The entire application (single file)
├── Picture1.png                          # Optional logo (loaded with graceful fallback)
├── README.md                             # This file
└── .git/                                 # Git version control
```

> **Architecture Note:** The app is a monolithic single-file application. All HTML structure, CSS styles, and JavaScript logic are contained within `Leaves Calculator Version 1.3.html`. This simplifies deployment (just open the file in a browser) but means all ~1,300 lines live in one place.

---

## Features

### 1. Dashboard (الواجهة الرئيسية)

The main tab displayed on load. Shows:

- **Header summary cards** displaying:
  - Available annual balance (days + hours)
  - Available compensatory balance (days + hours)
  - **Total combined balance** (days + hours) — highlighted in gold
- **Selected employee info panel** — read-only fields showing job ID, name, department, hire date, and contracting company
- **Service duration** — auto-calculated from hire date (`X years and Y months` in Arabic grammar)
- **Annual entitlement rate** — days per year based on seniority tier
- **Monthly entitlement rate** — hours and minutes per month
- **Yearly breakdown table** — interactive table showing for each calendar year:
  - Hours earned
  - Carry-over from previous year (days)
  - Hours consumed (editable input per year)
  - Forfeited balance
  - Available balance (hours and days)

### 2. Employee Management (بيانات الموظفين)

- **Add employees manually** with fields: Job ID, Name, Department, Hire Date, Contracting Company
- **Import employees from Excel** (`.xlsx` / `.xls`) — maps Arabic column headers:
  - `اسم الموظف` → Name
  - `الرقم الوظيفي` → Job ID
  - `القسم` → Department
  - `الشركة المتعاقدة` → Company
  - `تاريخ المباشرة` → Hire Date (handles Excel serial dates)
- **Employee registry table** with:
  - Search/filter by name, department, hire date
  - Configurable items per page (50 / 100 / 250 / 500 / custom)
  - Pagination controls
  - "Select" button to load employee into the dashboard
  - "Delete" button with confirmation modal
- **Bulk balance registration** — register calculated balances for all employees in a filtered department at once
- **Smart dropdowns** for Department and Company fields that auto-populate from existing data

### 3. Compensatory Hours (ساعات تعويضية)

Two sub-tabs:

- **Entry form** — add compensatory hour records with:
  - Employee Job ID (validates employee exists)
  - Date (must not be in the future)
  - Number of hours
- **Records list** — filterable table showing all compensatory entries with:
  - Search by name or Job ID
  - Date range filter (from/to)
  - Running total of filtered hours
  - Delete individual entries

### 4. Calculated Balances & Taken Leaves (الإجازات والرصيد)

Two sub-tabs:

#### 4a. Archived Calculated Balances (سجل الأرصدة المحتسبة)

- Stores "snapshots" of employee balances at calculation time
- **Dynamic re-calculation** — even after archiving, balances update dynamically when compensatory hours or taken leaves change
- Filterable by Job ID, Name, Department, Company
- Pagination with configurable page sizes
- Bulk delete and Excel export
- Columns: Job ID, Name, Department, Hire Date, Company, Calculation Date, Annual Balance (hours/days), Compensatory Balance, Taken Leaves, **Total Balance (days)**

#### 4b. Taken Leaves (الإجازات المتمتع بها)

- Record leaves taken with fields:
  - Job ID, Request Date, Request Time, Leave Start Date, Leave Start Time (optional), Return Date, Reason, Total (hours)
- Table listing all recorded leaves with delete capability
- Taken leaves are automatically deducted from the header balances

### 5. Statistics (إحصائيات)

- **By Department** — sorted bar chart showing employee count per department
- **By Company** — sorted bar chart showing employee count per contracting company

### 6. Guidelines (إرشادات)

Static reference page documenting the leave entitlement rules (Arabic text):

- 0–4 years: 21 days/year
- 5–9 years: 23 days/year
- 10–14 years: 25 days/year
- 15+ years: +3 days every 5 years

---

## Business Logic

### Annual Leave Entitlement Rules

The system uses a **tiered seniority model** implemented in `getAnnualRate(hireDate, currentDate)`:

| Years of Service | Annual Entitlement (days) | Monthly Rate (hours) | Monthly Rate (approx.) |
| ---------------- | ------------------------- | -------------------- | ---------------------- |
| 0 – 4            | 21                        | 14h 0m               | 14 hours               |
| 5 – 9            | 23                        | 15h 20m              | 15 hours 20 minutes    |
| 10 – 14          | 25                        | 16h 40m              | 16 hours 40 minutes    |
| 15 – 19          | 28                        | 18h 40m              | +3 days (1st bump)     |
| 20 – 24          | 31                        | 20h 40m              | +3 days (2nd bump)     |
| 25+              | 34+                       | ...                  | +3 every 5 years       |

**Formula (15+ years):**
```
annualDays = 25 + (Math.floor((yearsOfService - 15) / 5) + 1) * 3
```

### Balance Calculation Algorithm

The core function `getSplitBalance(employee)` performs the following:

1. **Determine calculation start date:**
   - If hire day ≤ 15th: start from 1st of hire month
   - If hire day > 15th: start from 1st of the following month

2. **Iterate year by year** from start to current year:
   - Calculate monthly earned hours: `(annualRate × 8 hours/day) / 12` per month
   - Apply manual usage overrides per year
   - Deduct usage from compensatory pool first, then from annual balance
   - Track carry-over between years
   - Track forfeited (non-carried) balance

3. **Apply taken leaves:**
   - Deduct from compensatory balance first
   - Remaining deducted from annual balance

4. **Return** `{ annual: hours, comp: hours }`

### Leave Deduction Priority

When leaves are consumed, the system follows a strict priority:

```
1. Compensatory hours pool → deducted first
2. Annual leave balance    → deducted second
```

This ensures employees use their overtime-earned hours before dipping into their annual entitlement.

### Carry-Over & Forfeiture

- Each year's **earned but unused** annual hours carry over to the next year
- The yearly breakdown table shows a "غير مرحل" (non-carried) column indicating forfeited hours
- Manual usage can be entered per year via editable cells in the yearly breakdown table

---

## Data Model

### localStorage Keys

| Key                          | Type     | Description                                      |
| ---------------------------- | -------- | ------------------------------------------------ |
| `leave_employees`            | `JSON[]` | Array of employee objects                        |
| `leave_extra_hours_v2`       | `JSON[]` | Array of compensatory hour entries               |
| `leave_calculated_balances`  | `JSON[]` | Array of archived balance snapshots              |
| `leave_taken_leaves`         | `JSON[]` | Array of taken leave records                     |
| `leave_usage_overrides`      | `JSON{}` | Nested object: `{ jobId: { year: hours } }`      |
| `leave_emp_name`             | `string` | Last selected employee name (session cache)      |
| `leave_job_id`               | `string` | Last selected employee job ID (session cache)    |
| `leave_hire_date`            | `string` | Last selected employee hire date (session cache) |

### Object Schemas

#### Employee
```javascript
{
  name: "محمد أحمد",         // string — Employee name
  jobId: "EMP001",           // string — Unique job/employee ID
  dept: "الموارد البشرية",    // string — Department
  company: "شركة التعاقد",   // string — Contracting company
  hireDate: "2020-01-15"     // string — ISO date (YYYY-MM-DD)
}
```

#### Extra Hours Entry (Compensatory)
```javascript
{
  id: 1711800000000,         // number — Unix timestamp (unique ID)
  jobId: "EMP001",           // string — References employee
  name: "محمد أحمد",         // string — Denormalized employee name
  date: "2024-06-15",        // string — Date of overtime work
  hours: 4                   // number — Hours worked
}
```

#### Calculated Balance (Archived Snapshot)
```javascript
{
  name: "محمد أحمد",           // string — Employee name at time of calculation
  jobId: "EMP001",             // string — Employee ID
  calcDate: "٢٠٢٤/٠٦/١٥",    // string — Calculation date (Arabic locale)
  annualHours: 168,            // number — Annual balance in hours
  compHours: 24,               // number — Compensatory balance in hours
  totalDays: "24.000"          // string — Total balance in days (formatted)
}
```

#### Taken Leave Entry
```javascript
{
  id: 1711800000000,           // number — Unix timestamp (unique ID)
  jobId: "EMP001",             // string — Employee ID
  name: "محمد أحمد",           // string — Denormalized employee name
  dept: "الموارد البشرية",      // string — Department
  company: "شركة التعاقد",     // string — Contracting company
  reqDate: "2024-06-01",       // string — Request date
  reqTime: "09:30",            // string — Request time
  startDate: "2024-06-10",     // string — Leave start date
  startTime: "08:00",          // string — Leave start time (optional)
  returnDate: "2024-06-15",    // string — Return/resume date
  reason: "إجازة سنوية",       // string — Leave reason
  total: 40                    // number — Total hours of leave
}
```

#### Manual Usage Overrides
```javascript
// Nested structure: { [jobId]: { [year]: hoursConsumed } }
{
  "EMP001": {
    "2022": 56,    // 56 hours consumed in 2022
    "2023": 80     // 80 hours consumed in 2023
  }
}
```

---

## PWA Support

The app includes basic Progressive Web App metadata:

- `<meta name="theme-color">` for browser chrome color
- `<meta name="apple-mobile-web-app-capable">` for iOS home screen
- Inline `manifest.json` via `data:` URI with:
  - App name: "متابع الإجازات الذكي" (Smart Leave Tracker)
  - Short name: "إجازاتي" (My Leaves)
  - Standalone display mode
  - Icon from Flaticon CDN

> **Note:** For full PWA offline support, a Service Worker would need to be added. Currently, the app works offline after initial load since all logic is client-side, but the CDN dependencies (Tailwind, SheetJS, Google Fonts) require internet on first load.

---

## Backup & Restore

### Export Backup
Clicking **"حفظ 💾"** exports all application data as a single JSON file (`Backup.json`):
```json
{
  "manualUsageOverrides": { ... },
  "employees": [ ... ],
  "calculatedBalances": [ ... ],
  "extraHoursEntries": [ ... ],
  "takenLeavesEntries": [ ... ]
}
```

### Import Backup
Clicking **"استعادة 📂"** and selecting a `.json` backup file restores all data, replacing current `localStorage` contents.

### Clear All Data
Clicking **"محو البيانات بالكامل 🗑️"** triggers a confirmation modal, then clears `localStorage` entirely and resets the UI.

---

## Excel Import / Export

### Import Employees (Excel)
- Supported formats: `.xlsx`, `.xls`
- **Replaces** the current employee list entirely
- Expected column headers (Arabic):

| Column Header        | Maps To       |
| -------------------- | ------------- |
| `اسم الموظف`        | `name`        |
| `الرقم الوظيفي`     | `jobId`       |
| `القسم`              | `dept`        |
| `الشركة المتعاقدة`  | `company`     |
| `تاريخ المباشرة`    | `hireDate`    |

- Handles Excel serial date numbers automatically via `XLSX.SSF.format()`

### Export Individual Report (Excel)
- Exports the currently displayed yearly breakdown table for the selected employee
- Includes employee info header rows

### Export Calculated Balances (Excel)
- Exports the full archived balances table with all columns
- Dynamically recalculates balances at export time
- File name includes the current date in Arabic locale

---

## UI / UX Design System

### Color Palette

| Token             | Hex       | Usage                              |
| ----------------- | --------- | ---------------------------------- |
| Primary           | `#2A3D71` | Headers, buttons, navigation       |
| Primary Light     | `#415385` | Header action buttons              |
| Accent            | `#F5C416` | Active indicators, CTAs, gold text |
| Background        | `#f1f5f9` | Page background (Slate-100)        |
| Card Background   | `#ffffff` | Content cards                      |
| Border            | `#DBE5F3` | Input borders, separators          |
| Text Primary      | `#2A3D71` | Table text, emphasis               |
| Text Secondary    | `#64748b` | Inactive tabs, muted text          |
| Danger            | `#ef4444` | Delete buttons, error states       |
| Success (Emerald) | `#10b981` | Taken leaves, success notifications|

### Component Patterns

- **Cards** — `border-radius: 16px`, subtle shadow, optional colored left/top border
- **Tables** — Sticky dark header (`bg-[#2A3D71]`), hover rows, 10px font size
- **Inputs** — `border-radius: 8px`, focus ring with primary color, dashed border for readonly
- **Buttons** — Rounded (`rounded-xl`), `active:scale-95` press animation, hover color transitions
- **Modals** — Centered, backdrop blur, border-top accent, icon + title + message pattern
- **Tabs** — Bottom border indicator, gold for main tabs, primary for sub-tabs

### Arabic Text Normalization

The utility function `normalizeArabicText()` enables fuzzy search by:
- Removing Arabic diacritics (tashkeel)
- Normalizing Alef variants (أ, إ, آ, ا → ا)
- Normalizing Taa Marbuta (ة → ه)
- Normalizing Alef Maqsura (ى → ي)

---

## Getting Started

### Prerequisites
- A modern web browser (Chrome, Firefox, Edge, Safari)
- No server, build tools, or installation required

### Running the App

```bash
# Option 1: Simply open the file in your browser
# Double-click "Leaves Calculator Version 1.3.html"

# Option 2: Serve locally (optional, for PWA testing)
npx serve .
```

### Quick Start Workflow

1. **Open** the HTML file in your browser
2. Go to **"بيانات الموظفين"** (Employee Data) tab
3. **Add employees** manually or import from Excel
4. Go back to **"الواجهة الرئيسية"** (Dashboard)
5. **Select an employee** from the registry → their leave balance auto-calculates
6. Optionally enter **manual usage** per year in the breakdown table
7. Click **"تسجيل الرصيد المحتسب"** to archive the calculated balance
8. Track **compensatory hours** in the "ساعات تعويضية" tab
9. Record **taken leaves** in the "الإجازات المتمتع بها" sub-tab
10. **Export** reports to Excel or **backup** data as JSON

---

## Configuration & Constants

| Constant        | Value | Location                  | Description                         |
| --------------- | ----- | ------------------------- | ----------------------------------- |
| `HOURS_PER_DAY` | `8`   | Line 606, `<script>` tag  | Working hours per day (8h workday)  |

The leave entitlement tiers are hardcoded in `getAnnualRate()` (line 680–685). To modify tiers, update the conditional logic there.

---

## Key Functions Reference

| Function                      | Purpose                                                         |
| ----------------------------- | --------------------------------------------------------------- |
| `calculateEverything()`       | Main orchestrator — recalculates all balances for current employee |
| `getSplitBalance(emp)`        | Returns `{annual, comp}` hours for an employee                  |
| `getAnnualRate(hd, cd)`       | Returns annual entitlement in days based on seniority            |
| `renderEmployees()`           | Renders the employee registry with filters and pagination        |
| `renderCalculatedBalances()`  | Renders archived balance table with dynamic recalculation        |
| `renderExtraHoursTable()`     | Renders compensatory hours table with filters                    |
| `renderTakenLeavesTable()`    | Renders taken leaves table                                       |
| `renderStatistics()`          | Renders dept/company breakdown statistics                        |
| `loadEmployee(index)`         | Loads an employee into the dashboard and triggers calculation     |
| `saveCalculatedBalance()`     | Archives current employee's balance to calculated records        |
| `executeBulkRegister()`       | Bulk-registers balances for all employees in a filtered department|
| `addExtraHoursEntry()`        | Adds a new compensatory hours record                             |
| `addTakenLeaveEntry()`        | Adds a new taken leave record                                    |
| `exportBackup()`              | Downloads all data as a JSON backup file                         |
| `importBackup(event)`         | Restores data from a JSON backup file                            |
| `handleExcelUpload(event)`    | Imports employee data from an Excel file                         |
| `exportToExcel()`             | Exports current employee's yearly breakdown to Excel             |
| `exportCalculatedToExcel()`   | Exports all archived balances to Excel                           |
| `normalizeArabicText(text)`   | Normalizes Arabic text for fuzzy search                          |
| `switchTab(tab)`              | Navigates between main tabs                                      |
| `switchExtraSubTab(subTab)`   | Navigates between compensatory hours sub-tabs                    |
| `switchCalcSubTab(subTab)`    | Navigates between calculated/leaves sub-tabs                     |
| `updateManualUsage(year, val)`| Updates manual consumption override for a year                   |
| `showNotification(key, type)` | Displays styled notification modal                               |
| `openResetModal(type, msg)`   | Opens confirmation modal for destructive actions                 |

---

## Known Limitations

1. **No authentication** — Anyone with access to the browser can view/modify all data
2. **localStorage limits** — Typically ~5–10MB per origin; may be insufficient for very large organizations (1000+ employees with years of records)
3. **Single-browser binding** — Data does not sync across browsers or devices (use backup/restore for migration)
4. **CDN dependencies** — Tailwind CSS, SheetJS, and Google Fonts require internet on first load. Cache them or vendor them locally for fully offline deployments
5. **No Service Worker** — PWA manifest is present but no offline caching strategy is implemented
6. **Excel import replaces** — Importing employees from Excel replaces the entire employee list rather than merging
7. **No undo** — Deletions and data clears are irreversible (use backup before destructive operations)
8. **Single-file architecture** — All logic in one file makes the codebase harder to maintain as it grows

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Edit `Leaves Calculator Version 1.3.html` (the single source file)
4. Test in multiple browsers (Chrome, Firefox, Safari, Edge)
5. Submit a Pull Request with a clear description

### Development Tips

- Use browser DevTools → Application → Local Storage to inspect/debug data
- The app auto-saves to `localStorage` on every data mutation
- Use the built-in backup/restore feature to save test data between sessions
- Arabic text is fully RTL; test UI changes on both desktop and mobile viewports

---

## License

This project is provided as-is. Please add a license file if you intend to distribute it.
