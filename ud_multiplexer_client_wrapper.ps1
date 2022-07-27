$RegistryPath = "HKCU:\Software\UltimeDecathlon\multiplexer_client"
If (-NOT (Test-Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force | Out-Null
}

Try {
    $livesplit = Get-ItemPropertyValue -Path $RegistryPath -Name "livesplit_connect_address"
}
Catch {
    $livesplit = "localhost:7592"
}
Try {
    $multiplexer = Get-ItemPropertyValue -Path $RegistryPath -Name "multiplexer_address"
}
Catch {
    $multiplexer = "ultimedecathlon.com:7602"
}
Try {
    $clientID = Get-ItemPropertyValue -Path $RegistryPath -Name "client_id"
}
Catch {
    $clientID = ""
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "UD Multiplexer Client"
$form.Size = New-Object System.Drawing.Size(300,260)
$form.StartPosition = "CenterScreen"

$livesplitLabel = New-Object System.Windows.Forms.Label
$livesplitLabel.Location = New-Object System.Drawing.Point(10,20)
$livesplitLabel.Size = New-Object System.Drawing.Size(300,20)
$livesplitLabel.Text = "LiveSplit Connect:"
$form.Controls.Add($livesplitLabel)

$livesplitTextBox = New-Object System.Windows.Forms.TextBox
$livesplitTextBox.Location = New-Object System.Drawing.Point(10,40)
$livesplitTextBox.Size = New-Object System.Drawing.Size(260,20)
$livesplitTextBox.Text = $livesplit
$form.Controls.Add($livesplitTextBox)

$multiplexerLabel = New-Object System.Windows.Forms.Label
$multiplexerLabel.Location = New-Object System.Drawing.Point(10,70)
$multiplexerLabel.Size = New-Object System.Drawing.Size(300,20)
$multiplexerLabel.Text = "UD Multiplexer:"
$form.Controls.Add($multiplexerLabel)

$multiplexerTextBox = New-Object System.Windows.Forms.TextBox
$multiplexerTextBox.Location = New-Object System.Drawing.Point(10,90)
$multiplexerTextBox.Size = New-Object System.Drawing.Size(260,20)
$multiplexerTextBox.Text = $multiplexer
$form.Controls.Add($multiplexerTextBox)

$nicknameLabel = New-Object System.Windows.Forms.Label
$nicknameLabel.Location = New-Object System.Drawing.Point(10,120)
$nicknameLabel.Size = New-Object System.Drawing.Size(300,20)
$nicknameLabel.Text = "Nickname:"
$form.Controls.Add($nicknameLabel)

$nicknameTextBox = New-Object System.Windows.Forms.TextBox
$nicknameTextBox.Location = New-Object System.Drawing.Point(10,140)
$nicknameTextBox.Size = New-Object System.Drawing.Size(260,20)
$nicknameTextBox.Text = $clientID
$form.Controls.Add($nicknameTextBox)

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(65,180)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = "Start"
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150,180)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = "Exit"
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$form.Topmost = $true

$form.Add_Shown({$multiplexerTextBox.Select()})
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $livesplit = $livesplitTextBox.Text
    $clientID = $nicknameTextBox.Text
    $multiplexer = $multiplexerTextBox.Text
    Write-Output "Starting UD Multiplexer Client LiveSplit='$livesplit' Multiplexer='$multiplexer' ClientID='$clientID' ..."
    Set-ItemProperty -Path $RegistryPath -Name "livesplit_connect_address" -Value $livesplit
    Set-ItemProperty -Path $RegistryPath -Name "multiplexer_address" -Value $multiplexer
    Set-ItemProperty -Path $RegistryPath -Name "client_id" -Value $clientID
    .\grpc-multiplexer-client --client-id $clientID --multiplexer-address $multiplexer
}

Write-Output "Press Any Key to Exit"
[void][System.Console]::ReadKey($true)
