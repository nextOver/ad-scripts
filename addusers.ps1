
Import-module activedirectory

$Password = (ConvertTo-SecureString -AsPlainText "pmp@2020" -Force) # Configura uma senha padrão

$Users=Import-csv C:\Users\jonadabe.serra\Documents\AddUsers\servidorLista.csv #Especifica arquivo CSV (Separado por vírgulas)
$OU = "OU=SEPLAN,DC=ad,DC=parauapebas,DC=pa,DC=gov, DC=br" # Unidade Organizacional que o usuário participa
$numberSuccess = 0
$numberFail = 0

ForEach($User in $Users)
      {

      $Parameters = @{
      'SamAccountName'        = $user.samaccountname
      'GivenName'             = $user.name
      'Name'                  = $user.name
      'Department'            = $user.department
      'UserPrincipalName'     = $user.samaccountname+"@ad.parauapebas.pa.gov.br"
      'Path'                  = $OU
      'AccountPassword'       = $Password 
      'Enabled'               = $true
      'ChangePasswordAtLogon' = $true
       }
       $username = $user.samaccountname

       if (Get-ADUser -F {SamAccountName -eq $username }) # Verifica se usuário já existe
	    {		 
		 Write-Warning "O usuário $username já existe no diretório, ignorando..."
         $numberFail = $numberFail + 1
	    }else
        {
         New-ADUser @Parameters
         Write-Host "[!] Usuário $username criado com sucesso."
         $numberSuccess = $numberSuccess + 1
        }

} # End While

Write-Host "[!] $numberSuccess Usuários criado com sucesso"  -ForegroundColor Green
Write-Host "[!] $numberFail Falhas" -ForegroundColor Red