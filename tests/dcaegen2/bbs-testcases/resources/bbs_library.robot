*** Settings ***
Library           RequestsLibrary
Library           Collections
Library           BbsLibrary.py
Resource          ../../../common.robot

*** Keywords ***
Create header
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    Set Suite Variable    ${suite_headers}    ${headers}

Create sessions
    Create Session    dmaap_setup_session    ${DMAAP_SIMULATOR_SETUP_URL}
    Set Suite Variable    ${dmaap_setup_session}    dmaap_setup_session
    Create Session    aai_setup_session    ${AAI_SIMULATOR_SETUP_URL}
    Set Suite Variable    ${aai_setup_session}    aai_setup_session

Reset Simulators
    Reset AAI simulator
    Reset DMaaP simulator

Invalid auth event processing
    [Arguments]    ${input_invalid_event_in_dmaap}
    [Timeout]    30s
    ${data}=    Get Data From File    ${input_invalid_event_in_dmaap}
    Set event in DMaaP    ${data}
    ${invalid_policy}=    Create invalid auth policy    ${data}
    ${err_msg}=    Catenate    SEPARATOR= \\n    |Incorrect json, consumerDmaapModel can not be created:     ${invalid_policy}
    Wait Until Keyword Succeeds    100x    100ms    Check BBS log    ${err_msg}

Valid auth event processing
    [Arguments]    ${input_valid_event_in_dmaap}
    [Timeout]    30s
    ${data}=    Get Data From File    ${input_valid_event_in_dmaap}
    ${posted_event_to_dmaap}=    Create auth policy    ${data}
    ${pnf_name}=    Create PNF name from auth    ${data}
    Set PNF name in AAI    ${pnf_name}
    Set event in DMaaP    ${data}
    Wait Until Keyword Succeeds    100x    300ms    Check auth policy    ${posted_event_to_dmaap}

Check auth policy
    [Arguments]    ${posted_event_to_dmaap}
    Set Test Variable    ${resp}    no_resp
    ${resp}=    Get Request    ${dmaap_setup_session}    /events/dcaeClOutput   headers=${suite_headers}
    Should Be Equal    ${resp.text}    ${posted_event_to_dmaap}
 
Invalid update event processing
    [Arguments]    ${input_invalid_event_in_dmaap}
    [Timeout]    30s
    ${data}=    Get Data From File    ${input_invalid_event_in_dmaap}
    Set event in DMaaP    ${data}
    ${invalid_policy}=    Create invalid update policy    ${data}
    ${err_msg}=    Catenate    SEPARATOR= \\n    |Incorrect json, consumerDmaapModel can not be created:     ${invalid_policy}
    Wait Until Keyword Succeeds    100x    100ms    Check BBS log    ${err_msg}

Valid update event processing
    [Arguments]    ${input_valid_event_in_dmaap}
    [Timeout]    30s
    ${data}=    Get Data From File    ${input_valid_event_in_dmaap}
    ${posted_event_to_dmaap}=    Create update policy    ${data}
    ${pnf_name}=    Create PNF name from update    ${data}
    Set PNF name in AAI    ${pnf_name}
    Set event in DMaaP    ${data}
    Wait Until Keyword Succeeds    100x    300ms    Check update policy    ${posted_event_to_dmaap}

Check update policy
    [Arguments]    ${posted_event_to_dmaap}
    ${resp}=    Get Request    ${dmaap_setup_session}    /events/dcaeClOutput   headers=${suite_headers}
    Should Be Equal    ${resp.text}    ${posted_event_to_dmaap}

Check BBS log
    [Arguments]    ${searched_log}
    ${status}=    Check for log    ${searched_log}
    Should Be Equal As Strings    ${status}    True

Set PNF name in AAI
    [Arguments]    ${pnfs_name}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=text/html
    ${resp}=    Put Request    ${aai_setup_session}    /set_pnfs    headers=${headers}    data=${pnfs_name}
    Should Be Equal As Strings    ${resp.status_code}    200

Set event in DMaaP
    [Arguments]    ${event_in_dmaap}
    ${resp}=    Put Request    ${dmaap_setup_session}    /set_get_event    headers=${suite_headers}    data=${event_in_dmaap}
    Should Be Equal As Strings    ${resp.status_code}    200

Reset AAI simulator
    ${resp}=    Post Request     ${aai_setup_session}    /reset
    Should Be Equal As Strings    ${resp.status_code}    200

Reset DMaaP simulator
    ${resp}=    Post Request     ${dmaap_setup_session}    /reset
    Should Be Equal As Strings    ${resp.status_code}    200