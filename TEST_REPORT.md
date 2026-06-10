# Test Report — Student Outbound Module

**Application:** Universitas Ciputra — Student Outbound module (`https://trial.uc.ac.id`)
**Test framework:** Robot Framework + SeleniumLibrary (Chrome)
**Test account:** `smatthew01` (Sean Matthew)
**Report date:** 2026-06-09
**Suites:** `test/01_Outbound-Program.robot`, `test/02_My-Outbound.robot`, `test/03_Request-Document.robot`

---

## 1. Executive Summary

| Metric | Count |
|--------|-------|
| **Total test cases** | 38 |
| ✅ Passed | 30 |
| ❌ Failed | 8 |
| ⏭️ Skipped | 0 |
| **Distinct defects found** | 5 |

All 8 failures are **genuine application defects** — the tests are working as intended and are retained as defect reports (assertions are *not* weakened to force green). No test-infrastructure failures or skips remain.

### Results by suite

| Suite | Tests | Pass | Fail | Failing TCs |
|-------|------|------|------|-------------|
| 01 — Outbound Program | 20 | 15 | 5 | TC-07, TC-14, TC-15, TC-16, TC-17 |
| 02 — My Outbound | 12 | 9 | 3 | TC-23, TC-28, TC-31 |
| 03 — Request Document | 6 | 6 | 0 | — |

### Defects at a glance

| # | Defect | Severity | Tests |
|---|--------|----------|-------|
| D1 | No file-type validation — `.exe` uploads accepted & stored | 🔴 Critical (security) | TC-07, TC-14, TC-15 |
| D2 | Uploaded attachments not retrievable (`BlobNotFound` 404) | 🟠 High (data integrity) | TC-23, TC-31 |
| D3 | Non-existent program ID renders a usable application form (no 404) | 🟡 Medium | TC-17 |
| D4 | Approval-history "Approver" column displays raw `null` | 🟢 Low (cosmetic) | TC-28 |
| D5 | Program-list poster images fail to load (broken images) | 🟢 Low (cosmetic) | TC-16 |

---

## 2. Test Case Catalogue

### Suite 01 — Outbound Program (`/student_outbound/program_list` + `/form_apply`)

| TC | What it verifies | Result |
|----|------------------|--------|
| TC-01 | "Active" status filter returns active programs (Woosong present) | ✅ |
| TC-02 | "Expired" status filter returns expired programs (INTI camp present) | ✅ |
| TC-03 | Combined "Expired" + "Competition" program-type filter | ✅ |
| TC-04 | "Clear Filter" button resets the list to the default view | ✅ |
| TC-05 | First "More Details" link opens the program detail page | ✅ |
| TC-06 | Detail page shows Program Name, Description, and PIC Contact | ✅ |
| TC-07 | Uploading an `.exe` to attachment 0 is **rejected** | ❌ **D1** |
| TC-08 | A file exceeding the 5 MB limit is rejected | ✅ |
| TC-09 | Submitting an incomplete application is blocked | ✅ |
| TC-10 | All three upload buttons are visible and labelled "Upload" | ✅ |
| TC-11 | A valid PDF is accepted on attachment 0 | ✅ |
| TC-12 | A valid PDF is accepted on attachment 1 | ✅ |
| TC-13 | A valid PDF is accepted on attachment 2 | ✅ |
| TC-14 | Uploading an `.exe` to attachment 1 is **rejected** | ❌ **D1** |
| TC-15 | Uploading an `.exe` to attachment 2 is **rejected** | ❌ **D1** |
| TC-16 | Program-card poster images actually render (`naturalWidth > 0`) | ❌ **D5** |
| TC-17 | A non-existent program ID does **not** render an application form | ❌ **D3** |
| TC-18 | Detail page shows Host Institution, Country, Information, PIC | ✅ |
| TC-19 | The "Information → Download" control is present | ✅ |
| TC-20 | Happy path: upload all 3 required docs → Submit succeeds | ✅ |

### Suite 02 — My Outbound (`/student_outbound/my_outbound`)

| TC | What it verifies | Result |
|----|------------------|--------|
| TC-21 | "Show Attachment" opens a new browser tab | ✅ |
| TC-22 | The new tab's URL points to a `.pdf` file | ✅ |
| TC-23 | The attachment tab does **not** show a storage error | ❌ **D2** |
| TC-24 | The approval-history modal opens | ✅ |
| TC-25 | History modal contains the required columns | ✅ |
| TC-26 | History data loads from the server (≥1 row) | ✅ |
| TC-27 | History "Status" values are not empty | ✅ |
| TC-28 | History "Approver" column does not display raw `null` | ❌ **D4** |
| TC-29 | "Excel" button downloads a file | ✅ |
| TC-30 | Excel export on an empty table downloads header only | ✅ |
| TC-31 | Show Attachment opens a new tab with a valid, error-free PDF | ❌ **D2** |
| TC-32 | "Show Progress" modal opens with approval-history data | ✅ |

### Suite 03 — Request Document (`/student_outbound/document_request`)

| TC | What it verifies | Result |
|----|------------------|--------|
| TC-33 | The Document Request page loads | ✅ |
| TC-34 | The table has the required columns | ✅ |
| TC-35 | The empty-state notice shows when there are no requests | ✅ |
| TC-36 | The Period filter "Search" works | ✅ |
| TC-37 | The "Show entries" control is present | ✅ |
| TC-38 | The DataTables search box filters the table | ✅ |

---

## 3. Defect Details (Failed Test Cases)

### D1 — No file-type validation: executable uploads are accepted 🔴 Critical
**Failing tests:** TC-07, TC-14, TC-15 (attachments 0/1/2)
**Category:** Security / Input validation

