*** Settings ***
Resource          ../resources/keywords.robot
Suite Setup       Open Browser And Login
Suite Teardown    Close All Browsers
Test Setup        Navigate To Outbound Program List

*** Test Cases ***
TC-01 Filter Active Programs
    Navigate To Outbound Program List
    Apply Select2 Filter    Active
    Program Results Should Be Rendered Or Empty
    Page Should Contain    Woosong University Korea Exchange Program Fall 2026/2027

TC-02 Filter Expired Programs
    Navigate To Outbound Program List
    Apply Select2 Filter    Expired
    Click Element    id=search
    Wait Until Page Contains    Student Outbound Program List    timeout=20s
    Sleep    3s
    Program Results Should Be Rendered Or Empty
    Page Should Contain    INTI Little Explorer Camp 2026, Malaysia

TC-03 Filter Expired Competition Programs
    Navigate To Outbound Program List
    Apply Select2 Filter    Expired
    Add Filter Row And Wait
    Select Native Filter Value    Competition
    Click Element    id=search
    Sleep    2s
    Program Results Should Be Rendered Or Empty
    Page Should Contain    Universiti Sains Malaysia Exchange Program Fall 26/27

TC-04 Clear Filters
    [Documentation]    Verifies that the Clear Filter button resets the list to the default view.
    Navigate To Outbound Program List
    Add Filter Row And Wait
    Wait Until Element Is Visible    id=clear    timeout=5s
    Click Element Safely    id=clear
    Wait Until Page Contains    Student Outbound Program List    timeout=20s
    Sleep    3s
    Program Results Should Be Rendered Or Empty
    Page Should Contain    INTI Little Explorer Camp 2026, Malaysia

