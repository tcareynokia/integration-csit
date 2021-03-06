*** Settings ***
Documentation     The main interface for interacting with Portal. It handles low level stuff like managing the selenium request library and Portal required steps
Library 	    ExtendedSelenium2Library
Library	          RequestsClientCert
Library 	      RequestsLibrary
Library	          UUID 
Library         DateTime  
Resource        ../global_properties.robot
Resource        ../browser_setup.robot

*** Variables ***
${PORTAL_ENV}            /ECOMPPORTAL
${PORTAL_LOGIN_URL}                ${GLOBAL_PORTAL_URL}${PORTAL_ENV}/login.htm
${PORTAL_HOME_PAGE}        ${GLOBAL_PORTAL_URL}${PORTAL_ENV}/applicationsHome
${PORTAL_MICRO_ENDPOINT}    ${GLOBAL_PORTAL_URL}${PORTAL_ENV}/commonWidgets
${PORTAL_HOME_URL}                ${GLOBAL_PORTAL_URL}${PORTAL_ENV}/applicationsHome
${App_First_Name}    appdemo    
${App_Last_Name}    demo
${App_Email_Address}    appdemo@onap.com
${App_LoginID}    appdemo 
${App_Loginpwd}    demo123456!
${App_LoginPwdCheck}    demo123456!
${Sta_First_Name}    stademo   
${Sta_Last_Name}    demo
${Sta_Email_Address}    stademo@onap.com
${Sta_LoginID}    stademo
${Sta_Loginpwd}    demo123456!
${Sta_LoginPwdCheck}    demo123456!
${Existing_User}    portal
${PORTAL_HEALTH_CHECK_PATH}        /ECOMPPORTAL/portalApi/healthCheck
#${Application}     'Virtual Infrastructure Deployment'  
#${Application_tab}     'select-app-Virtual-Infrastructure-Deployment'   
#${Application_dropdown}    'div-app-name-dropdown-Virtual-Infrastructure-Deployment'
#${Application_dropdown_select}    'div-app-name-Virtual-Infrastructure-Deployment'  
${APPC_LOGIN_URL}     http://104.130.74.99:8282/apidoc/explorer/index.html 
${PORTAL_ASSETS_DIRECTORY}    C:\\Users\\kk707x\\Downloads


  


*** Keywords ***

Run Portal Health Check
     [Documentation]    Runs Portal Health check
     ${resp}=    Run Portal Get Request    ${PORTAL_HEALTH_CHECK_PATH}    
     Should Be Equal As Strings 	${resp.status_code} 	200
     Should Be Equal As Strings 	${resp.json()['statusCode']} 	200
Run Portal Get Request
     [Documentation]    Runs Portal Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session 	portal	${GLOBAL_PORTAL_URL}
     ${uuid}=    Generate UUID
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
     ${resp}= 	Get Request 	portal 	${data_path}     headers=${headers}
     Log    Received response from portal ${resp.text}
     [Return]    ${resp}     
     

Portal admin Login To Portal GUI
    [Documentation]   Logs into Portal GUI
    # Setup Browser Now being managed by test case
    ##Setup Browser
    Go To    ${PORTAL_LOGIN_URL}
    Maximize Browser Window
    Set Selenium Speed    ${GLOBAL_SELENIUM_DELAY}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Log    Logging in to ${GLOBAL_PORTAL_SERVER}${PORTAL_ENV}
   # Handle Proxy Warning
    Title Should Be    Login
    Input Text    xpath=//input[@ng-model='loginId']    ${GLOBAL_PORTAL_ADMIN_USER}
    Input Password    xpath=//input[@ng-model='password']    ${GLOBAL_PORTAL_ADMIN_PWD}
    Click Link    xpath=//a[@id='loginBtn']
    Wait Until Page Contains Element    xpath=//img[@alt='Onap Logo']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}    
    Log    Logged in to ${GLOBAL_PORTAL_SERVER}${PORTAL_ENV}

Portal admin Go To Portal HOME
    [Documentation]    Naviage to Portal Home
    Go To    ${PORTAL_HOME_URL}
    Wait Until Page Contains Element    xpath=//div[@class='applicationWindow']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}   
    
