# This code will walk through using a third party-api however, due to being sample code, it won't show using
# the API key in a header, which is more likely in a real-world situation.  But, we can make a faux one.

# API Reference: https://api.spaceflightnewsapi.net/v4/docs/

$apiBaseURL = "https://api.spaceflightnewsapi.net"
$apiEndpoints = @{
    # Token - This API endpoint does not exist in this API, this is for demonstration purposes
    "get-token" = "/tokenuri"

    # Articles
    "get-all-articles" = "/v4/articles/"
    "get-article-by-id"  = "/v4/articles/{id}"

    # Blogs
    "get-all-blogs" = "/v4/blogs/"
    "get-blog-by-id"  = "/v4/blogs/{id}"

    # Info
    "get-info" = "/v4/reports/"

    # Reports
    "get-all-reports" = "/v4/reports/"
    "get-report-by-id" = "/v4/reports/{id}"
}
$clientId = "sampleId"
$clientKey = "samplekey"

function Get-Token(){
    <# Sometimes we use a client_id, secret, etc to get a token. This method is kind of a scaffold for those
     situations!  However, how we use this may change.  If there is a request limit, even token requests
     can work against you and you may opt to get a token ONCE and send it into every request you use (e.g it
     expires in 24 hours!) If tokens are short-lived, then you can use this function in every call, so you
     know you always have a valid token when performing the requests.

     Other APIs use your secret for authorization using something like this:
        $Bytes = [System.Text.Encoding]::Unicode.GetBytes($yoursecret)
        $EncodedText =[Convert]::ToBase64String($Bytes)

        $header = {
            Authorization = "Basic $encodedText"
        }
        
        So, definitely read the API doc!
    #>

    $requestURI = $apiBaseURL + $apiEndpoints["get-token"]
    $requestBody = @{
        client_id = $clientId  # Sometimes, these aren't needed as secrets are unique enough
        secret    = $clientKey # Usually only shown once on the screen, and can be scoped in permissions
    }
    
    # vvv This is what it could look like! Notice the "Post" method, so we'll want the information in the body
    #$resp = Invoke-WebRequest -Method Post -Uri $requestURI -Body $requestBody
    #$access_token = ($resp | ConvertFrom-Json).access_token
    
    # Because this is an open API:
    $access_token = "this_is_an_open_API_but_it_would_go_here"

    return $access_token
}

function Get-LatestLaunchBlog() {
    $requestURI = $apiBaseURL + $apiEndpoints["get-all-blogs"]
    $requestBody = @{
        has_launch = $true  # Filter on blogs that have a related launch.
        limit = 1           # Get the top event
    }
    $headers = @{
        # Sometimes, Bearer is capitalized.  Check the API docs!
        Authorization = "bearer $(Get-Token)"
    }
    $resp = Invoke-WebRequest -Method Get -Uri $requestURI -Body $requestBody -Headers $headers

    # Convert the response from JSON to a PowerShell hash object, and then return back just "results"
    return ($resp | ConvertFrom-Json -Depth 99).results

}

Get-LatestLaunchBlog