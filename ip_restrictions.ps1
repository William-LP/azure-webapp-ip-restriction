Write-Host "Chargement des modules ..."
ForEach ($module in (Get-Content -Path "modules.txt")) {
    if (Get-Module -ListAvailable -Name $module) {
        Write-Host "$module : OK"
    } 
    else {
        Write-Host "$module : Absent, tentative de téléchargement ..."
        try {
            Find-Module -Name Az.Accounts | Install-Module
            Write-Host "Module $module : OK"
        } catch {
            Write-Host "Impossible de télécharger le module : $module"
        }
    }
}






# Connect-AzAccount
