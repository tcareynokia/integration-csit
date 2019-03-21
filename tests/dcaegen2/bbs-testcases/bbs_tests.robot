*** Settings ***
Documentation     Integration tests for BBS.
...               BBS receives CPE_AUTHENTICATION event from DMaaP and triggers a Policy that updates the CFS service with the PNF.
...               BBS receives PNF_UPDATE event from DMaaP and triggers a Policy that updates the CFS service resources associated with the PNF.
Library           BbsLibrary
Resource          resources/bbs_library.robot
Resource          ../../common.robot
Suite Setup       Run keywords   Create header  AND  Create sessions  AND  Ensure Container Is Running  bbs-event-processor 
Test Teardown     Reset Simulators


*** Variables ***
${DMAAP_SIMULATOR_SETUP_URL}    http://${DMAAP_SIMULATOR_SETUP}
${AAI_SIMULATOR_SETUP_URL}    http://${AAI_SIMULATOR_SETUP}
${AUTH_EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}    %{WORKSPACE}/tests/dcaegen2/bbs-testcases/assets/json_events/auth_event_with_all_fields.json
${AUTH_EVENT_WITHOUT_SWVERSION}    %{WORKSPACE}/tests/dcaegen2/bbs-testcases/assets/json_events/auth_event_without_swversion.json
${AUTH_EVENT_WITH_MISSING_ADDITIONAL}    %{WORKSPACE}/tests/dcaegen2/bbs-testcases/assets/json_events/auth_event_with_missing_additional.json
${AUTH_EVENT_WITH_MISSING_STATE}    %{WORKSPACE}/tests/dcaegen2/bbs-testcases/assets/json_events/auth_event_with_missing_new_old_state.json
${AUTH_EVENT_WITH_MISSING_SOURCENAME}    %{WORKSPACE}/tests/dcaegen2/bbs-testcases/assets/json_events/auth_event_with_missing_sourceName.json
${AUTH_NOT_JSON_FORMAT}    %{WORKSPACE}/tests/dcaegen2/bbs-testcases/assets/json_events/auth_not_json_format.json
${AUTH_POLICY}    %{WORKSPACE}/tests/dcaegen2/bbs-testcases/assets/json_events/auth_policy_with_all_fields.json
${UPDATE_EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}    %{WORKSPACE}/tests/dcaegen2/bbs-testcases/assets/json_events/update_event_with_all_fields.json
${UPDATE_EVENT_WITH_MISSING_ATTACHMENT}    %{WORKSPACE}/tests/dcaegen2/bbs-testcases/assets/json_events/update_event_with_missing_attachment.json
${UPDATE_EVENT_WITH_MISSING_CORRELATION}    %{WORKSPACE}/tests/dcaegen2/bbs-testcases/assets/json_events/update_event_with_missing_correlation.json
${UPDATE_NOT_JSON_FORMAT}    %{WORKSPACE}/tests/dcaegen2/bbs-testcases/assets/json_events/update_not_json_format.json
${UPDATE_POLICY}    %{WORKSPACE}/tests/dcaegen2/bbs-testcases/assets/json_events/update_policy_with_all_fields.json

*** Test Cases ***
Valid DMaaP CPE_AUTHENTICATION event can trigger Policy
    [Documentation]    BBS get valid CPE_AUTHENTICATION event from DMaaP with required fields - BBS triggers Policy
    [Tags]    BBS    Valid CPE_AUTHENTICATION event    test
    [Template]    Valid auth event processing
    ${AUTH_EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}
    ${AUTH_EVENT_WITHOUT_SWVERSION}

Invalid DMaaP CPE_AUTHENTICATION event cannot trigger Policy
    [Documentation]    BBS get invalid CPE_AUTHENTICATION event from DMaaP with missing required fields - BBS does not trigger Policy
    [Tags]    BBS    Invalid CPE_AUTHENTICATION event
    [Template]    Invalid auth event processing
    ${AUTH_EVENT_WITH_MISSING_ADDITIONAL}
    ${AUTH_EVENT_WITH_MISSING_STATE}
    ${AUTH_EVENT_WITH_MISSING_SOURCENAME}

