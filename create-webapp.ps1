$UserName = ((az ad signed-in-user show | ConvertFrom-Json).userPrincipalName -replace '@.*$','' -replace '\W','').ToLower()

az appservice plan create `
  --name asp-beer4me `
  --sku B1 `
  --is-linux `
  --resource-group rg-beer4me | Out-Null

az webapp create `
  --name wa-beer4me-$UserName `
  --runtime DOTNETCORE:8.0 `
  --assign-identity `
  --https-only true `
  --public-network-access Enabled `
  --plan asp-beer4me `
  --resource-group rg-beer4me | Out-Null

# Allow access from web app to database
# see https://learn.microsoft.com/en-us/azure/app-service/tutorial-connect-msi-azure-database
az extension add --name serviceconnector-passwordless --upgrade
az webapp connection create postgres-flexible `
  --connection beer4me_webapp `
  --resource-group rg-beer4me `
  --name wa-beer4me-$UserName `
  --target-resource-group rg-beer4me `
  --server db-beer4me-$UserName `
  --database beer4me `
  --system-identity `
  --client-type dotnet | Out-Null

az extension add --name rdbms-connect
$User = az ad signed-in-user show | ConvertFrom-Json
$AccessToken = az account get-access-token --resource-type oss-rdbms | ConvertFrom-Json
az postgres flexible-server execute `
  --querytext "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO `"aad_beer4me_webapp`";GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO `"aad_beer4me_webapp`";" `
  --database-name beer4me `
  --admin-user $User.userPrincipalName `
  --admin-password $AccessToken.accessToken `
  --name db-beer4me-$UserName

$WebApp = az webapp show `
  --name wa-beer4me-$UserName `
  --resource-group rg-beer4me | ConvertFrom-Json
Write-Host "### Web app: $($WebApp.defaultHostName)"
