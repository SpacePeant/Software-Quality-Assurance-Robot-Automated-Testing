*** Settings ***
Resource          ../resources/keywords.robot
Suite Setup       Open Browser And Login
Suite Teardown    Close All Browsers
Test Setup        Navigate To Document Request

*** Test Cases ***
TC-33 Document Request Page Loads
    [Tags]    document_request    smoke
    Page Should Contain    Student Outbound Document Request
    Page Should Contain    Request Document

TC-34 Document Request Table Has Required Columns
    [Tags]    document_request    ui
    Page Should Contain    Student Name
    Page Should Contain    Program Name
    Page Should Contain    Document
    Page Should Contain    Deadline
    Page Should Contain    Request Date

TC-35 Document Request Shows Empty State When No Requests
    [Tags]    document_request    negative
    ${data_rows}=    Get Element Count    xpath=//table/tbody/tr[td[not(contains(@class,'dataTables_empty'))]]
    IF    ${data_rows} == 0
        Page Should Contain    No data available in table
    ELSE
        Log    ${data_rows} document request row(s) present; empty-state check skipped.
    END

TC-36 Document Request Period Filter Search Works
    [Tags]    document_request    filter
    Wait Until Element Is Visible    id=search    timeout=10s
    Element Should Be Enabled    id=search
    Click Element    id=search
    Wait Until Page Contains    Student Outbound Document Request    timeout=20s
    Wait Until Element Is Visible    xpath=//table | //*[contains(text(),'No data available')]    timeout=20s

TC-37 Document Request Show Entries Control Is Present
    [Tags]    document_request    ui
    Wait Until Element Is Visible
    ...    xpath=//div[contains(@class,'dataTables_length')] | //select[contains(@name,'length')]
    ...    timeout=10s

TC-38 Document Request Search Box Filters To Empty
    [Tags]    document_request    ui
    ${has_box}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//div[contains(@class,'dataTables_filter')]//input
    Pass Execution If    not ${has_box}    No DataTables search box present on this page.
    Input Text    xpath=//div[contains(@class,'dataTables_filter')]//input    zzznomatchzzz
    Sleep    1s
    ${source}=    Get Source
    Should Match Regexp    ${source}    (?i)No matching records|No data available
