<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Untitled
#>
Add-Type -AssemblyName System.Windows.Forms
Import-module activedirectory

[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = New-Object System.Drawing.Point(406,383)
$Form.text                       = "Adicionar usuários em lote - PMP"
$Form.TopMost                    = $false
$Form.BackColor                  = [System.Drawing.ColorTranslator]::FromHtml("#ffffff")

$file                            = New-Object system.Windows.Forms.TextBox
$file.readonly                   = $true
$file.multiline                  = $false
$file.width                      = 216
$file.height                     = 20
$file.location                   = New-Object System.Drawing.Point(37,63)
$file.Font                       = New-Object System.Drawing.Font('Microsoft Sans Serif',10)


$ComboBox                        = New-Object system.Windows.Forms.ComboBox
$ComboBox.text                   = "Selecione"
$ComboBox.width                  = 130
$ComboBox.height                 = 20
$ComboBox.location               = New-Object System.Drawing.Point(37,113)
$ComboBox.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$password                        = New-Object system.Windows.Forms.TextBox
$password.multiline              = $false
$password.width                  = 131
$password.height                 = 20
$password.location               = New-Object System.Drawing.Point(37,160)
$password.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "Selecionar"
$Button1.width                   = 79
$Button1.height                  = 20
$Button1.location                = New-Object System.Drawing.Point(296,64)
$Button1.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Selecionar arquivo CSV"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 20
$Label1.location                 = New-Object System.Drawing.Point(44,37)
$Label1.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "Unidade Organizacional"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 20
$Label2.location                 = New-Object System.Drawing.Point(45,92)
$Label2.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label3                          = New-Object system.Windows.Forms.Label
$Label3.text                     = "Senha"
$Label3.AutoSize                 = $true
$Label3.AutoSize                 = $true
$Label3.width                    = 25
$Label3.height                   = 20
$Label3.location                 = New-Object System.Drawing.Point(45,139)
$Label3.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$start                           = New-Object system.Windows.Forms.Button
$start.text                      = "Iniciar"
$start.width                     = 60
$start.height                    = 30
$start.location                  = New-Object System.Drawing.Point(67,212)
$start.Font                      = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$console                         = New-Object system.Windows.Forms.TextBox
$console.multiline               = $true
$console.width                   = 368
$console.height                  = 93
$console.location                = New-Object System.Drawing.Point(19,259)
$console.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$console.ScrollBars              = "Vertical"



$Form.controls.AddRange(@($file,$password,$Button1,$Label1,$Label2,$Label3,$start,$console, $ComboBox))



$Users = Get-ADOrganizationalUnit -SearchScope OneLevel -filter * | select -ExpandProperty Name

Foreach ($User in $Users)

{

$ComboBox.Items.Add($User);

}


$fileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    Filter = 'SpreadSheet (*.csv)|*.csv'
}
$Button1.Add_Click(

{

$fileBrowser.ShowDialog()
$file.text = $fileBrowser.filename
}

)
$start.Add_Click({

$Password =  (ConvertTo-SecureString -AsPlainText $password.text -Force)
$OU       =   "OU=" + $ComboBox.text + ",DC=ad,DC=parauapebas,DC=pa,DC=gov, DC=br"
$numberSuccess = 0
$numberFail = 0

$Users=Import-csv $file.text

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
		 #Write-Warning "O usuário $username já existe no diretório, ignorando..."
         $console.text = $console.text + "`r`n" + "O usuário $username já existe no diretório, ignorando.."
         $numberFail = $numberFail + 1
	    }else
        {
         New-ADUser @Parameters
         #Write-Host "[!] Usuário $username criado com sucesso."
          $console.text = $console.text + "`r`n" + "[!] Usuário $username criado com sucesso."
         $numberSuccess = $numberSuccess + 1
        }

}
$console.text = $console.text + "`r`n" + "[!] $numberSuccess Usuários criado com sucesso"

$console.text = $console.text + "`r`n" + "[!] $numberFail Falhas"

#Write-Host "[!] $numberSuccess Usuários criado com sucesso"  -ForegroundColor Green
#Write-Host "[!] $numberFail Falhas" -ForegroundColor Red



})

$Form.ShowDialog()