TC-05 Open First Program Detail
    [Tags]    program_detail
    Apply Select2 Filter    Active
    Click Element    id=search
    Dismiss AI Assistant Widget
    Wait Until Element Is Visible    
    ...    xpath=(//a[contains(@class, 'btn-success') and contains(., 'More Details')])[1]    
    ...    timeout=20s
    Open Program Detail By Index    1
    Wait Until Page Contains    Outbound Program Information    timeout=15s

TC-06 Verify Program Detail Info
    [Tags]    program_detail
    Apply Select2 Filter    Active
    Click Element    id=search
    Dismiss AI Assistant Widget
    Wait Until Element Is Visible    xpath=(//a[contains(@class, 'btn-success') and contains(., 'More Details')])[1]    timeout=20s
    Open Program Detail By Index    1
    Wait Until Page Contains    Program Name    timeout=20s
    Page Should Contain    Program Description
    Page Should Contain    PIC Contact

TC-07 Upload Invalid File
    [Documentation]    KNOWN DEFECT - expected to FAIL until server-side file-type validation is added.
    ...    The form accepts executable uploads: invalid_file.exe is stored server-side and the
    ...    field is populated with a path ending in .exe instead of being rejected. The upload
    ...    widget (upload.js) only enforces extensions when the field declares an accept/accpt
    ...    list, and these attachment fields declare none, so no file-type validation occurs.
    ...    This test asserts the expected secure behavior; its FAIL flags the missing validation.
    [Tags]    upload    negative    file-type    known-defect
    Go To    ${FORM_URL}
    Wait Until Page Contains Element    id=attachment_0_btn    timeout=20s
    Dismiss AI Assistant Widget
    Wait Until Element Is Visible    id=attachment_0_btn    timeout=15s
    Upload File To Attachment    0    ${INVALID_FILE_PATH}
    Sleep    3s
    ${value}=    Get Element Attribute    id=attachment_0    value
    Should Be Empty    ${value}    msg=DEFECT: invalid .exe accepted (no file-type validation); attachment_0 should be empty but was '${value}'

TC-08 Upload File Exceeding Size Limit
    [Tags]    upload    negative    file-size
    Go To    ${FORM_URL}
    Wait Until Page Contains Element    id=attachment_0_btn    timeout=20s
    Dismiss AI Assistant Widget
    Wait Until Element Is Visible    id=attachment_0_btn    timeout=15s
    Upload File To Attachment    0    ${LARGE_FILE_PATH}
    ${alert_present}=    Run Keyword And Return Status    Alert Should Be Present    timeout=8s
    IF    not ${alert_present}
        ${value}=    Get Element Attribute    id=attachment_0    value
        Should Be Empty    ${value}    msg=Large file was accepted; expected rejection due to 5MB limit
    ELSE
        Handle Alert    action=ACCEPT
    END

TC-09 Submit Incomplete Application
    [Tags]    upload    negative    validation
    Go To    ${FORM_URL}
    Wait Until Page Contains Element    xpath=//button[contains(normalize-space(.), 'Submit')]    timeout=20s
    Dismiss AI Assistant Widget
    Wait Until Element Is Visible    xpath=//button[contains(normalize-space(.), 'Submit')]    timeout=15s
    Execute Javascript    document.querySelector('button.btn-success[onclick*="areYouSure"]').click();
    ${alert_present}=    Run Keyword And Return Status    Alert Should Be Present    text=Please Check Required Attachment.    timeout=5s
    IF    not ${alert_present}
        ${invalid_count}=    Get Element Count    xpath=//input[contains(@class,'form-control') and @required and @value='']
        Should Be True    ${invalid_count} > 0
    END

TC-10 All Upload Buttons Are Visible
    [Tags]    upload    ui    visibility
    Go To    ${FORM_URL}
    Wait Until Page Contains Element    id=attachment_0_btn    timeout=20s
    Dismiss AI Assistant Widget
    Element Should Be Visible    id=attachment_0_btn
    Element Should Be Visible    id=attachment_1_btn
    Element Should Be Visible    id=attachment_2_btn
    Element Should Contain    id=attachment_0_btn    Upload
    Element Should Contain    id=attachment_1_btn    Upload
    Element Should Contain    id=attachment_2_btn    Upload

TC-11 Upload Valid File To First Attachment
    [Tags]    upload    positive
    Go To    ${FORM_URL}
    Wait Until Page Contains Element    id=attachment_0_btn    timeout=20s
    Dismiss AI Assistant Widget
    Wait Until Element Is Visible    id=attachment_0_btn    timeout=15s
    Upload File To Attachment    0    ${VALID_FILE_PATH}
    Sleep    3s
    ${value}=    Get Element Attribute    id=attachment_0    value
    Should Not Be Empty    ${value}    msg=Valid file was not accepted by attachment_0

TC-12 Upload Valid File To Second Attachment
    [Tags]    upload    positive
    Go To    ${FORM_URL}
    Wait Until Page Contains Element    id=attachment_1_btn    timeout=20s
    Dismiss AI Assistant Widget
    Wait Until Element Is Visible    id=attachment_1_btn    timeout=15s
    Upload File To Attachment    1    ${VALID_FILE_PATH}
    Sleep    3s
    ${value}=    Get Element Attribute    id=attachment_1    value
    Should Not Be Empty    ${value}    msg=Valid file was not accepted by attachment_1

TC-13 Upload Valid File To Third Attachment
    [Tags]    upload    positive
    Go To    ${FORM_URL}
    Wait Until Page Contains Element    id=attachment_2_btn    timeout=20s
    Dismiss AI Assistant Widget
    Wait Until Element Is Visible    id=attachment_2_btn    timeout=15s
    Upload File To Attachment    2    ${VALID_FILE_PATH}
    Sleep    3s
    ${value}=    Get Element Attribute    id=attachment_2    value
    Should Not Be Empty    ${value}    msg=Valid file was not accepted by attachment_2

TC-14 Upload Invalid File To Second Attachment
    [Documentation]    KNOWN DEFECT - expected to FAIL until server-side file-type validation is added.
    ...    Same missing-validation defect as TC-07, verified on the second attachment field:
    ...    invalid_file.exe is accepted and stored instead of being rejected. The FAIL flags the
    ...    missing file-type validation; it is an intentional defect report, not a flaky test.
    [Tags]    upload    negative    file-type    known-defect
    Go To    ${FORM_URL}
    Wait Until Page Contains Element    id=attachment_1_btn    timeout=20s
    Dismiss AI Assistant Widget
    Wait Until Element Is Visible    id=attachment_1_btn    timeout=15s
    Upload File To Attachment    1    ${INVALID_FILE_PATH}
    Sleep    3s
    ${value}=    Get Element Attribute    id=attachment_1    value
    Should Be Empty    ${value}    msg=DEFECT: invalid .exe accepted (no file-type validation); attachment_1 should be empty but was '${value}'

TC-15 Upload Invalid File To Third Attachment
    [Documentation]    KNOWN DEFECT - expected to FAIL until server-side file-type validation is added.
    ...    Same missing-validation defect as TC-07, verified on the third attachment field:
    ...    invalid_file.exe is accepted and stored instead of being rejected. The FAIL flags the
    ...    missing file-type validation; it is an intentional defect report, not a flaky test.
    [Tags]    upload    negative    file-type    known-defect
    Go To    ${FORM_URL}
    Wait Until Page Contains Element    id=attachment_2_btn    timeout=20s
    Dismiss AI Assistant Widget
    Wait Until Element Is Visible    id=attachment_2_btn    timeout=15s
    Upload File To Attachment    2    ${INVALID_FILE_PATH}
    Sleep    3s
    ${value}=    Get Element Attribute    id=attachment_2    value
    Should Be Empty    ${value}    msg=DEFECT: invalid .exe accepted (no file-type validation); attachment_2 should be empty but was '${value}'

TC-16 Program Poster Images Should Load
    [Tags]    program_list    images    bug_check
    Apply Select2 Filter    Active
    Click Element    id=search
    Dismiss AI Assistant Widget
    Wait Until Element Is Visible    xpath=(//a[contains(@class, 'btn-success') and contains(., 'More Details')])[1]    timeout=20s
    Poster Images Should Load

TC-17 Non-Existent Program Does Not Render Application Form
    [Tags]    program_detail    negative
    Go To    ${BASE_URL}/student_outbound/form_apply/00000000-0000-0000-0000-000000000000/
    Sleep    2s
    ${shows_form}=    Run Keyword And Return Status    Page Should Contain    Outbound Program Information
    Should Not Be True    ${shows_form}    msg=A non-existent program ID still rendered a valid application form.

TC-18 Verify Full Program Detail Fields
    [Tags]    program_detail
    Apply Select2 Filter    Active
    Click Element    id=search
    Dismiss AI Assistant Widget
    Wait Until Element Is Visible    xpath=(//a[contains(@class, 'btn-success') and contains(., 'More Details')])[1]    timeout=20s
    Open Program Detail By Index    1
    Wait Until Page Contains    Outbound Program Information    timeout=15s
    Page Should Contain    Host Institution
    Page Should Contain    Country
    Page Should Contain    Information
    Page Should Contain    PIC Contact

TC-19 Information Download Control Is Available
    [Tags]    program_detail
    Go To    ${FORM_URL}
    Dismiss AI Assistant Widget
    Wait Until Page Contains    Outbound Program Information    timeout=20s
    Element Should Be Visible    xpath=//a[contains(normalize-space(.),'Download')] | //button[contains(normalize-space(.),'Download')]

TC-20 Submit Complete Application
    [Documentation]    Happy path: upload all three required documents and submit.
    ...    NOTE: this creates a real application in the trial environment. If the program
    ...    has already been applied for, the system may reject resubmission, so the test
    ...    passes on either a success indicator OR navigation away from the form.
    [Tags]    upload    submission    positive    e2e
    Go To    ${FORM_URL}
    Wait Until Page Contains Element    id=attachment_0_btn    timeout=20s
    Dismiss AI Assistant Widget
    Upload All Required Documents
    Submit Application Form
    Sleep    3s
    ${source}=    Get Source
    ${url}=    Get Location
    ${has_success}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${source}    (?i)success|berhasil|submitted|waiting approval|already
    ${left_form}=    Run Keyword And Return Status    Should Not Contain    ${url}    form_apply
    Should Be True    ${has_success} or ${left_form}    msg=Submission produced no success indicator and stayed on the form.