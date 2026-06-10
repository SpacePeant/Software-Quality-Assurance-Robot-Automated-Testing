*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem
Library           String
Library           Collections
Resource          variables.robot

*** Keywords ***
Open Browser And Login
    Open Browser    ${DASHBOARD_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains Element    name=username    timeout=10s
    Input Text      name=username    ${VALID_USERNAME}
    Input Password  name=password    ${VALID_PASSWORD}
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Contains    student_dashboard    timeout=15s

Click Element Safely
    [Arguments]    ${locator}    ${timeout}=15s
    Wait Until Element Is Visible    ${locator}    timeout=${timeout}
    Wait Until Element Is Enabled    ${locator}    timeout=${timeout}
    ${element}=    Get WebElement    ${locator}
    Execute Javascript    arguments[0].scrollIntoView({block: 'center', inline: 'nearest'});    ARGUMENTS    ${element}
    Sleep    300ms
    ${clicked}=    Run Keyword And Return Status    Click Element    ${element}
    IF    not ${clicked}
        Log    Normal click was intercepted; retrying with JavaScript click for locator: ${locator}    level=WARN
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${element}
    END

Navigate To Student International Submenu
    Open Burger Menu
    ${is_expanded}=    Get Element Attribute    xpath=//a[@data-bs-target='#nax-accordion-item-6a266203a1487']    aria-expanded
    IF    '${is_expanded}' == 'false'
        Click Element Safely    xpath=//a[@data-bs-target='#nax-accordion-item-6a266203a1487']    timeout=10s
    END
    Wait Until Element Is Visible    xpath=//a[@href='${OUTBOUND_LIST_URL}']    timeout=10s

Navigate To Outbound Program List
    Go To    ${OUTBOUND_LIST_URL}
    Wait Until Page Contains    Student Outbound Program List    timeout=20s
    # Wait for the main container that holds all the program cards
    # This is much more reliable than waiting for a specific button inside a card
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'row')]    timeout=20s
    Sleep    2s

