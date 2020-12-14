#Requires -RunAsAdministrator
Write-Host ""
Write-Host "+----------------------------+"
Write-Host "+   Azure WebApp WhiteList   +"
Write-Host "+----------------------------+"
Write-Host ""

function loadModules($file) {
    Write-Host "Chargement des modules ..."
    $file="./modules.txt"
    ForEach ($module in (Get-Content -Path $file)) {
        if (Get-Module -ListAvailable -Name $module) {
            Write-Host "$module : OK"
        } 
        else {
            Write-Host "$module : Absent, tentative de téléchargement ..."
            try {
                Find-Module -Name Az.Accounts | Install-Module -Force
                Write-Host "Module $module : OK"
            } catch {
                Write-Host "Impossible de télécharger le module : $module"
            }
        }
    }
}




loadModules



# Connect-AzAccount

