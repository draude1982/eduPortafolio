# SCRIPT : Users from Groups Powershell
# Create a csv with Groups and Users
function Inicializar{

    #Config Variables
    $CSVFilePath = $PSScriptRoot +"\UserAzure.csv"
    return $CSVFilePath
}

function Datos {
    
    $Sitio="BIBLIOTECA"
    $SiteURL="SITIO DE SHAREPOINT"+$Sitio
    return $SiteURL,$Sitio
}


try {
    $FileData = @()
    
    Write-Host ( "Se procede a la recopilacion de grupos-usuarios en csv") -ForegroundColor blue
    Write-Host ( "Espere, por favor") -ForegroundColor Yellow
    
    $SiteUrl,$Sitio=Datos
    Connect-PnPOnline -Url $SiteUrl -Interactive
    $grupo=Get-PnPAzureADGroup | Where-Object {$_.DisplayName -match "NOMBRE GRUPO"}
    foreach ($g in $grupo){ 

        $grup=$g.DisplayName
        
         $users=get-PnPAzureADGroupMember -Identity $g.DisplayName
        foreach ($u in $users){ 
        # create object powershell
            $FileData += [PSCustomObject][ordered]@{
                Grupo         = $grup
                Usuarios        = $u.DisplayName
                }
        }



    }

    #Export Files data to CSV File
    $CSVFilePath = Inicializar
    $FileData | Sort-object Size -Descending
    $FileData | Export-Csv -Path $CSVFilePath -Delimiter ';' -NoTypeInformation
    write-host "`nSe esta creando CSV informe.csv`n" -f Green
    write-host "`nEl informe esta en la misma que el script`n" -f Green


    }

catch {
    $CSVFilePath = $PSScriptRoot +"\Log.txt"
    $error_message="El siguiente error ha ocurrido:`n" + $_
    $error_message|Out-File -Path $CSVFilePath 
    Write-Host "El siguiente error ha ocurrido:" -f Red
    Write-Host $_
}




finally {
    Disconnect-PnPOnline
}