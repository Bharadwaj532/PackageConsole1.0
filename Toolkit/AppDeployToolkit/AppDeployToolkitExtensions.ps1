<#
.SYNOPSIS

PSAppDeployToolkit - Provides the ability to extend and customise the toolkit by adding your own functions that can be re-used.

.DESCRIPTION

This script is a template that allows you to extend the toolkit with your own custom functions.

This script is dot-sourced by the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.

PSApppDeployToolkit is licensed under the GNU LGPLv3 License - (C) 2024 PSAppDeployToolkit Team (Sean Lillis, Dan Cunningham and Muhammad Mashwani).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
for more details. You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

.EXAMPLE

powershell.exe -File .\AppDeployToolkitHelp.ps1

.INPUTS

None

You cannot pipe objects to this script.

.OUTPUTS

None

This script does not generate any output.

.NOTES

.LINK

https://psappdeploytoolkit.com
#>


[CmdletBinding()]
Param (
)

##*===============================================
##* VARIABLE DECLARATION
##*===============================================

# Variables: Script
[string]$appDeployToolkitExtName = 'PSAppDeployToolkitExt'
[string]$appDeployExtScriptFriendlyName = 'App Deploy Toolkit Extensions'
[version]$appDeployExtScriptVersion = [version]'3.10.2'
[string]$appDeployExtScriptDate = '05/03/2024'
[hashtable]$appDeployExtScriptParameters = $PSBoundParameters
[bool]$Global:isUpgrade = 0
##*===============================================
##* FUNCTION LISTINGS
##*===============================================

# <Your custom functions go here>
# set the detailed logging folder

Function Get-ExePathCustom {
    #None of the built in EXE function work? Code your own.
    [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$true)]
            [string]$Number,
            [Parameter(Mandatory=$false)]
            [string]$INIFile

        )
        begin {
            ## Get the name of this function and write header, for bookkeeping please do not change.
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
            #Get-ActionString determines if the current program action being done and will logically return either Install, Upgrade or Uninstall
            #This should not be changed in most cases
            $ActionString = Get-ActionString 
            $Guid = (Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "GUID")
            #Examples of Reading the INI file to get values
                #The Switches 
                    #-FilePath is used to specify the INI file to be read, this should almost always be set to $INIFILE
                    #-Section is the section you want to read. This is value should almost always be set to "$ActionString$Number"
                    #-Key this is the tag in the ini file. 
                        #Examples IN INI FILE:  FOLDER=, EXENAME=, PATHVALUE=
                        #EXamples in script: -key "Folder", -key "EXENAME", -key "PATHVALUE"
                #SET the GET-IniValue to a variable as in the example on the next line
                    #$Folder = Resolve-EnvVariable  -value (Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "FOLDER")
                    #$Name = Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "EXE"
        }
        Process{
            # This is where you write the string that is the path to the EXE being used
            # We typically use $ExePath for this value

            # WRITING COMPLEX PATH STRINGS
                # First we setup of  variable to store the string
                    # $ExePath = [System.Text.StringBuilder]::new()
                # Second we Append to the string to make the final path
                # We use [void] as it does not return a value but just stores the value
                # $PkgPath is the location of the .\Files directory within the PSADTK directory structure
                    # [void]$ExePath.Append( $PkgPath ) 
                    # [void]$ExePath.Append( '\' )
                    # [void]$ExePath.Append( $Folder )
                    # [void]$ExePath.Append( '\' )
                    # [void]$ExePath.Append( $Name )
                
                # It is good practice to write out the value that was set
                # This helps verify the logic and is done with the Write-log function, example:
                    # Write-log "The executable path is set to $ExePath"    

            
            #This value is IMPORTANT!  
            #The Write-Output will return your value back to the logic that actually performs the Install, Upgrade or Uninstall
                 Write-Output -InputObject $ExePath
        }
        End {
            #This part write an entry in the log regarding the fuction and is for bookkeeping, please do not change
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
        }
}

Function Get-ExeCustomArguements {
    [CmdletBinding()]
    Param(
        [string]$Number,
        [Parameter(Mandatory=$true)]
        [string]$INIFile
    )
    begin {
        ## Get the name of this function and write header
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
         Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
         $ActionString = Get-ActionString 
         $Guid = (Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "GUID")

    }
    Process{
        if ($ActionString -ieq "INSTALL"){

            # WRITING COMPLEX PATH STRINGS
                # First we setup of  variable to store the string
                    #$arguements = [System.Text.StringBuilder]::new()
                # Second we add values as needed
                    #[void]$arguements.Append( $Switches )
                    #[void]$arguements.Append( ' /LOG="' )
                    #[void]$arguements.Append( "$configMSILogDir" )  #Note: $configMSILogDir is the folde generated in the UHGLogs directory
                    #[void]$arguements.Append( "\" )
                    #[void]$arguements.Append( "Logfile_Name" )
                    #[void]$arguements.Append( "_$DTStamp" )        #Note: $DTStamp is the date time stamp we grab at the beginning of the script
                    #[void]$arguements.Append( '.Log"' )            #Nothing fancy here this just gives the string an extenion for the log file
           
         } 
         Else {
                    
         }
        #It is always good practice to write the $arguements to the log so verification can be done
        Write-Log -Message "Commandline arguements are set to $ExeArgs" -Source ${CmdletName}
        #This value is IMPORTANT!  
        #The Write-Output will return your value back to the logic that actually performs the Install, Upgrade or Uninstall
        Write-Output -InputObject $ExeArgs      
    }
    End {
        #This part write an entry in the log regarding the fuction and is for bookkeeping, please do not change
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    }
}


Function Set-DetailLogFolder{
    [string]$appDetLogFld = "$appVENDOR $appNAME $appVER"

    # Check for and create detailed logging folder
    If (-Not (Test-Path "$configToolkitLogDir\$appDetLogFld")){
        ## Create folder
        Write-log -Message "Creating folder for detailed log files: $configToolkitLogDir\$appDetLogFld" -LogType CMTrace
        New-Item -ItemType "directory" -Path "$configToolkitLogDir\$appDetLogFld" -ErrorAction SilentlyContinue
        Return
    } 
    Else {
        Return "$configToolkitLogDir\$appDetLogFld"
    }
}

Function Add-CacheMedia {
    [CmdletBinding()]
    Param(
    )
    Begin{
        ## Get the name of this function and write header
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
        If(!(Test-Path "$env:SystemDrive\ProgramData\OMC\$AppID")) {
            New-Folder -Path "$env:SystemDrive\ProgramData\OMC\$AppID"
        }
        $Srcpath = "$env:SystemDrive\ProgramData\OMC\$AppID"
    }
    Process{
	    If(!([string]::IsNullOrEmpty($ZIPFOL))){
            Write-Log -Message "Zip file specified, starting process to extract the zip file $ZIPFOL"
            Write-Log -Message "Starting extraction of $dirfiles\$ZIPFOL to the folder $Srcpath"
		    Expand-ZIPFile -SourcePath "$dirfiles\$ZIPFOL" -DestinationPath "$Srcpath" -ErrorAction SilentlyContinue
		#=============Setting full path of the installer under SCCM Temp Cache location===========#
		    $PkgPath = $Srcpath
	    } 
	    Else {
            Write-Log -Message "Copying $dirfiles to $Srcpath"
            copy-item -Path "$dirfiles\*" -Destination $Srcpath -Recurse -Force -ErrorAction SilentlyContinue 
		    $PkgPath = $Srcpath
	    }
        Write-Log -Message "Media should is ste to $PkgPath"
         Write-Output -InputObject $PkgPath
    }
    End{
        #This part write an entry in the log regarding the fuction and is for bookkeeping, please do not change
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    }
}

Function Remove-CacheMedia {
    [CmdletBinding()]
    Param(
    )
    Begin{
        ## Get the name of this function and write header
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
    }
    Process{
        ## Clean up media if needed
        If ($deploymentType -ieq "Install" -and $RemoveMedia -ieq "Install"){
            Write-Log -Message "Removing installation media on install from $Pkgpath"
            Remove-Folder -Path $Pkgpath 
        }
        Elseif ($deploymentType -ieq "Uninstall" -and $RemoveMedia -ieq "Uninstall"){
            Write-Log -Message "Removing installation media on uninstall from $Pkgpath"
            Remove-Folder -Path $Pkgpath 
        }
        Elseif ($RemoveMedia -ieq "Always"){
            Write-Log -Message "Removing installation media on install and uninstall from $Pkgpath"
            Remove-Folder -Path $Pkgpath 
        }
        Else{
            Write-Log -Message "Media left in cache at $Pkgpath"
        }
    }
    End{
        #This part write an entry in the log regarding the fuction and is for bookkeeping, please do not change
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    }
}

Function Resolve-EnvVariable{
    [CmdletBinding()]
    Param(            
        [Parameter(Mandatory=$False)]
        [string]$value           
    )
    
    Begin {
    ## Get the name of this function and write header
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header        
    }       
    Process { 
        If(-not ([string]::IsNullOrEmpty($value))){
            $regex = "%(.+)s"            
            #$NewText = ""                        
            # If we match, add to our results
            While($value -match $regex){  
                $startIndex = $value.Indexof("(")
                $endIndex = $value.IndexOf(")")  
                $len = $endIndex - $startIndex              
                $eText = $value.SubString($startIndex+1, $len-1)

                switch ($eText){
                        "PkgFiles" { $updateText = $PkgPath }
                        "ProgramFilesx86" {$updateText= [Environment]::GetEnvironmentVariable("ProgramFiles(x86)")}
                        Default { 
                                    Try{
                                        $updateText = [Environment]::GetEnvironmentVariable($eText)  
                                    }Catch{
                                        Write-Log -Message "$eText Variable cannot be resolved."
                                        Exit-Script -ExitCode 69000
                                    } 
                                }
                    }
                    $value = $value.replace('%(' + $eText + ')s',$updateText) 
                }               
        }   
            Write-log "The environment variable resolved from the Value."              
            Write-Output -InputObject $value  
    }         
    
   End {
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
   }         
}  


# Function Resolve-EnvVariable{
#     [CmdletBinding()]
#     Param(            
#         [Parameter(Mandatory=$False)]
#         [string]$value           
#     )
    
#     Begin {
#     ## Get the name of this function and write header
#         [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
#         Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header        
#     }       
#     Process { 
#         If(-not ([string]::IsNullOrEmpty($value))){
#             $regex = "%(.+)s"            
#             $NewText = ""                        
#             # If we match, add to our results
#             While($value -match $regex){  
#                 $startIndex = $value.Indexof("(")
#                 $endIndex = $value.IndexOf(")")  
#                 $len = $endIndex - $startIndex              
#                 $eText = $value.SubString($startIndex+1, $len-1)
#                 If($eText -ine "PkgFiles"){
#                     Try{
#                         $updateText = [Environment]::GetEnvironmentVariable($eText)  
#                     }Catch{
#                         Write-Log -Message "$eText Variable cannot be resolved."
#                     }                                      
#                     $value = $value.replace('%(' + $eText + ')s',$updateText)
#                 }
#                 Else{                        
#                     $value = $value.replace('%(' + $eText + ')s',$dirFiles)
#                 }
#                 #[System.Windows.Forms.MessageBox]::Show($value)                   
#             }   
#             Write-log "The environment variable resolved from the Value."              
#             Write-Output -InputObject $value  
#         }         
#    } 
#    End {
#         Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
#    }         
# }  


