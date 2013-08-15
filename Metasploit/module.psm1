﻿# Modules
#########################################################################################

#region module

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-MetasploitModuleStats
{
    [CmdletBinding(DefaultParameterSetName = 'Index')]
    param(

        # Metasploit session index
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=0)]
        [int32[]]$Index = @(),

        # Metasploit session object
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        ValueFromPipeline=$true,
        Position=0)]
        [psobject]$Session
       
    )
    BEGIN 
    {
        
    }
    PROCESS 
    {    
        if ($Index.Count -gt 0)
        {
            foreach($conn in $Global:MetasploitConn)
            {
                if ($conn.index -in $Index)
                {
                    $MSession = $conn
                }
            }
        }
        elseif ($Session -ne $null -and $Session.pstypenames[0] -eq "Metasploit.Session")
        {
            if ($Global:MetasploitConn.Contains($Session))
            {
                $MSession = $Session
            }
            else
            {
                throw "The session object that was passed does not exists in `$Global:MetasploitConn"
            }
        }
        else 
        {
            throw "No Metasploit server session was provided"
        }

        if ($MSession -eq $null)
        {
            throw "Specified session was not found"
        }
        
        $request_reply = $MSession.Manager.GetCoreModuleStats()

        if ($request_reply.ContainsKey("error_code"))
        {
            if ($request_reply.error_code -eq 401)
            {
                write-verbose "The session has expired, Re-authenticating"

                $SessionProps = New-Object System.Collections.Specialized.OrderedDictionary
                $sessparams   = $MSession.Credentials.GetNetworkCredential().UserName,$MSession.Credentials.GetNetworkCredential().Password,$MSession.URI
                $msfsess = New-Object metasploitsharp.MetasploitSession -ArgumentList $sessparams
                if ($msfsess)
                {
                    Write-Verbose "Authentication successful."
                    # Select the correct session manager for the existing session
                    if ($MSession.Manager.GetType().tostring() -eq 'metasploitsharp.MetasploitManager')
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitManager -ArgumentList $msfsess
                    }
                    else
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitProManager -ArgumentList $msfsess
                    }

                    # Build the session object
                    $SessionProps.Add('Manager',$msfmng)
                    $SessionProps.Add('URI',$MSession.URI)
                    $SessionProps.add('Host',$MSession.host)
                    $SessionProps.add('Session',$msfsess)
                    $SessionProps.Add('Credentials',$MSession.Credentials)
                    $SessionProps.Add('Index', $MSession.index)
                    $sessionobj = New-Object -TypeName psobject -Property $SessionProps
                    $sessionobj.pstypenames[0] = "Metasploit.Session"

                    # Update the session with the new information
                    Write-Verbose "Updating session with new authentication token"
                    [void]$Global:MetasploitConn.Remove($MSession)
                    [void]$Global:MetasploitConn.Add($sessionobj)

                    # Get again the information
                    $request_reply = $sessionobj.Manager.GetCoreModuleStats()
                    if ($request_reply.ContainsKey('post'))
                    {
                        $request_reply.add('MSHost', $MSession.Host)
                        $consoleobj = New-Object -TypeName psobject -Property $request_reply
                        $consoleobj.pstypenames[0] = "Metasploit.Module.Stats"
                        $consoleobj   
                    }
                }
            }
        }
        else
        {
            if ($request_reply.ContainsKey('post'))
            {
                $request_reply.add('MSHost', $MSession.Host)
                $consoleobj = New-Object -TypeName psobject -Property $request_reply
                $consoleobj.pstypenames[0] = "Metasploit.Module.Stats"
                $consoleobj   
            }
        }
    }
}


