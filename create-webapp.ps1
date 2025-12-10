$UserName = ((az ad signed-in-user show | ConvertFrom-Json).userPrincipalName -replace '@.*$','' -replace '\W','').ToLower()

az group create --name rg-fingerflitzer --location swedencentral | Out-Null

az appservice plan create `
  --name asp-fingerflitzer `
  --sku P0V3 `
  --is-linux `
  --resource-group rg-fingerflitzer | Out-Null

az webapp create `
  --name wa-fingerflitzer-$UserName `
  --runtime DOTNETCORE:8.0 `
  --assign-identity `
  --https-only true `
  --public-network-access Enabled `
  --plan asp-fingerflitzer `
  --resource-group rg-fingerflitzer | Out-Null

$SubscriptionId = (az account show | ConvertFrom-Json).id

az ad sp create-for-rbac `
  --name "gh-action-to-deploy-fingerflitzer-webapp-seil" `
  --role contributor `
  --scopes /subscriptions/$SubscriptionId/resourceGroups/rg-fingerflitzer/providers/Microsoft.Web/sites/wa-fingerflitzer-$UserName `
  --json-auth


# # Allow access from web app to database
# # see https://learn.microsoft.com/en-us/azure/app-service/tutorial-connect-msi-azure-database
# az extension add --name serviceconnector-passwordless --upgrade
# az webapp connection create postgres-flexible `
#   --connection fingerflitzer_webapp `
#   --resource-group rg-fingerflitzer `
#   --name wa-fingerflitzer-$UserName `
#   --target-resource-group rg-fingerflitzer `
#   --server db-fingerflitzer-$UserName `
#   --database fingerflitzer `
#   --system-identity `
#   --client-type dotnet | Out-Null

# az extension add --name rdbms-connect
# $User = az ad signed-in-user show | ConvertFrom-Json
# $AccessToken = az account get-access-token --resource-type oss-rdbms | ConvertFrom-Json
# az postgres flexible-server execute `
#   --querytext "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO `"aad_beer4me_webapp`";GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO `"aad_beer4me_webapp`";" `
#   --database-name fingerflitzer `
#   --admin-user $User.userPrincipalName `
#   --admin-password $AccessToken.accessToken `
#   --name db-fingerflitzer-$UserName

$WebApp = az webapp show `
  --name wa-fingerflitzer-$UserName `
  --resource-group rg-fingerflitzer | ConvertFrom-Json
Write-Host "### Web app: https://$($WebApp.defaultHostName)"

# az group delete --name rg-fingerflitzer --no-wait