Function Perform-Upgrade {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$INIFile,
        [Parameter(Mandatory=$False)]
        [string]$Upgradecount
    )
    $isUpgrade = 1
    $int = "0"
    Do { $int = [int]$int + 1
        $UPGTYPE = (Get-IniValue -FilePath "$INIFile" -Section "UPGRADE$int" -Key "TYPE")
        #$UPGSUBTYPE = (Get-IniValue -FilePath "$INIFile" -Section "UPGRADE$int" -Key "SUBTYPE")
        #$UPGEXE = (Get-IniValue -FilePath "$INIFile" -Section "UPGRADE$int" -Key "EXE")
        $UPGNAME = (Get-IniValue -FilePath "$INIFile" -Section "UPGRADE$int" -Key "NAME")
        $UPGVER = (Get-IniValue -FilePath "$INIFile" -Section "UPGRADE$int" -Key "VER")
        $UPGGUID = (Get-IniValue -FilePath "$INIFile" -Section "UPGRADE$int" -Key "GUID")
        $UPGSWITCHES = Resolve-EnvVariable -value (Get-IniValue -FilePath "$INIFile" -Section "UPGRADE$int" -Key "SWITCHES")
        $UPGFOLDER = Resolve-EnvVariable -value (Get-IniValue -FilePath "$INIFile" -Section "UPGRADE$int" -Key "FOLDER")
        $UPGRESPONSE = Resolve-EnvVariable -value (Get-IniValue -FilePath "$INIFile" -Section "UPGRADE$int" -Key "RESPONSE")
        $UPGIGNORECODE = (Get-IniValue -FilePath "$INIFile" -Section "UPGRADE$int" -Key "IGNOREEXITCODE")
        If([string]::IsNullOrEmpty($UPGIGNORECODE)) {
           $IEXITCODES = "0"
        }
        Else {
            $IEXITCODES = $UPGIGNORECODE
        }
        Write-Log -Message "Starting UPGRADE$int details"
        If ($UPGTYPE -ieq "MSI") {
            Write-Log -Message "Upgrade$int details for MSI found in the INI File"
            If(!([string]::IsNullOrEmpty($UPGGUID))) {
                [psobject]$UninstallAppNameVersion = Get-InstalledApplication -ProductCode $UPGGUID | Select-Object -Property 'Publisher', 'DisplayName', 'DisplayVersion' -First 1 -ErrorAction 'SilentlyContinue'
                $UninstName = $UninstallAppNameVersion.DisplayName
                $UninstVers = $UninstallAppNameVersion.DisplayVersion
	            Write-Log -Message "Uninstalling $UninstName $UninstVers"
	            If ([string]::IsNullOrEmpty($UPGSWITCHES)){
                    Execute-MSI -Action Uninstall -Path $UPGGUID -Parameters "REBOOT=ReallySuppress /QN" -LogName "$UPGNAME $UPGVER $DTStamp" -IgnoreExitCodes "$IEXITCODES"
                }
                ELSE {
                    Execute-MSI -Action Uninstall -Path $UPGGUID -Parameters "$UPGSWITCHES REBOOT=ReallySuppress /QN" -LogName "$UPGNAME $UPGVER $DTStamp" -IgnoreExitCodes "$IEXITCODES"
                }
            }
        }
        ElseIf ($UPGTYPE -ieq "EXE") {
            ##============  Added (([string]::IsNullOrEmpty($UPGGUID)) -or to allow an empty AppGuid for running utilities on upgrade release 24.1.30======##
            if (([string]::IsNullOrEmpty($UPGGUID)) -or (Get-IsAppInstalled -AppGuid $UPGGUID)){
                Write-Log -Message "UPGRADE$int details for EXE found in the INI FIle"
                $UPGExePath = Set-ExePath -Number $int -INIFile $INIFile
                $UPGSWITCHES = Set-ExeArguements -INIFile $INIFile -Number $int
                if(!([string]::IsNullOrEmpty($UPGExePath))){
                    Write-Log -Message "Upgrade media $UPGExePath"
                    If(!(Test-Path $UPGExePath)){
                        Write-Log -Message "Uninstallation media $UPGExePath could not be found."
                        Show-InstallationPrompt -Message "Uninstallation Failed" -ButtonRightText 'OK' -Icon Error -NoWait
                        Exit-script -ExitCode 1000 
                    }
                    if([string]::IsNullOrEmpty($UPGSWITCHES)){
                        Execute-Process -path $UPGExePath -WindowStyle 'Hidden' -PassThru -ExitOnProcessFailure $true -IgnoreExitCodes "$IEXITCODES"
                    }
                    Else{
                        Execute-Process -path $UPGExePath -parameters $UPGSWITCHES -WindowStyle 'Hidden' -PassThru -IgnoreExitCodes "$IEXITCODES" -ExitOnProcessFailure $true
                    }
                    Remove-Arp -AppGuid $UPGGUID
                } 
                Else {
                    Write-Log -Message "A valid executable was not defined."
                }
            }
            Else {
                Write-Log -Message "$UPGGUID could not be found in the registry."
            }
            
        }
        Else {
            Write-HOST "No suitable Value Found"
            $isUpgrade = 0
            Return
        }
        Write-Log -Message "Finished UPGRADE$int details"
    } Until($int -ieq "$Upgradecount")
}



Function Install-APP {
[CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$INIFile
    )
    Begin{
        ## Get the name of this function and write header
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header  

        ## Prep for loop
        [int]$int = 1

        ## Get Variables needed to process
        $installType = (Get-IniValue -FilePath "$INIFile" -Section "INSTALL$int" -Key "TYPE")
    }
    Process{
        Do {
            $installName = (Get-IniValue -FilePath "$INIFile" -Section "INSTALL$int" -Key "NAME")
            $installVersion = (Get-IniValue -FilePath "$INIFile" -Section "INSTALL$int" -Key "VER")
            $installGuid = (Get-IniValue -FilePath "$INIFile" -Section "INSTALL$int" -Key "GUID")

            If (([string]::IsNullOrEmpty($installGuid)) -or (!(Get-IsAppInstalled -AppGuid $installGuid))){
                switch ($installType) {
                    #Perform MSI Based Installed
                    "MSI" {Install-MSI -Number $int -INIFile $INIFile}
                    #Perform MSP Based Installed
                    "MSP" {Install-MSP -Number $int -INIFile $INIFile} 
                    #Perform EXE Based Installed
                    "EXE" {Install-Exe -Number $int -INIFile $INIFile} 
                    Default {Write-log -message "Invalid type specified"}
                }
            }
            Else{
                Write-Log -message "Application $installName $InstallVersion is already installed."
            }

            [int]$int++
            $installType = (Get-IniValue -FilePath "$INIFile" -Section "INSTALL$int" -Key "TYPE")
        }Until([string]::IsNullOrEmpty($installType))

    }
    End{
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    }
}
Function Install-EXE {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Number,
        [Parameter(Mandatory=$true)]
        [string]$INIFile
    )
    Begin{
        ## Get the name of this function and write header
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
    }
    Process{
        $installIgnoreCode = (Get-IniValue -FilePath "$INIFile" -Section "INSTALL$Number" -Key "IGNOREEXITCODE")
        If([string]::IsNullOrEmpty($installIgnoreCode)) {
            $installIgnoreCode = "0"
        }

        # Write-Log -Message "Starting INSTALL$Number details"
        # If([string]::IsNullOrEmpty($installFolder)){
        #     $mediaPath =  "$PkgPath"    
        # }
        # Else {
        #     $mediaPath =  "$PkgPath\$installFolder"
        # }

        Write-Log -Message "INSTALL$int details for EXE found in the INI FIle"
        $installExePath = Set-ExePath -Number $Number -INIFile $INIFile
        $installArguements = Resolve-EnvVariable -Value (Set-ExeArguements -Number $Number -INIFile $INIFile)
        Write-Log -Message "Installation media $installExePath"
        If(!(Test-Path $installExePath)){
            Write-Log -Message "Installation media $installExePath could not be found."
            Show-InstallationPrompt -Message "Installation Failed" -ButtonRightText 'OK' -Icon Error -NoWait
            Exit-script -ExitCode 1000 
        }
        If([string]::IsNullOrEmpty($InstallArguements)){
            Execute-Process -path $installExePath -WindowStyle 'Hidden' -PassThru -IgnoreExitCodes "$installIgnoreCode" -ExitOnProcessFailure $true
        }
        Else{
            Execute-Process -path $installExePath -parameters $installArguements -WindowStyle 'Hidden' -PassThru -IgnoreExitCodes "$installIgnoreCode" -ExitOnProcessFailure $true
        }
        Write-Log -Message "Finished INSTALL$Number details"
    }
    End{
        #This part write an entry in the log regarding the fuction and is for bookkeeping, please do not change
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    }
}
Function Install-MSI {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Number,
        [Parameter(Mandatory=$true)]
        [string]$INIFile
    )
    Begin{
        ## Get the name of this function and write header
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header 

        ## Get MSI Name and MSP Name
        $installMSI = Resolve-EnvVariable -value (Get-IniValue -FilePath "$INIFile" -Section "INSTALL$int" -Key "MSI")
        $installMST = Resolve-EnvVariable -value (Get-IniValue -FilePath "$INIFile" -Section "INSTALL$int" -Key "MST")
        $installSwitches = Resolve-EnvVariable  -value (Get-IniValue -FilePath "$INIFile" -Section "INSTALL$int" -Key "SWITCHES")
        $installFolder = Resolve-EnvVariable  -value (Get-IniValue -FilePath "$INIFile" -Section "INSTALL$int" -Key "FOLDER")
        
        $installIgnoreCode = (Get-IniValue -FilePath "$INIFile" -Section "INSTALL$Number" -Key "IGNOREEXITCODE")
        If([string]::IsNullOrEmpty($installIgnoreCode)) {
            $installIgnoreCode = "0"
        }
    }
    Process{
        If([string]::IsNullOrEmpty($installFolder)){
            $mediaPath =  "$PkgPath"    
        }
        Else {
            $mediaPath =  "$PkgPath\$installFolder"
        }
        Write-Log -Message "INSTALL$number details for MSI found in the INI File"
        Write-Log -Message "Installation media folder is set to $mediaPath."
        If(!(Test-Path $mediaPath\$installMSI)){
            Write-Log -Message "Installation media $mediaPath\$installMSI could not be found."
            Show-InstallationPrompt -Message "Installation Failed" -ButtonRightText 'OK' -Icon Error -NoWait
            Exit-script -ExitCode 1000 
        }
        If ((!([string]::IsNullOrEmpty($installMSI))) -and (!([string]::IsNullOrEmpty($installMST)))) {
            #Write-Log -Message "Installing $installName $INSTALVER"
            Execute-MSI -Action Install -Path "$mediaPath\$installMSI" -Transform "$installMST" -Parameters "$installSwitches REBOOT=ReallySuppress /QN" -LogName "$installName $installVersion $DTStamp" -IgnoreExitCodes "$installIgnoreCode"
        } 
        Else {
            #Write-Log -Message "Installing $INSTALNAME $INSTALVER"
            Execute-MSI -Action Install -Path "$mediaPath\$installMSI" -Parameters "$installSwitches REBOOT=ReallySuppress /QN" -LogName "$installName $installVersion $DTStamp" -IgnoreExitCodes "$installIgnoreCode"
        }
    }
    End{
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    }
}
Function Install-MSP {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Number,
        [Parameter(Mandatory=$true)]
        [string]$INIFile
    )
    Begin{
        ## Get the name of this function and write header
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header

        # Get msi, mst and msp variables        
        $installMSI = Resolve-EnvVariable -value (Get-IniValue -FilePath "$INIFile" -Section "INSTALL$int" -Key "MSI")
        $installMST = Resolve-EnvVariable -value (Get-IniValue -FilePath "$INIFile" -Section "INSTALL$int" -Key "MST")
        $installMSP = (Get-IniValue -FilePath "$INIFile" -Section "INSTALL$int" -Key "MSP")        
        $installSWITCHES = Resolve-EnvVariable  -value (Get-IniValue -FilePath "$INIFile" -Section "INSTALL$int" -Key "SWITCHES")
        $installFolder = Resolve-EnvVariable  -value (Get-IniValue -FilePath "$INIFile" -Section "INSTALL$int" -Key "FOLDER")
        $installIgnoreCode = (Get-IniValue -FilePath "$INIFile" -Section "INSTALL$Number" -Key "IGNOREEXITCODE")
        If([string]::IsNullOrEmpty($installIgnoreCode)) {
            $installIgnoreCode = "0"
        }

    }
    Process{
        If([string]::IsNullOrEmpty($installFolder)){
            $mediaPath =  "$PkgPath"    
        }
        Else {
            $mediaPath =  "$PkgPath\$installFolder"
        }
        Write-Log -Message "INSTALL$int details for MSP found in the INI FIle"
        Write-Log -Message "Installation media folder is set to $mediaPath."
        If(!(Test-Path $mediaPath\$installMSP)){
            Write-Log -Message "Installation media $mediaPath\$installMSP could not be found."
            Show-InstallationPrompt -Message "Installation Failed" -ButtonRightText 'OK' -Icon Error -NoWait
            Exit-script -ExitCode 1000 
        }
        If ((!([string]::IsNullOrEmpty($installMSI))) -and (!([string]::IsNullOrEmpty($installMST))) -and (!([string]::IsNullOrEmpty($installMSP)))) {
            #Write-Log -Message "Installing $INSTALNAME $INSTALVER with Transform & Patch"
            Execute-MSI -Action Install -Path "$mediaPath\$installMSI" -Transform "$mediaPath\$installMST" -Patch "$mediaPath\$installMSP" -Parameters "$installSWITCHES REBOOT=ReallySuppress /QN" -LogName "$installName $installVersion $DTStamp" -IgnoreExitCodes "$installIgnoreCode"
        }
        ElseIf ((!([string]::IsNullOrEmpty($installMSI))) -and (!([string]::IsNullOrEmpty($installMSP)))) {
            #Write-Log -Message "Installing $INSTALNAME $INSTALVER with Patch"
            Execute-MSI -Action Install -Path "$mediaPath\$installMSI" -Patch "$mediaPath\$installMSP" -Parameters "$installSWITCHES REBOOT=ReallySuppress /QN" -LogName "$installName $installVersion $DTStamp" -IgnoreExitCodes "$installIgnoreCode"
        }
        Else {
            #Write-Log -Message "Installing $INSTALNAME $INSTALVER Patch"
            Execute-MSI -Action Patch -Path "$mediaPath\$installMSP" -Parameters "$installSWITCHES REBOOT=ReallySuppress /QN" -LogName "$installName $installVersion $DTStamp" -IgnoreExitCodes "$IEXITCODES"
        }
    }
    End{
        #This part write an entry in the log regarding the fuction and is for bookkeeping, please do not change
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    }
}


