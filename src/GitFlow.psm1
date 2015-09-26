# https://github.com/nvie/gitflow/wiki/Command-Line-Arguments

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'GitHub.psm1')
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Solution.psm1')

function Initialize-GitFlow {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory = $true, Position = 0)]
		[Solution] $Solution
	)
	Process
	{				
		Push-Location -Path $Path
		git flow init -fd
		Pop-Location
	}
}

Function Start-Feature 
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory = $true)]
		[PSCustomObject] $Solution
 	)
	
	DynamicParam 
	{
        $Owner = $Solution.GitHubRepository.Owner.Login
        $RepositoryName = $Solution.GitHubRepository.Name

        $GitHubIssues = Get-GitHubIssue -Owner $Owner -RepositoryName $RepositoryName | Select-Object -ExpandProperty Number

		$ValidatedDynamicParameter = New-ValidatedDynamicParameter -ParameterName 'GitHubIssue' -ValidateSet $GitHubIssues

        $RuntimeDefinedParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $RuntimeDefinedParameterDictionary.Add('GitHubIssue', $ValidatedDynamicParameter)
	
		return $RuntimeDefinedParameterDictionary
    }
    Begin 
    {
        # Bind the parameter to a friendly variable
        $GitHubIssue = $PsBoundParameters['GitHubIssue']
    }
    Process
    {
        git flow feature start -F $GitHubIssue
    }
}

Function Finish-Feature   
{
	[CmdletBinding()]
	Param
	(
		
 	)
	DynamicParam 
	{
        $Features = Get-Features

		$ValidatedDynamicParameter = New-ValidatedDynamicParameter -ParameterName 'Feature' -ValidateSet $Features

        $RuntimeDefinedParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $RuntimeDefinedParameterDictionary.Add('Feature', $ValidatedDynamicParameter)
	
		return $RuntimeDefinedParameterDictionary
    }
    Begin
    {
        $Feature = $PSBoundParameters['Feature']
    }
	Process	
	{
        
		git flow feature finish -rFS $Feature
	}	
}

Function Get-Features
{
	[OutputType([string[]])]
	[CmdletBinding()]
	Param()

	Process	
	{
		git flow feature | Select-Object -Property @{'Name' = 'Feature'; 'Expression' = {$_.Replace("* ", '').Trim()}} | Select-Object -ExpandProperty Feature
	}
}

Function New-ValidatedDynamicParameter
{
	[OutputType([System.Management.Automation.RuntimeDefinedParameter])]
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory = $true)]
		[String]$ParameterName,
		[Parameter(Mandatory = $true)]
		[string[]] $ValidateSet
 	)
	Process
	{		
		# Create the dictionary 
		$RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

		# Create the collection of attributes
		$AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
		
		# Create and set the parameters' attributes
		$ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
		$ParameterAttribute.Mandatory = $true
		$ParameterAttribute.Position = 1

		# Add the attributes to the attributes collection
		$AttributeCollection.Add($ParameterAttribute)

		# Generate and set the ValidateSet 
		$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($ValidateSet)

		# Add the ValidateSet to the attributes collection
		$AttributeCollection.Add($ValidateSetAttribute)

		# Create and return the dynamic parameter
		$RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
		$RuntimeParameter
	}
}