*** Settings ***
Resource          ../resources/keywords.robot
Suite Setup       Open Browser And Login
Suite Teardown    Close All Browsers
Test Setup        Navigate To My Outbound

*** Test Cases ***

TC-21 Show Attachment Opens New Tab
    [Tags]    show_attachment
    Wait For My Outbound Data Row
    Wait Until Element Is Visible    xpath=//a[contains(@class,'btn-primary') and contains(.,'Show Attachment')]    timeout=15s
    ${handles_before}=    Get Window Handles
    ${count_before}=      Get Length    ${handles_before}
    Click Element         xpath=//a[contains(@class,'btn-primary') and contains(.,'Show Attachment')]
    Sleep                 2s
    ${handles_after}=     Get Window Handles
    ${count_after}=       Get Length    ${handles_after}
    Should Be True        ${count_after} > ${count_before}    New tab was not opened
    ${handles}=           Get Window Handles
    Switch Window         ${handles}[1]
    Close Window
    Switch Window         ${handles}[0]

TC-22 Show Attachment New Tab URL Points To PDF
    [Tags]    show_attachment
    Wait For My Outbound Data Row
    Wait Until Element Is Visible    xpath=//a[contains(@class,'btn-primary') and contains(.,'Show Attachment')]    timeout=15s
    Click Element         xpath=//a[contains(@class,'btn-primary') and contains(.,'Show Attachment')]
    Sleep                 2s
    ${handles}=           Get Window Handles
    Switch Window         ${handles}[1]
    ${url}=               Get Location
    Should Contain        ${url}    .pdf    New tab URL does not point to a PDF file
    Close Window
    Switch Window         ${handles}[0]

TC-23 Show Attachment New Tab Does Not Show Error
    [Tags]    show_attachment
    Wait For My Outbound Data Row
    Wait Until Element Is Visible    xpath=//a[contains(@class,'btn-primary') and contains(.,'Show Attachment')]    timeout=15s
    Click Element         xpath=//a[contains(@class,'btn-primary') and contains(.,'Show Attachment')]
    Sleep                 2s
    ${handles}=           Get Window Handles
    Switch Window         ${handles}[1]
    ${url}=               Get Location
    Should Not Contain    ${url}    404    New tab shows a 404 error page
    ${source}=            Get Source
    Should Not Contain    ${source}    BlobNotFound    New tab shows BlobNotFound error
    Should Not Contain    ${source}    does not exist    New tab shows blob not found error
    Close Window
    Switch Window         ${handles}[0]

TC-24 Show History Modal Opens
    [Tags]    show_history
    Open Approval History
    Element Should Be Visible        id=history_modal
    Element Should Contain           xpath=//div[@id='history_modal']//h5[@class='modal-title']    History Approval

TC-25 Show History Modal Contains Required Columns
    [Tags]    show_history
    Open Approval History
    Element Should Contain    id=history_tabel    Transaction Number
    Element Should Contain    id=history_tabel    Status
    Element Should Contain    id=history_tabel    Reason
    Element Should Contain    id=history_tabel    Name
    Element Should Contain    id=history_tabel    Approver
    Element Should Contain    id=history_tabel    Date
    Close History Modal
    Wait Until Element Is Not Visible    id=history_modal    timeout=${LONG_WAIT}

TC-26 Show History Data Loads From Server
    [Tags]    show_history
    Open Approval History
    Wait Until Element Is Visible    xpath=//tbody[@id='hist_grid']/tr[1]/td[1]    timeout=${LONG_WAIT}
    ${row_count}=         Get Element Count    xpath=//tbody[@id='hist_grid']/tr
    Should Be True        ${row_count} > 0    History table has no data rows
    Close History Modal