Function Uninstall-APP {
    [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$true)]
            [string]$INIFile
        )
        Begin{
            ## Get the name of this function and write header
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header  
            If($deploymentType -eq "Install" ){
                $Global:isUpgrade = 1
            }
            ## Prep for loop
            [int]$int = 1

            ## Get action type
            $Action = Get-ActionString
    
            ## Get Variables needed to process
            $installType = (Get-IniValue -FilePath "$INIFile" -Section "$Action$int" -Key "TYPE")
        }
        Process{
            Do {
                $installName = (Get-IniValue -FilePath "$INIFile" -Section "$Action$int" -Key "NAME")
                $installVersion = (Get-IniValue -FilePath "$INIFile" -Section "$Action$int" -Key "VER")
                $installGuid = (Get-IniValue -FilePath "$INIFile" -Section "$Action$int" -Key "GUID")
    
                If (([string]::IsNullOrEmpty($installGuid)) -or (Get-IsAppInstalled -AppGuid $installGuid)){
                    switch ($installType) {
                        #Perform MSI Based Uninstalled
                        "MSI" {Uninstall-MSI -Number $int -INIFile $INIFile -Action $Action}
                        #Perform EXE Based Uninstalled
                        "EXE" {Uninstall-Exe -Number $int -INIFile $INIFile -Action $Action} 
                        Default {Write-log -message "Invalid type specified."}
                    }
                }
                Else{
                    Write-Log -message "Application $installName $InstallVersion is not installed."
                }
    
                [int]$int++
                $installType = (Get-IniValue -FilePath "$INIFile" -Section "$Action$int" -Key "TYPE")
            }Until([string]::IsNullOrEmpty($installType))  
        }
        End{
            If($Action -ieq "Upgrade"){
                Write-Log -message "Upgrades are complete, setting global upgrade variable to 0."
                $Global:isUpgrade = 0
            }
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
        }
    }

    Function Uninstall-MSI {
        [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$true)]
            [string]$Number,
            [Parameter(Mandatory=$true)]
            [string]$INIFile,
            [Parameter(Mandatory=$true)]
            [string]$Action
        )
        Begin{
            ## Get the name of this function and write header
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
            # Get msi variables        
            $uninstallGUID = Resolve-EnvVariable -value (Get-IniValue -FilePath "$INIFile" -Section "$Action$Number" -Key "GUID")      
            $uninstallSWITCHES = Resolve-EnvVariable  -value (Get-IniValue -FilePath "$INIFile" -Section "$Action$Number" -Key "SWITCHES")
            $iExitCodes = (Get-IniValue -FilePath "$INIFile" -Section "$Action$Number" -Key "IGNOREEXITCODE")
            #$uninstallFolder = (Get-IniValue -FilePath "$INIFile" -Section "$Action$Number" -Key "FOLDER")
            If([string]::IsNullOrEmpty($iExitCodes)) {
                $iExitCodes = "0"
            }
    
        }
        Process{
            Write-Log -Message "Uninstalling $uninstallName $uninstallVersion"
            If ([string]::IsNullOrEmpty($uninstallSWITCHES)){
                Execute-MSI -Action Uninstall -Path $uninstallGUID -Parameters "REBOOT=ReallySuppress /QN" -LogName "$uninstallName $uninstallVersion $DTStamp" -IgnoreExitCodes "$iExitCodes"
            }
            ELSE {
                Execute-MSI -Action Uninstall -Path $uninstallGUID -Parameters "$uninstallSWITCHES REBOOT=ReallySuppress /QN" -LogName "$uninstallName $uninstallVersion $DTStamp" -IgnoreExitCodes "$iExitCodes"
            }
        }
        End{
            #This part write an entry in the log regarding the fuction and is for bookkeeping, please do not change
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
        }
    }

    Function Uninstall-EXE {
        [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$true)]
            [string]$Number,
            [Parameter(Mandatory=$true)]
            [string]$Action,
            [Parameter(Mandatory=$true)]
            [string]$INIFile
        )
        Begin{
            ## Get the name of this function and write header
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
        }
        Process{
            $iExitCodes = (Get-IniValue -FilePath "$INIFile" -Section "$Action$Number" -Key "IGNOREEXITCODE")
            #$uninstallFolder = (Get-IniValue -FilePath "$INIFile" -Section "$Action$Number" -Key "FOLDER")
            If([string]::IsNullOrEmpty($iExitCodes)) {
                $iExitCodes = "0"
            }
            # Write-Log -Message "Starting $Action$Number details"
            # If([string]::IsNullOrEmpty($uninstallFolder)){
            #     $mediaPath =  "$PkgPath"    
            # }
            # Else {
            #     $mediaPath =  "$PkgPath\$uninstallFolder"
            # }
    
            Write-Log -Message "$Action$Number details for EXE found in the INI FIle"
            $uninstallExePath = Set-ExePath -Number $Number -INIFile $INIFile
            $uninstallArguements = Set-ExeArguements -Number $Number -INIFile $INIFile
            Write-Log -Message "$Action media $uninstallExePath"
            If(!(Test-Path $uninstallExePath)) {
                Write-Log -Message "Uninstallation media $uninstallExePath could not be found."
                Show-InstallationPrompt -Message "Uninstallation Failed" -ButtonRightText 'OK' -Icon Error -NoWait
                Exit-script -ExitCode 1000 
            }
    
            If([string]::IsNullOrEmpty($UnInstallArguements)){
                Execute-Process -path $uninstallExePath -WindowStyle 'Hidden' -PassThru -IgnoreExitCodes "$iExitCodes" -ExitOnProcessFailure $true
            }
            Else{               
                Execute-Process -path $uninstallExePath -parameters $UnInstallArguements -WindowStyle 'Hidden' -PassThru -IgnoreExitCodes "$iExitCodes" -ExitOnProcessFailure $true
            }
            Write-Log -Message "Finished $Action$Number details"
        }
        End{
            #This part write an entry in the log regarding the fuction and is for bookkeeping, please do not change
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
        }
    }
    
    

Function Copy-UserFileFolder{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$source,
        [Parameter(Mandatory=$true)]
        [string]$dest
    )
    begin {
        ## Get the name of this function and write header
		    [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		    Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header        
    }  
    Process { 

        $Usrs = Get-UserProfiles ExcludeSystemProfiles -ExcludeDefaultUser

        try{
	        Foreach ($Usr in $Usrs)
            {
                $CUsr = $Usr.ProfilePath        
                New-folder -Path "$CUsr\$dest"
                if(Test-Path "$dirfiles\$source"){
                    Copy-item -Path "$dirfiles\$source" -Destination "$CUsr\$dest" -Recurse -Force -Erroraction Stop
                }
            }           
            $default_profile="$envSystemDrive\Users\Default"
            New-folder -Path "$default_profile\$dest"
            Copy-item -Path "$dirfiles\$source" -destination "$default_profile\$dest" -Recurse -Force -Erroraction Stop

            Write-Log -Message "Copy item Succeeded"

        }catch{
            Write-Log -Message "Copy item Failed"
        }
    } 
    End {
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    } 
    
}

Function Remove-UserFileFolder{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$item
    )
    begin {
        ## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header        
    }  
    Process { 

        $Usrs = Get-UserProfiles ExcludeSystemProfiles -ExcludeDefaultUser

        try{
	        Foreach ($Usr in $Usrs)
            {
                $CUsr = $Usr.ProfilePath        
                if(Test-Path "$CUsr\$item"){
                    Remove-Item "$CUsr\$item" -Force -Recurse -Erroraction Stop
                }        
            }       
            $default_profile="$envSystemDrive\Users\Default"      
            Remove-Item "$default_profile\$item" -Force -Recurse -Erroraction Stop

            Write-Log -Message "Deleting File/Folder Succeeded."

        }catch{
            Write-Log -Message "Deleting File/Folder Failed."
        }
    } 
    End {
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    } 
    
}

Function Set-UserRegistry{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$key,
        [Parameter(Mandatory=$true)]
        [string]$name,
        [Parameter(Mandatory=$true)]
        [string]$value,
        [Parameter(Mandatory=$true)]
        [string]$type
    )
    begin {
        ## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header        
    }  
    Process {

        [scriptblock]$HKCURegistrySettings = {    
            Set-RegistryKey -Key "$key" -Name "$name" -Value "$value" -Type "$type" -SID $UserProfile.SID    	
        }
        Invoke-HKCURegistrySettingsForAllUsers -RegistrySettings $HKCURegistrySettings
    }
    End {
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    } 

}


Function Remove-UserRegistry{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$key,
        [Parameter(Mandatory=$false)]
        [string]$name
    )

     begin {
        ## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header        
    }  
    Process { 

        [scriptblock]$HKCURegistrySettings = {   
            if(!([string]::IsNullOrEmpty($name))){
                Remove-RegistryKey -Key "$key" -Name "$name" -SID $UserProfile.SID    
            }
            else{
                Remove-RegistryKey -Key "$key" -Recurse -SID $UserProfile.SID
            }	
        }
        Invoke-HKCURegistrySettingsForAllUsers -RegistrySettings $HKCURegistrySettings

    } 
    End {
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    } 
}



Function UserSpecific {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$INIFile,
        [Parameter(Mandatory=$False)]
        [string]$UserSpecificcount,
        [Parameter(Mandatory=$False)]
        [string]$int
    )        
        
    
    begin {
        ## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header        
        $USRTYPE = (Get-IniValue -FilePath "$INIFile" -Section "USERSPECIFIC$int" -Key "TYPE")        
        $USROPERATION = (Get-IniValue -FilePath "$INIFile" -Section "USERSPECIFIC$int" -Key "OPERATION")
        $USRSOURCE = (Get-IniValue -FilePath "$INIFile" -Section "USERSPECIFIC$int" -Key "SOURCE")
        $USRDESTINATION = (Get-IniValue -FilePath "$INIFile" -Section "USERSPECIFIC$int" -Key "DESTINATION")
        $USRDELETEFILEFOLDER =  (Get-IniValue -FilePath "$INIFile" -Section "USERSPECIFIC$int" -Key "DELETEFILEFLD")        
        $USRREGWRITE = (Get-IniValue -FilePath "$INIFile" -Section "USERSPECIFIC$int" -Key "REGWRITE")
        $USRREGDELETE = (Get-IniValue -FilePath "$INIFile" -Section "USERSPECIFIC$int" -Key "REGDELETE")
    }
    Process {                          
                
        Write-Log -Message "Starting UserSpecific$int details"
        If (($USRTYPE -ieq "FILE") -or ($USRTYPE -ieq "FOLDER")) {
            Write-Log -Message "UserSpecific$int details for FILE found in the INI File"
            If($USROPERATION -ieq "COPY") {                
                Copy-UserFileFolder -source $USRSOURCE -dest $USRDESTINATION                
            }
            ElseIf($USROPERATION -ieq "DELETE"){
                Remove-UserFileFolder -item $USRDELETEFILEFOLDER
            }
            Else{
                Write-Log -Message "Operation $USROPERATION is incorrect"
            }
        }        
        ElseIf ($USRTYPE -ieq "REGISTRY") {
            If($USROPERATION -ieq "COPY") {     
                $REGInfo = $USRREGWRITE.Split(",")   
                $REGKey = $REGInfo[0]
                $REGName = $REGInfo[1]        
                $REGValue = $REGInfo[2]
                $REGType = $REGInfo[3]
                Set-UserRegistry -key $REGKey -name $REGName -value $REGValue -type $REGType               
            }
            ElseIf($USROPERATION -ieq "DELETE"){
                $REGDeleteInfo = $USRREGDELETE.Split(",")
                $REGKey = $REGDeleteInfo[0]
                $REGName = $REGDeleteInfo[1]
                Remove-UserRegistry -key $REGKey -name $REGName
            }
            Else{
                Write-Log -Message "Operation $USROPERATION is incorrect"
            }       
        }
        Else {
            Write-HOST "No suitable Value Found"            
            Return
        }  
    } 
    End {
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    }          
}