<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Invoke-MetasploitModuleReload
{
    [CmdletBinding(DefaultParameterSetName = 'Index')]
    param(

        # Metasploit session index
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=0)]
        [int32[]]$Index = @(),

        # Metasploit session object
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        ValueFromPipeline=$true,
        Position=0)]
        [psobject]$Session
       
    )
    BEGIN 
    {
        
    }
    PROCESS 
    {    
        if ($Index.Count -gt 0)
        {
            foreach($conn in $Global:MetasploitConn)
            {
                if ($conn.index -in $Index)
                {
                    $MSession = $conn
                }
            }
        }
        elseif ($Session -ne $null -and $Session.pstypenames[0] -eq "Metasploit.Session")
        {
            if ($Global:MetasploitConn.Contains($Session))
            {
                $MSession = $Session
            }
            else
            {
                throw "The session object that was passed does not exists in `$Global:MetasploitConn"
            }
        }
        else 
        {
            throw "No Metasploit server session was provided"
        }

        if ($MSession -eq $null)
        {
            throw "Specified session was not found"
        }
        
        $request_reply = $MSession.Manager.ReloadCoreModules()

        if ($request_reply.ContainsKey("error_code"))
        {
            if ($request_reply.error_code -eq 401)
            {
                write-verbose "The session has expired, Re-authenticating"

                $SessionProps = New-Object System.Collections.Specialized.OrderedDictionary
                $sessparams   = $MSession.Credentials.GetNetworkCredential().UserName,$MSession.Credentials.GetNetworkCredential().Password,$MSession.URI
                $msfsess = New-Object metasploitsharp.MetasploitSession -ArgumentList $sessparams
                if ($msfsess)
                {
                    Write-Verbose "Authentication successful."
                    # Select the correct session manager for the existing session
                    if ($MSession.Manager.GetType().tostring() -eq 'metasploitsharp.MetasploitManager')
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitManager -ArgumentList $msfsess
                    }
                    else
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitProManager -ArgumentList $msfsess
                    }

                    # Build the session object
                    $SessionProps.Add('Manager',$msfmng)
                    $SessionProps.Add('URI',$MSession.URI)
                    $SessionProps.add('Host',$MSession.host)
                    $SessionProps.add('Session',$msfsess)
                    $SessionProps.Add('Credentials',$MSession.Credentials)
                    $SessionProps.Add('Index', $MSession.index)
                    $sessionobj = New-Object -TypeName psobject -Property $SessionProps
                    $sessionobj.pstypenames[0] = "Metasploit.Session"

                    # Update the session with the new information
                    Write-Verbose "Updating session with new authentication token"
                    [void]$Global:MetasploitConn.Remove($MSession)
                    [void]$Global:MetasploitConn.Add($sessionobj)

                    # Get again the information
                    $request_reply = $sessionobj.Manager.ReloadCoreModules()
                    if ($request_reply.ContainsKey('post'))
                    {
                        $request_reply.add('MSHost', $MSession.Host)
                        $consoleobj = New-Object -TypeName psobject -Property $request_reply
                        $consoleobj.pstypenames[0] = "Metasploit.Module.Stats"
                        $consoleobj   
                    }
                }
            }
        }
        else
        {
            if ($request_reply.ContainsKey('post'))
            {
                $request_reply.add('MSHost', $MSession.Host)
                $consoleobj = New-Object -TypeName psobject -Property $request_reply
                $consoleobj.pstypenames[0] = "Metasploit.Module.Stats"
                $consoleobj   
            }
        }
    }
}

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-MetasploitAuxiliaryModule
{
    [CmdletBinding(DefaultParameterSetName = 'Index')]
    param(

        # Metasploit session index
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=0)]
        [int32[]]$Index = @(),

        # Metasploit session object
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        ValueFromPipeline=$true,
        Position=0)]
        [psobject]$Session
       
    )
    BEGIN 
    {
        
    }
    PROCESS 
    {    
        if ($Index.Count -gt 0)
        {
            foreach($conn in $Global:MetasploitConn)
            {
                if ($conn.index -in $Index)
                {
                    $MSession = $conn
                }
            }
        }
        elseif ($Session -ne $null -and $Session.pstypenames[0] -eq "Metasploit.Session")
        {
            if ($Global:MetasploitConn.Contains($Session))
            {
                $MSession = $Session
            }
            else
            {
                throw "The session object that was passed does not exists in `$Global:MetasploitConn"
            }
        }
        else 
        {
            throw "No Metasploit server session was provided"
        }

        if ($MSession -eq $null)
        {
            throw "Specified session was not found"
        }
        
        $request_reply = $MSession.Manager.GetAuxiliaryModules()

        if ($request_reply.ContainsKey("error_code"))
        {
            if ($request_reply.error_code -eq 401)
            {
                write-verbose "The session has expired, Re-authenticating"

                $SessionProps = New-Object System.Collections.Specialized.OrderedDictionary
                $sessparams   = $MSession.Credentials.GetNetworkCredential().UserName,$MSession.Credentials.GetNetworkCredential().Password,$MSession.URI
                $msfsess = New-Object metasploitsharp.MetasploitSession -ArgumentList $sessparams
                if ($msfsess)
                {
                    Write-Verbose "Authentication successful."
                    # Select the correct session manager for the existing session
                    if ($MSession.Manager.GetType().tostring() -eq 'metasploitsharp.MetasploitManager')
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitManager -ArgumentList $msfsess
                    }
                    else
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitProManager -ArgumentList $msfsess
                    }

                    # Build the session object
                    $SessionProps.Add('Manager',$msfmng)
                    $SessionProps.Add('URI',$MSession.URI)
                    $SessionProps.add('Host',$MSession.host)
                    $SessionProps.add('Session',$msfsess)
                    $SessionProps.Add('Credentials',$MSession.Credentials)
                    $SessionProps.Add('Index', $MSession.index)
                    $sessionobj = New-Object -TypeName psobject -Property $SessionProps
                    $sessionobj.pstypenames[0] = "Metasploit.Session"

                    # Update the session with the new information
                    Write-Verbose "Updating session with new authentication token"
                    [void]$Global:MetasploitConn.Remove($MSession)
                    [void]$Global:MetasploitConn.Add($sessionobj)

                    # Get again the information
                    $request_reply = $sessionobj.Manager.GetAuxiliaryModules()
                    if ($request_reply.ContainsKey('modules'))
                    {
                        foreach ($module in $request_reply['modules'])
                        {
                            $moduleprops = @{}
                            $moduleprops.add('MSHost', $MSession.Host)
                            $moduleprops.Add('Name', $module)
                            $consoleobj = New-Object -TypeName psobject -Property $moduleprops
                            $consoleobj.pstypenames[0] = "Metasploit.Module.auxiliary"
                            $consoleobj
                        }   
                    }
                }
            }
        }
        else
        {
            if ($request_reply.ContainsKey('modules'))
            {
                foreach ($module in $request_reply['modules'])
                {
                    $moduleprops = @{}
                    $moduleprops.add('MSHost', $MSession.Host)
                    $moduleprops.Add('Name', $module)
                    $consoleobj = New-Object -TypeName psobject -Property $moduleprops
                    $consoleobj.pstypenames[0] = "Metasploit.Module.auxiliary"
                    $consoleobj
                }   
            }
        }
    }
}