TC-27 Show History Status Values Are Not Empty
    [Tags]    show_history
    Open Approval History
    Wait Until Element Is Visible    xpath=//tbody[@id='hist_grid']/tr[1]/td[2]    timeout=${LONG_WAIT}
    ${row_count}=    Get Element Count    xpath=//tbody[@id='hist_grid']/tr
    FOR    ${i}    IN RANGE    1    ${row_count} + 1
        ${status}=    Get Text    xpath=(//tbody[@id='hist_grid']/tr[${i}]/td[2])
        Should Not Be Empty    ${status}    Status is empty on row ${i}
    END
    Close History Modal

TC-28 Show History Approver Column Does Not Display Raw Null
    [Tags]    show_history    bug_check
    Open Approval History
    Wait Until Element Is Visible    xpath=//tbody[@id='hist_grid']/tr[1]/td[5]    timeout=${LONG_WAIT}
    ${row_count}=    Get Element Count    xpath=//tbody[@id='hist_grid']/tr
    FOR    ${i}    IN RANGE    1    ${row_count} + 1
        ${approver}=    Get Text    xpath=(//tbody[@id='hist_grid']/tr[${i}]/td[5])
        Should Not Be Equal As Strings    ${approver}    null
        ...    Approver column shows raw "null" on row ${i}
    END
    Close History Modal

# ─── EXCEL ───

TC-29 Excel Button Downloads A File
    [Tags]    excel
    ${files_before}=    List Files In Directory    ${DOWNLOAD_DIR}
    ${count_before}=    Get Length    ${files_before}
    Click Element       xpath=//button[contains(@class,'buttons-excel') and contains(.,'Excel')]
    FOR    ${i}    IN RANGE    15
        Sleep    1s
        ${files_now}=    List Files In Directory    ${DOWNLOAD_DIR}
        ${count_now}=    Get Length    ${files_now}
        IF    ${count_now} > ${count_before}    BREAK
    END
    ${files}=    List Files In Directory    ${DOWNLOAD_DIR}
    Should Not Be Empty    ${files}    No file downloaded after clicking Excel

TC-30 Excel Export On Empty Table Downloads Header Only
    [Tags]    excel    negative
    [Teardown]    Run Keywords    Reselect Period    ${original_period}    AND    Navigate To My Outbound
    ${original_period}=    Get Value    css=select._value
    Execute JavaScript
    ...    document.querySelector('select._value').value = '365b30de-700c-11ea-a86c-000d3aa02732'
    Click Element        id=search
    Wait Until Page Contains    Showing    timeout=${LONG_WAIT}
    ${row_count}=    Get Element Count    xpath=//table[@id='data_grid']/tbody/tr[td]
    Pass Execution If    ${row_count} > 0    Period is not empty — skipping empty state test
    ${initial_count}=    Get File Count In Download Dir
    Click Element        xpath=//button[contains(@class,'buttons-excel') and contains(.,'Excel')]
    Wait For New File In Download Dir    ${initial_count}
    ${files}=            List Files In Directory    ${DOWNLOAD_DIR}
    ${xlsx_files}=       Get Matches    ${files}    *.xlsx
    Should Not Be Empty  ${xlsx_files}    No xlsx downloaded for empty table state

TC-31 Show Attachment Opens New Tab With PDF
    [Tags]    show_attachment
    [Teardown]    Close Extra Windows    ${main_handle}
    Navigate To My Outbound
    Wait For My Outbound Data Row
    ${handles}=    Get Window Handles
    Set Test Variable    ${main_handle}    ${handles}[0]
    Click Element
    ...    xpath=//a[contains(@class,'btn-primary') and contains(normalize-space(.),'Show Attachment')]
    Wait Until Keyword Succeeds    10s    1s    Switch Window    NEW
    Wait Until Keyword Succeeds    10s    1s    Location Should Contain    .pdf
    ${source}=    Get Source
    Should Not Contain    ${source}    BlobNotFound    New tab shows BlobNotFound error
    Should Not Contain    ${source}    does not exist    New tab shows blob not found error


TC-32 Show Progress Modal Opens With History Data
    [Tags]    show_progress
    Navigate To My Outbound
    Open Approval History
    Element Should Be Visible    id=history_modal
    Element Should Contain
    ...    xpath=//div[@id='history_modal']//h5[@class='modal-title']
    ...    History Approval
    Wait Until Element Is Visible
    ...    xpath=//tbody[@id='hist_grid']/tr[1]/td[1]    timeout=${LONG_WAIT}
    ${row_count}=    Get Element Count    xpath=//tbody[@id='hist_grid']/tr
    Should Be True    ${row_count} > 0    History modal has no data rows
    Close History Modal
    