Function MachineSpecific {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$INIFile,
        [Parameter(Mandatory=$False)]
        [string]$MachineSpecificcount,
        [Parameter(Mandatory=$False)]
        [string]$int
    )        
          
    begin {
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header           
        $MACTYPE = (Get-IniValue -FilePath "$INIFile" -Section "MACHINESPECIFIC$int" -Key "TYPE")        
        $MACOPERATION = (Get-IniValue -FilePath "$INIFile" -Section "MACHINESPECIFIC$int" -Key "OPERATION")
        $MACSOURCE = Resolve-EnvVariable -value (Get-IniValue -FilePath "$INIFile" -Section "MACHINESPECIFIC$int" -Key "SOURCE")
        $MACDESTINATION = Resolve-EnvVariable -value (Get-IniValue -FilePath "$INIFile" -Section "MACHINESPECIFIC$int" -Key "DESTINATION")
        $MACDELETEFILEFOLDER =  Resolve-EnvVariable -value (Get-IniValue -FilePath "$INIFile" -Section "MACHINESPECIFIC$int" -Key "DELETEFILEFLD")        
        $MACREGWRITE = Resolve-EnvVariable -value (Get-IniValue -FilePath "$INIFile" -Section "MACHINESPECIFIC$int" -Key "REGWRITE")
        $MACREGDELETE = Resolve-EnvVariable -value (Get-IniValue -FilePath "$INIFile" -Section "MACHINESPECIFIC$int" -Key "REGDELETE")

    }
    Process {
                
        Write-Log -Message "Starting MachineSpecific$int details"
        If (($MACTYPE -ieq "FILE") -or ($MACTYPE -ieq "FOLDER")) {
            Write-Log -Message "MachineSpecific$int details for FILE found in the INI File"
            If($MACOPERATION -ieq "COPY") {   
                try{             
                    Copy-File -Path "$dirfiles\$MACSOURCE" -Destination "$MACDESTINATION"
                    Write-Log -Message "Copy item Succeeded"
                }Catch{
                    Write-Log -Message "Copy item Failed"
                }              
            }
            ElseIf($MACOPERATION -ieq "DELETE"){
                try{
                    if(Test-Path -Path "$MACDELETEFILEFOLDER" -PathType Container){
                        Remove-Folder -Path "$MACDELETEFILEFOLDER"
                        Write-Log -Message "Delete Folder `"$MACDELETEFILEFOLDER`" Succeeded"
                    }
                    else{
                        Remove-File -Path "$MACDELETEFILEFOLDER"
                        Write-Log -Message "Delete File `"$MACDELETEFILEFOLDER`" Succeeded"
                    }
                    
                }catch{
                    Write-Log -Message "Delete Folder `"$MACDELETEFILEFOLDER`" Failed"
                }
            }
            Else{
                Write-Log -Message "Operation `"$MACOPERATION`" is incorrect"
            }
        }        
        ElseIf ($MACTYPE -ieq "REGISTRY") {
            If($MACOPERATION -ieq "COPY") {     
                $REGInfo = $MACREGWRITE.Split(",")   
                $REGKey = $REGInfo[0]
                $REGName = $REGInfo[1]        
                $REGValue = $REGInfo[2]
                $REGType = $REGInfo[3]
                Set-RegistryKey -Key $REGKey -name $REGName -value $REGValue -type $REGType               
            }
            ElseIf($MACOPERATION -ieq "DELETE"){
                If($MACREGDELETE -match ","){
                $REGDeleteInfo = $MACREGDELETE.Split(",")
                $REGKey = $REGDeleteInfo[0]
                $REGName = $REGDeleteInfo[1]
                Remove-RegistryKey -Key $REGKey -name $REGName
                }
                Else
                {Remove-RegistryKey -Key $MACREGDELETE}
            }
            Else{
                Write-Log -Message "Operation $MACOPERATION is incorrect"
            }       
        }
        Else {
            Write-HOST "No suitable Value Found"            
            Return
        }
    } 
    End {
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    }
                
}

Function ARP-Tagging {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$INIFile
    )
    
    $int = "1"
    $Taginfo = (Get-IniValue -FilePath "$INIFile" -Section "TAG" -Key "TAG$int")
    $ActionString = Get-ActionString
    Do { 
        $TaginCodes = $Taginfo.Split(",")
        $TaginCode = $TaginCodes[1]
       #$SetToRemove = (&{if($TaginCodes[2] -ieq 'true'){$true}else{$false}})
        If([string]::IsNullOrEmpty($TaginCodes[2])){
            $SetToRemove = $true
        }
        Else {
            <# Action when all if and elseif conditions are false #>
            $SetToRemove = (&{if($TaginCodes[2] -ieq 'true'){$true}else{$false}})
        }
         
        #get the function we are doing, install, uninstall or upgrade
        
        If($TaginCode -ieq $null) {
            Write-Log -Message "Tagging INFO is not available in the INI or completed tagging."
            Return
        }
        Else {

            $Is64b = Get-InstalledApplication -ProductCode $TaginCode | Select-Object -Property 'Is64BitApplication' -ErrorAction 'SilentlyContinue'
            #Write-log "Found uninstall GUID in 64-bit registry = $Is64b"
            If ($Is64b.Is64BitApplication -ieq $true){
                ##application is 64-bit
                Write-log "64-bit registry = $($Is64b.Is64BitApplication)"
                $UninsCodeKey = "HKLM:Software\Microsoft\Windows\CurrentVersion\Uninstall\$TaginCode"
            }
            ElseIf ($Is64b.Is64BitApplication -ieq $false) {
                ##application is 32-bit
                Write-log "64-bit registry = $($Is64b.Is64BitApplication)"
                $UninsCodeKey = "HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$TaginCode"
            }
            
            if(!([string]::IsNullOrEmpty($UninsCodeKey)) -and $ActionString -ieq 'Install'){
                Set-RegistryKey -Key "$UninsCodeKey" -Name "Comments" -Value "DRM Build: $appDRMBUILD" -Type String
                Set-RegistryKey -Key "$UninsCodeKey" -Name "Contact" -Value "United Support Center" -Type String
                Set-RegistryKey -Key "$UninsCodeKey" -Name "DRMBuild" -Value "$appDRMBUILD" -Type String
                Set-RegistryKey -Key "$UninsCodeKey" -Name "HelpLink" -Value "http://helpdesk.uhg.com/" -Type String
                Set-RegistryKey -Key "$UninsCodeKey" -Name "HelpTelephone" -Value "1-888-UHT-DESK (888-848-3375)" -Type String
                Set-RegistryKey -Key "$UninsCodeKey" -Name "InstalledBy" -Value "$Env:UserName" -Type String
                Set-RegistryKey -Key "$UninsCodeKey" -Name "InstalledOn" -Value (get-date -format "MM/dd/yyyy HH:mm:ss") -Type String
                Set-RegistryKey -Key "$UninsCodeKey" -Name "URLInfoAbout" -Value "" -Type String
                Set-RegistryKey -Key "$UninsCodeKey" -Name "URLUpdateInfo" -Value "" -Type String
            }
            ElseIf (($ActionString -ieq 'Uninstall' -or $ActionString -ieq 'Upgrade') -and $SetToRemove){ 
                If ( $SetToRemove ){
                    Remove-ARP -AppGuid $TaginCode
                }
            }
        }
        $int = [int]$int + 1
        $Taginfo = (Get-IniValue -FilePath "$INIFile" -Section "TAG" -Key "TAG$int")      
    } Until([string]::IsNullOrEmpty($Taginfo))
}

