# Add IP Restriction over Web App

## Requirements
* Code has been developped and tested with **PowerShell 5.1**
## Usage
This script allows you to add bunk of ip restriction to Web App in Azure

**data.json**

`data.json` file should be filled as follow for full automation :
```
{
    "modules" : [
        "Az.Accounts",
        "Az.Websites"
    ],
    "subscription_id" : "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "tenant_id" : "xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "ressource_group_name" : "My-optional-RG",
    "app_service" : "My-optional-WebApp"
}
```

Although `subscription_id` and `tenant_id` are mandatory field, `ressource_group_name` and `app_service` are optional. You'll be prompted during script execution with online's available ressources.

To find your `subscription_id` go to portal.azure.com > Subscriptions (or click [here](https://portal.azure.com/#blade/Microsoft_Azure_Billing/SubscriptionsBlade)).

To find your `tenant_id` go to portal.azure.com > Azure Active Directory > Properties (or click [here](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Properties)).



**whitelist.txt**

File should be named `whitelist.txt` and location specified at line 5 of [ip_restrictions.ps1](ip_restrictions.ps1) (default location is same directory)
```
RuleName;IP/CIDR
```

`RuleName` must have a length of 32 characters maximum.

`IP/CIDR` must look like `x.x.x.x/XX` to match the regex control.