<#
.SYNOPSIS

PSApppDeployToolkit - This script performs the installation or uninstallation of an application(s).

.DESCRIPTION

- The script is provided as a template to perform an install or uninstall of an application(s).
- The script either performs an "Install" deployment type or an "Uninstall" deployment type.
- The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.

The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.

PSApppDeployToolkit is licensed under the GNU LGPLv3 License - (C) 2024 PSAppDeployToolkit Team (Sean Lillis, Dan Cunningham and Muhammad Mashwani).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
for more details. You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

.PARAMETER DeploymentType

The type of deployment to perform. Default is: Install.

.PARAMETER DeployMode

Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.

.PARAMETER AllowRebootPassThru

Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.

.PARAMETER TerminalServerMode

Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Desktop Session Hosts/Citrix servers.

.PARAMETER DisableLogging

Disables logging to file for the script. Default is: $false.

.EXAMPLE

powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeployMode 'Silent'; Exit $LastExitCode }"

.EXAMPLE

powershell.exe -Command "& { & '.\Deploy-Application.ps1' -AllowRebootPassThru; Exit $LastExitCode }"

.EXAMPLE

powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeploymentType 'Uninstall'; Exit $LastExitCode }"

.EXAMPLE

Deploy-Application.exe -DeploymentType "Install" -DeployMode "Silent"

.INPUTS

None

You cannot pipe objects to this script.

.OUTPUTS

None

This script does not generate any output.

.NOTES

Toolkit Exit Code Ranges:
- 60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
- 69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
- 70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1

.LINK

https://psappdeploytoolkit.com
#>