Portal admin User Notifications 
    [Documentation]    Naviage to User notification tab
    Click Link    xpath=//a[@id='parent-item-User-Notifications']
    Wait Until Element Is Visible    xpath=//h1[@class='heading-page']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
    Click Button    xpath=//button[@id='button-openAddNewApp']
    Click Button    xpath=(//button[@id='undefined'])[1]
    #Click Button    xpath=//input[@id='datepicker-start']
    
Portal admin Add Application Admin New User
    [Documentation]    Naviage to Admins tab
    Click Link    xpath=//a[@title='Admins']
    Wait Until Element Is Visible    xpath=//h1[contains(.,'Admins')]    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
    Page Should Contain      Admins
    Click Button    xpath=//button[@ng-click='admins.openAddNewAdminModal()']
    Click Button    xpath=//button[@id='Create-New-User-button']
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.firstName']    ${First_Name}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.lastName']    ${Last_Name}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.emailAddress']    ${Email_Address}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginId']    ${LoginID}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginPwd']    ${Loginpwd}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginPwdCheck']    ${LoginPwdCheck} 
    Click Button    xpath=//button[@ng-click='searchUsers.addNewUserFun()']
    Click Button    xpath=//button[@id='search-users-button-next']
    Click Button    xpath=//input[@value='Select application']
    Scroll Element Into View    xpath=(//input[@value='Select application']/following::*[contains(text(),'Virtual Infrastructure Deployment')])[1]
    #Scroll Element Into View    xpath=(//input[@value='Select application']/following::*[contains(text(),'Virtual Infrastructure Deployment')])[1]
    Click Element    xpath=(//li[contains(.,'Virtual Infrastructure Deployment')])[2]
     Click Button    xpath=//button[@id='div-updateAdminAppsRoles']
   Click Element    xpath=//button[@id='admin-div-ok-button']
    Click Element    xpath=//button[@id='div-confirm-ok-button']
    Click Link    xpath=//a[@aria-label='Admins']
    Click Button    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
    Input Text    xpath=//input[@id='input-table-search']    ${First_Name}
    Element Text Should Be      xpath=(//span[contains(.,'Test')] )[1]   ${First_Name}
    
    
    
    
Portal admin Add Application Admin Exiting User 
    [Documentation]    Naviage to Admins tab
    Wait Until Element Is Visible    xpath=//a[@title='Admins']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
    Click Link    xpath=//a[@title='Admins']
    Wait Until Element Is Visible    xpath=//h1[contains(.,'Admins')]    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
    Page Should Contain      Admins
    Click Button    xpath=//button[@ng-click='admins.openAddNewAdminModal()']
    Input Text    xpath=//input[@id='input-user-search']    ${Existing_User}   
    Click Button    xpath=//button[@id='button-search-users']
    Click Element    xpath=//span[@id='result-uuid-0']
    Click Button    xpath=//button[@id='search-users-button-next']
    Click Button    xpath=//input[@value='Select application']
    Scroll Element Into View    xpath=(//input[@value='Select application']/following::*[contains(text(),'Virtual Infrastructure Deployment' )])[1]
    
    Click Element    xpath=(//li[contains(.,'Virtual Infrastructure Deployment' )])[2]
    #Select From List    xpath=(//input[@value='Select application']/following::*[contains(text(),'Virtual Infrastructure Deployment')])[1]   Virtual Infrastructure Deployment
    Click Button    xpath=//button[@id='div-updateAdminAppsRoles']
    Click Element    xpath=//button[@id='admin-div-ok-button']
    Click Element    xpath=//button[@id='div-confirm-ok-button']
    Get Selenium Implicit Wait
    Click Link    xpath=//a[@aria-label='Admins']
    Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment' )]
    Input Text    xpath=//input[@id='input-table-search']    ${Existing_User}
    Element Text Should Be      xpath=(//span[contains(.,'portal')])[1]   ${Existing_User}
    
    
Portal admin Delete Application Admin Existing User  
    [Documentation]    Naviage to Admins tab
    Click Element    xpath=(//span[contains(.,'portal')] )[1] 
    Click Element    xpath=//*[@id='select-app-Virtual-Infrastructure-Deployment']/following::i[@id='i-delete-application']
    Click Element    xpath=//button[@id='div-confirm-ok-button']
    Click Button    xpath=//button[@id='div-updateAdminAppsRoles']
    Click Element    xpath=//button[@id='admin-div-ok-button']
    #Is Element Visible      xpath=(//span[contains(.,'Portal')] )[2]
    #Is Element Visible    xpath=(//*[contains(.,'Portal')] )[2]
    Element Should Not Contain     xpath=//*[@table-data='admins.adminsTableData']    portal
    
    
Portal admin Add Application admin User New user
    [Documentation]    Naviage to Users tab
    Click Link    xpath=//a[@title='Users']
    Page Should Contain      Users
    Click Button    xpath=//button[@ng-click='users.openAddNewUserModal()']
    Click Button    xpath=//button[@id='Create-New-User-button']
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.firstName']    ${App_First_Name}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.lastName']    ${App_Last_Name}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.emailAddress']    ${App_Email_Address}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginId']    ${App_LoginID}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginPwd']    ${App_Loginpwd}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginPwdCheck']    ${App_LoginPwdCheck}
    Click Button    xpath=//button[@ng-click='searchUsers.addNewUserFun()']
    Click Button    xpath=//button[@id='next-button']
    #Scroll Element Into View    xpath=//div[@id='div-app-name-dropdown-Virtual-Infrastructure-Deployment']
    Click Element    xpath=//*[@id='div-app-name-dropdown-Virtual-Infrastructure-Deployment']
    Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::input[@id='Standard-User-checkbox']
    Set Selenium Implicit Wait    3000
    Click Button    xpath=//button[@id='new-user-save-button']
    Set Selenium Implicit Wait    3000
    Go To    ${PORTAL_HOME_PAGE}
     Click Link    xpath=//a[@title='Users']
     Click Element    xpath=//input[@id='dropdown1']
     Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
    Input Text    xpath=//input[@id='input-table-search']    ${App_First_Name}
    Element Text Should Be      xpath=(//span[contains(.,'appdemo')] )[1]   ${App_First_Name}
    
    
Portal admin Add Standard User New user
    [Documentation]    Naviage to Users tab
    Click Link    xpath=//a[@title='Users']
    Page Should Contain      Users
    Click Button    xpath=//button[@ng-click='users.openAddNewUserModal()']
    Click Button    xpath=//button[@id='Create-New-User-button']
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.firstName']    ${Sta_First_Name}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.lastName']    ${Sta_Last_Name}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.emailAddress']    ${Sta_Email_Address}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginId']    ${Sta_LoginID}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginPwd']    ${Sta_Loginpwd}
    Input Text    xpath=//input[@ng-model='searchUsers.newUser.loginPwdCheck']    ${Sta_LoginPwdCheck}
    Click Button    xpath=//button[@ng-click='searchUsers.addNewUserFun()']
    Click Button    xpath=//button[@id='next-button']
    #Scroll Element Into View    xpath=//div[@id='div-app-name-dropdown-Virtual-Infrastructure-Deployment']
    Click Element    xpath=//*[@id='div-app-name-dropdown-Virtual-Infrastructure-Deployment']
    Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::input[@id='Standard-User-checkbox']
    Set Selenium Implicit Wait    3000
    Click Button    xpath=//button[@id='new-user-save-button']
    Set Selenium Implicit Wait    3000
    Go To    ${PORTAL_HOME_PAGE}
     Click Link    xpath=//a[@title='Users']
     Click Element    xpath=//input[@id='dropdown1']
     Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
    Input Text    xpath=//input[@id='input-table-search']    ${Sta_First_Name}
    Element Text Should Be      xpath=(//span[contains(.,'appdemo')] )[1]   ${Sta_First_Name} 
    
    
    
Portal admin Add Application Admin Exiting User -APPDEMO 
    [Documentation]    Naviage to Admins tab
    Wait Until Element Is Visible    xpath=//a[@title='Admins']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
    Click Link    xpath=//a[@title='Admins']
    Wait Until Element Is Visible    xpath=//h1[contains(.,'Admins')]    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
    Page Should Contain      Admins
    Click Button    xpath=//button[@ng-click='admins.openAddNewAdminModal()']
    Input Text    xpath=//input[@id='input-user-search']    ${App_First_Name}   
    Click Button    xpath=//button[@id='button-search-users']
    Click Element    xpath=//span[@id='result-uuid-0']
    Click Button    xpath=//button[@id='search-users-button-next']
    Click Button    xpath=//input[@value='Select application']
    Scroll Element Into View    xpath=(//input[@value='Select application']/following::*[contains(text(),'Virtual Infrastructure Deployment' )])[1]
    
    Click Element    xpath=(//li[contains(.,'Virtual Infrastructure Deployment' )])[2]
    #Select From List    xpath=(//input[@value='Select application']/following::*[contains(text(),'Virtual Infrastructure Deployment')])[1]   Virtual Infrastructure Deployment
    Click Button    xpath=//button[@id='div-updateAdminAppsRoles']
    Click Element    xpath=//button[@id='admin-div-ok-button']
    Click Element    xpath=//button[@id='div-confirm-ok-button']
    Get Selenium Implicit Wait
    Click Link    xpath=//a[@aria-label='Admins']
    Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment' )]
    Input Text    xpath=//input[@id='input-table-search']    ${App_First_Name}
    Element Text Should Be      xpath=(//span[contains(.,'appdemo')])[1]   ${App_First_Name}    
    
    
      
Portal admin Add Standard User Existing user   
     [Documentation]    Naviage to Users tab
     Click Link    xpath=//a[@title='Users']
     Page Should Contain      Users
     Click Button    xpath=//button[@ng-click='users.openAddNewUserModal()']
     Input Text    xpath=//input[@id='input-user-search']    ${Existing_User}
     Click Button    xpath=//button[@id='button-search-users']
     Click Element    xpath=//span[@id='result-uuid-0']
     Click Button    xpath=//button[@id='next-button']
     Click Element    xpath=//*[@id='div-app-name-dropdown-Virtual-Infrastructure-Deployment']
     Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::input[@id='Standard-User-checkbox']
     #Click Element    xpath=//div[@id='div-app-name-dropdown-xDemo-App']
     #Click Element    xpath=//div[@id='div-app-name-xDemo-App']/following::input[@id='Standard-User-checkbox']
     
     Set Selenium Implicit Wait    3000
     Click Button    xpath=//button[@id='new-user-save-button']
     Set Selenium Implicit Wait    3000
     #Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
     #Select From List    xpath=//input[@value='Select application']    Virtual Infrastructure Deployment
     #Click Link    xpath=//a[@title='Users']
     #Page Should Contain      Users
     #Focus    xpath=//input[@name='dropdown1']
    
     Go To    ${PORTAL_HOME_PAGE}
     Click Link    xpath=//a[@title='Users']
     Click Element    xpath=//input[@id='dropdown1']
     Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
     #Click Element    xpath=//li[contains(.,'XDemo App')]
     Input Text    xpath=//input[@id='input-table-search']    ${Existing_User}
     Element Text Should Be      xpath=(.//*[@id='rowheader_t1_0'])[2]   Standard User
     
     
Portal admin Edit Standard User Existing user  
     [Documentation]    Naviage to Users tab
     Click Element    xpath=(.//*[@id='rowheader_t1_0'])[2]
     Click Element    xpath=//*[@id='div-app-name-dropdown-Virtual-Infrastructure-Deployment']
     Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::input[@id='Standard-User-checkbox']
     Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::input[@id='System-Administrator-checkbox']
     Set Selenium Implicit Wait    3000
     Click Button    xpath=//button[@id='new-user-save-button']
     Set Selenium Implicit Wait    3000
     Page Should Contain      Users
     #Click Button    xpath=//input[@id='dropdown1']
     #Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
     Input Text    xpath=//input[@id='input-table-search']    ${Existing_User}
     Element Text Should Be      xpath=(.//*[@id='rowheader_t1_0'])[2]   System Administrator
     
     
 Portal admin Delete Standard User Existing user    
     [Documentation]    Naviage to Users tab
     Click Element    xpath=(.//*[@id='rowheader_t1_0'])[2]
     Scroll Element Into View    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::*[@id='app-item-delete'][1]
     Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::*[@id='app-item-delete'][1]
     Click Element    xpath=//button[@id='div-confirm-ok-button']
     Click Button    xpath=//button[@id='new-user-save-button']
     #Input Text    xpath=//input[@id='input-table-search']    ${Existing_User}
     #Is Element Visible    xpath=(//*[contains(.,'Portal')] )[2]  
      Element Should Not Contain     xpath=//*[@table-data='users.accountUsers']    portal  
     
     
     
     
Functional Top Menu Get Access     
    [Documentation]    Naviage to Support tab
     Click Link    xpath=//a[contains(.,'Support')]
     Mouse Over    xpath=//*[contains(text(),'Get Access')]
     Click Link    xpath=//a[contains(.,'Get Access')]
     Element Text Should Be    xpath=//h1[contains(.,'Get Access')]    Get Access
     
     
Functional Top Menu Contact Us     
    [Documentation]    Naviage to Support tab
     Click Link    xpath=//a[contains(.,'Support')]
     Mouse Over    xpath=//*[contains(text(),'Contact Us')]
     Click Link    xpath=//a[contains(.,'Contact Us')]
     Element Text Should Be    xpath=//h1[contains(.,'Contact Us')]    Contact Us    
     Click Image    xpath=//img[@alt='Onap Logo'] 
     

Portal admin Edit Functional menu  
    [Documentation]    Naviage to Edit Functional menu tab
    Click Link    xpath=//a[@title='Edit Functional Menu']
    Click Link    xpath=.//*[@id='Manage']/div/a
    Click Link    xpath=.//*[@id='Design']/div/a
    Click Link    xpath=.//*[@id='Product_Design']/div/a
    Open Context Menu    xpath=//*[@id='Product_Design']/div/span
    Click Link    xpath=//a[@href='#add']
    Input Text    xpath=//input[@id='input-title']    ONAP Test
    #Input Text    xpath=//input[@id='input-url']    http://google.com
    Click Element     xpath=//input[@id='select-app']
    Scroll Element Into View    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
    Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
    Input Text    xpath=//input[@id='input-url']    http://google.com
    Click Button    xpath=//button[@id='button-save-continue']
    #Click Button    xpath=//div[@title='Select Roles']
    Click Element    xpath=//*[@id='app-select-Select Roles']
    Click Element    xpath=//input[@id='Standard-User-checkbox']
    Click Element    xpath=//button[@id='button-save-add']
    Click Image     xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000
    Click Link    xpath=//a[contains(.,'Manage')]
     Mouse Over    xpath=//*[contains(text(),'Design')]
     Set Selenium Implicit Wait    3000
     Element Text Should Be    xpath=//a[contains(.,'ONAP Test')]      ONAP Test  
     Set Selenium Implicit Wait    3000
      Click Link    xpath=//a[@title='Edit Functional Menu']
    Click Link    xpath=.//*[@id='Manage']/div/a
    Click Link    xpath=.//*[@id='Design']/div/a
    Click Link    xpath=.//*[@id='Product_Design']/div/a
    Open Context Menu    xpath=//*[@id='ONAP_Test']
    Click Link    xpath=//a[@href='#delete']
     Set Selenium Implicit Wait    3000
     Click Element    xpath=//button[@id='div-confirm-ok-button']
     Click Image     xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000
    Click Link    xpath=//a[contains(.,'Manage')]
     Mouse Over    xpath=//*[contains(text(),'Design')]
     Set Selenium Implicit Wait    3000
     Element Should Not Contain    xpath=(.//*[contains(.,'Design')]/following::ul[1])[1]      ONAP Test  
     
    
     
     
    
    
    
    
Portal admin Microservice Onboarding
     [Documentation]    Naviage to Edit Functional menu tab
     Click Link    xpath=//a[@title='Microservice Onboarding']
     Click Button    xpath=//button[@id='microservice-onboarding-button-add']
     Input Text    xpath=//input[@name='name']    Test Microservice
     Input Text    xpath=//*[@name='desc']    Test
     Click Element    xpath=//input[@id='microservice-details-input-app']
     Scroll Element Into View    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
     Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
     Click Element     xpath=//*[@name='desc']
     Input Text    xpath=//input[@name='url']    ${PORTAL_MICRO_ENDPOINT}
     Click Element    xpath=//input[@id='microservice-details-input-security-type']
     Scroll Element Into View    xpath=//li[contains(.,'Basic Authentication')]
     Click Element    xpath=//li[contains(.,'Basic Authentication')]
     Input Text    xpath=//input[@name='username']    ${GLOBAL_PORTAL_ADMIN_USER}
     Input Text    xpath=//input[@name='password']    ${GLOBAL_PORTAL_ADMIN_PWD}
     Click Button    xpath=//button[@id='microservice-details-save-button']
     #Table Column Should Contain    xpath=//*[@table-data='serviceList']    0    Test Microservice
     Element Text Should Be    xpath=//*[@table-data='serviceList']    Test Microservice
     
    
    
Portal Admin Create Widget for All users 
    [Documentation]    Naviage to Create Widget menu tab
    ${WidgetAttachment}=    Catenate    ${PORTAL_ASSETS_DIRECTORY}\\widget_news.zip
    Click Link    xpath=//a[@title='Widget Onboarding']
    Click Button    xpath=//button[@id='widget-onboarding-button-add']
    Input Text    xpath=//*[@name='name']    ONAP-VID
    Input Text    xpath=//*[@name='desc']    ONAP VID
    Click Element    xpath=//*[@id='widgets-details-input-endpoint-url']
    Scroll Element Into View    xpath=//li[contains(.,'Test Microservice')]
    Click Element    xpath=//li[contains(.,'Test Microservice')]
    Click Element    xpath=//*[contains(text(),'Allow all user access')]/preceding::input[@ng-model='widgetOnboardingDetails.widget.allUser'][1] 
    Choose File    xpath=//input[@id='widget-onboarding-details-upload-file']    ${WidgetAttachment}
    Click Button    xpath=//button[@id='widgets-details-save-button']
    Wait Until Page Contains    ONAP-VID    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
    Page Should Contain    ONAP-VID
     Set Selenium Implicit Wait    3000
    GO TO    ${PORTAL_HOME_PAGE}
    
    
Portal Admin Delete Widget for All users 
     [Documentation]    Naviage to delete Widget menu tab
     #Wait Until Page Contains    ONAP-VID    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
     #Page Should Contain    ONAP-VID
     #Click Image    xpath=//img[@alt='Onap Logo']
     Click Link    xpath=//a[@title='Widget Onboarding']
     Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
     #Wait Until Page Contains    xpath=(.//*[contains(text(),'ONAP-VID')]/followi
     #Wait Until Page Contains    xpath=(.//*[contains(text(),'ONAP-VID')]/following::*[@ng-click='widgetOnboarding.deleteWidget(rowData)'])[1]    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
     Click Element    xpath=(.//*[contains(text(),'ONAP-VID')]/following::*[@ng-click='widgetOnboarding.deleteWidget(rowData)'])[1]
     Click Element    xpath=//button[@id='div-confirm-ok-button']
     Set Selenium Implicit Wait    3000
     Element Should Not Contain     xpath=//*[@table-data='portalAdmin.portalAdminsTableData']    ONAP-VID
     #Is Element Visible    xpath=//*[@table-data='portalAdmin.portalAdminsTableData']
     #Table Column Should Contain    .//*[@table-data='portalAdmin.portalAdminsTableData']    0       ONAP-VID    
     #Set Selenium Implicit Wait    3000
    
    
Portal Admin Create Widget for Application Roles 
    [Documentation]    Naviage to Create Widget menu tab 
    ${WidgetAttachment}=    Catenate    ${PORTAL_ASSETS_DIRECTORY}\\widget_news.zip 
    Click Link    xpath=//a[@title='Widget Onboarding'] 
    Click Button    xpath=//button[@id='widget-onboarding-button-add'] 
    Input Text    xpath=//*[@name='name']    ONAP-VID 
    Input Text    xpath=//*[@name='desc']    ONAP VID 
    Click Element    xpath=//*[@id='widgets-details-input-endpoint-url'] 
    Scroll Element Into View    xpath=//li[contains(.,'Test Microservice')] 
    Click Element    xpath=//li[contains(.,'Test Microservice')] 
    Click element    xpath=//*[@id="app-select-Select Applications"] 
    click element    xpath=//*[@id="Virtual-Infrastructure-Deployment-checkbox"] 
    Click element    xpath=//*[@name='desc'] 
    click element    xpath=//*[@id="app-select-Select Roles"] 
    click element    xpath=//*[@id="Standard-User-checkbox"] 
    Click element    xpath=//*[@name='desc'] 
    Scroll Element Into View    xpath=//input[@id='widget-onboarding-details-upload-file'] 
    Choose File    xpath=//input[@id='widget-onboarding-details-upload-file']    ${WidgetAttachment} 
    Click Button    xpath=//button[@id='widgets-details-save-button'] 
     Click Image     xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000
    #Wait Until Page Contains    ONAP-VID    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
    Click Link    xpath=//a[@title='Widget Onboarding'] 
    Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
    Page Should Contain    ONAP-VID 
    Set Selenium Implicit Wait    3000 
    GO TO    ${PORTAL_HOME_PAGE}
    
    
    
    
 Portal Admin Delete Widget for Application Roles 
     [Documentation]    Naviage to delete Widget menu tab
     #Wait Until Page Contains    ONAP-VID    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT} 
     #Page Should Contain    ONAP-VID
     #Click Image    xpath=//img[@alt='Onap Logo']
     Click Link    xpath=//a[@title='Widget Onboarding']
     Click Element    xpath=//input[@id='dropdown1']
    Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
     #Wait Until Page Contains    xpath=(.//*[contains(text(),'ONAP-VID')]/following::*[@ng-click='widgetOnboarding.deleteWidget(rowData)'])[1]    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
     Click Element    xpath=(.//*[contains(text(),'ONAP-VID')]/following::*[@ng-click='widgetOnboarding.deleteWidget(rowData)'])[1]
     Click Element    xpath=//button[@id='div-confirm-ok-button']
     Set Selenium Implicit Wait    3000
     Element Should Not Contain     xpath=//*[@table-data='portalAdmin.portalAdminsTableData']    ONAP-VID
     #Is Element Visible    xpath=//*[@table-data='portalAdmin.portalAdminsTableData']
     #Table Column Should Contain    .//*[@table-data='portalAdmin.portalAdminsTableData']    0       ONAP-VID    
     #Set Selenium Implicit Wait    3000   
    
    
    
Portal Admin Edit Widget
    [Documentation]    Naviage to Home tab  
    #Mouse Over    xpath=(//h3[contains(text(),'News')]/following::span[1])[1]
    Click Element    xpath=(//h3[contains(text(),'News')]/following::span[1])[1]
    Set Browser Implicit Wait    8000
    #Wait Until Element Is Visible    xpath=(//h3[contains(text(),'News')]/following::span[1]/following::a[contains(text(),'Edit')])[1]    60
    Mouse Over    xpath=(//h3[contains(text(),'News')]/following::span[1]/following::a[contains(text(),'Edit')])[1] 
    Click Link    xpath=(//h3[contains(text(),'News')]/following::span[1]/following::a[contains(text(),'Edit')])[1]
    Input Text    xpath=//input[@name='title']    ONAP_VID
    Input Text    xpath=//input[@name='url']    http://about.att.com/news/international.html
    Input Text    xpath=//input[@id='widget-input-add-order']    5
    Click Link    xpath=//a[contains(.,'Add New')]
    Click Element    xpath=//div[@id='close-button']
    Element Should Contain    xpath=//*[@table-data='ignoredTableData']    ONAP_VID
    Click Element    xpath=.//div[contains(text(),'ONAP_VID')]/following::*[contains(text(),'5')][1]/following::div[@ng-click='remove($index);'][1]
    Click Element    xpath=//div[@id='confirmation-button-next']
    Element Should Not Contain    xpath=//*[@table-data='ignoredTableData']    ONAP_VID
    Click Link    xpath=//a[@id='close-button']
    
    
    
    
Portal Admin Broadcast Notifications 
    [Documentation]   Portal Test Admin Broadcast Notifications 
    ${CurrentDay}=    Get Current Date    result_format=%m/%d/%Y 
    ${NextDay}=    Get Current Date    increment=24:00:00    result_format=%m/%d/%Y 
    ${CurrentDate}=    Get Current Date    result_format=%m%d%y%H%M
    ${AdminBroadCastMsg}=    catenate    ONAP VID Broadcast Automation${CurrentDate} 
    Click Image     xpath=//img[@alt='Onap Logo']
    Set Selenium Implicit Wait    3000
    Click Link    xpath=//*[@id="parent-item-User-Notifications"] 
    Wait until Element is visible    xpath=//*[@id="button-openAddNewApp"]    timeout=10 
    Click button    xpath=//*[@id="button-openAddNewApp"] 
    Input Text    xpath=//input[@id='datepicker-start']     ${CurrentDay} 
    Input Text    xpath=//input[@id='datepicker-end']     ${NextDay} 
    Input Text    xpath=//*[@id="add-notification-input-title"]    ONAP VID Broadcast Automation 
    Input Text    xpath=//*[@id="user-notif-input-message"]    ${AdminBroadCastMsg} 
    click element    xpath=//*[@id="button-notification-save"] 
    Wait until Element is visible    xpath=//*[@id="button-openAddNewApp"]    timeout=10 
    click element    xpath=//*[@id="megamenu-notification-button"] 
    click element    xpath=//*[@id="notification-history-link"] 
    Wait until Element is visible    xpath=//*[@id="notification-history-table"]    timeout=10 
    Table Column Should Contain    xpath=//*[@id="notification-history-table"]    2    ${AdminBroadCastMsg} 
    log    ${AdminBroadCastMsg} 
    [Return]     ${AdminBroadCastMsg}
        
Portal Admin Category Notifications 
    [Documentation]   Portal Admin Broadcast Notifications 
    ${CurrentDay}=    Get Current Date    result_format=%m/%d/%Y 
    ${NextDay}=    Get Current Date    increment=24:00:00    result_format=%m/%d/%Y 
    ${CurrentDate}=    Get Current Date    result_format=%m%d%y%H%M
    ${AdminCategoryMsg}=    catenate    ONAP VID Category Automation${CurrentDate} 
    Click Link    xpath=//a[@id='parent-item-Home'] 
    Click Link    xpath=//*[@id="parent-item-User-Notifications"] 
    Wait until Element is visible    xpath=//*[@id="button-openAddNewApp"]    timeout=10 
    Click button    xpath=//*[@id="button-openAddNewApp"]
    #Select Radio Button    NO     radio-button-no
    Click Element    //*[contains(text(),'Broadcast to All Categories')]/following::*[contains(text(),'No')][1]
    #Select Radio Button    //label[@class='radio']    radio-button-approles
    Click Element    xpath=//*[contains(text(),'Categories')]/following::*[contains(text(),'Application Roles')][1]
    Click Element    xpath=//*[contains(text(),'Virtual Infrastructure Deployment')]/preceding::input[@ng-model='member.isSelected'][1] 
    Input Text    xpath=//input[@id='datepicker-start']     ${CurrentDay} 
    Input Text    xpath=//input[@id='datepicker-end']     ${NextDay} 
    Input Text    xpath=//*[@id="add-notification-input-title"]    ONAP VID Category Automation 
    Input Text    xpath=//*[@id='user-notif-input-message']    ${AdminCategoryMsg} 
    click element    xpath=//*[@id="button-notification-save"] 
    Wait until Element is visible    xpath=//*[@id="button-openAddNewApp"]    timeout=10 
    click element    xpath=//*[@id="megamenu-notification-button"] 
    click element    xpath=//*[@id="notification-history-link"] 
    Wait until Element is visible    xpath=//*[@id="notification-history-table"]    timeout=10 
    Table Column Should Contain    xpath=//*[@id="notification-history-table"]    2    ${AdminCategoryMsg} 
    log    ${AdminCategoryMsg}   
     [Return]     ${AdminCategoryMsg}  
    
    
 Portal admin Logout from Portal GUI
    [Documentation]   Logout from Portal GUI
    Click Element    xpath=//div[@id='header-user-icon']
    Click Button    xpath=//button[contains(.,'Log out')]
    Title Should Be    Login
    
    
    
Application admin Login To Portal GUI
    [Documentation]   Logs into Portal GUI
    # Setup Browser Now being managed by test case
    ##Setup Browser
    Go To    ${PORTAL_LOGIN_URL}
    Maximize Browser Window
    Set Selenium Speed    ${GLOBAL_SELENIUM_DELAY}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Log    Logging in to ${GLOBAL_PORTAL_SERVER}${PORTAL_ENV}
   # Handle Proxy Warning
    Title Should Be    Login
    Input Text    xpath=//input[@ng-model='loginId']    ${GLOBAL_APP_ADMIN_USER}
    Input Password    xpath=//input[@ng-model='password']    ${GLOBAL_APP_ADMIN_PWD}
    Click Link    xpath=//a[@id='loginBtn']
    Wait Until Page Contains Element    xpath=//img[@alt='Onap Logo']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}    
    Log    Logged in to ${GLOBAL_PORTAL_SERVER}${PORTAL_ENV}    
    
Application Admin Navigation Application Link Tab    
    [Documentation]   Logs into Portal GUI as application admin
    Click Link    xpath=//a[@id='parent-item-Home']
    Click Element    xpath=.//h3[contains(text(),'Virtual Infras...')]/following::div[1]
    Page Should Contain    Welcome to VID
    Click Element    xpath=//i[@class='ion-close-round']    
    Click Element    xpath=(.//span[@id='tab-Home'])[1]
    
    
Application Admin Navigation Functional Menu     
    [Documentation]   Logs into Portal GUI as application admin
    Click Link    xpath=//a[contains(.,'Manage')]
     Mouse Over    xpath=//*[contains(text(),'Technology Insertion')]
     Click Link    xpath= //*[contains(text(),'Infrastructure VNF Provisioning')] 
     Page Should Contain    Welcome to VID
     Click Element    xpath=//i[@class='ion-close-round']
     Click Element    xpath=(.//span[@id='tab-Home'])[1]
     
     
Application admin Add Standard User Existing user   
     [Documentation]    Naviage to Users tab
     Click Link    xpath=//a[@title='Users']
     Page Should Contain      Users
     Click Button    xpath=//button[@ng-click='users.openAddNewUserModal()']
     Input Text    xpath=//input[@id='input-user-search']    ${Existing_User}
     Click Button    xpath=//button[@id='button-search-users']
     Click Element    xpath=//span[@id='result-uuid-0']
     Click Button    xpath=//button[@id='next-button']
     Click Element    xpath=//*[@id='div-app-name-dropdown-Virtual-Infrastructure-Deployment']
     Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::input[@id='Standard-User-checkbox']
     Set Selenium Implicit Wait    3000
     Click Button    xpath=//button[@id='new-user-save-button']
     Set Selenium Implicit Wait    3000
     #Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
     #Select From List    xpath=//input[@value='Select application']    Virtual Infrastructure Deployment
     #Click Link    xpath=//a[@title='Users']
     #Page Should Contain      Users
     Go To    ${PORTAL_HOME_PAGE}
     Set Selenium Implicit Wait    3000
     Click Link    xpath=//a[@title='Users']
     Click Element    xpath=//input[@id='dropdown1']
     Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
     Input Text    xpath=//input[@id='input-table-search']    ${Existing_User}
     Element Text Should Be      xpath=(.//*[@id='rowheader_t1_0'])[2]   Standard User
     
     
Application admin Edit Standard User Existing user  
     [Documentation]    Naviage to Users tab
     Click Element    xpath=(.//*[@id='rowheader_t1_0'])[2]
     Click Element    xpath=//*[@id='div-app-name-dropdown-Virtual-Infrastructure-Deployment']
     Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::input[@id='Standard-User-checkbox']
     Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::input[@id='System-Administrator-checkbox']
     Set Selenium Implicit Wait    3000
     Click Button    xpath=//button[@id='new-user-save-button']
     Set Selenium Implicit Wait    3000
     Page Should Contain      Users
     #Click Button    xpath=//input[@id='dropdown1']
     #Click Element    xpath=//li[contains(.,'Virtual Infrastructure Deployment')]
     Input Text    xpath=//input[@id='input-table-search']    ${Existing_User}
     Element Text Should Be      xpath=(.//*[@id='rowheader_t1_0'])[2]   System Administrator
     
     
Application admin Delete Standard User Existing user    
     [Documentation]    Naviage to Users tab
     Click Element    xpath=(.//*[@id='rowheader_t1_0'])[2]
     Scroll Element Into View    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::*[@id='app-item-delete'][1]
     Click Element    xpath=//*[@id='div-app-name-Virtual-Infrastructure-Deployment']/following::*[@id='app-item-delete'][1]
     Click Element    xpath=//button[@id='div-confirm-ok-button']
     Click Button    xpath=//button[@id='new-user-save-button']
     #Input Text    xpath=//input[@id='input-table-search']    ${Existing_User}
     #Is Element Visible    xpath=(//*[contains(.,'Portal')] )[2] 
     Element Should Not Contain     xpath=//*[@table-data='users.accountUsers']    Portal   
     
     
     
Application admin Logout from Portal GUI
    [Documentation]   Logout from Portal GUI
    Click Element    xpath=//div[@id='header-user-icon']
    Click Button    xpath=//button[contains(.,'Log out')]
    #Confirm Action	
    Title Should Be    Login   
    
    
Standared user Login To Portal GUI
    [Documentation]   Logs into Portal GUI
    # Setup Browser Now being managed by test case
    ##Setup Browser
    Go To    ${PORTAL_LOGIN_URL}
    Maximize Browser Window
    Set Selenium Speed    ${GLOBAL_SELENIUM_DELAY}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Log    Logging in to ${GLOBAL_PORTAL_SERVER}${PORTAL_ENV}
   # Handle Proxy Warning
    Title Should Be    Login
    Input Text    xpath=//input[@ng-model='loginId']    ${GLOBAL_STA_USER_USER}
    Input Password    xpath=//input[@ng-model='password']    ${GLOBAL_STA_USER_PWD}
    Click Link    xpath=//a[@id='loginBtn']
    Wait Until Page Contains Element    xpath=//img[@alt='Onap Logo']    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}    
    Log    Logged in to ${GLOBAL_PORTAL_SERVER}${PORTAL_ENV}       
     
 
Standared user Navigation Application Link Tab    
    [Documentation]   Logs into Portal GUI as application admin
    #Portal admin Go To Portal HOME
    Click Element    xpath=.//h3[contains(text(),'Virtual Infras...')]/following::div[1]
    Page Should Contain    Welcome to VID    
    Click Element    xpath=(.//span[@id='tab-Home'])[1]
    
    
Standared user Navigation Functional Menu     
    [Documentation]   Logs into Portal GUI as application admin
    Click Link    xpath=//a[contains(.,'Manage')]
     Mouse Over    xpath=//*[contains(text(),'Technology Insertion')]
     Click Link    xpath= //*[contains(text(),'Infrastructure VNF Provisioning')] 
     Page Should Contain    Welcome to VID
     Click Element    xpath=(.//span[@id='tab-Home'])[1]   
     
     
     
Standared user Broadcast Notifications 
    [Documentation]   Logs into Portal GUI as application admin 
    [Arguments]    ${AdminBroadCastMsg}
    Click element    xpath=//*[@id='megamenu-notification-button'] 
    Click element    xpath=//*[@id='notification-history-link'] 
    Wait until Element is visible    xpath=//*[@id='app-title']    timeout=10 
    Table Column Should Contain    xpath=//*[@id='notification-history-table']    2    ${AdminBroadCastMsg} 
    log    ${AdminBroadCastMsg}   
    
   
Standared user Category Notifications 
    [Documentation]   Logs into Portal GUI as application admin 
    [Arguments]    ${AdminCategoryMsg}
    #click element    xpath=//*[@id='megamenu-notification-button'] 
    #click element    xpath=//*[@id="notification-history-link"] 
    Wait until Element is visible    xpath=//*[@id='app-title']    timeout=10 
    Table Column Should Contain    xpath=//*[@id='notification-history-table']    2    ${AdminCategoryMsg} 
    log    ${AdminCategoryMsg} 
    
    
Standared user Logout from Portal GUI
    [Documentation]   Logout from Portal GUI
    Click Element    xpath=//div[@id='header-user-icon']
    Click Button    xpath=//button[contains(.,'Log out')]
    #Confirm Action	
    Title Should Be    Login     
        
     
     
     
Tear Down     
    [Documentation]   Close all browsers
    Close All Browsers
    

 
 
 
    
    
