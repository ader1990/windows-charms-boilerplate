$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$moduleHome = Split-Path -Parent $here
$moduleRoot = Split-Path -Parent $moduleHome

$modulePath = ${env:PSModulePath}.Split(";")
if(!($moduleRoot -in $modulePath)){
    $env:PSModulePath += ";$moduleRoot"
}
$savedEnv = [System.Environment]::GetEnvironmentVariables()

Import-Module JujuHooks

function Clean-Environment {
    $current = [System.Environment]::GetEnvironmentVariables()
    foreach($i in $savedEnv.GetEnumerator()) {
        $envVarValue = $i.Value
        if (!$savedEnv[$i.Name]) {
            $envVarValue = $null
        }
        [System.Environment]::SetEnvironmentVariable($i.Name, $envVarValue, "Process")
    }
}

Describe "Test Confirm-ContextComplete" {
    AfterEach {
        Clean-Environment
    }
    It "Should return False" {
        $ctx = @{
            "test" = $null;
            "test2" = "test";
        }
        Confirm-ContextComplete -Context $ctx | Should Be $false

        $ctx = @{
            "test" = $null;
            "test2" = "test";
        }
        Confirm-ContextComplete -Context $ctx | Should Be $false

        $ctx = @{}
        Confirm-ContextComplete -Context $ctx | Should Be $false
    }

    It "Should return True" {
        $ctx = @{
            "hello" = "world";
        }
        Confirm-ContextComplete -Context $ctx | Should Be $true
    }

    It "Should Throw an exception" {
        $ctx = "not a hashtable"
        { Confirm-ContextComplete -Context $ctx} | Should Throw
    }
}
