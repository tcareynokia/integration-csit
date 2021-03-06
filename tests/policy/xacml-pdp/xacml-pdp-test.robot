*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Test Cases ***
Healthcheck
     [Documentation]    Runs Policy Xacml PDP Health check
     ${auth}=    Create List    healthcheck    zb!XztG34 
     Log    Creating session https://${POLICY_PDPX_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PDPX_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/pdpx/v1/healthcheck     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200

Statistics
     [Documentation]    Runs Policy Xacml PDP Statistics
     ${auth}=    Create List    healthcheck    zb!XztG34 
     Log    Creating session https://${POLICY_PDPX_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PDPX_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/pdpx/v1/statistics     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200
