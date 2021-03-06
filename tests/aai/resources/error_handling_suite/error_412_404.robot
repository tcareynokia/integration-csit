*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       requests
Library       Collections

*** Variables ***
${PSERVERKEYVALUE}  pserver-integration-test1
${PSERVERURL}       https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/pservers/pserver/${PSERVERKEYVALUE}
${PSERVERDATA}      {"hostname":"${PSERVERKEYVALUE}"}

*** Test Cases ***
Run AAI Put Pserver
    [Documentation]             Create an pserver object
    ${resp}=                    PutWithCert              ${PSERVERURL}              ${PSERVERDATA}
    log                         ${PSERVERURL}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201
	
Run AAI Put Pserver again
    [Documentation]             Create an pserver object again without resource-version
    ${resp}=                    PutWithCert              ${PSERVERURL}              ${PSERVERDATA}
    log                         ${PSERVERURL}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      412	

Run AAI Get Pserver
    [Documentation]             Get the pserver object just created
    ${resp}                     GetWithCert              ${PSERVERURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete Pserver
    [Documentation]             Delete the pserver just created
    ${resp}=                    DeleteWithCert           ${PSERVERURL}?resource-version=${resource_version}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      204
	
Run AAI Get Pserver
    [Documentation]             Get the pserver object just deleted
    ${resp}                     GetWithCert              ${PSERVERURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      404	

*** Keywords ***
PutWithCert
    [Arguments]      ${url}      ${data}
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=integration-aai    X-FromAppId=integration-aai   Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.put('${url}', data='${data}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [return]         ${resp}

PostWithCert
    [Arguments]      ${url}      ${data}
    ${auth}=         Create List  AAI AAI
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=integration-aai    X-FromAppId=integration-aai   Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.post('${url}', data='${data}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [return]         ${resp}

GetWithCert
    [Arguments]      ${url}
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=integration-aai    X-FromAppId=integration-aai   Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.get('${url}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [return]         ${resp}

DeleteWithCert
    [Arguments]      ${url}
    ${auth}=         Create List  AAI AAI
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=integration-aai    X-FromAppId=integration-aai   Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.delete('${url}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [return]         ${resp}