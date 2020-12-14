#Requires -RunAsAdministrator


$json_data=(Get-Content -Raw -Path "data.json") | ConvertFrom-Json 
$whitelist="whitelist.txt"

Write-Host ""
Write-Host "+----------------------------+"
Write-Host "+   Azure WebApp WhiteList   +"
Write-Host "+----------------------------+"
Write-Host ""


function loadModules{
    Write-Host "Chargement des modules :"
    ForEach ($module in $json_data.modules) {
        if (Get-Module -ListAvailable -Name $module) {
            Write-Host "- $module : OK"
        } 
        else {
            Write-Host "- $module : Absent /!\ --> tentative de téléchargement ..."
            try {
                Find-Module -Name $module | Install-Module -Force
                Write-Host "- $module : OK"
            } catch {
                Write-Host "Impossible de télécharger le module : $module"
                Write-Host $_
            }
        }
    }
    Write-Host ""
    getRG
}

function azureConnect { 
    try { 
        Get-AzureADTenantDetail | out-null 
        Write-Host "Connection à Azure :"
    } catch {         
        $directoryName = $json_data.directory_name
        $tenantId = $json_data.tenant_id
        Connect-AzAccount -Tenant $tenantId -SubscriptionId $directoryName | out-null
    } 
    Write-Host "- Connexion OK"    
    Write-Host ""
    loadModules
}

function getRG {
    Write-Host "Selection du Ressource Group :"
    $JsonRGs=Get-AzResourceGroup | ConvertTo-Json | ConvertFrom-Json
    if ($json_data.ressource_group_name) {
        $selectedRg = $json_data.ressource_group_name        
        Write-Host "-"$selectedRg
        $hasMatchRG = $False
        foreach ($RG in $JsonRGs) {
            if ($selectedRg -match $RG.ResourceGroupName){                
                $hasMatchRG = $True
                break
            } 
        }
        if (!$hasMatchRG) { 
        Write-Host "Le ressource group '$selectedRg' n'existe pas !"
        Write-Host "Vérifier le fichier json et si vous ne connaissez pas le RG, laissez le champs vide."
        exit 
        }
    } else {
        $rgsList = @()        
        $i = 0     
       foreach ($RG in $JsonRGs) {
            $i++
            Write-Host "- [$i]" $RG.ResourceGroupName
            $rgsList += $RG.ResourceGroupName
        }
        Write-Host ""
        $rgSelected = Read-Host -Prompt "Dans quel ressource groupe ce trouve la WebApp "        
        $selectedRg = $rgsList[$rgSelected - 1]         
    }
    Write-Host ""
    getAppService
}

function getAppService {
     Write-Host "Selection de l'AppService :"
     $JsonAppService=Get-AzWebApp -ResourceGroupName $selectedRg | ConvertTo-Json | ConvertFrom-Json
    if ($json_data.app_service) {
        $selectedAppService = $json_data.app_service        
        Write-Host "-"$selectedAppService
        $hasMatchAS = $False
        foreach ($AS in $JsonAppService) {
            if ($selectedAppService -match $AS.Name){                
                $hasMatchAS = $True
                break
                Write-Host "GG"
            } 
        }
        if (!$hasMatchAS) { 
        Write-Host "L'AppService '$selectedAppService' n'existe pas !"
        Write-Host "Vérifier le fichier json et si vous ne connaissez pas l'AppService, laissez le champs vide."
        exit 
        }
    } else {
        $ASsList = @()        
        $i = 0     
       foreach ($AS in $JsonAppService) {
            $i++
            Write-Host "- [$i]" $AS.Name
            $ASsList += $AS.Name
        }
        Write-Host ""
        $asSelected = Read-Host -Prompt "Selection de l'App Service : "        
        $selectedAppService = $ASsList[$asSelected - 1]    
    }
    Write-Host ""
    updateAppServiceRestriction
}

function updateAppServiceRestriction {
    $priority=10
    foreach($line in Get-Content $whitelist) {
        $RuleName,$ip = $line.split(';') 
        Write-Host "--- Ajout nouvelle règle ---"
        write-host "Nom : $RuleName"
        write-host "IP : $ip"
        write-host "Priorité : $priority"
        Write-host "Type: Allow"
        Add-AzWebAppAccessRestrictionRule `
        -ResourceGroupName $selectedRg `
        -WebAppName $selectedAppService `
        -Name $RuleName `
        -Priority $priority `
        -Action 'Allow' `
        -IpAddress $ip

        $priority++
    }
}


azureConnect
# updateAppServiceRestriction





