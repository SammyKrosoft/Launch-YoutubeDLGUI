Function Update-CommandLine {
    if (($wpf.txtURL.text -eq "") -or -not ($wpf.txtURL.text -match "\b((http|https):\/\/?)[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|\/?))")) {
        $wpf.btnRun.IsEnabled = $false
        $strCommand = "Type or paste a valid URL first on the URL box..."
    } Else {
        $wpf.btnRun.IsEnabled = $true
        $strCommand = ("youtube-dl -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 ") + ('"') + ($wpf.txtURL.text) + ('"') + (' -o "%(artist)s - %(title)s.%(ext)s"')
    }
    $wpf.txtCmd.Text = $strCommand
}

Function Check-Exec {
    $FileExists = Test-Path $($wpf.txtExecLocation.text)
    If ($FileExists){
        $wpf.btnRun.IsEnabled = $True
        $wpf.lblExecStatus.Content = "Executable is there !"
        $wpf.lblExecStatus.Foreground = "Green"
    } Else {
        $wpf.btnRun.IsEnabled = $False
        $wpf.lblExecStatus.Content = "Executable is missing ... try another path and click the [Check] button "
        $wpf.lblExecStatus.Foreground = "Red"
    }
}

# Load a WPF GUI from a XAML file build with Visual Studio
Add-Type -AssemblyName presentationframework, presentationcore
$wpf = @{ }
# NOTE: Either load from a XAML file or paste the XAML file content in a "Here String"
#$inputXML = Get-Content -Path ".\WPFGUIinTenLines\MainWindow.xaml"
$inputXML = @"
<Window x:Name="frmYoutubeDL" x:Class="Launch_Y_CMD.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:Launch_Y_CMD"
        mc:Ignorable="d"
        Title="MainWindow" Height="450" Width="800">
    <Grid>
        <TextBox x:Name="txtURL" HorizontalAlignment="Left" Height="64" Margin="10,94,0,0" TextWrapping="Wrap" Text="&lt;paste your URL here&gt;" VerticalAlignment="Top" Width="744"/>
        <Label Content="URL:" HorizontalAlignment="Left" Margin="10,63,0,0" VerticalAlignment="Top"/>
        <Button x:Name="btnRun" Content="Download" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="10,216,0,0"/>
        <TextBox x:Name="txtCmd" HorizontalAlignment="Left" Height="43" Margin="10,163,0,0" TextWrapping="Wrap" Text="TextBox" VerticalAlignment="Top" Width="744" IsReadOnly="True" Background="Black" Foreground="Yellow"/>
        <TextBox x:Name="txtExecLocation" HorizontalAlignment="Left" Height="49" Margin="326,291,0,0" TextWrapping="Wrap" Text="C:\Users\SammyKrosoft\OneDrive\Utils\Youtube-dl" VerticalAlignment="Top" Width="294"/>
        <Label Content="Location of Youtube-dl.exe:" HorizontalAlignment="Left" Margin="326,260,0,0" VerticalAlignment="Top"/>
        <Button x:Name="btnCheckExec" Content="Check" HorizontalAlignment="Left" Margin="326,345,0,0" VerticalAlignment="Top" Width="75"/>
        <Label x:Name="lblExecStatus" Content="Label" HorizontalAlignment="Left" Margin="326,370,0,0" VerticalAlignment="Top"/>

    </Grid>
</Window>
"@

$inputXMLClean = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace 'x:Class=".*?"','' -replace 'd:DesignHeight="\d*?"','' -replace 'd:DesignWidth="\d*?"',''
[xml]$xaml = $inputXMLClean
$reader = New-Object System.Xml.XmlNodeReader $xaml
$tempform = [Windows.Markup.XamlReader]::Load($reader)
$namedNodes = $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")
$namedNodes | ForEach-Object {$wpf.Add($_.Name, $tempform.FindName($_.Name))}

#Get the form name to be used as parameter in functions external to form...
$FormName = $NamedNodes[0].Name


#Define events functions
#region Load, Draw (render) and closing form events
#Things to load when the WPF form is loaded aka in memory
$wpf.$FormName.Add_Loaded({
    #Update-Cmd
})
#Things to load when the WPF form is rendered aka drawn on screen
$wpf.$FormName.Add_ContentRendered({
    Update-CommandLine
    Check-Exec
})
$wpf.$FormName.add_Closing({
    $msg = "bye bye !"
    write-host $msg
})
#endregion Load, Draw and closing form events
#End of load, draw and closing form events

#region buttons events
#endregion button events
#End of button events

#region text box events
$wpf.btnRun.add_click({
    Update-CommandLine #normally not necessary here because each time you change the txtURL, the cmdline is updated anyways through the txtURL.add_Changed event handler ... but well just in case !
    Invoke-Expression $($wpf.txtCmd.Text)
})

$wpf.txtURL.add_TextChanged({
    Update-CommandLine
})

$wpf.btnCheckExec.add_Click({
    Check-Exec
})
#endregion text box events
#End of text box events


#HINT: to update progress bar and/or label during WPF Form treatment, add the following:
# ... to re-draw the form and then show updated controls in realtime ...
$wpf.$FormName.Dispatcher.Invoke("Render",[action][scriptblock]{})


# Load the form:
# Older way >>>>> $wpf.MyFormName.ShowDialog() | Out-Null >>>>> generates crash if run multiple times
# Newer way >>>>> avoiding crashes after a couple of launches in PowerShell...
# USing method from https://gist.github.com/altrive/6227237 to avoid crashing Powershell after we re-run the script after some inactivity time or if we run it several times consecutively...
$async = $wpf.$FormName.Dispatcher.InvokeAsync({
    $wpf.$FormName.ShowDialog() | Out-Null
})
$async.Wait() | Out-Null