<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-MetasploitPostModule
{
    [CmdletBinding(DefaultParameterSetName = 'Index')]
    param(

        # Metasploit session index
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=0)]
        [int32[]]$Index = @(),

        # Metasploit session object
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        ValueFromPipeline=$true,
        Position=0)]
        [psobject]$Session
       
    )
    BEGIN 
    {
        
    }
    PROCESS 
    {    
        if ($Index.Count -gt 0)
        {
            foreach($conn in $Global:MetasploitConn)
            {
                if ($conn.index -in $Index)
                {
                    $MSession = $conn
                }
            }
        }
        elseif ($Session -ne $null -and $Session.pstypenames[0] -eq "Metasploit.Session")
        {
            if ($Global:MetasploitConn.Contains($Session))
            {
                $MSession = $Session
            }
            else
            {
                throw "The session object that was passed does not exists in `$Global:MetasploitConn"
            }
        }
        else 
        {
            throw "No Metasploit server session was provided"
        }

        if ($MSession -eq $null)
        {
            throw "Specified session was not found"
        }
        
        $request_reply = $MSession.Manager.GetPostModules()

        if ($request_reply.ContainsKey("error_code"))
        {
            if ($request_reply.error_code -eq 401)
            {
                write-verbose "The session has expired, Re-authenticating"

                $SessionProps = New-Object System.Collections.Specialized.OrderedDictionary
                $sessparams   = $MSession.Credentials.GetNetworkCredential().UserName,$MSession.Credentials.GetNetworkCredential().Password,$MSession.URI
                $msfsess = New-Object metasploitsharp.MetasploitSession -ArgumentList $sessparams
                if ($msfsess)
                {
                    Write-Verbose "Authentication successful."
                    # Select the correct session manager for the existing session
                    if ($MSession.Manager.GetType().tostring() -eq 'metasploitsharp.MetasploitManager')
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitManager -ArgumentList $msfsess
                    }
                    else
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitProManager -ArgumentList $msfsess
                    }

                    # Build the session object
                    $SessionProps.Add('Manager',$msfmng)
                    $SessionProps.Add('URI',$MSession.URI)
                    $SessionProps.add('Host',$MSession.host)
                    $SessionProps.add('Session',$msfsess)
                    $SessionProps.Add('Credentials',$MSession.Credentials)
                    $SessionProps.Add('Index', $MSession.index)
                    $sessionobj = New-Object -TypeName psobject -Property $SessionProps
                    $sessionobj.pstypenames[0] = "Metasploit.Session"

                    # Update the session with the new information
                    Write-Verbose "Updating session with new authentication token"
                    [void]$Global:MetasploitConn.Remove($MSession)
                    [void]$Global:MetasploitConn.Add($sessionobj)

                    # Get again the information
                    $request_reply = $sessionobj.Manager.GetPostModules()
                    if ($request_reply.ContainsKey('modules'))
                    {
                        foreach ($module in $request_reply['modules'])
                        {
                            $moduleprops = @{}
                            $moduleprops.add('MSHost', $MSession.Host)
                            $moduleprops.Add('Name', $module)
                            $consoleobj = New-Object -TypeName psobject -Property $moduleprops
                            $consoleobj.pstypenames[0] = "Metasploit.Module.post"
                            $consoleobj
                        }   
                    }
                }
            }
        }
        else
        {
            if ($request_reply.ContainsKey('modules'))
            {
                foreach ($module in $request_reply['modules'])
                {
                    $moduleprops = @{}
                    $moduleprops.add('MSHost', $MSession.Host)
                    $moduleprops.Add('Name', $module)
                    $consoleobj = New-Object -TypeName psobject -Property $moduleprops
                    $consoleobj.pstypenames[0] = "Metasploit.Module.post"
                    $consoleobj
                }   
            }
        }
    }
}


