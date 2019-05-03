filter Get-FolderPath {
<#
.SYNOPSIS
Collates the full folder path
.DESCRIPTION
The function will find the full folder path returning a name and path
.NOTES
Source:  Automating vSphere Administration
#>
    $_ | Get-View | ForEach-Object {
        $row = "" | Select-Object Name, Path
        $row.Name = $_.Name
        $current = Get-View $_.Parent
        $path = $_.Name
        do {
            $parent = $current
            if($parent.Name -ne "vm"){
    ​           $path = $parent.Name + "\" + $path
            }
            $current = Get-View $current.Parent
        }
        while ($null -ne $current.Parent)
        $row.Path = $path
        $row
    }
}
############################################################
function Export-Folders {
<#
.SYNOPSIS
Creates a csv file of folders in vCenter Server.
.DESCRIPTION
The function will export folders from vCenter Server and add them to a CSV file.
.NOTES
Source: Automating vSphere Administration
.PARAMETER FolderType
The type of folder to export
.PARAMETER DC
The Datacenter where the folders reside
.PARAMETER Filename
The path of the CSV file to use when exporting
.EXAMPLE
Export-Folders -FolderType "Blue" -DC "DC01" -Filename "C:\BlueFolders.csv"
.EXAMPLE
Export-Folders -FolderType "Yellow" -DC "Datacenter" -Filename "C:\YellowFolders.csv"
#>
    param(
        [String]$FolderType,
        [String]$DC,
        [String]$Filename
    )
    Process {
    ​   If ($Foldertype -eq "Yellow") {
            $type = "host"
        } 
        Else {
            $type = "vm"
        }
        $report = @()
        $report = Get-Datacenter $dc | Get-Folder $type | Get-Folder | Get-FolderPath
        $report | Foreach-Object {
            if ($type -eq "vm") {
                $_.Path = ($_.Path).Replace($dc + "\","$type\")
            }
        }
        $report | Export-Csv $filename -NoTypeInformation
    }
}
############################################################
function Export-VMLocation {
<#
.SYNOPSIS
Creates a csv file with the folder location of each VM.
.DESCRIPTION
The function will export VM locations from vCenter Server and add them to a CSV file.
.NOTES
Source:  Automating vSphere Administration
.PARAMETER DC
The Datacenter where the folders reside
.PARAMETER Filename
The path of the CSV file to use when exporting
.EXAMPLE
Export-VMLocation -DC "DC01" -Filename "C:\VMLocations.csv"
#>
    param(
        [String]$DC,
    ​    [String]$Filename
    )
    Process {
        $report = @()
        $report = Get-Datacenter $dc | Get-VM | Get-FolderPath
        $report | Export-Csv $filename -NoTypeInformation
    }
}
############################################################
Export-Folders "Blue" "DC01" "C:\BlueFolders.csv"
Export-VMLocation "DC01" "C:\VMLocation.csv"
Export-Folders "Yellow" "DC01" "C:\YellowFolders.csv"
  
