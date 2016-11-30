<#
    .SYNOPSIS

    this script creates customer folder structure from template structure 

    .DESCRIPTION
    with this script users with special permission can automatically create a specified folder structure (also with specified permissions) 



    .EXAMPLE
    - .\template-creation-0-1.ps1 


    .Notes
    - first popup you need to define the folder name where the templates are copied. After this you can browse to the folder where you want to create the named folder within templates
    Do not create an folder on your own and choose this one. This script will do it for you.  


  
    ---------------------------------------------------------------------------------
                                                                                 
    Script:       template-creation-0-1.ps1                                     
    Author:       A. Koehler; blog.it-koehler.com
    ModifyDate:   30/11/2016                                                        
    Usage:        
    Version:      0.1
                                                                                  
    ---------------------------------------------------------------------------------
#>


##################################################### variables to define 
#script writes logs to this folder
$logpath = "C:\temp\copy_customertemplate_"

#template folder (the content from this folder will be copied)
$sourcepath = "C:\files\template"

#define the path where explorer browsing starts (important for checking if the user has  selected a folder, if you irgnore this you may overwrite lots of folders)
$startexplorerbrowsing = "C:\files\"


##################################################### beginnig of the script

#find date and convert to string
$date=((Get-Date).ToString('yyyy-MM-dd-HH-mm-ss'))
#find date and convert to string(only date)
$datelog = ((Get-Date).ToString('dd-MM-yyyy'))
#find date and convert to string (only time)
$timelog = ((Get-Date).ToString('HH-mm-ss'))
#defines the path where to find the log file of this script
$Logfile = $logpath+$date+".log"


#convert date and time to string
$date=((Get-Date).ToString('yyyy-MM-dd-HH-mm-ss'))
$datelog = ((Get-Date).ToString('dd-MM-yyyy'))
$timelog = ((Get-Date).ToString('HH-mm-ss'))

Function Write-Log
{
  Param ([string]$logstring)

  Add-content $Logfile -value $logstring
}

Write-Log "#####################################################################"
Write-Log "#                                                                   #"
Write-Log "#         written by a.koehler blog.it-koehler.com                  #"
Write-Log "#         foldercreation started  $datelog    $timelog            #"
Write-Log "#                                                                   #"
Write-Log "#####################################################################"

#dialog box folder name
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form 
$form.Text = "Define foldername"
$form.Size = New-Object System.Drawing.Size(300,200) 
$form.StartPosition = "CenterScreen"

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20) 
$label.Size = New-Object System.Drawing.Size(280,20) 
$label.Text = "Please enter the name of the folder:"
$form.Controls.Add($label) 

$textBox = New-Object System.Windows.Forms.TextBox 
$textBox.Location = New-Object System.Drawing.Point(10,40) 
$textBox.Size = New-Object System.Drawing.Size(260,20) 
$form.Controls.Add($textBox) 

$form.Topmost = $True

$form.Add_Shown({$textBox.Select()})
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $foldername = $textBox.Text
    $foldername
}
#check if there was an input from user
if (!$foldername)
{
  Write-Log "No Foldername defined, nothing was done!"
  exit
}


#start explorer dialog for folderbrowsing

Add-Type -AssemblyName System.Windows.Forms
  $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
    SelectedPath = $startexplorerbrowsing
  }
  [void]$FolderBrowser.ShowDialog()

$destinationpath = ($FolderBrowser).SelectedPath

#check if the user has selected something (not the original path)
if ($destinationpath -eq $startexplorerbrowsing)
{
  Write-Log "No path was selected by user"
  exit
}
#check if the user selected the template folder  
if ($destinationpath -eq $sourcepath)
{
  Write-Log "Templatefolder was selected, this is not possible"
  exit
}

#check if sourcepath exists
if( -not (Test-Path ($sourcepath)) )
{
   Throw (Write-Log "Sourcefolder not found!")
}

#if it exists create new folder inside
else {
  #check numbers of folders and files in source
  $folderstemplate = Get-ChildItem $sourcepath | Where {$_.PsIsContainer}
  $filestemplate = Get-ChildItem $sourcepath | Where {!$_.PsIsContainer}
  $templatefoldernumber = $folderstemplate | Measure-Object
  $templatefoldernumbers = ($templatefoldernumber).Count
  $templatefilenumber = $filestemplate | Measure-Object
  $templatefilenumbers = ($templatefilenumber).Count
  
  Write-Log   "$templatefoldernumbers folder/s and $templatefilenumbers file/s will be copied from template"
  $projectpath = ($destinationpath+"\"+$foldername)
    #generate folder in selected path  
    New-Item -Path  ($projectpath) -type directory -Force      
         
        if (-not (Test-Path ($projectpath))){
          Write-Log "Error, file $projectpath not created!"
        }
        else{
          Write-Log "Folder $projectpath created!"
          #folders will be copied via robocopy and paste output to logfile
          robocopy $sourcepath $projectpath /sec /mir /NFL /NDL /NP | Out-File -FilePath $Logfile -encoding utf8 -append
          #check numbers of folders and files in destination
          $foldersprojectpath = Get-ChildItem $projectpath | Where {$_.PsIsContainer}
          $foldernumberprojectpath = $foldersprojectpath | Measure-Object 
          $foldernumbersprojectpath = ($foldernumberprojectpath).Count
          $filesprojectpath = Get-ChildItem $projectpath | Where {!$_.PsIsContainer}
          $filesnumberprojectpath = $filesprojectpath | Measure-Object 
          $filesnumbersprojectpath = ($filesnumberprojectpath).Count 
          
          Write-Log "$foldernumbersprojectpath folder/s and $filesnumbersprojectpath files created successfully! "
          
          
        }
        
        
        
      }