Get valid CPE_AUTHENTICATION event from DMaaP and PNF record in AAI does not exist
    [Documentation]    BBS get valid event from DMaaP with all required fields and in AAI record doesn't exist - BBS does not trigger Policy
    [Tags]    BBS    Missing AAI record
    [Timeout]    30s
    ${data}=    Get Data From File    ${AUTH_EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}
    Set PNF name in AAI    wrong_aai_record
    Set event in DMaaP    ${data}
    Wait Until Keyword Succeeds    100x    300ms    Check BBS log    |AAIProducerTask exception has been registered
    Wait Until Keyword Succeeds    100x    300ms    Check BBS log    |Chain of tasks have been aborted due to errors in BBS workflow

CPE_AUTHENTICATION Event in DMaaP is not JSON format
    [Documentation]    BBS CPE_AUTHENTICATION not JSON format event from DMaaP - BBS does not Trigger Policy
    [Tags]    BBS
    ${data}=    Get Data From File    ${AUTH_NOT_JSON_FORMAT}
    Set event in DMaaP    ${data}
    Wait Until Keyword Succeeds    100x    300ms    Check BBS log    |java.lang.IllegalStateException: Not a JSON Array:

Get valid CPE_AUTHENTICATION event from DMaaP and AAI is not responding
    [Documentation]    BBS get valid CPE_AUTHENTICATION event from DMaaP with all required fields and AAI is not responding - BBS does not trigger Policy
    [Tags]    BBS    AAI
    [Timeout]    180s
    ${data}=    Get Data From File    ${AUTH_EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}
    Ensure Container Is Exited   aai_simulator
    Set event in DMaaP    ${data}
    Wait Until Keyword Succeeds    100x    300ms    Check BBS log    java.net.UnknownHostException: aai_imulator
    Ensure Container Is Running  aai_simulator
    
Valid DMaaP PNF_UPDATE event can trigger Policy
    [Documentation]    BBS get valid PNF_UPDATE event from DMaaP with required fields - BBS triggers Policy
    [Tags]    BBS    Valid PNF_UPDATE event    test
    [Template]    Valid update event processing
    ${UPDATE_EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}

Invalid DMaaP PNF_UPDATE event cannot trigger Policy
    [Documentation]    BBS get invalid PNF_UPDATE event from DMaaP with missing required fields - BBS does not trigger Policy
    [Tags]    BBS    Invalid PNF_UPDATE event
    [Template]    Invalid update event processing
    ${UPDATE_EVENT_WITH_MISSING_ATTACHMENT}
    ${UPDATE_EVENT_WITH_MISSING_CORRELATION}

Get valid PNF_UPDATE event from DMaaP and PNF record in AAI does not exist
    [Documentation]    BBS get valid PNF_UPDATE event from DMaaP with all required fields and in AAI record doesn't exist - BBS does not trigger Policy
    [Tags]    BBS    Missing AAI record
    [Timeout]    30s
    ${data}=    Get Data From File    ${UPDATE_EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}
    Set PNF name in AAI    wrong_aai_record
    Set event in DMaaP    ${data}
    Wait Until Keyword Succeeds    100x    300ms    Check BBS log    |AAIProducerTask exception has been registered
    Wait Until Keyword Succeeds    100x    300ms    Check BBS log    |Chain of tasks have been aborted due to errors in BBS workflow

PNF_UPDATE Event in DMaaP is not JSON format
    [Documentation]    BBS PNF_UPDATE not JSON format event from DMaaP - BBS does not Trigger Policy
    [Tags]    BBS
    ${data}=    Get Data From File    ${UPDATE_NOT_JSON_FORMAT}
    Set event in DMaaP    ${data}
    Wait Until Keyword Succeeds    100x    300ms    Check BBS log    |java.lang.IllegalStateException: Not a JSON Array:

Get valid PNF_UPDATE event from DMaaP and AAI is not responding
    [Documentation]    BBS get valid PNF_UPDATE event from DMaaP with all required fields and AAI is not responding - BBS does not trigger Policy
    [Tags]    BBS    AAI
    [Timeout]    180s
    ${data}=    Get Data From File    ${UPDATE_EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}
    Ensure Container Is Exited   aai_simulator
    Set event in DMaaP    ${data}
    Wait Until Keyword Succeeds    100x    300ms    Check BBS log    java.net.UnknownHostException: aai
    Ensure Container Is Running  aai_simulator
