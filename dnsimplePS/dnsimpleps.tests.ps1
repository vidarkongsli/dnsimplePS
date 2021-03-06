[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
param()
import-module $PSScriptRoot\dnsimpleps.psm1 -Force

InModuleScope dnsimpleps {

    Describe 'Dnsimple cmdlets' {
        Context 'Token handling ' {
            It 'Should write access tokens to file' {

                $tempFile = join-path $TestDrive '.access.token'

                Write-AccessToken -Account 11111 -AccessToken thetoken `
                    -Path $tempFile

                [xml](Get-Content $tempFile) `
                    | Select-xml "//s:I32[@N='Key' and text()='11111']" `
                        -Namespace @{s='http://schemas.microsoft.com/powershell/2004/04'} `
                        | Should Not BeNullOrEmpty
            }

            It 'Should be able to read access tokens from file' {
                
                #Arrange
                $tempFile = join-path $TestDrive '.access.token'
                $account = 11111
                $accessToken = 'thetoken'
                Write-AccessToken -Account $account -AccessToken $accessToken `
                    -Path $tempFile

                #Act
                $result = Read-AccessToken $account -Path $tempFile

                #Assert
                $result.Account | Should Be $account
                (new-object pscredential 'foo',$result.AccessToken).GetNetworkCredential().Password | Should Be $AccessToken
            }
        }

        Context 'Records handling' {
            Mock Invoke-RestMethod {
                    $bodyPS = ConvertFrom-Json $Body
                    return [PSCustomObject]@{
                        data = [PSCustomObject]@{
                            id=11278049
                            zone_id=$Zone
                            parent_id=$null
                            name=$bodyPS.name
                            content=$bodyPS.Content
                            ttl=3600
                            priority=$null
                            type=$bodyPS.type
                            regions=@('global')
                            system_record=$false
                            created_at='2017-03-24T11:53:27Z'
                            updated_at='2017-03-24T11:53:27Z'
                        }
                    }
                } -ParameterFilter { $Method -eq 'POST' -and $Uri -eq "https://api.dnsimple.com/v2/$account/zones/$zone/records" }

            $account = [pscustomobject]@{
                Account=11111
                AccessToken=(ConvertTo-SecureString 'thetoken' -AsPlainText -Force)
            }
            $zone = 'pwrsh.io'

            It 'should be able to add zone record' {
                $recordType = 'MX'
                $content = 'smtp.pwrsh.io'
                $name = 'record1'
                $result = $account | Add-ZoneRecord -Zone $zone -RecordType $recordType `
                    -Name $name -Content $content

                    $result.zone_id | Should be $zone
                    $result.content | Should be $content
                    $result.name | Should be $name
            }

            Mock Invoke-WebRequest {
                    return [pscustomobject]@{
                        StatusCode=204
                        StatusDescription='No Content'
                        Content=''
                        RawContentLength=0
                    }
                } -ParameterFilter { $Method -eq 'DELETE' -and $Uri -eq "https://api.dnsimple.com/v2/$Account/zones/$Zone/records/$id" } 

            It 'should be able to delete record' {
                $id = 1
                $result = $account | Remove-ZoneRecord -Zone $zone -Id $id

                $result.StatusCode | Should Be 204
            }

            Mock Invoke-RestMethod {
                    return [PSCustomObject]@{
                        data = [PSCustomObject]@{
                            id=11278049
                            zone_id=$Zone
                            parent_id=$null
                            name="name"
                            content="content"
                            ttl=3600
                            priority=$null
                            type="MX"
                            regions=@('global')
                            system_record=$false
                            created_at='2017-03-24T11:53:27Z'
                            updated_at='2017-03-24T11:53:27Z'
                        }
                    }
                } -ParameterFilter { $Method -eq 'get' -and $Uri -eq "https://api.dnsimple.com/v2" }


            It 'should unwrap result' {
                CallDnsimpleApi 'get' 'https://api.dnsimple.com/v2' $null $Account.AccessToken
            }
        }
    }
}