Function Remove-ARP {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False)]
        [string]$AppGuid
    )
    begin{
         ## Get the name of this function and write header
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
    }
    Process{
        ## get our drm tags
        [psobject]$tagInfo = get-DRMInfo -ProductCode "$AppGuid"
        ## get the installed application information 
        #[psobject]$installedApp = Get-InstalledApplication -ProductCode "$AppGuid"

        ## in case we have multiple we are searching for a match based on 64-bit or 32-bit
        ## first check to ensure the DRM info in $tagInfo is not place
        
        #Write-log "Get-InstalledApplication reporting guid as 64-bit? $($installedApp.Is64BitApplication)"
        if(!([string]::IsNullOrEmpty($tagInfo.Is64bit))){
            foreach ($tag in $tagInfo){
                Write-log "Get-DRMInfo reporting guid as 64-bit? $($tag.Is64bit)"
                if($tag.Is64bit){
                    Write-log "Setting key to 64-bit"
                    $UninsCodeKey = "HKLM:Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppGuid"
                }
                Else{
                    Write-log "Setting key to 32-bit"
                    $UninsCodeKey = "HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$AppGuid"
                }
                If([string]::IsNullOrEmpty($UninsCodeKey)){
                    Write-log "An installed application with a GUID of $AppGuid was not found."
                }
                Else{
                    Write-log "Installed application found with registry key of $UninsCodeKey"
                    if(!([string]::IsNullOrEmpty($tag.DRMBuild))){
                        if(Test-Path $UninsCodeKey){
                            $PropertyCount = Get-Item $UninsCodeKey | Select-Object -ExpandProperty property | ForEach-Object { New-Object psobject -Property @{“property”=$_; “Value” = (Get-ItemProperty -Path $UninsCodeKey -Name $_).$_}} | Measure-Object
                            If ($PropertyCount.Count -lt 4 ){
                            #[psobject[]]$Test = Get-ItemProperty -LiteralPath $UninsCodeKey -ErrorAction 'SilentlyContinue'
                                if( [string]::IsNullOrEmpty($tag.DisplayName) -and [string]::IsNullOrEmpty($tag.DisplayVersion) -and [string]::IsNullOrEmpty($tag.UninstallString) -and (!([string]::IsNullOrEmpty($tagInfo.DRMBuild))) -and (!([string]::IsNullOrEmpty($tagInfo.InstalledBy)) -and (!([string]::IsNullOrEmpty($tagInfo.InstalledOn))))){
                                    Write-Log -Message "Less than 4 registry values remaining, only DRMBuild and InstalledBy remain removing $UninsCodeKey"
                                    Remove-RegistryKey -Key $UninsCodeKey
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    End{
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    }
}

Function Get-IsAppInstalled {
    Param(
        [Parameter(Mandatory=$False)]
        [string]$AppGuid
    )
    Write-Log -Message "Checking if app guid $AppGuid is present."
    [psobject]$installedApp = Get-InstalledApplication -ProductCode $AppGuid
    If ($installedApp.Displayname){
        Write-Log -Message "Found display name $($installedApp.DisplayName) version $($installedApp.DisplayVersion)."
        $isInstalled = $true
    }
    Else{
        Write-Log -Message "An app with the guid of $AppGuid was not present."
        $isInstalled = $false
    }
    write-output -inputobject $isInstalled
}


Function Set-Permissions{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$INIFile,
        [Parameter(Mandatory=$false)]
        [string]$Permissioncount
    )
    
    Begin {
    ## Get the name of this function and write header
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header        
    }       
    Process { 
        $int = "0"
        Do { $int = [int]$int + 1
            $FolPermisinfo = Resolve-EnvVariable -value (Get-IniValue -FilePath "$INIFile" -Section "FOLDERPERM" -Key "FLD$int")
            If($FolPermisinfo -ieq $null) {
            Write-Log -Message "Folder Permission INFO is not available in the INI."
            Break
            }
            ElseIf($FolPermisinfo -ne "") {
                if(Test-path $FolPermisinfo){
                    Set-ItemPermission -Path "$FolPermisinfo" -User "Users" -Permission Modify -Inheritance ObjectInherit,ContainerInherit
                    Write-Log -Message "Folder Permissions applied on $FolPermisinfo."
                }else{
                    Write-Log -Message "Folder $FolPermisinfo does not exist"
                }
            }
            Else {
                Write-Log -Message "Folder Permission INFO is not available in the INI or completed setting up the permissions."
                Break
            }           
        }Until($int -ieq "$Permissioncount")

        #Setting File Permissions
        $Num = "0"
        Do { $Num = [int]$Num + 1
            $FilePermisinfo = Resolve-EnvVariable -value (Get-IniValue -FilePath "$INIFile" -Section "FILEPERM" -Key "FILE$Num")
            If($FilePermisinfo -ieq $null) {
            Write-Log -Message "File Permission INFO is not available in the INI."
            Return
            }
            ElseIf($FilePermisinfo -ne "") {
                if(Test-path $FilePermisinfo){
                    Set-ItemPermission -Path "$FilePermisinfo" -User "Users" -Permission Modify
                    Write-Log -Message "File Permissions applied on $FilePermisinfo."
                }else{
                    Write-Log -Message "File $FilePermisinfo does not exist"
                }
            }
            Else {
                Write-Log -Message "File Permission INFO is not available in the INI or Completed setting up the permissions."
                Return
            }
        }Until($Num -ieq "$Permissioncount")
    }         
    
   End {
    ## Write a function footer
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    
   }         
}  

#Setting File Lock Permissions
Function Set-FileLockPermissions{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$INIFile,
        [Parameter(Mandatory=$false)]
        [string]$Permissioncount
    )
    
    Begin {
    ## Get the name of this function and write header
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header        
    }       
    Process { 
        $int = "0"
        Do { $int = [int]$int + 1
            $FileLockPermisinfo = (Get-IniValue -FilePath "$INIFile" -Section "FILELOCK" -Key "FILE$int")
            If($FileLockPermisinfo -ieq $null) {
                Write-Log -Message "File Lock Permission INFO is not available in the INI."
                Break
            }
            ElseIf($FileLockPermisinfo -ne "") {
                if((Test-Path -Path $FileLockPermisinfo)){

                    $setAcl = "$dirSupportFiles\SetACL.exe"
                    $ADMIN_FULL = "-actn ace -ace ""n:S-1-5-32-544;p:full;s:y"""
                    $SYSTEM_FULL = "-actn ace -ace ""n:S-1-5-18;p:full;s:y"""
                    $USERS_RX = "-actn ace -ace ""n:S-1-5-32-545;p:read_ex;s:y;"""
                    $CLEAR_IN = "-actn setprot -op ""dacl:p_nc;sacl:p_nc"""

                    Start-Process -FilePath "$setAcl" -ArgumentList "-on ""$FileLockPermisinfo"" -ot file $ADMIN_FULL $SYSTEM_Full $USERS_RX $CLEAR_IN" -PassThru -Wait
                       
                   }
                Write-Log -Message "File Lock Permissions applied on $FileLockPermisinfo."
            } Else {
                Write-Log -Message "File Lock Permission INFO is not available in the INI or completed setting up the permissions."
                Break
            }        
        }Until($int -ieq "$Permissioncount")
    }         
    
   End {
    ## Write a function footer
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    
   }         
}  

#Setting Registry Permissions
Function Set-RegPermissions{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$INIFile,
        [Parameter(Mandatory=$false)]
        [string]$Permissioncount
    )
    
    Begin {
    ## Get the name of this function and write header
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header        
    }       
    Process { 
        $int = "0"
        Do { $int = [int]$int + 1
            $RegPermisinfo = (Get-IniValue -FilePath "$INIFile" -Section "REGPERM" -Key "REG$int")
            If($RegPermisinfo -ieq $null) {
                Write-Log -Message "Registry Permission INFO is not available in the INI."
                Break
            }
            ElseIf($RegPermisinfo -imatch "HKLM") {
                if((Test-Path -Path $RegPermisinfo)){
                    $acl = Get-Acl $RegPermisinfo
                    $person = [System.Security.Principal.NTAccount]"BuiltIn\Users"          
                    $access = [System.Security.AccessControl.RegistryRights]"FullControl"
                    $inheritance = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit"
                    $propagation = [System.Security.AccessControl.PropagationFlags]"None"
                    $type = [System.Security.AccessControl.AccessControlType]"Allow"
                    $rule = New-Object System.Security.AccessControl.RegistryAccessRule($person,$access,$inheritance,$propagation,$type)
                    $acl.AddAccessRule($rule)
                    $acl |Set-Acl
                   }
                Write-Log -Message "Registry Permissions applied on $RegPermisinfo."
            } 
            Else {
                Write-Log -Message "Registry Permission INFO is not available in the INI or completed setting up the permissions."
                Break
            }        
        }Until($int -ieq "$Permissioncount")
    }         
    
   End {
    ## Write a function footer
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    
   }         
}  

Function Expand-ZIPFile {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$SourcePath,
        [Parameter(Mandatory=$true)]
        [string]$DestinationPath
     )
    #ExitCode = 100 : The Source Path provide is not Valid
    #ExitCode = 101 : There is an error during extraction of the compressed folder
    If(!(Test-Path $SourcePath)){
      Write-Log "The Source Path provided is not valid. Script terminating with error $ExitCode"
      Show-InstallationPrompt -Message "Installation Failed" -ButtonRightText 'OK' -Icon Error -NoWait
      Exit-Script -ExitCode 100
    }
    Else {
        Try{
            Expand-Archive -Path $SourcePath -DestinationPath $DestinationPath -Force -ErrorAction Stop
        } 
        Catch {
            Write-Log "There is an error during the extraction of the compressed folder. Script terminating with error 101."
            Show-InstallationPrompt -Message "Installation Failed" -ButtonRightText 'OK' -Icon Error -NoWait
            Exit-Script -ExitCode 101      
        }
        Write-Log "The media was uncompressed to directory: $Destinationpath."
    }
}

Function Set-ExePath {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Number,
        [Parameter(Mandatory=$true)]
        [string]$INIFile
    )
    begin {
        ## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
        $ActionString = Get-ActionString
        $SubType = (Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "SUBTYPE")
        $GUID = (Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "GUID")
        $installerType = ($SubType.Trim()).ToUpper()
    }
    Process {
        #specific path builder for unique installers and the default
        #if isUpgrade is true we use the uninstall logic in the else statement
        if($ActionString-ieq "Install"){
            switch ($installerType) {
                #Inno wrapper install uses the default install logic based on ini file settings
                "INNO" {$ExePath = Get-ExePathGeneric -Number $Number -INIFile $INIFile}
                #InstallShield wrapper install uses the default install logic based on ini file settings
                "INSTALLSHIELD" {$ExePath = Get-ExePathGeneric -Number $Number -INIFile $INIFile} 
                #NSIS wrapper install uses the default install logic based on ini file settings
                "NSIS" {$ExePath = Get-ExePathGeneric -Number $Number -INIFile $INIFile} 
                #JAR wrapper install uses the default install logic based on ini file settings
                "JAR" {$ExePath = Get-ExePathJAR -Number $Number -INIFile $INIFile} 
                #this is for custom install setup that determines path based on the ini file settings
                "CUSTOM" {$ExePath = Get-ExePathCustom -Number $Number -INIFile $INIFile} 
                #this is the default uninstall setup that determines path based on the ini file settings
                Default {$ExePath = Get-ExePathGeneric -Number $Number -INIFile $INIFile}
            }
        } 
        Else {
            #this is the uninstall/upgrade logic for getting the path
            switch ($installerType) {
                #Inno wrapper uninstall/upgrade uses the UninstallString to determine uninstall exe path
                "INNO" { $ExePath = Get-ExePathInno -Guid $GUID }
                #InstallShield wrapper install uses the default install logic based on ini file settings
                "INSTALLSHIELD" {$ExePath = Get-ExePathGeneric -Number $Number -INIFile $INIFile} 
                #NSIS wrapper uninstall/upgrade uses the UninstallString to determine uninstall exe path
                "NSIS" {$ExePath = Get-ExePathNSIS -Guid $GUID }
                #JAR wrapper uninstall/upgrade uses the default install logic based on ini file settings
                "JAR" {$ExePath = Get-ExePathJAR -Number $Number -INIFile $INIFile} 
                #this is for custom uninstall/upgrade setup that determines path based on the ini file settings
                "CUSTOM" {$ExePath = Get-ExePathCustom -Number $Number -INIFile $INIFile} 
                #this is the default uninstall/upgrade setup that determines path based on the ini file settings
                Default {$ExePath = Get-ExePathGeneric -Number $Number -INIFile $INIFile}
            }
        }
        Write-log "The executable path is set to $ExePath"    
        Write-Output -InputObject $ExePath
    }
    End {
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    }

}
Function Get-ExePathGeneric {
    #this gets the default settings for the exe path from the INI file which will look in the files directory to build the path
    [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$true)]
            [string]$Number,
            [Parameter(Mandatory=$false)]
            [string]$INIFile
        )
        begin {
            ## Get the name of this function and write header
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
            $ActionString = Get-ActionString
            $Folder = Resolve-EnvVariable  -value (Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "FOLDER")
            $Name = Resolve-EnvVariable  -value (Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "EXE")

        }
        Process{
            # ====start process the $PkgPath, $INSTALFOLDER, $INSTALEXE and turn into a path for the execute process
            $ExePath = [System.Text.StringBuilder]::new()
           if($Name.ToUpper().StartsWith("C:\")){
                $ExePath = $Name
            } 
            Else {
                Write-log -message "The PkgPath is set to $PkgPath"
                [void]$ExePath.Append( $PkgPath )
                if (!([string]::IsNullOrEmpty($Folder))){
                    [void]$ExePath.Append( '\' )
                    [void]$ExePath.Append( $Folder )
                }
                [void]$ExePath.Append( '\' )
                [void]$ExePath.Append( $Name )
                # ====end process for making the install exe path and name
                Write-log "The executable path is set to $ExePath"    
            }
            Write-Output -InputObject $ExePath
        }
        End {
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
        }
}
Function Get-ExePathInno {
    #this if for Inno wrappers and gets the uninstall exe path from the registry
    [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$true)]
            [string]$Guid
        )
        begin {
            ## Get the name of this function and write header
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
        }
        Process{
            # ====start process the string location of the exe found in the product guid uninstallstring key
            # ==== this might be changed on the future to a different function to handle more options for getting exe values and potential switches
            [psobject]$UninstallAppNameVersion = Get-InstalledApplication -ProductCode $Guid | Select-Object -Property 'UninstallString' -First 1 -ErrorAction 'SilentlyContinue'              
            $Exepath,$ExeArgs = ($UninstallAppNameVersion.UninstallString -split '.exe').Trim().Trim('"')
            if ([string]::IsNullOrEmpty($Exepath)){
                $ExePath = $null
            }
            Else {
                $ExePath = $ExePath +'.exe'
            }
            # ====end process the string location of the exe found in the product guid uninstallstring key
            Write-log "The executable path is set to $ExePath"    
            Write-Output -InputObject $ExePath
        }
        End {
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
        }
}

Function Get-ExePathJAR {
    #this if for Inno wrappers and gets the uninstall exe path from the registry
    [CmdletBinding()]
        Param(
            [string]$Number,
            [Parameter(Mandatory=$true)]
            [string]$INIFile
        )
        begin {
            ## Get the name of this function and write header
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
        }
        Process{

            $ExePath = Get-JavaPath -Number $Number -INIFile $INIFile
            # ====end process the string location of the exe found in the product guid uninstallstring key
            Write-log "The executable path is set to $ExePath"    
            Write-Output -InputObject $ExePath
        }
        End {
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
        }
}


Function Get-ExePathNSIS {
    #this if for Inno wrappers and gets the uninstall exe path from the registry
    [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$true)]
            [string]$Guid
        )
        begin {
            ## Get the name of this function and write header
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
        }
        Process{
            # ====start process the string location of the exe found in the product guid uninstallstring key
            # ==== this might be changed on the future to a different function to handle more options for getting exe values and potential switches
            [psobject]$UninstallAppNameVersion = Get-InstalledApplication -ProductCode $Guid | Select-Object -Property 'UninstallString' -First 1 -ErrorAction 'SilentlyContinue'              
            $Exepath,$ExeArgs = ($UninstallAppNameVersion.UninstallString -split '.exe').Trim().Trim('"').Trim()
            if ([string]::IsNullOrEmpty($Exepath)){
                $ExePath = $null
            }
            Else {
                $ExePath = $ExePath +'.exe'
            }

            # ====end process the string location of the exe found in the product guid uninstallstring key
            Write-log "The executable path is set to $ExePath"    
            Write-Output -InputObject $ExePath
        }
        End {
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
        }
}
Function Health-Check {
    # Check INI to see if Health Check should be run
    If($isWorkStationOS){
        $HCRUN = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "HEALTH CHECK" -Key "RUN")
        If($HCRUN -EQ "NO"){
            Write-Log -Message "Health Check setting set to not run" -Severity 2
            Return
        }
    }
    Else {
        Write-Log -Message "Server OS detected, disabling healthcheck." -Severity 2
        Return
    }
    # Get the rest of the Health Check settings
    $HCEVENTLOGS = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "HEALTH CHECK" -Key "EVENTLOGS")
    $HCREBOOTCHECK = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "HEALTH CHECK" -Key "REBOOTCHECK")
    $HCSERVICES = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "HEALTH CHECK" -Key "SERVICES")
    
    #Set Health Check Log File Name
    $HCLOG = "Health Check $DTStamp.log"
    
    Write-Log -Message "Starting workstation Health Check."
    Write-Log -Message "Starting workstation Health Check." -LogFileDirectory $configMSILogDir -LogFileName $HCLOG

    # Gathers information for System Name, Operating System, Microsoft Build Number, Major Service Pack Installed, and the last time the system was booted
    $HC_OS = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue | Select-Object -property CSName,Caption,Version,BuildNumber,ServicePackMajorVersion,ServicePackMinorVersion,LastBootUpTime,InstallDate
    $HC_OSImgBld = (Get-ItemProperty -ErrorAction SilentlyContinue -Path "HKLM:\System\UHG\DesktopServices").UHTLifeCycleBaseline
    $HC_OSImgVer = (Get-ItemProperty -ErrorAction SilentlyContinue -Path "HKLM:\System\UHG\DesktopServices").UHTLifeCycleVer
    $HC_OSDisVer = (Get-ItemProperty -ErrorAction SilentlyContinue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
    $HC_OSPatch = (Get-ItemProperty -ErrorAction SilentlyContinue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").UBR
    Write-Log -Message "** OS Info **" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Name : $($HC_OS.CSName)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   OS : $($HC_OS.Caption)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Version : $($HC_OS.Version)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Build : $($HC_OS.BuildNumber)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Display Version : $HC_OSDisVer" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Patch Level : $HC_OSPatch" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Service Pack(Major) : $($HC_OS.ServicePackMajorVersion)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Service Pack(Minor) : $($HC_OS.ServicePackMinorVersion)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Install Date : $($HC_OS.InstallDate)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Image Build : $HC_OSImgBld" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Image Version : $HC_OSImgVer" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Last Reboot : $($HC_OS.LastBootUpTime)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   OS Architecture is $envOSArchitecture" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message " " -LogFileDirectory $configMSILogDir -LogFileName $HCLOG

    Write-Log -Message '** Hardware Platform Information.' -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    $HC_Bios = Get-CimInstance -ClassName Win32_BIOS -ErrorAction SilentlyContinue | Select-Object -Property Version,SerialNumber
    $HC_MakeModel = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction SilentlyContinue | Select-Object -Property Model,Manufacturer,HypervisorPresent,NumberOfLogicalProcessors,NumberOfProcessors
	If ($HC_BIOS.Version -match 'VRTUAL') { $HC_HWType = 'Virtual:Hyper-V' }
	ElseIf ($HC_BIOS.Version -match 'A M I') { $HC_HWType = 'Virtual:Virtual PC' }
	ElseIf ($HC_BIOS.Version -like '*Xen*') { $HC_HWType = 'Virtual:Xen' }
	ElseIf ($HC_BIOS.SerialNumber -like '*VMware*') { $HC_HWType = 'Virtual:VMWare' }
	ElseIf (($HC_MakeModel.Manufacturer -like '*Microsoft*') -and ($HC_MakeModel.Model -notlike '*Surface*')) { $HC_HWType = 'Virtual:Hyper-V' }
	ElseIf ($HC_MakeModel.Manufacturer -like '*VMWare*') { $HC_HWType = 'Virtual:VMWare' }
	ElseIf ($HC_MakeModel.Model -like '*Virtual*') { $HC_HWType = 'Virtual' }
	Else { $HC_HWType = 'Physical' }
    Write-Log -Message "   BIOS Version Hardware : $($HC_Bios.Version)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   BIOS Serail Number : $($HC_Bios.SerialNumber)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Computer Manufacturer : $($HC_MakeModel.Manufacturer)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Computer Model : $($HC_MakeModel.Model)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Hardware Type : $HC_HWType" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Hypervisor Present : $($HC_MakeModel.HypervisorPresent)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Number of Processors : $($HC_MakeModel.NumberOfProcessors)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Number of Logical Processors : $($HC_MakeModel.NumberOfLogicalProcessors)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message " " -LogFileDirectory $configMSILogDir -LogFileName $HCLOG

    #Gathers AppSense Information
    Write-Log -Message "** AppSense Configuration Info **" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    $today = Get-Date -ErrorAction SilentlyContinue
    $ASFile = "$envProgramData\AppSense\Application Manager\Configuration\configuration.aamp"
    If (Test-Path -Path "$ASFile" -PathType Leaf) {
        $HC_AppsenseAMDate = (Get-Item "$ASFile").LastWriteTime
        $xdays = New-TimeSpan -Start $HC_AppsenseAMDate -End $today -ErrorAction SilentlyContinue
        Write-Log -Message "   The AppSense AM configuration is $($xdays.days) days old, it was last updated on $HC_AppsenseAMDate" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    }
        Else {
        Write-Log -Message "   Did not find AppSense AM rules on workstation" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG -Severity 2
    }
    $ASFile = "$envProgramData\AppSense\Environment Manager\configuration.aemp"
    If (Test-Path -Path "$ASFile" -PathType Leaf) {
        $HC_AppsenseEMDate = (Get-Item "$ASFile").LastWriteTime
        $xdays = New-TimeSpan -Start $HC_AppsenseEMDate -End $today -ErrorAction SilentlyContinue
        Write-Log -Message "   The AppSense EM configuration is $($xdays.days) days old, it was last updated on $HC_AppsenseEMDate" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    }
        Else {
        Write-Log -Message "   Did not find AppSense EM rules on workstation" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG -Severity 2
    }
    $ASFile = "$envProgramData\AppSense\Environment Manager\System_configuration.aemp"
    If (Test-Path -Path "$ASFile" -PathType Leaf) {
        $HC_AppsenseEMSDate = (Get-Item "$ASFile").LastWriteTime
        $xdays = New-TimeSpan -Start $HC_AppsenseEMSDate -End $today -ErrorAction SilentlyContinue
        Write-Log -Message "   The AppSense EM System configuration is $($xdays.days) days old, it was last updated on $HC_AppsenseEMSDate" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    }
        Else {
        Write-Log -Message "   Did not find AppSense EM System rules on workstation" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG -Severity 2
    }
    Write-Log -Message " " -LogFileDirectory $configMSILogDir -LogFileName $HCLOG

    #Gather Memory Information
    Write-Log -Message "** Memory Info **" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    $HC_TMem = (Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue | Measure-Object -Property Capacity -Sum).sum /1gb
    $HC_AMem = (Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue | Measure-Object -Property FreePhysicalMemory -Sum).sum /1mb
    # Note AMem is returned in Kbytes so we divide by 1mb instead of 1gb
    Write-Log -Message "   Memory (Total) : $HC_TMem GB" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Memory (Available) : $([math]::Round($HC_AMem)) GB" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message " " -LogFileDirectory $configMSILogDir -LogFileName $HCLOG

    # Gathers information for Device ID, Volume Name, Size in Gb, Free Space in Gb, and Percent of Free Space on each storage device that the system sees
    $HC_Disks = Get-CimInstance -ClassName Win32_LogicalDisk -ErrorAction SilentlyContinue | Select-Object -Property DeviceID,VolumeName,Compressed,@{n="Size GB";e={[math]::Round($_.Size/1GB,0)}},@{n="FreeSpace GB";e={[math]::Round($_.FreeSpace/1GB,0)}}
    Write-Log -Message "** Disk Info **" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    ForEach ($HC_Disk in $HC_Disks) {
        Write-Log -Message "   Device ID : $($HC_DISK.DeviceID)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
        Write-Log -Message "      Volume Name : $($HC_DISK.VolumeName)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
        Write-Log -Message "      Compressed : $($HC_DISK.Compressed)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
        Write-Log -Message "      Size : $($HC_DISK.'Size GB') GB" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
        Write-Log -Message "      FreeSpace : $($HC_DISK.'FreeSpace GB') GB" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    }
    Write-Log -Message " " -LogFileDirectory $configMSILogDir -LogFileName $HCLOG

    #Video Card and Display Info
    Write-Log -Message "** Video Card and Display Info **" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    #Display Adapters
    ForEach ($HC_GPU in Get-CimInstance -ClassName Win32_VideoController -ErrorAction SilentlyContinue | Select DeviceID,Name,@{Expression={$_.adapterram/1MB};label="MB"}) {
        Write-Log -Message "   $($HC_GPU.DeviceID)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
        Write-Log -Message "      Name : $($HC_GPU.Name)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
        Write-Log -Message "      Memory : $($HC_GPU.MB) MB" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    }
    #Screen resolution info
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
    $HC_ScrCnt  = [System.Windows.Forms.Screen]::AllScreens.Count
    $HC_ColScr = [system.windows.forms.screen]::AllScreens
    Write-Log -Message "   Total Screen Count: $HC_ScrCnt" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    $HC_ScrInfo = ($HC_ColScr | ForEach-Object {
            If ("$($_.Primary)" -eq "True") {
                $HC_Type = "Primary Monitor    "
            }
            Else {
                $HC_Type = "Secondary Monitor  "
            }
            If ("$($_.Bounds.Width)" -gt "$($_.Bounds.Height)") {
                $HC_Orientation = "Landscape"
            }
            Else {
                $HC_Orientation = "Portrait"
            }
            Write-Log -Message "   $HC_Type" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message "      Resolution : $($_.Bounds.Width) x $($_.Bounds.Height)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message "      Orientation : $HC_Orientation" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message "      Bits Per Pixel : $($_.BitsPerPixel)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
        }
    )
    Write-Log -Message " " -LogFileDirectory $configMSILogDir -LogFileName $HCLOG

    Write-Log -Message "** OS History **" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    $HC_Hist = Get-ItemProperty -Path "HKLM:\SYSTEM\UHG\DesktopServices\OSHISTORY" -ErrorAction SilentlyContinue | Select-Object -Property Windows*
    $OS_Hists = $HC_Hist.psobject.Members | Where-Object {$_.membertype -like 'noteproperty' } -ErrorAction SilentlyContinue | ForEach-Object {New-Object psobject -Property @{"Name"=$_.Name; "Value"=$_.Value}}
    $OS_Hists | ForEach-Object -ErrorAction SilentlyContinue {Write-Log -Message "   $($_.Name)  $($_.Value)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG}
    Write-Log -Message " " -LogFileDirectory $configMSILogDir -LogFileName $HCLOG

    # Gathers information about Installed Hotfixes on the Machine.
    $HC_Hotfixs = Get-CimInstance -ClassName Win32_QuickFixEngineering -ErrorAction SilentlyContinue | Select-Object HotFixID, InstalledOn | sort HotFixID 
    Write-Log -Message "** Hotfix Info  **" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   HotFix ID     Installed On" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG  
    $HC_Hotfixs | ForEach-Object -ErrorAction SilentlyContinue {Write-Log -Message "   $($_.HotFixID)   $($_.InstalledOn)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG}
    Write-Log -Message " " -LogFileDirectory $configMSILogDir -LogFileName $HCLOG

    # Gathers information for Bitlocker Status
    Write-Log -Message "** Bitlocker Info **" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    $HC_BLDESvc = Get-Service -Name BDESVC -ErrorAction SilentlyContinue
    Write-Log -Message "   The status of BitLocker Drive Encryption Service is $($HC_BLDESvc.Status)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    If([string]::IsNullOrEmpty($HC_BLDESvc)) {
        Write-Log -Message "   The BitLocker Drive Encryption Service is not installed." -LogFileDirectory $configMSILogDir -LogFileName $HCLOG -Severity 2
        Write-Log -Message "   Skipping Bitlocker Status." -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    }
    Else {
        $HC_BLs = Get-BitLockerVolume -ErrorAction SilentlyContinue | Select-Object -Property MountPoint,ProtectionStatus,VolumeStatus,EncryptionPercentage,EncryptionMethod
        Write-Log -Message "** Bitlocker Info **" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
        ForEach ($HC_BL in $HC_BLs) {
            Write-Log -Message "   Drive : $($HC_BL.MountPoint)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message "      Protection : $($HC_BL.ProtectionStatus)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message "      Status : $($HC_BL.VolumeStatus)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message "      Encryption % : $($HC_BL.EncryptionPercentage)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message "      Encryption Method : $($HC_BL.EncryptionMethod)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
        }
    }
    Write-Log -Message " " -LogFileDirectory $configMSILogDir -LogFileName $HCLOG

    # Gathers information on Runing Application.  Displays the application name, and path.  Sorted by image path.
    Write-Log -Message "** Running Applications Info **" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    $HC_Procs = Get-Process -IncludeUserName -ErrorAction SilentlyContinue |Where-Object {$_.MainWindowTitle} | Select Name, Path | Sort Name
    $HC_Procs | ForEach-Object -ErrorAction SilentlyContinue {Write-Log -Message "   $($_.Name) - $($_.Path)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG}
    Write-Log -Message " " -LogFileDirectory $configMSILogDir -LogFileName $HCLOG

    # Gathers information about Installed Applications on the Machine.
    $HC_InsApps = Get-WmiObject -Class Win32_Product -ErrorAction SilentlyContinue | Select-Object Name,Version,IdentifyingNumber | sort Name
    Write-Log -Message "** Installed Applications **" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Write-Log -Message "   Name Version - GUID" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    $HC_InsApps | ForEach-Object -ErrorAction SilentlyContinue {Write-Log -Message "   $($_.Name) $($_.Version) - $($_.IdentifyingNumber)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG}
    Write-Log -Message " " -LogFileDirectory $configMSILogDir -LogFileName $HCLOG

#    # Gathers information about Installed AppX Applications on the Machine.
#    Write-Log -Message "** Installed Modern Applications **" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
#    $HC_AppXSvc = Get-Service -Name AppXSvc -ErrorAction SilentlyContinue
#    Write-Log -Message "   The status of AppXSvc is $($HC_AppXSvc.Status)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
#    If($HC_AppXSvc.Status -EQ "Running"){
#        $HC_InsAppXs = Get-AppxPackage -Allusers -ErrorAction SilentlyContinue | Select-Object Name,PackageFullName | sort Name
#        Write-Log -Message "   Name - GUID" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
#        $HC_InsAppxs | ForEach-Object -ErrorAction SilentlyContinue {Write-Log -Message "   $($_.Name) $($_.PackageFullName)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG}
#        Write-Log -Message " " -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
#    }
#    Else {
#        Write-Log -Message "   The AppXSrv status is currently not running, cannot list Modern Applications that are installed." -LogFileDirectory $configMSILogDir -LogFileName $HCLOG -Severity 2
#        Write-Log -Message "   Skipping Installed Modern Applications list." -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
#    }

    If($HCSERVICES -EQ "NO"){
        Write-Log -Message "Skipping Health Check services check" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    }
    Else {
        # Gathers information on Services.  Displays the service name, System name of the Service, Start Mode, and State.  Sorted by Start Mode and then State.
        $HC_Servs = Get-WmiObject -Class win32_service -ErrorAction SilentlyContinue | Select-Object DisplayName,Name,StartMode,State | sort StartMode, State, DisplayName
        Write-Log -Message "** Services Info **" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
        ForEach ($HC_Serv in $HC_Servs) {
            Write-Log -Message "   Display Name : $($HC_Serv.DisplayName)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message "   Name         : $($HC_Serv.Name)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message "   Start Mode   : $($HC_Serv.StartMode)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message "   State        : $($HC_Serv.State)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message " " -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
        }
    }

    If($HCEVENTLOGS -EQ "NO"){
        Write-Log -Message "Skipping Health Check event logs check" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    }
    Else {
        # Gathers Warning and Errors out of the Application event log.  Displays Event ID, Event Type, Source of event, Time the event was generated, and the message of the event.
        $HC_AppEvents = Get-EventLog -LogName Application -EntryType "Error","Warning"-after $HC_OS.LastBootUpTime | Select-Object -property EventID,EntryType,Source,TimeGenerated,Message | Sort TimeGenerated
        Write-Log -Message "** Health Check - Application Event Info **"
        ForEach ($HC_AppEvent in $HC_AppEvents) {
            Write-Log -Message "   EventID   : $($HC_AppEvent.EventID)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message "   EntryType : $($HC_AppEvent.EntryType)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message "   Source    : $($HC_AppEvent.Source)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message "   Date\Time : $($HC_AppEvent.TimeGenerated)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message "   Message   : $($HC_AppEvent.Message)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message " " -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
        }
        
        # Gathers Warning and Errors out of the System event log.  Displays Event ID, Event Type, Source of event, Time the event was generated, and the message of the event.
        $HC_SysEvents = Get-EventLog -LogName System -EntryType "Error","Warning" -After $HC_OS.LastBootUpTime | Select-Object -property EventID,EntryType,Source,TimeGenerated,Message | Sort TimeGenerated
        Write-Log -Message "** Health Check - System Event Info **"
        ForEach ($HC_SysEvent in $HC_SysEvents) {
            Write-Log -Message "   EventID   : $($HC_SysEvent.EventID)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message "   EntryType : $($HC_SysEvent.EntryType)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message "   Source    : $($HC_SysEvent.Source)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message "   Date\Time : $($HC_SysEvent.TimeGenerated)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message "   Message   : $($HC_SysEvent.Message)" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            Write-Log -Message " " -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
        }
    }
   
    If($HCREBOOTCHECK -EQ "NO"){
        Write-Log -Message "Skipping Health Check pending reboot check" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    }
    Else {
        #Check For Pending Reboot
        [bool]$PendingReboot = $false
        #Checking for pending reboot registry keys
        Write-Log -Message "Starting check for pending reboots." -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
        If ((Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") -eq $true) {
            Write-Log -Message "Reboot pending, found - HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            $PendingReboot = $true
        }
        If ((Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\PostRebootReporting") -eq $true) {
            Write-Log -Message "Reboot pending, found - HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\PostRebootReporting" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            $PendingReboot = $true
        }
        If ((Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") -eq $true) {
            Write-Log -Message "Reboot pending, found - HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            $PendingReboot = $true
        }
        If ((Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending") -eq $true) {
            Write-Log -Message "Reboot pending, found - HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            $PendingReboot = $true
        }
        If ((Test-Path -Path "HKLM:\SOFTWARE\Microsoft\ServerManager\CurrentRebootAttempts") -eq $true) {
            Write-Log -Message "Reboot pending, found - HKLM:\SOFTWARE\Microsoft\ServerManager\CurrentRebootAttempts" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            $PendingReboot = $true
        }
        #Check for Values
        If ((Test-RegistryValue -Key "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing" -Value "RebootInProgress") -eq $true) {
            Write-Log -Message "Reboot pending, found - HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing > RebootInProgress" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            $PendingReboot = $true
        }
        If ((Test-RegistryValue -Key "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing" -Value "PackagesPending") -eq $true) {
            Write-Log -Message "Reboot pending, found - HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing > PackagesPending" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            $PendingReboot = $true
        }
        If ((Test-RegistryValue -Key "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Value "PendingFileRenameOperations") -eq $true) {
            Write-Log -Message "Reboot pending, found - HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager > PendingFileRenameOperations" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            $PendingReboot = $true
        }
        If ((Test-RegistryValue -Key "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Value "PendingFileRenameOperations2") -eq $true) {
            Write-Log -Message "Reboot pending, found - HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager > PendingFileRenameOperations2" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            $PendingReboot = $true
        }
        If ((Test-RegistryValue -Key "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Value "DVDRebootSignal") -eq $true) {
            Write-Log -Message "Reboot pending, found - HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce > DVDRebootSignal" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            $PendingReboot = $true
        }
        If ((Test-RegistryValue -Key "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon" -Value "JoinDomain") -eq $true) {
            Write-Log -Message "Reboot pending, found - HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon > JoinDomain" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            $PendingReboot = $true
        }
        If ((Test-RegistryValue -Key "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon" -Value "AvoidSpnSet") -eq $true) {
            Write-Log -Message "Reboot pending, found - HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon > AvoidSpnSet" -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
            $PendingReboot = $true
        }
        If ($PendingReboot -eq $true) {
            Write-Log -Message "Reboot pending check found that the workstation does require a reboot." -LogFileDirectory $configMSILogDir -LogFileName $HCLOG -Severity 2
        }
        Else {
            Write-Log -Message "Workstation does not require a reboot." -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
        }
    }
    Write-Log -Message "Completed workstation Health Check."
    Write-Log -Message "Completed workstation Health Check." -LogFileDirectory $configMSILogDir -LogFileName $HCLOG
    Return
}
Function Get-DRMInfo {
    <#
    .SYNOPSIS
        Retrieves DRM information about installed applications.
    .DESCRIPTION
        Retrieves DRM information about installed applications by querying the registry. Specify an application's product code.
        Returns DRM information about application DRM build, InstalledOn and InstallBy
    .PARAMETER ProductCode
        The product code of the application to retrieve information for.
    .EXAMPLE
        Get-InstalledApplication -ProductCode '{1AD147D0-BE0E-3D6C-AC11-64F6DC4163F1}'
    .NOTES   
    #>
        [CmdletBinding()]
        Param (
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [string]$ProductCode
        )
    
        Begin {
            ## Get the name of this function and write header
            #[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
            #Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
        }
        Process {
            [string[]]$regKeyApps = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall','Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
            		## Enumerate the installed applications from the registry for applications that have the "DisplayName" property
            
            try{
                [psobject[]]$regKeyApplications = @()
                ForEach ($regKey in $regKeyApps) {
                    $regKeyApplications += (Get-ChildItem -LiteralPath $regKey -ErrorAction 'SilentlyContinue' -ErrorVariable '+ErrorUninstallKeyPath' | Where-Object {$_.PSChildName -eq $ProductCode})
                    }
                 [psobject[]]$regKeyDRMInfo = @()
                ForEach ($regApps in $regKeyApplications) {          
                    $regKeyDRMInfo += New-Object -TypeName 'PSObject' -Property @{
                            "DRMBuild"=(Get-ItemProperty -Path $regApps.PSPath -Name 'DRMBUILD'-ErrorAction 'SilentlyContinue' | Select-Object -ExpandProperty 'DRMBuild');
                            "InstalledOn"=(Get-ItemProperty -Path $regApps.PSPath -Name 'InstalledOn' -ErrorAction 'SilentlyContinue'| Select-Object -ExpandProperty 'InstalledOn');
                            "InstalledBy"=(Get-ItemProperty -Path $regApps.PSPath -Name 'InstalledBy' -ErrorAction 'SilentlyContinue'| Select-Object -ExpandProperty 'InstalledBy');
                            "DisplayName"=(Get-ItemProperty -Path $regApps.PSPath -Name 'DisplayName' -ErrorAction 'SilentlyContinue'| Select-Object -ExpandProperty 'DisplayName');
                            "DisplayVersion"=(Get-ItemProperty -Path $regApps.PSPath -Name 'DisplayVersion' -ErrorAction 'SilentlyContinue'| Select-Object -ExpandProperty 'DisplayVersion');
                            "UninstallString"=(Get-ItemProperty -Path $regApps.PSPath -Name 'UninstallString' -ErrorAction 'SilentlyContinue'| Select-Object -ExpandProperty 'UninstallString');
                            "Is64bit" =If ($regApps.PSPath -notmatch '^Microsoft\.PowerShell\.Core\\Registry::HKEY_LOCAL_MACHINE\\SOFTWARE\\Wow6432Node') { $true } Else { $false }
                    }
                
                }
             }
             Catch {
                    #Write-Log -Message "Failed to resolve application drm details from registry for [$ProductCode]. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
                    Continue
                }
            
            If (-not $installedApplication) {
               # Write-Log -Message "Found no application based on the supplied parameters." -Source ${CmdletName}
            }    
            Write-Output -InputObject $regKeyDRMInfo
        }
        
        End {
            #Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
        }
    }

    Function Get-UninstallStrings {
        <#
        .SYNOPSIS
            Retrieves the Uninstall and QuietUninstallStrings.
        .DESCRIPTION
            Retrieves the Uninstall and QuietUninstallStrings. Stores them in their respective named properties and returns it as an object.
        .PARAMETER ProductCode
            The product code of the application to retrieve information for.
        .EXAMPLE
            Get-UninstallStrings -ProductCode '{1AD147D0-BE0E-3D6C-AC11-64F6DC4163F1}'
        .NOTES   
        #>
            [CmdletBinding()]
            Param (
                [Parameter(Mandatory=$true)]
                [ValidateNotNullorEmpty()]
                [string]$ProductCode
            )
        
            Begin {
                ## Get the name of this function and write header
                [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
                Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
            }
            Process {
                [string[]]$regKeyApps = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall','Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
                        ## Enumerate the installed applications from the registry for applications that have the "DisplayName" property
                
                try{
                    [psobject[]]$regKeyApplications = @()
                    ForEach ($regKey in $regKeyApps) {
                        $regKeyApplications += (Get-ChildItem -LiteralPath $regKey -ErrorAction 'SilentlyContinue' -ErrorVariable '+ErrorUninstallKeyPath' | Where-Object {$_.PSChildName -eq $ProductCode})
                        }
                     [psobject[]]$regKeyUninstallStrings = @()
                    ForEach ($regApps in $regKeyApplications) {          
                        $regKeyUninstallStrings += New-Object -TypeName 'PSObject' -Property @{
                                "QuietUninstallString"=(Get-ItemProperty -Path $regApps.PSPath -Name 'QuietUninstallString'-ErrorAction 'SilentlyContinue' | Select-Object -ExpandProperty 'QuietUninstallString');
                                "UninstallString"=(Get-ItemProperty -Path $regApps.PSPath -Name 'UninstallString' -ErrorAction 'SilentlyContinue'| Select-Object -ExpandProperty 'UninstallString');
                        }
                    
                    }
                 }
                 Catch {
                        Write-Log -Message "Failed to resolve application drm details from registry for [$ProductCode]. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
                        Continue
                    }
                
                If (-not $installedApplication) {
                    Write-Log -Message "Found no application based on the supplied parameters." -Source ${CmdletName}
                }    
                Write-Output -InputObject $regKeyUninstallStrings
            }
            
            End {
                Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
            }
        }
    Function Set-ExeArguements {
        [CmdletBinding()]
            Param(
                [string]$Number,
                [Parameter(Mandatory=$true)]
                [string]$INIFile
            )
        Begin {
            ## Get the name of this function and write header
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
             Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
            #we want to ensure we are comparing APPLES to apples so we make the subtype all caps
            #$INSTALSWITCHES = Resolve-EnvVariable  -value (Get-IniValue -FilePath "$INIFile" -Section "INSTALL$Number" -Key "SWITCHES")
            $ActionString = Get-ActionString
            $SubType = (Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "SUBTYPE")
            $Switches = Resolve-EnvVariable -value (Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "SWITCHES")

            $installerType = ($SubType.Trim()).ToUpper()
        }
        Process {
            #check if doing an install, but not an upgrade
            If($ActionString  -ieq "Install"){
                Switch -exact ($installerType){
                    "INNO" { $Parameters = get-ExeInnoArguements -Number $Number -INIFile $INIFile}
                    "JAR" { $Parameters = Get-ExeJarArguements -Number $Number -INIFile $INIFile}
                    "CUSTOM" { $Parameters = get-ExeCustomArguements -Number $Number -INIFile $INIFile}
                    "INSTALLSHIELD" {$Parameters = Get-ExeInstallShieldArguements -Number $Number -INIFile $INIFile }
                    Default { $Parameters = $Switches }
                }
            }
            Else{
                #uninstall\upgrade arguments logic
                Switch -exact ($installerType){
                    "JAR" { $Parameters = Get-ExeJarArguements -Number $Number -INIFile $INIFile}
                    "INSTALLSHIELD" {$Parameters = Get-ExeInstallShieldArguements -Number $Number -INIFile $INIFile }
                    "CUSTOM" { $Parameters = get-ExeCustomArguements -Number $Number -INIFile $INIFile}
                    Default { $Parameters = $Switches }
                }    
            }
            Write-log "Switch parameters set to $Parameters"      
            Write-Output -InputObject $Parameters       
        }
        End {
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
        }
    }

    Function Get-ExeInstallShieldArguements {
        [CmdletBinding()]
            Param(
                [string]$Number,
                [Parameter(Mandatory=$true)]
                [string]$INIFile
            )
        begin {
            ## Get the name of this function and write header
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
             Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
             $ActionString = Get-ActionString
             $Switches = Resolve-EnvVariable  -value (Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "SWITCHES")
             $Response = Resolve-EnvVariable  -value (Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "RESPONSE")
        }
        Process{
            Write-log "Getting install/uninstall arguments for Installshield"
            if ($ActionString -ieq "Install"){
                # ====start process the $PkgPath, $INSTALFOLDER, $INSTALEXE and turn into a path for the execute process
                $arguments = [System.Text.StringBuilder]::new()
                [void]$arguments.Append( $Switches )
                [void]$arguments.Append( '"' )
                [void]$arguments.Append( "$PkgPath" )
                [void]$arguments.Append( "\" )
                [void]$arguments.Append( "$Response" )
                [void]$arguments.Append( '"' )
                # ====end process for making the install exe path and name
             } 
             Else {               
                $arguments = [System.Text.StringBuilder]::new()
                [void]$arguments.Append( $Switches )
                [void]$arguments.Append( '"' )
                [void]$arguments.Append( "$PkgPath" )
                [void]$arguments.Append( "\" )
                [void]$arguments.Append( "$Response" )
                [void]$arguments.Append( '"' )
             }
            Write-Log -Message "Commandline arguments are set to $arguments" -Source ${CmdletName}
           Write-Output -InputObject $arguments       
        }
        End {
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
        }
    }

    Function Get-ExeInnoArguements {
        [CmdletBinding()]
        Param(
            [string]$Number,
            [Parameter(Mandatory=$true)]
            [string]$INIFile
        )
        begin {
            ## Get the name of this function and write header
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
             Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
             $ActionString = Get-ActionString
             $Switches = Resolve-EnvVariable  -value (Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "SWITCHES")
             $Name = Resolve-EnvVariable  -value (Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "NAME")
        }
        Process{
            if ($ActionString -ieq "INSTALL"){

                # ====start process the $PkgPath, $INSTALFOLDER, $INSTALEXE and turn into a path for the execute process
                $arguements = [System.Text.StringBuilder]::new()
                [void]$arguements.Append( $Switches )
                [void]$arguements.Append( ' /LOG="' )
                [void]$arguements.Append( "$configMSILogDir" )
                [void]$arguements.Append( "\" )
                [void]$arguements.Append( "$Name" )
                [void]$arguements.Append( "_$DTStamp" )
                [void]$arguements.Append( '.Log"' )
                # ====end process for making the install exe path and name
             } 
             Else {
                
                $arguements = [System.Text.StringBuilder]::new()
                [void]$arguements.Append( $Switches )
                [void]$arguements.Append( ' /LOG="' )
                [void]$arguements.Append( "$configMSILogDir" )
                [void]$arguements.Append( "\" )
                [void]$arguements.Append( "$Name" )
                [void]$arguements.Append( "_Uninstall_" )
                [void]$arguements.Append( "_$DTStamp" )
                [void]$arguements.Append( '.Log"' )
             }
            Write-Log -Message "Commandline arguements are set to $arguements" -Source ${CmdletName}
           Write-Output -InputObject $arguements       
        }
        End {
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
        }
    }
    Function Get-ExeJarArguements {
        [CmdletBinding()]
        Param(
            [string]$Number,
            [Parameter(Mandatory=$true)]
            [string]$INIFile
        )
        begin {
            ## Get the name of this function and write header
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
             Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
             $ActionString = Get-ActionString
             $Switches = Resolve-EnvVariable  -value (Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "SWITCHES")
             $Media = Resolve-EnvVariable  -value (Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "MEDIA")
             $Response = Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "RESPONSE"
             $Log = Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "LOG"
             $Name = Resolve-EnvVariable  -value (Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "NAME")
        }
        Process{
            if ($ActionString -ieq "INSTALL"){

                # ====start process the $PkgPath, $INSTALFOLDER, $INSTALEXE and turn into a path for the execute process
                $arguements = [System.Text.StringBuilder]::new()
                [void]$arguements.Append( $Switches )
                [void]$arguements.Append( " $PkgPath\$Media" )
                if(!([string]::IsNullOrEmpty($Response))){
                    [void]$arguements.Append( " $PkgPath\$Response" )
                }
                #[void]$arguements.Append( ">$configMSILogDir\$Log" )
                # ====end process for making the install exe path and name
             } 
             Else {
                $arguements = [System.Text.StringBuilder]::new()
                [void]$arguements.Append( $Switches )
                If ($Media.ToUpper().StartsWith("C:\")){
                    [void]$arguements.Append( " $Media" )
                } 
                Else {
                    [void]$arguements.Append( " $PkgPath\$Media" )
                }
                if(!([string]::IsNullOrEmpty($Response))){
                    [void]$arguements.Append( " $Response" )
                }
             }
            Write-Log -Message "Commandline arguements are set to $arguements" -Source ${CmdletName}
           Write-Output -InputObject $arguements       
        }
        End {
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
        }
    }
    Function Get-ActionString {
        [CmdletBinding()]
            Param(
            )
        Begin {
            ## Get the name of this function and write header
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
             Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
        }
        Process {
            if( $DeploymentType -ieq "Install" -and !($Global:isUpgrade)){
                $ActionString  = "INSTALL"
            }
            Elseif( $DeploymentType -ieq "Install" -and ($Global:isUpgrade)) {
                $ActionString  = "UPGRADE"
            }
            Else {
                $ActionString  = "UNINSTALL"
            }  
            Write-Output -InputObject $ActionString       
        }
        End {
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
        }
    }

    Function Get-JavaPath{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Number,
        [Parameter(Mandatory=$true)]
        [string]$INIFile
    )
        begin {
            ## Get the name of this function and write header
            [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
            $ActionString = Get-ActionString
            $PreReqName = Get-IniValue -FilePath "$INIFile" -Section "$ActionString$Number" -Key "JAVA_ARP_NAME"
        }
        Process{

            [psobject]$PreReqAppName = Get-InstalledApplication -Name $PreReqName | Select-Object -Property 'InstallLocation' -First 1 -ErrorAction 'SilentlyContinue'
            if ([string]::IsNullOrEmpty($PreReqAppName)){
                Write-log "Java pre-requisite was not found exiting with a 1611"
                exit-script 1611
            } 
            Else{
                $JavaPath = (get-childitem $PreReqAppName.InstallLocation -filter "java.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1)
                Write-log "Java path is $JavaPath"   
                    If([string]::IsNullOrEmpty($JavaPath)){
                        Write-Log -Message "Java.exe not found in installation location of pre-requisite Java install." 
                        exit-script 1005
                    }             
                }
     
            Write-Output -InputObject $JavaPath
        }
        End {
            Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
        }
    }   
    Function Set-ArpEntry {
        Param(
            [Parameter(Mandatory=$true)]
            [string]$INIFile
        )
        $ActionString = Get-ActionString
        $int = 1
        $ARPGUID = (Get-IniValue -FilePath "$INIFile" -Section "ARP$int" -Key "GUID")

        if (!([string]::IsNullOrEmpty($ARPGUID))){
            Do { 
                $DisplayName = (Get-IniValue -FilePath "$INIFile" -Section "ARP$int" -Key "Name")
                $DisplayVersion = (Get-IniValue -FilePath "$INIFile" -Section "ARP$int" -Key "Version")
                $Publisher = (Get-IniValue -FilePath "$INIFile" -Section "ARP$int" -Key "Publisher")
                $UninstallString = Resolve-EnvVariable  -value (Get-IniValue -FilePath "$INIFile" -Section "ARP$int" -Key "UninstallString")
                $ARCH = (Get-IniValue -FilePath "$INIFile" -Section "ARP$int" -Key "ARCH")
                $NoRemove = (Get-IniValue -FilePath "$INIFile" -Section "ARP$int" -Key "NOREMOVE")
                $NoRepair = (Get-IniValue -FilePath "$INIFile" -Section "ARP$int" -Key "NOREPAIR")
                $NoModify = (Get-IniValue -FilePath "$INIFile" -Section "ARP$int" -Key "NOMODIFY")
                $ScriptCopyForUninstall = Get-IniValue -FilePath "$INIFile" -Section "ARP$int" -Key "LOCALCOPY"

                If ( $ScriptCopyForUninstall -ieq "YES" ){
                    Copy-Item -Path $scriptParentPath -Destination ("$env:ProgramFiles\UHGUninstall\$DisplayName" + "_$DisplayVersion") -Recurse
                    $invokingScriptName= (Split-Path($invokingScript) -leaf)
                    $invokingShortName,$extJunk = $invokingScriptName -split ".ps1"
                    $UninstallString = [System.Text.StringBuilder]::new()
                    $UninstallString.Append("$env:ProgramFiles\UHGUninstall\$DisplayName")
                    $UninstallString.Append("_$DisplayVersion\$invokingShortName.exe")
                    $UninstallString.Append(' "')
                    $UninstallString.Append( "$invokingScriptName" )
                    $UninstallString.Append( '"')
                    $UninstallString.Append( " -DeploymentType Uninstall ")
                }
                Else {
                    $UninstallString = "Remove using Software Managment Software uninstall job."
                }

                If($ARCH -eq 64){
                    $UninsCodeKey = "HKLM:Software\Microsoft\Windows\CurrentVersion\Uninstall\$ARPGUID"
                }      
                Else{
                    $UninsCodeKey = "HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$ARPGUID"
                }

                    If ($ActionString -ieq "Install"){
                        Set-RegistryKey -Key "$UninsCodeKey"
                        Set-RegistryKey -Key "$UninsCodeKey" -Name "DisplayName" -Value "$DisplayName" -Type String
                        Set-RegistryKey -Key "$UninsCodeKey" -Name "DisplayVersion" -Value "$DisplayVersion" -Type String
                        Set-RegistryKey -Key "$UninsCodeKey" -Name "Publisher" -Value "$Publisher" -Type String
                        
                        if (!([string]::IsNullOrEmpty($UninstallString))){
                            Set-RegistryKey -Key "$UninsCodeKey" -Name "UninstallString" -Value "$UninstallString" -Type ExpandString
                        }
                        if($NoRemove -ieq "YES"){
                            Set-RegistryKey -Key "$UninsCodeKey" -Name "NoRemove" -Value 1 -Type DWord
                        }
                        if($NoRepair -ieq "YES"){
                            Set-RegistryKey -Key "$UninsCodeKey" -Name "NoRepair" -Value 1 -Type DWord 
                        }
                        if($NoModify -ieq "YES"){
                            Set-RegistryKey -Key "$UninsCodeKey" -Name "NoModify" -Value 1 -Type DWord
                        }       
                    }
                    Else
                    {
                        Remove-RegistryKey -Key "$UninsCodeKey" -Recurse
                        Remove-Folder -path ("$env:ProgramFiles\UHGUninstall\$DisplayName" + "_$DisplayVersion")
                    }
            $int++
            $ARPGUID = (Get-IniValue -FilePath "$INIFile" -Section "ARP$int" -Key "GUID")      
            } Until([string]::IsNullOrEmpty($ARPGUID))
        }
        Else{
            Write-Log -Message "No custom ARP to set."
        }
    }

    Function Check-AppsRunning {
        [CmdletBinding()]
        Param (
            [Parameter(Mandatory=$true)]
            [string]$AppsList
        )
        Write-Log -Message "Checking for running processes."
        ## Create a Process object with custom descriptions where they are provided (split on an '=' sign)
        [psobject[]]$processObjects = @()
        #  Split multiple processes on a comma, then split on equal sign, then create custom object with process name and description
        ForEach ($process in ($AppsList -split ',' | Where-Object { $_ })) {
            If ($process.Contains('=')) {
                [string[]]$ProcessSplit = $process -split '='
                $processObjects += New-Object -TypeName 'PSObject' -Property @{
                    ProcessName = $ProcessSplit[0]
                    ProcessDescription = $ProcessSplit[1]
                }
            }
            Else {
                [string]$ProcessInfo = $process
                $processObjects += New-Object -TypeName 'PSObject' -Property @{
                    ProcessName = $process
                    ProcessDescription = ''
                }
            }
        }
        [bool]$AreAppsRunning = Get-RunningProcesses -ProcessObjects $processObjects
        If($AreAppsRunning) {
            Write-Log -Message "Found apps running that need to be shutdown or blocked"
        }
        Else {
            Write-Log -Message "Did not find any apps running that need to be shutdown or blocked"
        }
        Write-Output -InputObject $AreAppsRunning
    }
    Function Get-DomainConnect {
        <#
        .SYNOPSIS
            Returns true if machine is connected to the domain, false if the computer is not.
        .DESCRIPTION
           Returns true if machine is connected to the domain, false if the computer is not. This is informational only at this time.
        .PARAMETER None
            This command has no parameters
        .EXAMPLE
            Get-DomainConnect
        .NOTES   
        #>
            [CmdletBinding()]
            Param (
            )
        
            Begin {
                ## Get the name of this function and write header
                [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
                #Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
            }
            Process {
                try {$isConnected = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()
    
                    if (!([string]::IsNullOrEmpty($isConnected))){
                        $domainConnected = $true
                    }
                
                
                #} catch [System.DirectoryServices.ActiveDirectory.ActiveDirectoryObjectNotFoundException]{ $domainConnected = $false }
                } catch { $domainConnected = $false }
            Write-Log -Message "Machine connected to domain: $domainConnected" -Source ${CmdletName}
            Write-Output -InputObject $domainConnected      
            }
            
            End {
                Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
            }
        }
    
##*===============================================
##* END FUNCTION LISTINGS
##*===============================================

##*===============================================
##* SCRIPT BODY
##*===============================================

If ($scriptParentPath) {
	Write-Log -Message "Script [$($MyInvocation.MyCommand.Definition)] dot-source invoked by [$(((Get-Variable -Name MyInvocation).Value).ScriptName)]" -Source $appDeployToolkitExtName
} Else {
	Write-Log -Message "Script [$($MyInvocation.MyCommand.Definition)] invoked directly" -Source $appDeployToolkitExtName
}

##*===============================================
##* END SCRIPT BODY
##*===============================================
