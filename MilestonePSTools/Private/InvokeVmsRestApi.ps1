# Copyright 2026 Milestone Systems A/S
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function InvokeVmsRestApi {
    <#
    .SYNOPSIS
    Invokes an authenticated request against the XProtect API Gateway REST endpoint.

    .DESCRIPTION
    InvokeVmsRestApi is an internal helper that sends HTTP requests to Milestone's
    XProtect API Gateway REST API under the /rest/v1 route. It resolves the API
    Gateway URI from the registered services for the active site, adds a bearer
    authorization header from the current login token cache, and returns the
    deserialized response. When a dictionary body is supplied it is serialized to
    JSON before sending.

    .PARAMETER Method
    Specifies the HTTP method used for the request. The default is Get.

    .PARAMETER Body
    Specifies the payload to send with methods that accept a request body. A
    dictionary/hashtable is converted to JSON with depth 10 before transmission.

    .PARAMETER ContentType
    Specifies the Content-Type header value to use when Body is present. The
    default is application/json.

    .PARAMETER ResourcePath
    Specifies the relative API resource path under /rest/v1, for example
    'loginproviders' or 'loginproviders/{id}'.

    .PARAMETER GatewayUri
    Specifies the base URI of the API Gateway service. If omitted, the function
    discovers the gateway URI from the registered services for the active site.

    .EXAMPLE
    InvokeVmsRestApi -ResourcePath 'loginproviders'

    Retrieves the collection of login providers from the registered API Gateway
    for the current site.

    .NOTES
    Requires a valid login token from (Get-LoginSettings).IdentityTokenCache.
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Method = 'Get',

        [Parameter()]
        [object]
        $Body,

        [Parameter()]
        [string]
        $ContentType = 'application/json',

        [Parameter(Mandatory)]
        [Alias('Path')]
        [string]
        $ResourcePath,

        [Parameter()]
        [uri]
        $GatewayUri
    )

    begin {
        Assert-VmsRequirementsMet
        if (-not $MyInvocation.BoundParameters.ContainsKey('GatewayUri')) {
            $GatewayUri = (Get-RegisteredService -ServiceType 'e46b7bf9-03ce-44eb-bbdc-8ba16d0aaa80').UriArray | Select-Object -First 1
        }
        if ($null -eq $GatewayUri) {
            throw "No 'API Gateway Service' registered on site $((Get-VmsSite).Name)."
        }
    }

    process {
        $uriBuilder = [uribuilder]$GatewayUri
        $uriBuilder.Path = $uriBuilder.Path.TrimEnd('/') + '/rest/v1/' + $ResourcePath
        $requestParams = @{
            Uri     = $uriBuilder.Uri
            Method  = $Method
            Headers = @{
                Authorization = "Bearer $((Get-LoginSettings).IdentityTokenCache.Token)"
            }
        }
        if ($MyInvocation.BoundParameters.ContainsKey('Body')) {
            $requestParams.ContentType = $ContentType
            if ($Body -is [System.Collections.IDictionary]) {
                $requestParams.Body = [pscustomobject]$Body | ConvertTo-Json -Depth 10
            } else {
                $requestParams.Body = $Body.ToString()
            }
        }
        Invoke-RestMethod @requestParams
    }
}
