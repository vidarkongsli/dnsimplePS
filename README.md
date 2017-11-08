# dnsimplePS
PowerShell client library for [Dnsimple API](https://developer.dnsimple.com/v2/).
See also this blogpost: [Manage your DNS records with PowerShell](https://www.kongsli.net/2017/11/08/manage-your-dns-…-with-powershell/)
## Installation
```posh
Install-Module dnsimplePS -Scope CurrentUser
```

## Store access token
Once you have retrieved an access token for your account via the [web portal](https://dnsimple.com/dashboard) (navigate to the current account page, select "Access Tokens" on the left menu), you can store it securely under the current Windows account.
```posh
Write-AccessToken -AccessToken <token> -Account <account number>
```

## Read access token
If you have stored the access token (see above), load it into a variable for use with the API like so:
```
$account = Read-AccessTooken -Account <account number>
```

## List records
Corresponds to [this](https://developer.dnsimple.com/v2/zones/records/#list) in the API.

### List by record type
```posh
$account | Get-ZoneRecord -Zone <zone> -RecordType URL
```

```posh
Get-ZoneRecord -Zone <zone> -RecordType URL -Account 99999 -AccessToken ae123...
```


### List by exact name
```posh
$account | Get-ZoneRecord -Zone <zone> -Name foo # returns record named 'foo'
```

```posh
Get-ZoneRecord -Zone <zone> -Name foo -Account 99999 -AccessToken ae123...
```

### List by name prefix
```posh
$account | Get-ZoneRecord -Zone <zone> -NameLike f # returns records which name starts with 'f'
```

```posh
Get-ZoneRecord -Zone <zone> -NameLike f -Account 99999 -AccessToken ae123...
```

## Retrieve record by id
```posh
$account | Get-ZoneRecord -Zone <zone> -Id 11627426
```

```posh
Get-ZoneRecord -Zone <zone> -Id 11627426 -Account 99999 -AccessToken ae123...
```

## Create a record
Corresponds to [this](https://developer.dnsimple.com/v2/zones/records/#create) in the API.
```posh
$account | Add-ZoneRecord -Zone <zone> -RecordType A -Name foo -Content 23.100.50.51 # points foo.<zone> to 23.100.50.51
```

```posh
Add-ZoneRecord -Zone <zone> -RecordType A -Name foo -Content 23.100.50.51 -Account 99999 -AccessToken ae123...
```

## Delete a record
Corresponds to [this](https://developer.dnsimple.com/v2/zones/records/#create) in the API.
```posh
$account | Remove-ZoneRecord -Zone <zone> -Id 11730242
```

```posh
Remove-ZoneRecord -Zone <zone> -Id 11730242 -Account 99999 -AccessToken ae123...
```

Questions? Create an [issue](https://github.com/vidarkongsli/dnsimplePS/issues).