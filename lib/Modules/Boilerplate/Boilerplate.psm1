#ps1_sysnative

# Copyright 2016 Cloudbase Solutions Srl
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
Import-Module JujuLogging

function Register-ReactiveModules {
    <#
    .SYNOPSIS
    This function looks in the standard locations for layers and interfaces and imports those modules using the module name
    as a prefix. This is done because powershell does not make use of namespaces for commandlets, and function names may clash.
    #>

    PROCESS {
        $charmDir = Get-JujuCharmDir
        if (!(Test-Path $charmDir)){
            return
        }
        Write-JujuInfo $charmDir
        $targets = @(
            (Join-Path $charmDir "reactive"),
            (Join-Path $charmDir "hooks\reactive"),
            (Join-Path $charmDir "hooks\relations")
        )
        foreach ($i in $targets){
            if(!(Test-Path $i)){
                continue
            }
            $items = Get-ChildItem $i
            foreach($j in $items) {
                if ($j.PSIsContainer){
                    $hasPsd = Get-ChildItem $j.FullName -Filter "*.psd1" -File
                    if ($hasPsd){
                        Import-Module $j.FullName
                    }
                } else {
                    if ($j.FullName.EndsWith(".psm1")) {
                        Import-Module $j.FullName
                    }
                }
            }
        }
    }
}

function Start-Reactive {
    Write-JujuInfo "Starting reactive framework"
    Register-ReactiveModules
    Write-JujuInfo "Finishing reactive framework"
}

Export-ModuleMember -Function Start-Reactive