<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-MetasploitExploitModule
{
    [CmdletBinding(DefaultParameterSetName = 'Index')]
    param(

        # Metasploit session index
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=0)]
        [int32[]]$Index = @(),

        # Metasploit session object
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        ValueFromPipeline=$true,
        Position=0)]
        [psobject]$Session
       
    )
    BEGIN 
    {
        
    }
    PROCESS 
    {    
        if ($Index.Count -gt 0)
        {
            foreach($conn in $Global:MetasploitConn)
            {
                if ($conn.index -in $Index)
                {
                    $MSession = $conn
                }
            }
        }
        elseif ($Session -ne $null -and $Session.pstypenames[0] -eq "Metasploit.Session")
        {
            if ($Global:MetasploitConn.Contains($Session))
            {
                $MSession = $Session
            }
            else
            {
                throw "The session object that was passed does not exists in `$Global:MetasploitConn"
            }
        }
        else 
        {
            throw "No Metasploit server session was provided"
        }

        if ($MSession -eq $null)
        {
            throw "Specified session was not found"
        }
        
        $request_reply = $MSession.Manager.GetExploitModules()

        if ($request_reply.ContainsKey("error_code"))
        {
            if ($request_reply.error_code -eq 401)
            {
                write-verbose "The session has expired, Re-authenticating"

                $SessionProps = New-Object System.Collections.Specialized.OrderedDictionary
                $sessparams   = $MSession.Credentials.GetNetworkCredential().UserName,$MSession.Credentials.GetNetworkCredential().Password,$MSession.URI
                $msfsess = New-Object metasploitsharp.MetasploitSession -ArgumentList $sessparams
                if ($msfsess)
                {
                    Write-Verbose "Authentication successful."
                    # Select the correct session manager for the existing session
                    if ($MSession.Manager.GetType().tostring() -eq 'metasploitsharp.MetasploitManager')
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitManager -ArgumentList $msfsess
                    }
                    else
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitProManager -ArgumentList $msfsess
                    }

                    # Build the session object
                    $SessionProps.Add('Manager',$msfmng)
                    $SessionProps.Add('URI',$MSession.URI)
                    $SessionProps.add('Host',$MSession.host)
                    $SessionProps.add('Session',$msfsess)
                    $SessionProps.Add('Credentials',$MSession.Credentials)
                    $SessionProps.Add('Index', $MSession.index)
                    $sessionobj = New-Object -TypeName psobject -Property $SessionProps
                    $sessionobj.pstypenames[0] = "Metasploit.Session"

                    # Update the session with the new information
                    Write-Verbose "Updating session with new authentication token"
                    [void]$Global:MetasploitConn.Remove($MSession)
                    [void]$Global:MetasploitConn.Add($sessionobj)

                    # Get again the information
                    $request_reply = $sessionobj.Manager.GetExploitModules()
                    if ($request_reply.ContainsKey('modules'))
                    {
                        foreach ($module in $request_reply['modules'])
                        {
                            $moduleprops = @{}
                            $moduleprops.add('MSHost', $MSession.Host)
                            $moduleprops.Add('Name', $module)
                            $consoleobj = New-Object -TypeName psobject -Property $moduleprops
                            $consoleobj.pstypenames[0] = "Metasploit.Module.exploit"
                            $consoleobj
                        }   
                    }
                }
            }
        }
        else
        {
            if ($request_reply.ContainsKey('modules'))
            {
                foreach ($module in $request_reply['modules'])
                {
                    $moduleprops = @{}
                    $moduleprops.add('MSHost', $MSession.Host)
                    $moduleprops.Add('Name', $module)
                    $consoleobj = New-Object -TypeName psobject -Property $moduleprops
                    $consoleobj.pstypenames[0] = "Metasploit.Module.exploit"
                    $consoleobj
                }   
            }
        }
    }
}

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-MetasploitPayloadModule
{
    [CmdletBinding(DefaultParameterSetName = 'Index')]
    param(

        # Metasploit session index
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=0)]
        [int32[]]$Index = @(),

        # Metasploit session object
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        ValueFromPipeline=$true,
        Position=0)]
        [psobject]$Session
       
    )
    BEGIN 
    {
        
    }
    PROCESS 
    {    
        if ($Index.Count -gt 0)
        {
            foreach($conn in $Global:MetasploitConn)
            {
                if ($conn.index -in $Index)
                {
                    $MSession = $conn
                }
            }
        }
        elseif ($Session -ne $null -and $Session.pstypenames[0] -eq "Metasploit.Session")
        {
            if ($Global:MetasploitConn.Contains($Session))
            {
                $MSession = $Session
            }
            else
            {
                throw "The session object that was passed does not exists in `$Global:MetasploitConn"
            }
        }
        else 
        {
            throw "No Metasploit server session was provided"
        }

        if ($MSession -eq $null)
        {
            throw "Specified session was not found"
        }
        
        $request_reply = $MSession.Manager.GetPayloads()

        if ($request_reply.ContainsKey("error_code"))
        {
            if ($request_reply.error_code -eq 401)
            {
                write-verbose "The session has expired, Re-authenticating"

                $SessionProps = New-Object System.Collections.Specialized.OrderedDictionary
                $sessparams   = $MSession.Credentials.GetNetworkCredential().UserName,$MSession.Credentials.GetNetworkCredential().Password,$MSession.URI
                $msfsess = New-Object metasploitsharp.MetasploitSession -ArgumentList $sessparams
                if ($msfsess)
                {
                    Write-Verbose "Authentication successful."
                    # Select the correct session manager for the existing session
                    if ($MSession.Manager.GetType().tostring() -eq 'metasploitsharp.MetasploitManager')
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitManager -ArgumentList $msfsess
                    }
                    else
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitProManager -ArgumentList $msfsess
                    }

                    # Build the session object
                    $SessionProps.Add('Manager',$msfmng)
                    $SessionProps.Add('URI',$MSession.URI)
                    $SessionProps.add('Host',$MSession.host)
                    $SessionProps.add('Session',$msfsess)
                    $SessionProps.Add('Credentials',$MSession.Credentials)
                    $SessionProps.Add('Index', $MSession.index)
                    $sessionobj = New-Object -TypeName psobject -Property $SessionProps
                    $sessionobj.pstypenames[0] = "Metasploit.Session"

                    # Update the session with the new information
                    Write-Verbose "Updating session with new authentication token"
                    [void]$Global:MetasploitConn.Remove($MSession)
                    [void]$Global:MetasploitConn.Add($sessionobj)

                    # Get again the information
                    $request_reply = $sessionobj.Manager.GetPayloads()
                    if ($request_reply.ContainsKey('modules'))
                    {
                        foreach ($module in $request_reply['modules'])
                        {
                            $moduleprops = @{}
                            $moduleprops.add('MSHost', $MSession.Host)
                            $moduleprops.Add('Name', $module)
                            $consoleobj = New-Object -TypeName psobject -Property $moduleprops
                            $consoleobj.pstypenames[0] = "Metasploit.Module.payload"
                            $consoleobj
                        }   
                    }
                }
            }
        }
        else
        {
            if ($request_reply.ContainsKey('modules'))
            {
                foreach ($module in $request_reply['modules'])
                {
                    $moduleprops = @{}
                    $moduleprops.add('MSHost', $MSession.Host)
                    $moduleprops.Add('Name', $module)
                    $consoleobj = New-Object -TypeName psobject -Property $moduleprops
                    $consoleobj.pstypenames[0] = "Metasploit.Module.payload"
                    $consoleobj
                }   
            }
        }
    }
}

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-MetasploitNOPS
{
    [CmdletBinding(DefaultParameterSetName = 'Index')]
    param(

        # Metasploit session index
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=0)]
        [int32[]]$Index = @(),

        # Metasploit session object
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        ValueFromPipeline=$true,
        Position=0)]
        [psobject]$Session
       
    )
    BEGIN 
    {
        
    }
    PROCESS 
    {    
        if ($Index.Count -gt 0)
        {
            foreach($conn in $Global:MetasploitConn)
            {
                if ($conn.index -in $Index)
                {
                    $MSession = $conn
                }
            }
        }
        elseif ($Session -ne $null -and $Session.pstypenames[0] -eq "Metasploit.Session")
        {
            if ($Global:MetasploitConn.Contains($Session))
            {
                $MSession = $Session
            }
            else
            {
                throw "The session object that was passed does not exists in `$Global:MetasploitConn"
            }
        }
        else 
        {
            throw "No Metasploit server session was provided"
        }

        if ($MSession -eq $null)
        {
            throw "Specified session was not found"
        }
        
        $request_reply = $MSession.Manager.GetNops()

        if ($request_reply.ContainsKey("error_code"))
        {
            if ($request_reply.error_code -eq 401)
            {
                write-verbose "The session has expired, Re-authenticating"

                $SessionProps = New-Object System.Collections.Specialized.OrderedDictionary
                $sessparams   = $MSession.Credentials.GetNetworkCredential().UserName,$MSession.Credentials.GetNetworkCredential().Password,$MSession.URI
                $msfsess = New-Object metasploitsharp.MetasploitSession -ArgumentList $sessparams
                if ($msfsess)
                {
                    Write-Verbose "Authentication successful."
                    # Select the correct session manager for the existing session
                    if ($MSession.Manager.GetType().tostring() -eq 'metasploitsharp.MetasploitManager')
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitManager -ArgumentList $msfsess
                    }
                    else
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitProManager -ArgumentList $msfsess
                    }

                    # Build the session object
                    $SessionProps.Add('Manager',$msfmng)
                    $SessionProps.Add('URI',$MSession.URI)
                    $SessionProps.add('Host',$MSession.host)
                    $SessionProps.add('Session',$msfsess)
                    $SessionProps.Add('Credentials',$MSession.Credentials)
                    $SessionProps.Add('Index', $MSession.index)
                    $sessionobj = New-Object -TypeName psobject -Property $SessionProps
                    $sessionobj.pstypenames[0] = "Metasploit.Session"

                    # Update the session with the new information
                    Write-Verbose "Updating session with new authentication token"
                    [void]$Global:MetasploitConn.Remove($MSession)
                    [void]$Global:MetasploitConn.Add($sessionobj)

                    # Get again the information
                    $request_reply = $sessionobj.Manager.GetNops()
                    if ($request_reply.ContainsKey('modules'))
                    {
                        foreach ($module in $request_reply['modules'])
                        {
                            $moduleprops = @{}
                            $moduleprops.add('MSHost', $MSession.Host)
                            $moduleprops.Add('Name', $module)
                            $consoleobj = New-Object -TypeName psobject -Property $moduleprops
                            $consoleobj.pstypenames[0] = "Metasploit.Module.NOP"
                            $consoleobj
                        }   
                    }
                }
            }
        }
        else
        {
            if ($request_reply.ContainsKey('modules'))
            {
                foreach ($module in $request_reply['modules'])
                {
                    $moduleprops = @{}
                    $moduleprops.add('MSHost', $MSession.Host)
                    $moduleprops.Add('Name', $module)
                    $consoleobj = New-Object -TypeName psobject -Property $moduleprops
                    $consoleobj.pstypenames[0] = "Metasploit.Module.NOP"
                    $consoleobj
                }   
            }
        }
    }
}

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-MetasploitModuleInfo
{
    [CmdletBinding(DefaultParameterSetName = 'Index')]
    param(

        # Metasploit session index
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=0)]
        [int32[]]$Index = @(),

        # Metasploit session object
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        ValueFromPipeline=$true,
        Position=0)]
        [psobject]$Session,

        # Module name
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        Position=1)]
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=1)]
        [string]$Name,

        # Module Type
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        Position=2)]
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=2)]
        [ValidateSet('post','auxiliary','exploit', 'payload')]
        [string]$Type
       
    )
    BEGIN 
    {
        
    }
    PROCESS 
    {    
        if ($Index.Count -gt 0)
        {
            foreach($conn in $Global:MetasploitConn)
            {
                if ($conn.index -in $Index)
                {
                    $MSession = $conn
                }
            }
        }
        elseif ($Session -ne $null -and $Session.pstypenames[0] -eq "Metasploit.Session")
        {
            if ($Global:MetasploitConn.Contains($Session))
            {
                $MSession = $Session
            }
            else
            {
                throw "The session object that was passed does not exists in `$Global:MetasploitConn"
            }
        }
        else 
        {
            throw "No Metasploit server session was provided"
        }

        if ($MSession -eq $null)
        {
            throw "Specified session was not found"
        }
        
        Write-Verbose "Getting information for module $name of type $type."
        $request_reply = $MSession.Manager.GetModuleInformation($Type.ToLower(),$Name)

        if ($request_reply.ContainsKey("error_code"))
        {
            Write-Verbose "An error was reported with code $($request_reply.error_code)"
            if ($request_reply.error_code -eq 401)
            {
                write-verbose "The session has expired, Re-authenticating"

                $SessionProps = New-Object System.Collections.Specialized.OrderedDictionary
                $sessparams   = $MSession.Credentials.GetNetworkCredential().UserName,$MSession.Credentials.GetNetworkCredential().Password,$MSession.URI
                $msfsess = New-Object metasploitsharp.MetasploitSession -ArgumentList $sessparams
                if ($msfsess)
                {
                    Write-Verbose "Authentication successful."
                    # Select the correct session manager for the existing session
                    if ($MSession.Manager.GetType().tostring() -eq 'metasploitsharp.MetasploitManager')
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitManager -ArgumentList $msfsess
                    }
                    else
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitProManager -ArgumentList $msfsess
                    }

                    # Build the session object
                    $SessionProps.Add('Manager',$msfmng)
                    $SessionProps.Add('URI',$MSession.URI)
                    $SessionProps.add('Host',$MSession.host)
                    $SessionProps.add('Session',$msfsess)
                    $SessionProps.Add('Credentials',$MSession.Credentials)
                    $SessionProps.Add('Index', $MSession.index)
                    $sessionobj = New-Object -TypeName psobject -Property $SessionProps
                    $sessionobj.pstypenames[0] = "Metasploit.Session"

                    # Update the session with the new information
                    Write-Verbose "Updating session with new authentication token"
                    [void]$Global:MetasploitConn.Remove($MSession)
                    [void]$Global:MetasploitConn.Add($sessionobj)

                    # Get again the information
                    $request_reply = $sessionobj.Manager.GetModuleInformation($Type.ToLower(),$Name)
                    $request_reply
                    if ($request_reply.ContainsKey('name'))
                    {
                        $request_reply.add('MSHost', $MSession.Host)
                        $consoleobj = New-Object -TypeName psobject -Property $request_reply
                        $consoleobj.pstypenames[0] = "Metasploit.Module.Info"
                        $consoleobj 
                    }
                }
            }
        }
        else
        {
            if ($request_reply.ContainsKey('name'))
            {
                $request_reply.add('MSHost', $MSession.Host)
                $consoleobj = New-Object -TypeName psobject -Property $request_reply
                $consoleobj.pstypenames[0] = "Metasploit.Module.Info"
                $consoleobj
            }
        }
    }
}


