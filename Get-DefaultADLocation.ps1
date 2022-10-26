function Get-DefaultADLocation {
    <#
    .Synopsis
       Short description
    .DESCRIPTION
       Long description
    .EXAMPLE
       Example of how to use this cmdlet
    .EXAMPLE
       Another example of how to use this cmdlet
    .INPUTS
       Inputs to this cmdlet (if any)
    .OUTPUTS
       Output from this cmdlet (if any)
    .NOTES
       General notes
    .COMPONENT
       The component this cmdlet belongs to
    .ROLE
       The role this cmdlet belongs to
    .FUNCTIONALITY
       The functionality that best describes this cmdlet
    #>
    [CmdletBinding()]
    Param
    ()

    Begin
    {
        Write-Verbose "FUNCTION -- Get-DefaultADLocation -- START"
        
    }
    Process
    {
       try {
            $ADRootDSE = Get-ADRootDSE
        }
        catch {
            Write-Verbose "Unable to get Directory Server information tree"
            return 1
        }

        try {
            Write-Verbose "Retreving current default path of WellKnownObjects"
            Get-ADObject -Identity $ADRootDSE.defaultNamingContext -Properties wellKnownObjects | Select-Object -ExpandProperty wellKnownObjects
        }
        catch {
            Write-Verbose "Unable to retrive WellKnownObjects from domain : $($ADRootDSE.defaultNamingContext)"
            return 1
        }
    }
    End
    {
        Write-Verbose "FUNCTION -- Get-DefaultADLocation -- END"
    }
}