**Expected:** Uploading `invalid_file.exe` to a document field should be rejected; the field value stays empty.

**Actual:** The `.exe` is accepted, uploaded, and **stored server-side**. The field is populated with a stored path, e.g.:
```
sis/t_so_participant_requirement/019eabc1-829a-76d9-95de-c2aa077ca2c9.exe
```

**Why it failed:** The assertion `Should Be Empty ${value}` fails because the field holds a `.exe` path instead of being empty. The upload widget (`upload.js`) only enforces extensions when the field declares an `accept` list, and these three attachment fields declare none — so no client- or server-side file-type check occurs.

**Risk:** Arbitrary executable files can be uploaded and stored. This is a security exposure (malware hosting / potential execution vector) and should be prioritised.

**Recommendation:** Enforce an allow-list of document types (e.g. PDF/JPG/PNG) on **both** the client and the server, and reject everything else.

---

### D2 — Uploaded attachments are not retrievable (`BlobNotFound`) 🟠 High
**Failing tests:** TC-23, TC-31
**Category:** Data integrity / Functional

**Expected:** Clicking "Show Attachment" opens the uploaded document (a valid PDF) in a new tab.

**Actual:** The new tab opens at a `.pdf` URL (so TC-22 passes), but the document content is an Azure Blob Storage error:
```
Code: 404  Value: The specified blob does not exist.
<error><code>BlobNotFound</code>
<message>The specified blob does not exist. RequestId:ef6a2772-... </message></error>
```

**Why it failed:** The page source contains `BlobNotFound`, tripping the `Should Not Contain ... BlobNotFound` assertion. The attachment record points to a blob that is missing from storage — the file link is generated but the underlying object isn't there (or is mislinked).

**Risk:** Submitted student documents cannot be viewed/downloaded by reviewers — a functional break in the approval workflow.

**Recommendation:** Verify the upload-to-storage pipeline (blob is actually persisted and the stored path matches the retrieval URL). Add a server-side existence check and a user-facing fallback message instead of a raw storage error.

> Note: TC-23 and TC-31 both cover this path; TC-31 is a combined PDF-opens + no-error check. Keeping both is slightly redundant but harmless.

---

### D3 — Non-existent program ID renders a usable application form (no 404) 🟡 Medium
**Failing test:** TC-17
**Category:** Error handling

**Expected:** Navigating to `/student_outbound/form_apply/00000000-0000-0000-0000-000000000000/` should return a 404 / "not found" page.

**Actual:** The application **renders a valid "Outbound Program Information" application form** for the non-existent program ID.

**Why it failed:** The assertion expecting the form *not* to render fails because the form is shown. The route does not validate that the program ID exists before rendering.

**Risk:** Improper error handling; users can reach/submit forms for programs that don't exist, and it may mask deeper authorization/validation gaps.

**Recommendation:** Validate the program ID server-side and return a proper 404 (or redirect to the program list with an error) when it does not resolve.

---

### D4 — Approval-history "Approver" column shows raw `null` 🟢 Low
**Failing test:** TC-28
**Category:** Data display

**Expected:** The "Approver" column shows an approver name or a friendly placeholder (e.g. "—"), never the literal string `null`.

**Actual:** A history row renders the literal text `null` in the Approver column:
```
Approver column shows raw "null" on row 5: null == null
```

**Why it failed:** The assertion `Should Not Be Equal As Strings ${approver} null` fails because the cell text is exactly `null` — an unmapped/empty backend value is being printed verbatim.

**Risk:** Cosmetic, but unprofessional and confusing in an approval audit trail.

**Recommendation:** Coalesce null approver values to a blank or placeholder in the history rendering.

---

### D5 — Program-list poster images fail to load (broken images) 🟢 Low
**Failing test:** TC-16
**Category:** UI / Assets

**Expected:** Every program-card poster image renders (`naturalWidth > 0`).

**Actual:** 6 poster images are broken (loaded but zero width):
```
One or more program poster images failed to load (broken image).: 6 != 0
```

**Why it failed:** The JS check counts visible card images with `naturalWidth === 0`; it returned 6, failing the `== 0` assertion.

**Risk:** Cosmetic; degrades the visual quality of the program catalogue.

**Recommendation:** Fix the poster image source URLs / missing assets, and consider a placeholder image fallback for missing posters.

---

## 4. Notes on Test Reliability

During this effort several **test-side** issues (not app bugs) were corrected so that the only remaining failures are genuine defects:

- **Approval-history trigger** — records expose either a "Show History" or a "Show Progress" button depending on state; a resilient `Open Approval History` keyword now clicks whichever is present (both open the same modal). *(TC-24–28, TC-32)*
- **Modal close** — replaced a flaky JavaScript close with the robust `Close History Modal` keyword. *(TC-27)*
- **Excel locator** — corrected `dt-button` → `buttons-excel`. *(TC-30)*
- **New-tab handling** — replaced positional window-handle indexing with `Switch Window NEW` + URL wait + a `Close Extra Windows` teardown. *(TC-31)*
- **Period leakage** — the empty-period export test now restores the original period in teardown so later tests are not starved of data. *(TC-30 → TC-31/32)*

---

## 5. Recommended Priority

1. **D1 — file-type validation** (Critical, security) — fix first.
2. **D2 — BlobNotFound attachment retrieval** (High, breaks approval workflow).
3. **D3 — non-existent program 404** (Medium, error handling).
4. **D4 / D5 — `null` approver & broken posters** (Low, cosmetic) — batch with UI cleanup.
