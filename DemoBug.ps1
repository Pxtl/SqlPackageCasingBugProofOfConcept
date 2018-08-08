#run this to demonstrate the bug
#it will build the SSDT packages, deploy them to local server
#and run queries demonstrating how ignoring case-changes can
#have bad effects

Param(
    $sqlPackageFileName = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\140\SqlPackage.exe", #path to SqlPackage on your machine
    $sqlServer = "."
)

Install-Module -Name Invoke-MsBuild -Force

Push-Location $PSScriptRoot
    #look at it
    Write-Host "before view:"
    Get-Content ".\BugDemoDatabaseBefore\dbo\Views\DateBugDemoView.sql" | Write-Host
   
    #build it
    $null = Invoke-MsBuild .\BugDemoDatabaseBefore\BugDemoDatabase.sqlproj -MsBuildParameters "/target:Clean;Build"
    $null = Invoke-MsBuild .\BugDemoDatabaseBefore\BugDemoDatabase.sqlproj
    
    #deploy it to local server
    & $sqlPackageFileName /SourceFile:".\BugDemoDatabaseBefore\bin\Debug\BugDemoDatabase.dacpac" `
            /TargetServerName:$sqlServer `
            /targetdatabasename:BugDemoDatabase `
            /Action:Publish `
            /p:BlockOnPossibleDataLoss=False `
            /p:BlockWhenDriftDetected=False `
            /p:GenerateSmartDefaults=True `
            /p:IgnoreAnsiNulls=True `
            /p:IgnoreQuotedIdentifiers=True `

    #query it out so we can see it
    Invoke-SqlCmd -ServerInstance "." -Query "SELECT * FROM BugDemoDatabase.dbo.DateBugDemoView" | Out-String
    Invoke-SqlCmd -ServerInstance "." -Query "SELECT * FROM BugDemoDatabase.dbo.UnrelatedView" | Out-String

    Write-Host "after view:"
    Get-Content ".\BugDemoDatabaseAfter\dbo\Views\DateBugDemoView.sql" | Write-Host
    
    #build the after package
    $null = Invoke-MsBuild .\BugDemoDatabaseAfter\BugDemoDatabase.sqlproj -MsBuildParameters "/target:Clean;Build"
    $null = Invoke-MsBuild .\BugDemoDatabaseAfter\BugDemoDatabase.sqlproj

    #deploy it to local database
    $null = & $sqlPackageFileName /SourceFile:".\BugDemoDatabaseAfter\bin\Debug\BugDemoDatabase.dacpac" `
            /TargetServerName:$sqlServer `
            /targetdatabasename:BugDemoDatabase `
            /Action:Publish `
            /p:BlockOnPossibleDataLoss=False `
            /p:BlockWhenDriftDetected=False `
            /p:GenerateSmartDefaults=True `
            /p:IgnoreAnsiNulls=True `
            /p:IgnoreQuotedIdentifiers=True `

    Write-Host "Notice how nothing has changed:" 
    Invoke-SqlCmd -ServerInstance "." -Query "SELECT * FROM BugDemoDatabase.dbo.DateBugDemoView" | Out-String
    Invoke-SqlCmd -ServerInstance "." -Query "SELECT * FROM BugDemoDatabase.dbo.UnrelatedView" | Out-String


Pop-Location