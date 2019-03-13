*** Settings ***
Documentation     Integration tests for BBS.
...               BBS receives PNF_UPDATE and CPE_AUTHENTICATION events from DMaaP and triggers associated Policies.
...               BBS communicates with AAI and DMaaP through SSL
Suite Setup       Run keywords   Create header  AND  Create sessions  AND  Ensure Container Is Running  ssl_bbs  AND  Ensure Container Is Exited  bbs
Suite Teardown    Ensure Container Is Running  bbs
Test Teardown     Reset Simulators
Library           resources/BbsLibrary.py
Resource          resources/bbs_library.robot
Resource          ../../common.robot

*** Variables ***
${DMAAP_SIMULATOR_SETUP_URL}    http://${DMAAP_SIMULATOR_SETUP}
${AAI_SIMULATOR_SETUP_URL}    http://${AAI_SIMULATOR_SETUP}
${AUTH_EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}    %{WORKSPACE}/tests/dcaegen2/bbs-testcases/assets/json_events/auth_event_with_all_fields.json
${AUTH_EVENT_WITHOUT_SWVERSION}    %{WORKSPACE}/tests/dcaegen2/bbs-testcases/assets/json_events/auth_event_without_swversion.json
${UPDATE_EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}    %{WORKSPACE}/tests/dcaegen2/bbs-testcases/assets/json_events/update_event_with_all_fields.json


*** Test Cases ***
Valid DMaaP CPE_AUTHENTICATION event can trigger Policy
    [Documentation]    BBS get valid CPE_AUTHENTICATION event from DMaaP with required fields - BBS triggers Policy
    [Tags]    BBS    Valid CPE_AUTHENTICATION event
    [Template]    Valid auth event processing
    ${AUTH_EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}
    ${AUTH_EVENT_WITHOUT_SWVERSION}

Valid DMaaP PNF_UPDATE event can trigger Policy
    [Documentation]    BBS get valid PNF_UPDATE event from DMaaP with required fields - BBS triggers Policy
    [Tags]    BBS    Valid PNF_UPDATE event
    [Template]    Valid update event processing
    ${UPDATE_EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}