<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-MetasploitExploitCompatiblePayloads
{
    [CmdletBinding(DefaultParameterSetName = 'Index')]
    param(

        # Metasploit session index
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=0)]
        [int32[]]$Index = @(),

        # Metasploit session object
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        ValueFromPipeline=$true,
        Position=0)]
        [psobject]$Session,

        # Exploit Module name
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        Position=1)]
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=1)]
        [string]$Name
    )
    BEGIN 
    {
        
    }
    PROCESS 
    {    
        if ($Index.Count -gt 0)
        {
            foreach($conn in $Global:MetasploitConn)
            {
                if ($conn.index -in $Index)
                {
                    $MSession = $conn
                }
            }
        }
        elseif ($Session -ne $null -and $Session.pstypenames[0] -eq "Metasploit.Session")
        {
            if ($Global:MetasploitConn.Contains($Session))
            {
                $MSession = $Session
            }
            else
            {
                throw "The session object that was passed does not exists in `$Global:MetasploitConn"
            }
        }
        else 
        {
            throw "No Metasploit server session was provided"
        }

        if ($MSession -eq $null)
        {
            throw "Specified session was not found"
        }
        
        $request_reply = $MSession.Manager.GetModuleCompatiblePayloads($Name)

        if ($request_reply.ContainsKey("error_code"))
        {
            Write-Verbose "An error was reported with code $($request_reply.error_code)"
            if ($request_reply.error_code -eq 401)
            {
                write-verbose "The session has expired, Re-authenticating"

                $SessionProps = New-Object System.Collections.Specialized.OrderedDictionary
                $sessparams   = $MSession.Credentials.GetNetworkCredential().UserName,$MSession.Credentials.GetNetworkCredential().Password,$MSession.URI
                $msfsess = New-Object metasploitsharp.MetasploitSession -ArgumentList $sessparams
                if ($msfsess)
                {
                    Write-Verbose "Authentication successful."
                    # Select the correct session manager for the existing session
                    if ($MSession.Manager.GetType().tostring() -eq 'metasploitsharp.MetasploitManager')
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitManager -ArgumentList $msfsess
                    }
                    else
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitProManager -ArgumentList $msfsess
                    }

                    # Build the session object
                    $SessionProps.Add('Manager',$msfmng)
                    $SessionProps.Add('URI',$MSession.URI)
                    $SessionProps.add('Host',$MSession.host)
                    $SessionProps.add('Session',$msfsess)
                    $SessionProps.Add('Credentials',$MSession.Credentials)
                    $SessionProps.Add('Index', $MSession.index)
                    $sessionobj = New-Object -TypeName psobject -Property $SessionProps
                    $sessionobj.pstypenames[0] = "Metasploit.Session"

                    # Update the session with the new information
                    Write-Verbose "Updating session with new authentication token"
                    [void]$Global:MetasploitConn.Remove($MSession)
                    [void]$Global:MetasploitConn.Add($sessionobj)

                    # Get again the information
                    $request_reply = $sessionobj.Manager.GetModuleCompatiblePayloads($Name)
                    $request_reply
                    if ($request_reply.ContainsKey('payloads'))
                    {
                        foreach ($payload in $request_reply['payloads'])
                        {
                            $moduleprops = @{}
                            $moduleprops.add('MSHost', $MSession.Host)
                            $moduleprops.Add('Name', $payload)
                            $consoleobj = New-Object -TypeName psobject -Property $moduleprops
                            $consoleobj.pstypenames[0] = "Metasploit.Module.payload"
                            $consoleobj
                        }  
                    }
                }
            }
        }
        else
        {
            if ($request_reply.ContainsKey('payloads'))
            {
                foreach ($payload in $request_reply['payloads'])
                {
                    $moduleprops = @{}
                    $moduleprops.add('MSHost', $MSession.Host)
                    $moduleprops.Add('Name', $payload)
                    $consoleobj = New-Object -TypeName psobject -Property $moduleprops
                    $consoleobj.pstypenames[0] = "Metasploit.Module.payload"
                    $consoleobj
                }  
            }
        }
    }
}


