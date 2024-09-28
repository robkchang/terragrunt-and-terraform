# This script is something that I found really useful.  I need to know if an IP is Azure,
# and if so, what service tag it is listed under

#region Variables

# Define the URL
$serviceTagListURI = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519"

# Just a test IP that is not found in the service tags
#$ipToCheckOn = "12.1.1.1"

# This IP is found around record 2000
$ipToCheckOn = "20.36.36.33"

#endregion

#region Functions!

function Convert-ToRange($subnet){
    # Seems silly to solve this when it's been done. A good scripter can synthesize other scripts and
    # bits into something functional and efficient. I'm going to reference the developer, confirm
    # the code is functional and efficient, by being diligent and reading/understanding it, then use
    # it and save myself a few hours.
    # reference: https://www.powershellgallery.com/packages/PoshFunctions/2.2.1.6/Content/Functions%5CGet-IpRange.ps1
    # and I don't want to import their module from PSGallery and create a dependency I need to keep forever

    if ($subnet -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2}$') {
        #Split IP and subnet
        $IP = ($Subnet -split '\/')[0]
        [int] $SubnetBits = ($Subnet -split '\/')[1]
        if ($SubnetBits -lt 7 -or $SubnetBits -gt 30) {
            throw 'The number following the / must be between 7 and 30. Read in $subnet'
            break
        }
        #Convert IP into binary
        #Split IP into different octects and for each one, figure out the binary with leading zeros and add to the total
        $Octets = $IP -split '\.'
        $IPInBinary = @()
        foreach ($Octet in $Octets) {
            #convert to binary
            $OctetInBinary = [convert]::ToString($Octet, 2)
            #get length of binary string add leading zeros to make octet
            $OctetInBinary = ('0' * (8 - ($OctetInBinary).Length) + $OctetInBinary)
            $IPInBinary = $IPInBinary + $OctetInBinary
        }
        $IPInBinary = $IPInBinary -join ''
        #Get network ID by subtracting subnet mask
        $HostBits = 32 - $SubnetBits
        $NetworkIDInBinary = $IPInBinary.Substring(0, $SubnetBits)
        #Get host ID and get the first host ID by converting all 1s into 0s
        $HostIDInBinary = $IPInBinary.Substring($SubnetBits, $HostBits)
        $HostIDInBinary = $HostIDInBinary -replace '1', '0'
        #Work out all the host IDs in that subnet by cycling through $i from 1 up to max $HostIDInBinary (i.e. 1s stringed up to $HostBits)
        #Work out max $HostIDInBinary
        $imax = [convert]::ToInt32(('1' * $HostBits), 2) - 1
        $IPs = @()
        #Next ID is first network ID converted to decimal plus $i then converted to binary
        For ($i = 1 ; $i -le $imax ; $i++) {
            #Convert to decimal and add $i
            $NextHostIDInDecimal = ([convert]::ToInt32($HostIDInBinary, 2) + $i)
            #Convert back to binary
            $NextHostIDInBinary = [convert]::ToString($NextHostIDInDecimal, 2)
            #Add leading zeros
            #Number of zeros to add
            $NoOfZerosToAdd = $HostIDInBinary.Length - $NextHostIDInBinary.Length
            $NextHostIDInBinary = ('0' * $NoOfZerosToAdd) + $NextHostIDInBinary
            #Work out next IP
            #Add networkID to hostID
            $NextIPInBinary = $NetworkIDInBinary + $NextHostIDInBinary
            #Split into octets and separate by . then join
            $IP = @()
            For ($x = 1 ; $x -le 4 ; $x++) {
                #Work out start character position
                $StartCharNumber = ($x - 1) * 8
                #Get octet in binary
                $IPOctetInBinary = $NextIPInBinary.Substring($StartCharNumber, 8)
                #Convert octet into decimal
                $IPOctetInDecimal = [convert]::ToInt32($IPOctetInBinary, 2)
                #Add octet to IP
                $IP += $IPOctetInDecimal
            }
            #Separate by .
            $IP = $IP -join '.'
            $IPs += $IP
        }
        return $IPs
    } else {
        throw "Subnet [$subnet] is not in a valid format"
    }
}
#endregion
function Get-LatestServiceTagIPs(){
    # I have seen people use Invoke-WebRequest instead of RestMethod, but generally speaking
    # I have found them to be about the same, except WebRequest will give headers and content
    # If I just need content, I just use RestMethod. If I need to dig into headers, I use
    # Invoke-WebRequest

    $downloadPage = Invoke-RestMethod -Uri $serviceTagListURI
    $linkLine = $downloadPage -split "`n" | Where-Object {$_ -like "*click here to download manually*"}
    # Use a little regex to get everything until the href=", then do a non-greedy search until the next quote
    # and put that into a reference object then match the rest. Replace it with the reference object. Needs
    # to be in single quotes to work with the $.
    $link = $linkLine -replace ".*href=`"(.*?)`".*",'$1'

    $tagsFileContents = Invoke-RestMethod -Uri $link

    return $tagsFileContents
}

$serviceTags = Get-LatestServiceTagIPs
"File retreived : $(Get-Date)"
"File Change Number: $($serviceTags.changeNumber)"
"Cloud Name: $($serviceTags.cloud)"

foreach ($serviceTag in $serviceTags.values){
    # $serviceTags.values is an array of objects.  Let's go through them to find our IP
    $tagGroupName = $serviceTag.Name
    if ($tagGroupName -notlike "*.*"){
        # if we don't have a dot in the name, it will be an entire category (like ActionGroup)
        # and that's great, but I'd love to get a region out of it
        continue
    }
    $tagGroupId = $serviceTag.id
    $ranges = $serviceTag.properties

    # Debugging! Every "Cyan" dot represents a checked Service Tag
    #Write-Host "." -NoNewLine -ForegroundColor Cyan
    foreach ($addressPrefix in $ranges.addressPrefixes){
        # Process each prefix. Going to ignore the logic to skip IPv6 here, because
        # I want that function to handle all my conversion requests. Just because
        # I throw something at it now that it can't handle, doesn't mean it always will
        try {
            # So, I ran this and there were about 2647 service tag groups. That's a lot of
            # work.  So, maybe if we trim down what we're looking for by, at the very least,
            # checking the numbers that don't match based on the address range and subnet.
            # This might cut out, optimistically, 90% of the checks.
            $networkPrefix = ($addressPrefix -split '\/')[1]
            $doCheck = $false
            if ($networkPrefix -ge 24){
                # if we're here, that means the first three octets won't change
                if ((($ipToCheckOn -split '\.')[0] -like ($addressPrefix -split '\.')[0]) `
                    -and (($ipToCheckOn -split '\.')[1] -like ($addressPrefix -split '\.')[1]) `
                    -and (($ipToCheckOn -split '\.')[2] -like ($addressPrefix -split '\.')[2])){
                    $doCheck = $true
                }
            } elseif ($networkPrefix -ge 16){
                # if we're here, that means the first two octets won't change
                if ((($ipToCheckOn -split '\.')[0] -like ($addressPrefix -split '\.')[0]) `
                    -and (($ipToCheckOn -split '\.')[1] -like ($addressPrefix -split '\.')[1])){
                    $doCheck = $true
                }
            } elseif ($networkPrefix -ge 8){
                # This is bonkers. This range would be massive, and I'm guessing not really possible unless it is an ISP
                if (($ipToCheckOn -split '\.')[0] -like ($addressPrefix -split '\.')[0]){
                    $doCheck = $true
                }
            }
            if ($doCheck){
                $ipsInCIDR = Convert-ToRange $addressPrefix -ErrorAction Stop
                if ($ipsInCIDR -contains $ipToCheckOn){
                    Write-Host "IP found: $ipToCheckOn" -ForegroundColor Magenta
                    Write-Host "`tService Tag: $tagGroupName"
                    Write-Host "`tRegion: $($ranges.region)"
                    Write-Host "`tPrefix: $addressPrefix"
                    return
                }
                # Debugging! Every "white" dot represents a checked subnet
                #Write-Host "." -NoNewLine
            }
        } catch {
            # If an IPv6 address is sent in, I know the code won't handle it.  Catch the error
            # and move on.  It's nice to throw an exception from inside a function and worry
            # about it later.
            continue
        }
    }
}
# If we're here, we just spent a lot of time looking with no results
Write-Host "Not found in Service Tags" -ForegroundColor Red

