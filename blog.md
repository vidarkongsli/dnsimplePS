
Manage your DNS records with PowerShell

In my video course PowerShell 5 Recipes, I used the DNSimple API as an example for writing PowerShell modules. In the course, I uploaded and made the library available on the PowerShell gallery. Even though it is not feature-complete with respect to the  DNSimple API, it is still usable for the core parts of the API.

Getting started
In order to access the Dnsimple API, you need an access token. In order to create one, log in to the web page and generate one under https://dnsimple.com/a/<account id>/account/access_tokens. For simplicity going forward, create a PowerShell object to hold the account id and the access token:
```powershell
$account = [pscustomobject]@{Account=27928;AccessToken=(
convertto-securestring 'G2uiIZLhsHNWt4BFNq6Y8VnF1iRz2sB1' -asplaintext -for
ce)}
```
Then, the next step is to install the module from the PowerShell Gallery, and load it into the current PowerShell instance:
```powershell
Find-Module DnsimplePS | Install-Module -Scope CurrentUser
Import-Module DnsimplePS
```
In order to check the available cmdlets, list them:
```powershell
Get-Command -Module DnsimplePS
```

Listing, adding and removing Zone records

The simplest thing you can do, is to list the records for your domain:
```powershell
$account | Get-ZoneRecord -Zone kongs.li
```
You can also search for records of a certain type (case-sensitive):
```powershell
$account | Get-ZoneRecord -Zone kongs.li -RecordType MX
```
Or, you can get a certain record by name
```powershell
$account | Get-ZoneRecord -Zone kongs.li -Name www
```
Or, you can match records by prefix using `-NameLike`:
```powershell
$account | Get-ZoneRecord -Zone kongs.li -NameLike w
```
You can also add a record:
```powershell
$account | Add-ZoneRecord -Zone kongs.li -RecordType URL `
  -Name dnsimple -Content https://dnsimple.com/
```
And you can delete a record:
```powershell
$account | Remove-ZoneRecord -Zone kongs.li -Id 11601106
```

Storing your access token securely

In the getting started section above, I directed you to go to the DNSimple web page to get an access token. This is often not practical in automated scripts, so I provided a couple of cmdlets to store and retrieve an access token from a file, encrypted under the current user's Windows credentials.

So, when you have retrieved the token from the web page, you can store it securely like so:
```powershell
Write-AccessToken -AccessToken $t -Account 27928
```
This will create a file named `.dnsimple.tokens` next to your `$PROFILE`. The file will look something like this:
```xml
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">
  <Obj RefId="0">
    <TN RefId="0">
      <T>Deserialized.System.Collections.Hashtable</T>
      <T>Deserialized.System.Object</T>
    </TN>
    <DCT>
      <En>
        <I32 N="Key">27928</I32>
        <S N="Value">01000000d08c9ddf0115d1118c7a00c04fc297eb01000000fff8656bc71ed747aa82e30ddd65735a00000000020000000000106600000001000020000000e7dfc8caf9534e51b2e2eb56b6968171ceb6c6ce9c8a7d55193791a207ffc56a000000000e800000000200002000000066c532a677f69c0c478733114d01b4371577340b0051160d95a3728d07c466ca500000005bbf59cee4314675324296591beeadef7970fc4e8589fce2b5bd80c6b5368e5198da424d1554a269921da4f0c6ef02e50db416fe2b7cbe63f187eb91d94d759da11e63121142f7e8794079e1ea74040d40000000d3f2a0be38aaa111ce20eeba05bcabb594e62400658486ed1c4ec2fe027e5d7e0916bc797aba0a0c1325fd7d0043ba9c9754782f695bdafab8a627f2259636f4</S>
      </En>
    </DCT>
  </Obj>
</Objs>
```
If you want to place the file somewhere else, point to it using the `-Path` parameter.

Extra: URL-shortener
In order to show off PowerShell modules being dependent on other modules, I created a second module that was dependent on the `DnsimplePS` module. This module has one cmdlet which is a short-hand for the special case I showed above for adding a record.

It creates a `URL` type record, which is basically a redirect record that allows the creation of short urls.

Example:
```powershell
$account | Add-ShortUrl -Zone kongs.li -Name dnsimple -Url https://dnsimple.com/
``` 
In the same vain, you can delete the url:
```powershell
$account | Remove-ShortUrl -Zone kongs.li -Name dnsimple
```
