# This code will walk through using a third party-api however, due to being sample code, it won't show using
# the API key in a header, which is more likely in a real-world situation.  But, we can make a faux one.

# API Reference: https://ip-api.com/docs/api:json

$apiBaseURL = "http://ip-api.com/json/"

function Get-IPGeoLocation($ipAddresses) {
    $requestURI = $apiBaseURL
    $fields = @{
        status = $true
        message = $true
        continent = $false
        continentCode = $false
        country = $true
        countryCode = $true
        region = $false
        regionName = $true
        city = $true
        district = $true
        zip = $true
        lat = $false
        lon = $false
        timezone = $false
        offset = $false
        currency = $true  # I mean, just for curiousity's sake
        isp = $true
        org = $false
        as = $false
        asname = $true
        reverse = $true
        mobile = $false
        proxy = $false
        hosting = $false
        query = $true
    }
    $fieldList = "fields="
    # This nasty loop just shortcuts the objects we iterate through to find only ones that are $true
    foreach ($field in ($fields.GetEnumerator() | Group-Object -Property Value)[$true].Group){
        # vvv we don't actually have to do this check, since we already filter out ones that match
        # Group-object is a neat function that does not get enough credit.
        #if ($field.Value) {
            $fieldList += $field.Name + ","
        #}
    }
    # Trim off the trailing comma
    $fieldList = $fieldList.TrimEnd(',')

    $requestURI += "?" + $fieldList
    $resp = Invoke-WebRequest -Method Get -Uri $requestURI -Body $requestBody

    # Convert the response from JSON to a PowerShell hash object"
    return ($resp.Content | ConvertFrom-Json -Depth 99)
    #return $resp

}

# Without putting in an API key, you'll just get your own information.
"========================"
"Your IP information:"
Get-IPGeoLocation
"========================"