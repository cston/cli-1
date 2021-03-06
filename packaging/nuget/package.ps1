# Copyright (c) .NET Foundation and contributors. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

param(
    [string]$toolsDir = $(throw "Specify the full path to the directory which has dotnet tool"),
    [string]$versionSuffix = ""
)

# unify trailing backslash
$toolsDir = $toolsDir.TrimEnd('\')
$versionArg = ""
if ($versionSuffix -ne "") {
    $versionArg = "--version-suffix $VersionSuffix"
}

. "$PSScriptRoot\..\..\scripts\_common.ps1"

$IntermediatePackagesDir = "$RepoRoot\artifacts\packages\intermediate"
$PackagesDir = "$RepoRoot\artifacts\packages"

New-Item -ItemType Directory -Force -Path $IntermediatePackagesDir

$Projects = @(
    "Microsoft.DotNet.Cli.Utils",
    "Microsoft.DotNet.ProjectModel",
    "Microsoft.DotNet.ProjectModel.Workspaces",
    "Microsoft.DotNet.Runtime",
    "Microsoft.Extensions.Testing.Abstractions"
)

foreach ($ProjectName in $Projects) {
    $ProjectFile = "$RepoRoot\src\$ProjectName\project.json"
    & $toolsDir\dotnet restore "$ProjectFile"
    if (!$?) {
        Write-Host "$toolsDir\dotnet restore failed for: $ProjectFile"
        Exit 1
    }
    & $toolsDir\dotnet pack "$ProjectFile" --output "$IntermediatePackagesDir" $versionArg
    if (!$?) {
        Write-Host "$toolsDir\dotnet pack failed for: $ProjectFile"
        Exit 1
    }
}

Get-ChildItem $IntermediatePackagesDir -Filter *.nupkg | Copy-Item -Destination $PackagesDir