[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall', 'Repair')]
    [String]$DeploymentType = 'Install',
    [Parameter(Mandatory = $false)]
    [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
    [String]$DeployMode = 'Interactive',
    [Parameter(Mandatory = $false)]
    [switch]$AllowRebootPassThru = $true,
    [Parameter(Mandatory = $false)]
    [switch]$TerminalServerMode = $false,
    [Parameter(Mandatory = $false)]
    [switch]$DisableLogging = $false,
    [Parameter(Mandatory=$false)]
    [switch]$NoDefer = $false,
    [Parameter(Mandatory=$false)]
    [switch]$NoCache,
    [Parameter(Mandatory=$false)]
    [string]$INIFile = 'Package.ini'
)

Try {
	## Set the script execution policy for this process
	Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' } Catch {}
	#==================== Pre-generating the AppDetails from INI File to build the Log File Name ========================#
	If(Test-Path "$PSScriptRoot\SupportFiles\$INIFile") {
		Try{ $PreGenAppName = (((Get-Content -Path "$PSScriptRoot\SupportFiles\$INIFile" | Where-Object {$_ -ilike "APPNAME=*"}).Split("="))[1]) } Catch {$PreGenAppName = "ErrorHandlerName"}
		Try{ $PreGenAppVendor = (((Get-Content -Path "$PSScriptRoot\SupportFiles\$INIFile" | Where-Object {$_ -ilike "APPVENDOR=*"}).Split("="))[1]) } Catch {$PreGenAppVendor = "ErrorHandlerVendor"}
		Try{ $PreGenAppVersion = (((Get-Content -Path "$PSScriptRoot\SupportFiles\$INIFile" | Where-Object {$_ -ilike "APPVER=*"}).Split("="))[1]) } Catch {$PreGenAppVersion = "ErrorHandlerVer"}
		Try{ $PreGenAppDRMBUILD = (((Get-Content -Path "$PSScriptRoot\SupportFiles\$INIFile" | Where-Object {$_ -ilike "DRMBUILD=*"}).Split("="))[1]) } Catch {$PreGenAppDRMBUILD = "ErrorHandlerDrmBuild"}
	}

	##*===============================================
	##* VARIABLE DECLARATION
	##*===============================================
	## Variables: Application
	[string]$appVendor = "$PreGenAppVendor"
	[string]$appName = "$PreGenAppName"
	[string]$appVersion = "$PreGenAppVersion"
	[string]$appDRMBUILD = "$PreGenAppDRMBUILD"
	[string]$appArch = ''
	[string]$appLang = 'EN'
	[string]$appRevision = '01'
	[string]$appScriptVersion = '24.11.7'
	[string]$appScriptDate = '1/30/2024'
	[string]$appScriptAuthor = "PSADTK Team"
	[string]$PkgName = "$appVendor $appName $appVersion"
	##*===============================================
	## Variables: Install Titles (Only set here to override defaults set by the toolkit)
	[string]$installName = ''
	[string]$installTitle = ''

    ##* Do not modify section below
    #region DoNotModify

	## Variables: Exit Code
	[int32]$mainExitCode = 0
	[bool]$installReboot = $false
	[bool]$uninstallReboot = $false

    ## Variables: Script
    [String]$deployAppScriptFriendlyName = 'Deploy Application'
    [Version]$deployAppScriptVersion = [Version]'3.10.2'
    [String]$deployAppScriptDate = '08/13/2024'
    [Hashtable]$deployAppScriptParameters = $PsBoundParameters

    ## Variables: Environment
    If (Test-Path -LiteralPath 'variable:HostInvocation') {
        $InvocationInfo = $HostInvocation
    }
    Else {
        $InvocationInfo = $MyInvocation
    }
    [String]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent

    ## Dot source the required App Deploy Toolkit Functions
    Try {
        [String]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
        If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) {
            Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]."
        }
        If ($DisableLogging) {
            . $moduleAppDeployToolkitMain -DisableLogging
        }
        Else {
            . $moduleAppDeployToolkitMain
        }
    }
    Catch {
        If ($mainExitCode -eq 0) {
            [Int32]$mainExitCode = 60008
        }
        Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
        ## Exit the script, returning the exit code to SCCM
        If (Test-Path -LiteralPath 'variable:HostInvocation') {
            $script:ExitCode = $mainExitCode; Exit
        }
        Else {
            Exit $mainExitCode
        }
    }

    #endregion
    ##* Do not modify section above
    
        ##*===============================================
	##* VARIABLE DECLARATION fetched from INI File
	##*===============================================   
    
    #============= Check & Fetch $INIFile information ================#	
	If(Test-Path "$dirSupportFiles\$INIFile") {
		$appVENDOR = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "PRODUCT INFO" -Key "APPVENDOR")
		$appNAME = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "PRODUCT INFO" -Key "APPNAME")
		[version]$appVER = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "PRODUCT INFO" -Key "APPVER")
		$ZIPFOL = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "PRODUCT INFO" -Key "ZIPFILENAME")
		$appDRMBUILD = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "PRODUCT INFO" -Key "DRMBUILD")
		$appGUID = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "PRODUCT INFO" -Key "APPGUID ")
		$appFAILONUNINSTALL= (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "PRODUCT INFO" -Key "FAILONUNINSTALL")
		$appREBOOTER = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "PRODUCT INFO" -Key "REBOOTER")
		$appSCRIPTVER = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "PRODUCT INFO" -Key "SCRIPTVER")
		$appINV = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "PRODUCT INFO" -Key "INVENTORY")
		$appSHUTDOWNTIMEOUT = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "APP CONTROL" -Key "SHUTDOWNTIMEOUT")
		$appSHUTDOWNNAME = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "APP CONTROL" -Key "SHUTDOWN")
		$appBLOCKNAME = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "APP CONTROL" -Key "BLOCK")
		$appDEFER = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "APP CONTROL" -Key "DEFER")
		$appDEFERCNT = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "APP CONTROL" -Key "DEFERCNT")
		$appDEFERTIMEOUT = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "APP CONTROL" -Key "DEFERTIMEOUT")
		$RemoveMedia = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "PRODUCT INFO" -Key "REMOVEMEDIA")
		$AppID = (Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "PRODUCT INFO" -Key "APPKEYID")
		$Global:isUpgrade = 0
	}
	Else {
		Write-Log -Message "$INIFile file doesn't exist in SupportFiles Directory of the package."
		Exit-Script -ExitCode 86
	}
	##*== Set Current Date and Time varable for log files ===
	$DTStamp = Get-Date -format "yyyy,MM,dd,HHmm"
	$AppDetFld = "$appVendor $appName $appVER"

	#checking for and create if needed detailed log folder
	[string]$configMSILogDir = Set-DetailLogFolder
	Write-Log -Message "The detailed logging directory is: $configMSILogDir"
    
    
    ##*===============================================
    #endregion END VARIABLE DECLARATION
    ##*===============================================
	If($NoDefer) {
		Write-Log -Message "NoDefer command line switch used, disabling deferrals" -Severity 2
		$appDEFER = "NO"
	}
	If ($appDEFER -like 'YES') {
		If($scriptDirectory -like "C:\Packages\*"){
			Write-Log -Message "Deferral option enabled but package is being run from C:\Packages folder.  Deferal being disabled because Altris does not support this feature" -Severity 2
			$appDEFER = 'NO'
		}
	}

    If ($deploymentType -ine 'Uninstall' -and $deploymentType -ine 'Repair') {
        ##*===============================================
        ##* MARK: PRE-INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Pre-Installation'

        ## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt
        ##Show-InstallationWelcome -CloseApps 'iexplore' -AllowDefer -DeferTimes 3 -CheckDiskSpace -PersistPrompt

        ## Show Progress Message (with the default message)
        ##Show-InstallationProgress

        ## <Perform Pre-Installation tasks here>
		#============= Check if Application already installed ================#
		If(!([string]::IsNullOrEmpty($APPGUID))) {
			[psobject]$InstlAppNameVersion = Get-InstalledApplication -ProductCode $APPGUID | Select-Object -Property 'Publisher', 'DisplayName', 'DisplayVersion' -First 1 -ErrorAction 'SilentlyContinue'
			[psobject]$InstlAppDRMInfo = Get-DRMInfo -ProductCode $APPGUID
			$InstlName = $InstlAppNameVersion.DisplayName
			[version]$InstlVers = $InstlAppNameVersion.DisplayVersion
			$InstlDRM = $InstlAppDRMInfo.DRMBuild
			If(($InstlVers -ige $appVER) -and ($InstlDRM -ieq $appDRMBUILD)) {
				Write-Log -Message "$InstlName $InstlVers with $InstlDRM is already installed on this Device. Hence exit the installation."
				Show-InstallationPrompt -Message "Application already installed." -ButtonRightText 'OK' -Icon Information -NoWait
				Exit-Script -ExitCode 0
			}
			Else{
				Write-Log -Message "$appVENDOR $appNAME with version $appVER is not installed on this Device. Continuing with installation"
			}
		}

		#Set the PkgPath to the dirfiles using cache logic
		If($NoCache -eq $true){
			Write-log "Caching of media is disabled in the INI file."
			$PkgPath = $dirfiles
		}
		Elseif(!($isWorkStationOS)){
			Write-log "Caching of media is disabled because server OS has been detected."
			$PkgPath = $dirfiles
		}
		Else{
			Write-log "Caching of media is enabled."
			$PkgPath = Add-CacheMedia
		}
		
				#=================== Display Defer & AppShutdown Messages =====================#
		If ($appDEFER -like 'YES') {
			If(!([string]::IsNullOrEmpty($appSHUTDOWNNAME))) {
				# Shutdown apps setting found, check to see if any are running.
				[bool]$AppsRunning = Check-AppsRunning -AppsList $appSHUTDOWNNAME
                Write-Log -Message "Are application running that need to be shutdown: $AppsRunning"
				If($AppsRunning) {
					#Shutdown apps found running show defer \ showdown message
					Show-InstallationWelcome -CloseApps "$appSHUTDOWNNAME" -ForceCloseAppsCountdown $appDEFERTIMEOUT -AllowDefer -DeferTimes $appDEFERCNT -ForceCountdown $appDEFERTIMEOUT
					# Reset deferral timeout if already displayed
					$appDEFERTIMEOUT = $appSHUTDOWNTIMEOUT
				}
			}
			If(!([string]::IsNullOrEmpty($appBLOCKNAME))) {
				# Block apps setting found, check to see if any are running.
				[bool]$AppsRunning = Check-AppsRunning -AppsList $appBLOCKNAME
				Write-Log -Message "Are application running that need to be blocked: $AppsRunning"
				If($AppsRunning) {
					#Block apps found running show defer \ showdown message
					Show-InstallationWelcome -CloseApps "$appBLOCKNAME" -ForceCloseAppsCountdown $appDEFERTIMEOUT -BlockExecution -AllowDefer -DeferTimes $appDEFERCNT -ForceCountdown $appDEFERTIMEOUT
				}
				Else {
					#Apps currently not running, block them to prevent launch
					Show-InstallationWelcome -CloseApps "$appBLOCKNAME" -ForceCloseAppsCountdown $appSHUTDOWNTIMEOUT -BlockExecution
				}
			}
		}
		Else {
			If(!([string]::IsNullOrEmpty($appSHUTDOWNNAME))) {
				Show-InstallationWelcome -CloseApps "$appSHUTDOWNNAME" -ForceCloseAppsCountdown $appSHUTDOWNTIMEOUT
			}
			If(!([string]::IsNullOrEmpty($appBLOCKNAME))) {
				Show-InstallationWelcome -CloseApps "$appBLOCKNAME" -ForceCloseAppsCountdown $appSHUTDOWNTIMEOUT -BlockExecution
			}
		}        
		#==================== Display Progress Message =======================#
		Show-InstallationProgress -StatusMessage "$appNAME $appVER installation in progress..."
		# Run Health Check Function
		Health-Check
		
		#Perform Upgrade Routine
		Uninstall-App -INIFile "$dirSupportFiles\$INIFile"
		
        #============= Copying\Deleting Userspecific File\Folder\Registry ================#
        $int = 0
        Do { 
            $int = [int]$int + 1  
            $UserspecificFound = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "USERSPECIFIC$int" -Key "TYPE"	
            $Place = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "USERSPECIFIC$int" -Key "PLACE"
            If(!([string]::IsNullOrEmpty($UserspecificFound)) -and $Place -eq "PREINSTALL"){
			    UserSpecific -INIFile "$dirSupportFiles\$INIFile" -int $int
		    }	
		    
        }Until([string]::IsNullOrEmpty($UserspecificFound))

        #============= Copying\Deleting Machine specific File\Folder\Registry ================#
        $int = 0
        Do { 
            $int = [int]$int + 1  
            $MachineSpecificFound = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "MACHINESPECIFIC$int" -Key "TYPE"	
            $Place = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "MACHINESPECIFIC$int" -Key "PLACE"
            If(!([string]::IsNullOrEmpty($MachineSpecificFound)) -and $Place -eq "PREINSTALL"){
			    MachineSpecific -INIFile "$dirSupportFiles\$INIFile" -int $int
		    }	
		    
        }Until([string]::IsNullOrEmpty($MachineSpecificFound))

        ##*===============================================
        ##* MARK: INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Installation'

        ## Handle Zero-Config MSI Installations
        # If ($useDefaultMsi) {
        #     [Hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Install'; Path = $defaultMsiFile }; If ($defaultMstFile) {
        #         $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile)
        #     }
        #     Execute-MSI @ExecuteDefaultMSISplat; If ($defaultMspFiles) {
        #         $defaultMspFiles | ForEach-Object { Execute-MSI -Action 'Patch' -Path $_ }
        #     }
        # }

        ## <Perform Installation tasks here>

	Install-App -INIFile "$dirSupportFiles\$INIFile"
	

        ##*===============================================
        ##* MARK: POST-INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Post-Installation'

		## <Perform Post-Installation tasks here>
		#=============================================#
		#============= Copying\Deleting Userspecific File\Folder\Registry ================#
		$int = 0
        Do { 
            $int = [int]$int + 1  
            $UserspecificFound = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "USERSPECIFIC$int" -Key "TYPE"	
            $Place = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "USERSPECIFIC$int" -Key "PLACE"
            If(!([string]::IsNullOrEmpty($UserspecificFound)) -and $Place -eq "POSTINSTALL"){
			    UserSpecific -INIFile "$dirSupportFiles\$INIFile" -int $int
		    }	
		    
        }Until([string]::IsNullOrEmpty($UserspecificFound))

        #============= Copying\Deleting Machine specific File\Folder\Registry ================#
        $int = 0
        Do { 
            $int = [int]$int + 1  
            $MachineSpecificFound = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "MACHINESPECIFIC$int" -Key "TYPE"	
            $Place = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "MACHINESPECIFIC$int" -Key "PLACE"
            If(!([string]::IsNullOrEmpty($MachineSpecificFound)) -and $Place -eq "POSTINSTALL"){
			    MachineSpecific -INIFile "$dirSupportFiles\$INIFile" -int $int
		    }	
		    
        }Until([string]::IsNullOrEmpty($MachineSpecificFound))
		
		#=============================================#
		#============= Setting File\Folder Permissions ================#
		$FolPermFound = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "FOLDERPERM" -Key "FLD1"
		$FilePermFound = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "FILEPERM" -Key "FILE1"
		If(($FolPermFound -ieq $null) -and ($FilePermFound -ieq $null)) {
			Write-Log -Message "Folder\File Permission details are not found under FOLDERPERM\FILEPERM section of the INI file"
		}
		Else {
			Set-Permissions -INIFile "$dirSupportFiles\$INIFile"
		}
		#=============================================#
		#============= Setting Lock File Permissions ================#        
		$FilePermFound = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "FILELOCK" -Key "FILE1"
		If($FilePermFound -ieq $null) {
			Write-Log -Message "Folder\File Permission details are not found under FOLDERPERM\FILEPERM section of the INI file"
		}
		Else {
			Set-FileLockPermissions -INIFile "$dirSupportFiles\$INIFile"
        }
		#=============================================#
		#============= Setting Registry Permissions ================#
		$RegPermFound = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "REGPERM" -Key "REG1"
		If($RegPermFound -ieq $null) {
			Write-Log -Message "Registry key Permission details are not found under REGPERM section of the INI file".
		}
		Else {
			Set-RegPermissions -INIFile "$dirSupportFiles\$INIFile"
		}
		#============= Adding Tagging ================#
		Set-ArpEntry -INIFile "$dirSupportFiles\$INIFile"
		$TagFound = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "TAG" -Key "TAG1"
		If([string]::IsNullOrEmpty($TagFound)) {
			Write-Log -Message "ARP Tagging details are not found under TAG section of INI file"
		} 
		Else {
			ARP-Tagging -INIFile "$dirSupportFiles\$INIFile"
		}


		## Display a message at the end of the install
		## If (-not $useDefaultMsi) { Show-InstallationPrompt -Message 'You can customize text to appear at the end of an install or remove it completely for unattended installations.' -ButtonRightText 'OK' -Icon Information -NoWait }        
        If (($AllowRebootPassThru) -and ((($msiRebootDetected) -or ($exitCode -eq 3010)) -or ($exitCode -eq 1641) -or ($appREBOOTER -ieq 'INSTALL') -or ($appREBOOTER -eq 'ALWAYS'))) {
			 $installReboot = $true
             Show-InstallationPrompt -Message "$appNAME $appVER installation complete, reboot required." -ButtonRightText 'OK' -Icon Information -NoWait
        }
        Else {
             Show-InstallationPrompt -Message "$appNAME $appVER installation complete." -ButtonRightText 'OK' -Icon Information -NoWait
        } 


	} 
	ElseIf ($deploymentType -ieq 'Uninstall') {
		##*===============================================
		##* PRE-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Uninstallation'

		## <Perform Pre-Uninstallation tasks here>
		#=================== Display AppShutdown Message =====================#
		If(!([string]::IsNullOrEmpty($appSHUTDOWNNAME))) {
			Show-InstallationWelcome -CloseApps "$appSHUTDOWNNAME" -ForceCloseAppsCountdown $appSHUTDOWNTIMEOUT
		}
		If(!([string]::IsNullOrEmpty($appBLOCKNAME))) {
			Show-InstallationWelcome -CloseApps "$appBLOCKNAME" -ForceCloseAppsCountdown $appSHUTDOWNTIMEOUT -BlockExecution
		}
		## Show Progress Message (with the default message)
		Show-InstallationProgress -StatusMessage "$appNAME $appVER uninstall in progress..."

		# Run Health Check Function
		Health-Check

		#=========Check for and extracting the compressed folder & checking the status of the extraction========#
		#$PkgPath = Extract-PackageZip
        #============= Copying\Deleting Userspecific File\Folder\Registry ================#

		#Set the PkgPath to the dirfiles using cache logic
		If($NoCache -eq $true){
			Write-log "Caching of media is disabled in the INI file."
			$PkgPath = $dirfiles
		}
		Elseif(!($isWorkStationOS)){
			Write-log "Caching of media is disabled because server OS has been detected."
			$PkgPath = $dirfiles
		}
		Else{
			Write-log "Caching of media is enabled."
			$PkgPath = Add-CacheMedia
		}



        $int = 0
        Do { 
            $int = [int]$int + 1  
            $UserspecificFound = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "USERSPECIFIC$int" -Key "TYPE"	
            $Place = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "USERSPECIFIC$int" -Key "PLACE"
            If(!([string]::IsNullOrEmpty($UserspecificFound)) -and $Place -eq "PREUNINSTALL"){
			    UserSpecific -INIFile "$dirSupportFiles\$INIFile" -int $int
		    }	
		    
        }Until([string]::IsNullOrEmpty($UserspecificFound))

        #============= Copying\Deleting Machine specific File\Folder\Registry ================#
        $int = 0
        Do { 
            $int = [int]$int + 1  
            $MachineSpecificFound = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "MACHINESPECIFIC$int" -Key "TYPE"	
            $Place = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "MACHINESPECIFIC$int" -Key "PLACE"
            If(!([string]::IsNullOrEmpty($MachineSpecificFound)) -and $Place -eq "PREUNINSTALL"){
			    MachineSpecific -INIFile "$dirSupportFiles\$INIFile" -int $int
		    }	
		    
        }Until([string]::IsNullOrEmpty($MachineSpecificFound))

		##*===============================================
		##* UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Uninstallation'

        ## Handle Zero-Config MSI Uninstallations
       ## If ($useDefaultMsi) {
        ##    [Hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Uninstall'; Path = $defaultMsiFile }; If ($defaultMstFile) {
        ##        $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile)
        ##    }
        ##    Execute-MSI @ExecuteDefaultMSISplat
       ## }

        ## <Perform Uninstallation tasks here>

	Uninstall-App -INIFile "$dirSupportFiles\$INIFile"

        ##*===============================================
        ##* MARK: POST-UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Post-Uninstallation'

        #============= Copying\Deleting Userspecific File\Folder\Registry ================#
        $int = 0
        Do { 
            $int = [int]$int + 1  
            $UserspecificFound = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "USERSPECIFIC$int" -Key "TYPE"	
            $Place = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "USERSPECIFIC$int" -Key "PLACE"
            If(!([string]::IsNullOrEmpty($UserspecificFound)) -and $Place -eq "POSTUNINSTALL"){
			    UserSpecific -INIFile "$dirSupportFiles\$INIFile" -int $int
		    }	
		    
        }Until([string]::IsNullOrEmpty($UserspecificFound))

        #============= Copying\Deleting Machine specific File\Folder\Registry ================#
        $int = 0
        Do { 
            $int = [int]$int + 1  
            $MachineSpecificFound = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "MACHINESPECIFIC$int" -Key "TYPE"	
            $Place = Get-IniValue -FilePath "$dirSupportFiles\$INIFile" -Section "MACHINESPECIFIC$int" -Key "PLACE"
            If(!([string]::IsNullOrEmpty($MachineSpecificFound)) -and $Place -eq "POSTUNINSTALL"){
			    MachineSpecific -INIFile "$dirSupportFiles\$INIFile" -int $int
		    }	
		    
        }Until([string]::IsNullOrEmpty($MachineSpecificFound))

		## <Perform Post-Uninstallation tasks here>
		#=============================================#		
		#============= Remove Tagging ================#

		ARP-Tagging -INIFile "$dirSupportFiles\$INIFile"
	
		Set-ArpEntry -INIFile "$dirSupportFiles\$INIFile"
        
        If (($AllowRebootPassThru) -and ((($msiRebootDetected) -or ($exitCode -eq 3010)) -or ($exitCode -eq 1641) -or ($appREBOOTER -ieq 'UNINSTALL'))) {
			$installReboot = $true
             Show-InstallationPrompt -Message "$appNAME $appVER uninstallation complete, reboot required." -ButtonRightText 'OK' -Icon Information -NoWait
        }
        Else {
             Show-InstallationPrompt -Message "$appNAME $appVER uninstallation complete." -ButtonRightText 'OK' -Icon Information -NoWait
        } 

    }
    ElseIf ($deploymentType -ieq 'Repair') {
        ##*===============================================
        ##* MARK: PRE-REPAIR
        ##*===============================================
        [String]$installPhase = 'Pre-Repair'

		## <Perform Pre-Repair tasks here>
		#=================== Display AppShutdown Message =====================#
		If(!([string]::IsNullOrEmpty($appSHUTDOWNNAME))) {
			Show-InstallationWelcome -CloseApps "$appSHUTDOWNNAME" -ForceCloseAppsCountdown $appSHUTDOWNTIMEOUT
		}
		If(!([string]::IsNullOrEmpty($appBLOCKNAME))) {
			Show-InstallationWelcome -CloseApps "$appBLOCKNAME" -ForceCloseAppsCountdown $appSHUTDOWNTIMEOUT -BlockExecution
		}

        ## Show Progress Message (with the default message)
		Show-InstallationProgress -StatusMessage "$appNAME $appVER repair in progress..."
		
	# Run Health Check Function
	Health-Check

        ## <Perform Pre-Repair tasks here>

        ##*===============================================
        ##* MARK: REPAIR
        ##*===============================================
        [String]$installPhase = 'Repair'

        ## Handle Zero-Config MSI Repairs
       # If ($useDefaultMsi) {
        #    [Hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Repair'; Path = $defaultMsiFile; }; If ($defaultMstFile) {
        #        $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile)
        #    }
        #    Execute-MSI @ExecuteDefaultMSISplat
        #}
        ## <Perform Repair tasks here>

        ##*===============================================
        ##* MARK: POST-REPAIR
        ##*===============================================
        [String]$installPhase = 'Post-Repair'

		## <Perform Post-Repair tasks here>
        If (($AllowRebootPassThru) -and ((($msiRebootDetected) -or ($exitCode -eq 3010)) -or ($exitCode -eq 1641) -or ($appREBOOTER -eq 'ALWAYS'))) {
			Show-InstallationPrompt -Message "$appNAME $appVER repair complete, reboot required." -ButtonRightText 'OK' -Icon Information -NoWait
		}
		Else {
			Show-InstallationPrompt -Message "$appNAME $appVER repair complete." -ButtonRightText 'OK' -Icon Information -NoWait
		}
	}
	##*===============================================
	##* END SCRIPT BODY
	##*===============================================

	If(($NoCache) -or (!($isWorkStationOS))){
		Write-Log -Message "Media was not cached."
	}
	Else{
		Remove-CacheMedia
	}
	# Run Software Inventory.  Note: MECM team says the HardwareInventory is used for ARP.
	If ($appINV -eq 'YES') {
		Write-Log -Message "Starting MECM inventory update process"
		Invoke-SCCMTask 'HardwareInventory'
	}
	Else {
		Write-Log -Message "Skipping MECM inventory update process" -Severity 2
	}
    ## Call the Exit-Script function to perform final cleanup operations
		# Check if REBOOTER is Alway or the reboot flaf was set and exit 3010
	If (($mainExitCode -eq 0) -and ($appREBOOTER -eq 'ALWAYS')) {
		$rebootExitCode = 3010
		Exit-Script -ExitCode $rebootExitCode
	}
	elseif (($mainExitCode -eq 0) -and ($installReboot -eq $true)) {
		$rebootExitCode = 3010
		Exit-Script -ExitCode $rebootExitCode
	}
	Else {
		Exit-Script -ExitCode $mainExitCode
	}
}
Catch {
    [Int32]$mainExitCode = 60001
    [String]$mainErrorMessage = "$(Resolve-Error)"
    Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
    Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
    Exit-Script -ExitCode $mainExitCode
}
