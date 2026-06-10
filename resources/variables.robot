*** Variables ***
${BROWSER}               chrome
${BASE_URL}              https://trial.uc.ac.id
${DASHBOARD_URL}         ${BASE_URL}/student_dashboard
${OUTBOUND_LIST_URL}     ${BASE_URL}/student_outbound/program_list
${MY_OUTBOUND_URL}       ${BASE_URL}/student_outbound/my_outbound
${DOC_REQUEST_URL}       ${BASE_URL}/student_outbound/document_request
${FORM_URL}              ${BASE_URL}/student_outbound/form_apply/019e0188-15cb-7a5a-aec3-48b0b685f13f

${VALID_USERNAME}        f
${VALID_PASSWORD}        f

${INHA_NAME}             Inha
${WOOSONG_NAME}          Woosong University Korea Exchange Program Fall 2026/2027

${LONG_WAIT}             15s
${DOWNLOAD_DIR}          D:\\Downloads
${VALID_FILE_PATH}       D:\\Downloads\\alp-sqa\\test\\test_files\\valid_document.pdf
${INVALID_FILE_PATH}     D:\\Downloads\\alp-sqa\\test\\test_files\\invalid_file.exe
${SMALL_FILE_PATH}       D:\\Downloads\\alp-sqa\\test\\test_files\\small_file.pdf
${LARGE_FILE_PATH}       D:\\Downloads\\alp-sqa\\test\\test_files\\large_file.pdf
@{PROGRAM_TYPES}    Competition    Exchange Program    International Conference    International Internship    Immersion/Short Program    International Seminar    International Webinar    Joint Classes    Joint Degree/Double Degree/Fast Track    Joint Project    Study Excursion