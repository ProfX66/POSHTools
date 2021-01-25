Function Test-SecureStringKey([String]$InputString, [Int]$KeySize = 16)
{
    if (!(@(8,12,16).Contains($KeySize)))
    {
        Write-Warning "Keysize can only be 8, 12, or 16."
        Write-Warning ("You tried a [ {0} ] bit key! [{1} (KeySize) * 16 (Char Type Size) = {0} Bits]" -f ($KeySize * 16), $KeySize)
        return
    }

    $Private:alphabet = @()
    for ([Byte]$c = [Char]'A'; $c -le [Char]'Z'; $c++) { $Private:alphabet += [char]$c }
    $Private:testKey = ($Private:alphabet -join "").Substring(0, $KeySize)

    Write-Host ("Encrypting [ {0} ] with [ {1} ] bit ({2} char) key..." -F $InputString, ($Private:testKey.Length * 16), $Private:testKey.Length)
    Write-Host ("Plain text key: {0}" -F $Private:testKey)

    $Private:enKey = ConvertTo-SecureString $Private:testKey -AsPlainText -Force
    $Private:strTemp = ConvertTo-SecureString $InputString -AsPlainText -Force
	$Private:enStrTemp = ConvertFrom-SecureString $Private:strTemp -SecureKey $Private:enKey
    Write-Host ("Encrypted string: {0}" -F $Private:enStrTemp)

    $Private:strTempEn = ConvertTo-SecureString $Private:enStrTemp -SecureKey $Private:enKey
	$Private:BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Private:strTempEn)
	$Private:strTempPT = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($Private:BSTR)
    Write-Host ("Plain text string: {0}" -F $Private:strTempPT)
}

Write-Host "=== 128 Key ================================"
Test-SecureStringKey -InputString "FooBar" -KeySize 8
Write-Host

Write-Host "=== 192 Key ================================"
Test-SecureStringKey -InputString "FooBar" -KeySize 12
Write-Host

Write-Host "=== 256 Key ================================"
Test-SecureStringKey -InputString "FooBar" -KeySize 16
Write-Host

Write-Host "=== Bad Key ================================"
Test-SecureStringKey -InputString "FooBar" -KeySize 32