Apply Select2 Filter
    [Arguments]    ${option}    ${index}=1
    Click Element Safely    xpath=(//span[contains(@class,'select2-selection')])[${index}]    timeout=10s
    Sleep    0.5s
    ${is_index}=    Run Keyword And Return Status    Should Match Regexp    ${option}    ^\\d+$
    IF    ${is_index}
        ${option_locator}=    Set Variable    xpath=(//li[contains(@class,'select2-results__option')])[${option}]
    ELSE
        ${option_locator}=    Set Variable    xpath=//li[contains(@class,'select2-results__option') and contains(normalize-space(.), '${option}')]
    END
    Click Element Safely    ${option_locator}    timeout=10s
    Sleep    2s

Select Native Filter Value
    [Arguments]    ${value}
    Wait Until Element Is Visible    css=.filter-item ._value    timeout=10s
    Select From List By Label    css=.filter-item ._value    ${value}
    Sleep    1s

Close History Modal
    Click Element Safely    xpath=//div[@id='history_modal']//button[@aria-label='Close']
    
    Wait Until Element Does Not Contain    id=history_modal    class="show"    timeout=10s
    
    ${visible}=    Run Keyword And Return Status    Element Should Be Visible    id=history_modal
    IF    ${visible}
        Execute Javascript    document.querySelector('.modal-backdrop').click()
    END
    
    Wait Until Element Is Not Visible    id=history_modal    timeout=15s

Navigate To My Outbound
    Go To    ${MY_OUTBOUND_URL}
    Wait Until Element Is Visible    xpath=//table/tbody/tr[1] | //*[contains(text(), 'No data available')]    timeout=20s

Add Filter Row And Wait
    Click Element    id=filter
    Wait Until Element Is Visible    css=.filter-item ._category    timeout=10s
    Sleep    0.5s

Open Program Detail By Index
    [Arguments]    ${index}=1
    ${detail_locator}=    Set Variable    xpath=(//a[contains(@class, 'btn-success') and contains(normalize-space(.), 'More Details')])[${index}]
    Click Element Safely    ${detail_locator}    timeout=20s

Program Results Should Be Rendered Or Empty
    ${program_count}=    Get Element Count    xpath=//a[contains(@class, 'btn-success') and contains(normalize-space(.), 'More Details')]
    ${source}=    Get Source
    ${has_empty_state}=    Run Keyword And Return Status    Should Match Regexp    ${source}    No data available|Tidak ada data|no records|empty
    Run Keyword If    ${program_count} == 0 and not ${has_empty_state}    Fail    Filtered program list shows neither program cards nor an empty-state message.

Wait For My Outbound Data Row
    Wait Until Element Is Visible    xpath=//table/tbody/tr[1] | //*[contains(normalize-space(), 'No data available')]    timeout=20s
    ${data_rows}=    Get Element Count    xpath=//table/tbody/tr[not(contains(normalize-space(.), 'No data available'))]
    IF    ${data_rows} == 0
        Skip    My Outbound has no data for the selected period; this scenario requires seeded outbound data.
    END

Wait For Download Attachment
    Wait For My Outbound Data Row
    ${attachment_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//a[.//i[contains(@class, 'fa-download')]]    timeout=10s
    IF    not ${attachment_visible}
        Skip    No uploaded attachment is available in the current My Outbound data; attachment validation requires seeded uploaded data.
    END

Dismiss AI Assistant Widget
    Execute Javascript    var el = document.getElementById('tp-ai-assistant'); if (el) el.style.display = 'none';
    Execute Javascript    var el = document.querySelector('.position-fixed.end-0.bottom-0'); if (el) el.style.display = 'none';

Upload File To Attachment
    [Documentation]    Selects ${file_path} for the hidden file input behind attachment ${index}.
    ...    SeleniumLibrary's Choose File sends the path directly to the input element, which works
    ...    even when the input is hidden. We must NOT wait for the input to become visible: its
    ...    parent container keeps it hidden, so a visibility wait always times out.
    [Arguments]    ${index}    ${file_path}
    Wait Until Page Contains Element    id=_inp_attachment_${index}    timeout=15s
    Execute Javascript    var i = document.getElementById('_inp_attachment_${index}'); if (i) i.style.display = 'block';
    Choose File    id=_inp_attachment_${index}    ${file_path}

Get File Count In Download Dir
    ${files}=    List Files In Directory    ${DOWNLOAD_DIR}
    ${count}=    Get Length    ${files}
    RETURN    ${count}

Wait For New File In Download Dir
    [Arguments]    ${initial_count}
    FOR    ${i}    IN RANGE    15
        Sleep    1s
        ${files_now}=    List Files In Directory    ${DOWNLOAD_DIR}
        ${count_now}=    Get Length    ${files_now}
        IF    ${count_now} > ${initial_count}    BREAK
    END

Navigate To Document Request
    Go To    ${DOC_REQUEST_URL}
    Wait Until Page Contains    Student Outbound Document Request    timeout=20s
    Wait Until Element Is Visible    xpath=//table | //*[contains(text(),'No data available')]    timeout=20s
    Dismiss AI Assistant Widget

Upload All Required Documents
    [Documentation]    Uploads a valid file to all three required attachment slots and
    ...    waits until each hidden input reports a value.
    Upload File To Attachment    0    ${VALID_FILE_PATH}
    Upload File To Attachment    1    ${VALID_FILE_PATH}
    Upload File To Attachment    2    ${VALID_FILE_PATH}
    Wait Until Keyword Succeeds    10s    1s    All Attachments Should Have Value

All Attachments Should Have Value
    FOR    ${i}    IN RANGE    0    3
        ${value}=    Get Element Attribute    id=attachment_${i}    value
        Should Not Be Empty    ${value}    msg=Attachment ${i} has no value after upload
    END

Submit Application Form
    [Documentation]    Clicks the form's Submit button and confirms the follow-up dialog,
    ...    which may be a native browser confirm OR a SweetAlert popup.
    Dismiss AI Assistant Widget
    Execute Javascript    document.querySelector('button.btn-success[onclick*="areYouSure"]').click();
    ${native}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=5s
    IF    not ${native}
        Run Keyword And Ignore Error    Click Element    xpath=//button[contains(@class,'swal2-confirm')]
    END

Poster Images Should Load
    [Documentation]    Fails if any visible program-card poster image is broken
    ...    (loaded but with naturalWidth == 0).
    ${broken}=    Execute Javascript
    ...    return Array.from(document.querySelectorAll('img')).filter(function(i){var c=i.closest('.card,[class*="col-"]');return c && /More Details/.test(c.textContent) && i.complete && i.naturalWidth===0;}).length;
    Should Be Equal As Integers    ${broken}    ${0}    msg=One or more program poster images failed to load (broken image).

Open Approval History
    [Documentation]    Opens the approval-history modal via whichever control the row exposes.
    ...    Depending on the record's state the My Outbound action column shows a "Show History"
    ...    button OR a "Show Progress" button; both render the same #history_modal.
    Wait For My Outbound Data Row
    ${trigger}=    Set Variable
    ...    xpath=//a[contains(@class,'btn-secondary') and contains(.,'Show History')] | //button[contains(normalize-space(.),'Show Progress')] | //a[contains(normalize-space(.),'Show Progress')]
    Wait Until Element Is Visible    ${trigger}    timeout=15s
    Click Element Safely    ${trigger}    timeout=15s
    Wait Until Element Is Visible    id=history_modal    timeout=${LONG_WAIT}

Reselect Period
    [Documentation]    Restores the period filter to ${period_value} and re-runs the search so a
    ...    prior test that switched to an empty period does not leak into later tests.
    [Arguments]    ${period_value}
    Run Keyword And Ignore Error    Execute JavaScript    document.querySelector('select._value').value = '${period_value}'
    Run Keyword And Ignore Error    Click Element    id=search
    Sleep    1s

Close Extra Windows
    [Documentation]    Closes every browser window except ${main_handle} and returns focus to it.
    ...    Safe to use as a teardown even if no extra window was opened.
    [Arguments]    ${main_handle}
    ${handles}=    Get Window Handles
    FOR    ${h}    IN    @{handles}
        IF    '${h}' != '${main_handle}'
            Switch Window    ${h}
            Close Window
        END
    END
    Switch Window    ${main_handle}