$env:PYTHONPATH = "C:\\Program Files\\Microsoft SDKs\\Azure\\CLI2"

$Location = (az policy assignment list --query "[?name == 'sys.regionrestriction'].parameters.listOfAllowedLocations.value" | ConvertFrom-Json)[0]

$UserName = ((az ad signed-in-user show | ConvertFrom-Json).userPrincipalName -replace '@.*$','' -replace '\W','').ToLower()

az group create --name rg-fingerflitzer --location $Location | Out-Null
# az postgres flexible-server list-skus --location $Location
az postgres flexible-server create `
  --name db-fingerflitzer-$UserName `
  --microsoft-entra-auth Enabled `
  --create-default-database Disabled `
  --database-name fingerflitzer `
  --location $Location `
  --password-auth Disabled `
  --public-access 0.0.0.0 `
  --sku-name Standard_B1ms `
  --storage-size 32 `
  --tier Burstable `
  --resource-group rg-fingerflitzer | Out-Null

# Zugriff von aktueller IP auf DB erlauben
$PublicIPAddress = Invoke-RestMethod http://ipinfo.io/ip
az postgres flexible-server firewall-rule create `
  --rule-name Local `
  --start-ip-address $PublicIPAddress `
  --name db-fingerflitzer-$UserName `
  --resource-group rg-fingerflitzer | Out-Null

# Aktuellem Benutzer Zugriff auf DB erlauben
$User = az ad signed-in-user show | ConvertFrom-Json
az postgres flexible-server microsoft-entra-admin create `
  --display-name $User.userPrincipalName `
  --object-id $User.id `
  --type User `
  --server-name db-fingerflitzer-$UserName `
  --resource-group rg-fingerflitzer | Out-Null

# Datenbankschema + Beispieldaten erstellen
az extension add --name rdbms-connect
$AccessToken = az account get-access-token --resource-type oss-rdbms | ConvertFrom-Json
az postgres flexible-server execute `
  --file-path .\db-schema.sql `
  --database-name fingerflitzer `
  --admin-user $User.userPrincipalName `
  --admin-password $AccessToken.accessToken `
  --name db-fingerflitzer-$UserName
az postgres flexible-server execute `
  --file-path .\sample-data.sql `
  --database-name fingerflitzer `
  --admin-user $User.userPrincipalName `
  --admin-password $AccessToken.accessToken `
  --name db-fingerflitzer-$UserName
