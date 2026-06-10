# Software Quality Assurance — Robot Framework Automated Testing

Automated black-box test suite for the **Student Outbound module** of Universitas Ciputra's internal academic system (`trial.uc.ac.id`), built with Robot Framework and SeleniumLibrary (Chrome).

---

## Project Structure

```
├── test/
│   ├── 01_Outbound-Program.robot   # Program list, detail, and application form tests
│   ├── 02_My-Outbound.robot        # Submitted application management tests
│   └── 03_Request-Document.robot   # Document request page tests
├── resources/                      # Shared keywords and variables
├── chromedriver-win64/             # ChromeDriver binary (Windows x64)
└── TEST_REPORT.md                  # Full defect report and test case catalogue
```

---

## Test Coverage

| Suite | Module | Test Cases |
|---|---|---|
| 01 — Outbound Program | Program list filters, detail page, file upload validation, form submission | TC-01 – TC-20 |
| 02 — My Outbound | Attachment retrieval, approval history modal, Excel export | TC-21 – TC-32 |
| 03 — Request Document | Page load, table filters, search, pagination controls | TC-33 – TC-38 |

**Total: 38 test cases across 3 suites.**

---

## Latest Run Results

| Metric | Count |
|---|---|
| Total | 38 |
| ✅ Passed | 30 |
| ❌ Failed | 8 |
| Distinct defects found | 5 |

All 8 failures are **genuine application defects** — no assertions were weakened to force green. See [TEST_REPORT.md](./TEST_REPORT.md) for full details.

### Defect Summary

| # | Defect | Severity |
|---|---|---|
| D1 | No file-type validation — `.exe` uploads accepted and stored | 🔴 Critical |
| D2 | Uploaded attachments not retrievable (`BlobNotFound` 404) | 🟠 High |
| D3 | Non-existent program ID renders a usable application form | 🟡 Medium |
| D4 | Approval-history "Approver" column displays raw `null` | 🟢 Low |
| D5 | Program-list poster images fail to load | 🟢 Low |

---

## Prerequisites

- Python 3.x
- Robot Framework
- SeleniumLibrary
- Google Chrome (matching version to included ChromeDriver)

```bash
pip install robotframework robotframework-seleniumlibrary
```

---

## Running the Tests

```bash
# Run all suites
robot test/

# Run a single suite
robot test/01_Outbound-Program.robot

# Run with a custom output directory
robot --outputdir results/ test/
```

> **Note:** Tests run against `https://trial.uc.ac.id` using test account `smatthew01`. Ensure network access and valid credentials before running.

---

## Tech Stack

- [Robot Framework](https://robotframework.org/)
- [SeleniumLibrary](https://github.com/robotframework/SeleniumLibrary)
- ChromeDriver (Win64)
