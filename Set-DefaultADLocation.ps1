function Set-DefaultADLocation {
    #
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
    #
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory, 
                   Position=0)]
        [ValidateSet(User, Computer)]
        $ObjectClass,

        # Param2 help description
        [Parameter(Mandatory,
                    Position=1)]
        [string]
        $NewOUPath
    )

    Begin
    {
        Write-Verbose FUNCTION -- Set-DefaultADLocation -- START

        Write-Verbose Initialising Check variable
        $Check = 0

        try {
            $ADRootDSE = Get-ADRootDSE
        }
        catch {
            Write-Verbose Unable to get Directory Server information tree
            $Check = 1
            return
        }

        try {
            Write-Verbose Retreving current default path of WellKnownObjects
            $WellKnownObjects = Get-ADObject -Identity $ADRootDSE.defaultNamingContext -Properties wellKnownObjects  Select-Object -ExpandProperty wellKnownObjects
        }
        catch {
            Write-Verbose Unable to retrive WellKnownObjects from domain  $($ADRootDSE.defaultNamingContext)
            $Check = 1
            return
        }
    }
    Process
    {
        Write-Verbose 'Checking Prerequisits'
        if ($Check -eq 1) {
            Write-Verbose Prerequisits FAILED -- Unable to run process
            return
        }

        switch ($ObjectClass) {
            
            'User'{
                Write-Verbose Retreving Users contaner default value from WellKnownObjects
                $DefaultContainer = $WellKnownObjects  Where-Object {$_ -like 'CN=Users,'}
            }
            'Computer'{
                Write-Verbose Retreving Computers contaner default value from WellKnownObjects
                $DefaultContainer = $WellKnownObjects  Where-Object {$_ -like 'CN=Computers,'}
            }
        }

        if($null -eq $DefaultContainer){

            Write-Verbose Unable to find DEFAULT location for objectclass  $($ObjectClass)
            Write-Verbose CHECK - If default settings have not already been changed
            return
        }
        else{

            Write-Verbose Building new value for ObjectClass  $($ObjectClass)
            $Array = $DefaultContainer.Split()
            $NewDefaultContainer = ($($Array[0])$($Array[1])$($Array[2])$($NewOUPath))


            Write-Verbose Changing default value  $($DefaultContainer) to NEW value $($NewDefaultContainer)
            if ($pscmdlet.ShouldProcess($($ADRootDSE.defaultNamingContext), Set-ADObject)) {

                Set-ADObject $ADRootDSE.defaultNamingContext -Add @{WellKnownObjects = $NewDefaultContainer} -Remove @{WellKnownObjects = $DefaultContainer} -Server (Get-ADDomainController).Name
            }
        }
    }
    End
    {
        Write-Verbose FUNCTION -- Set-DefaultADLocation -- END
    }
}