<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-MetasploitModuleOptions
{
    [CmdletBinding(DefaultParameterSetName = 'Index')]
    param(

        # Metasploit session index
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=0)]
        [int32[]]$Index = @(),

        # Metasploit session object
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        ValueFromPipeline=$true,
        Position=0)]
        [psobject]$Session,

        # Module name
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        Position=1)]
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=1)]
        [string]$Name,

        # Module Type
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        Position=2)]
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=2)]
        [ValidateSet('post','auxiliary','exploit', 'payload')]
        [string]$Type
       
    )
    BEGIN 
    {
        
    }
    PROCESS 
    {    
        if ($Index.Count -gt 0)
        {
            foreach($conn in $Global:MetasploitConn)
            {
                if ($conn.index -in $Index)
                {
                    $MSession = $conn
                }
            }
        }
        elseif ($Session -ne $null -and $Session.pstypenames[0] -eq "Metasploit.Session")
        {
            if ($Global:MetasploitConn.Contains($Session))
            {
                $MSession = $Session
            }
            else
            {
                throw "The session object that was passed does not exists in `$Global:MetasploitConn"
            }
        }
        else 
        {
            throw "No Metasploit server session was provided"
        }

        if ($MSession -eq $null)
        {
            throw "Specified session was not found"
        }
        
        Write-Verbose "Getting information for module $name of type $type."
        $request_reply = $MSession.Manager.GetModuleInformation($Type.ToLower(),$Name)

        if ($request_reply.ContainsKey("error_code"))
        {
            Write-Verbose "An error was reported with code $($request_reply.error_code)"
            if ($request_reply.error_code -eq 401)
            {
                write-verbose "The session has expired, Re-authenticating"

                $SessionProps = New-Object System.Collections.Specialized.OrderedDictionary
                $sessparams   = $MSession.Credentials.GetNetworkCredential().UserName,$MSession.Credentials.GetNetworkCredential().Password,$MSession.URI
                $msfsess = New-Object metasploitsharp.MetasploitSession -ArgumentList $sessparams
                if ($msfsess)
                {
                    Write-Verbose "Authentication successful."
                    # Select the correct session manager for the existing session
                    if ($MSession.Manager.GetType().tostring() -eq 'metasploitsharp.MetasploitManager')
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitManager -ArgumentList $msfsess
                    }
                    else
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitProManager -ArgumentList $msfsess
                    }

                    # Build the session object
                    $SessionProps.Add('Manager',$msfmng)
                    $SessionProps.Add('URI',$MSession.URI)
                    $SessionProps.add('Host',$MSession.host)
                    $SessionProps.add('Session',$msfsess)
                    $SessionProps.Add('Credentials',$MSession.Credentials)
                    $SessionProps.Add('Index', $MSession.index)
                    $sessionobj = New-Object -TypeName psobject -Property $SessionProps
                    $sessionobj.pstypenames[0] = "Metasploit.Session"

                    # Update the session with the new information
                    Write-Verbose "Updating session with new authentication token"
                    [void]$Global:MetasploitConn.Remove($MSession)
                    [void]$Global:MetasploitConn.Add($sessionobj)
                    
                    # Get again the Optios
                    $request_reply = $sessionobj.Manager.GetModuleOptions($Type.ToLower(),$Name)
                    $request_reply
                    if ($request_reply.ContainsKey('type'))
                    {
                        $request_reply.add('MSHost', $MSession.Host)
                        $consoleobj = New-Object -TypeName psobject -Property $request_reply
                        $consoleobj.pstypenames[0] = "Metasploit.Module.Option"
                        $consoleobj 
                    }
                }
            }
        }
        else
        {
            if ($request_reply.ContainsKey('type'))
            {
                $request_reply.add('MSHost', $MSession.Host)
                $consoleobj = New-Object -TypeName psobject -Property $request_reply
                $consoleobj.pstypenames[0] = "Metasploit.Module.Option"
                $consoleobj
            }
        }
    }
}

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-MetasploitPostCompatiblePayloads
{
    [CmdletBinding(DefaultParameterSetName = 'Index')]
    param(

        # Metasploit session index
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=0)]
        [int32[]]$Index = @(),

        # Metasploit session object
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        ValueFromPipeline=$true,
        Position=0)]
        [psobject]$Session,

        # Post Module Name
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        Position=1)]
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=1)]
        [string]$Name
    )
    BEGIN 
    {
        
    }
    PROCESS 
    {    
        if ($Index.Count -gt 0)
        {
            foreach($conn in $Global:MetasploitConn)
            {
                if ($conn.index -in $Index)
                {
                    $MSession = $conn
                }
            }
        }
        elseif ($Session -ne $null -and $Session.pstypenames[0] -eq "Metasploit.Session")
        {
            if ($Global:MetasploitConn.Contains($Session))
            {
                $MSession = $Session
            }
            else
            {
                throw "The session object that was passed does not exists in `$Global:MetasploitConn"
            }
        }
        else 
        {
            throw "No Metasploit server session was provided"
        }

        if ($MSession -eq $null)
        {
            throw "Specified session was not found"
        }
        
        $request_reply = $MSession.Manager.GetModuleCompatibleSessions($Name)

        if ($request_reply.ContainsKey("error_code"))
        {
            Write-Verbose "An error was reported with code $($request_reply.error_code)"
            if ($request_reply.error_code -eq 401)
            {
                write-verbose "The session has expired, Re-authenticating"

                $SessionProps = New-Object System.Collections.Specialized.OrderedDictionary
                $sessparams   = $MSession.Credentials.GetNetworkCredential().UserName,$MSession.Credentials.GetNetworkCredential().Password,$MSession.URI
                $msfsess = New-Object metasploitsharp.MetasploitSession -ArgumentList $sessparams
                if ($msfsess)
                {
                    Write-Verbose "Authentication successful."
                    # Select the correct session manager for the existing session
                    if ($MSession.Manager.GetType().tostring() -eq 'metasploitsharp.MetasploitManager')
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitManager -ArgumentList $msfsess
                    }
                    else
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitProManager -ArgumentList $msfsess
                    }

                    # Build the session object
                    $SessionProps.Add('Manager',$msfmng)
                    $SessionProps.Add('URI',$MSession.URI)
                    $SessionProps.add('Host',$MSession.host)
                    $SessionProps.add('Session',$msfsess)
                    $SessionProps.Add('Credentials',$MSession.Credentials)
                    $SessionProps.Add('Index', $MSession.index)
                    $sessionobj = New-Object -TypeName psobject -Property $SessionProps
                    $sessionobj.pstypenames[0] = "Metasploit.Session"

                    # Update the session with the new information
                    Write-Verbose "Updating session with new authentication token"
                    [void]$Global:MetasploitConn.Remove($MSession)
                    [void]$Global:MetasploitConn.Add($sessionobj)

                    # Get again the information
                    $request_reply = $sessionobj.Manager.GetModuleCompatibleSessions($Name)
                    $request_reply
                    if ($request_reply.ContainsKey('sessions'))
                    {
                        foreach ($payload in $request_reply['sessions'])
                        {
                            $moduleprops = @{}
                            $moduleprops.add('MSHost', $MSession.Host)
                            $consoleobj = New-Object -TypeName psobject -Property $moduleprops
                            $consoleobj.pstypenames[0] = "Metasploit.Module.Session"
                            $consoleobj
                        }  
                    }
                }
            }
        }
        else
        {
            if ($request_reply.ContainsKey('sessions'))
            {
                foreach ($payload in $request_reply['sessions'])
                {
                    $moduleprops = @{}
                    $moduleprops.add('MSHost', $MSession.Host)
                    $consoleobj = New-Object -TypeName psobject -Property $moduleprops
                    $consoleobj.pstypenames[0] = "Metasploit.Module.Session"
                    $consoleobj
                }  
            }
        }
    }
}


<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Invoke-MetasploitModule
{
    [CmdletBinding(DefaultParameterSetName = 'Index')]
    param(

        # Metasploit session index
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=0)]
        [int32[]]$Index = @(),

        # Metasploit session object
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        ValueFromPipeline=$true,
        Position=0)]
        [psobject]$Session,

        # Module name
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        Position=1)]
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=1)]
        [string]$Name,

        # Module Type
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        Position=2)]
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=2)]
        [ValidateSet('post','auxiliary','exploit', 'payload')]
        [string]$Type,

        # Module Options
        [Parameter(Mandatory=$true,
        ParameterSetName = "Session",
        Position=3)]
        [Parameter(Mandatory=$true,
        ParameterSetName = "Index",
        Position=3)]
        [hashtable]$Options
       
    )
    BEGIN 
    {
        
        
    }
    PROCESS 
    {    
        if ($Index.Count -gt 0)
        {
            foreach($conn in $Global:MetasploitConn)
            {
                if ($conn.index -in $Index)
                {
                    $MSession = $conn
                }
            }
        }
        elseif ($Session -ne $null -and $Session.pstypenames[0] -eq "Metasploit.Session")
        {
            if ($Global:MetasploitConn.Contains($Session))
            {
                $MSession = $Session
            }
            else
            {
                throw "The session object that was passed does not exists in `$Global:MetasploitConn"
            }
        }
        else 
        {
            throw "No Metasploit server session was provided"
        }

        if ($MSession -eq $null)
        {
            throw "Specified session was not found"
        }

        $ops = New-Object 'system.collections.generic.dictionary[string,object]'
        foreach ($opt in $Options.Keys)
        {
            $ops.Add($opt,$Options[$opt])
        }
        
        Write-Verbose "Getting information for module $name of type $type."
        $request_reply = $MSession.Manager.ExecuteModule($Type.ToLower(),$Name, $ops)

        if ($request_reply.ContainsKey("error_code"))
        {
            Write-Verbose "An error was reported with code $($request_reply.error_code)"
            if ($request_reply.error_code -eq 401)
            {
                write-verbose "The session has expired, Re-authenticating"

                $SessionProps = New-Object System.Collections.Specialized.OrderedDictionary
                $sessparams   = $MSession.Credentials.GetNetworkCredential().UserName,$MSession.Credentials.GetNetworkCredential().Password,$MSession.URI
                $msfsess = New-Object metasploitsharp.MetasploitSession -ArgumentList $sessparams
                if ($msfsess)
                {
                    Write-Verbose "Authentication successful."
                    # Select the correct session manager for the existing session
                    if ($MSession.Manager.GetType().tostring() -eq 'metasploitsharp.MetasploitManager')
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitManager -ArgumentList $msfsess
                    }
                    else
                    {
                        $msfmng = New-Object metasploitsharp.MetasploitProManager -ArgumentList $msfsess
                    }

                    # Build the session object
                    $SessionProps.Add('Manager',$msfmng)
                    $SessionProps.Add('URI',$MSession.URI)
                    $SessionProps.add('Host',$MSession.host)
                    $SessionProps.add('Session',$msfsess)
                    $SessionProps.Add('Credentials',$MSession.Credentials)
                    $SessionProps.Add('Index', $MSession.index)
                    $sessionobj = New-Object -TypeName psobject -Property $SessionProps
                    $sessionobj.pstypenames[0] = "Metasploit.Session"

                    # Update the session with the new information
                    Write-Verbose "Updating session with new authentication token"
                    [void]$Global:MetasploitConn.Remove($MSession)
                    [void]$Global:MetasploitConn.Add($sessionobj)
                    
                    # Get again the Optios
                    $request_reply = $sessionobj.Manager.ExecuteModule($Type.ToLower(),$Name, $ops)
                    $request_reply
                    if ($request_reply.ContainsKey('job_id'))
                    {
                        $request_reply.add('MSHost', $MSession.Host)
                        $consoleobj = New-Object -TypeName psobject -Property $request_reply
                        $consoleobj.pstypenames[0] = "Metasploit.Job"
                        $consoleobj 
                    }
                }
            }
        }
        else
        {
            if ($request_reply.ContainsKey('job_id'))
            {
                $request_reply.add('MSHost', $MSession.Host)
                $consoleobj = New-Object -TypeName psobject -Property $request_reply
                $consoleobj.pstypenames[0] = "Metasploit.Job"
                $consoleobj
            }
        }
    }
}
#endregion