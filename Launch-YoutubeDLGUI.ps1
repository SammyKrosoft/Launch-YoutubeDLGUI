Function Update-CommandLine {
    if (($wpf.txtURL.text -eq "") -or -not ($wpf.txtURL.text -match "\b((http|https):\/\/?)[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|\/?))")) {
        $global:CommandLineValid = $false
        $strCommand = "Type or paste a valid URL first on the URL box..."
    } Else {
        $global:CommandLineValid = $true
        $DownloadDirectory = $wpf.txtDownloadFolder.Text
        If ($wpf.chkDownloadVideo.IsChecked){
            #$strCommand = ('youtube-dl.exe -i -f best ') + ('"') + ($wpf.txtURL.text) + ('"') + (' -o ') + ('"') + $DownloadDirectory + ('%(artist)s - %(title)s.%(ext)s')+('"')
            $strCommand = ('youtube-dl.exe -i -f best ') + ('"') + ($wpf.txtURL.text) + ('"') + (' -o ') + ('"') + $DownloadDirectory + ('%(artist)s - %(title)s.%(ext)s')+('"')
            $wpf.chkCustomVideoAudio.IsEnabled = $true
            $wpf.txtVideo.IsEnabled = $true
            $wpf.txtAudio.IsEnabled = $true
        } Else {
            $strCommand = ('youtube-dl.exe -i -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 ') + ('"') + ($wpf.txtURL.text) + ('"') + (' -o ') + ('"') + $DownloadDirectory + ('%(artist)s - %(title)s.%(ext)s')+('"')
            $wpf.chkCustomVideoAudio.IsEnabled = $False
            $wpf.txtVideo.IsEnabled = $false
            $wpf.txtAudio.IsEnabled = $false
        }
    }
    $wpf.txtCmd.Text = $strCommand

    if (($global:CommandLineValid) -and ($global:ExecExist)){
        $wpf.btnRun.IsEnabled = $true
        $wpf.btnChkFormats.IsEnabled = $true
        $wpf.graphBusy.Visibility = "Hidden"
        $wpf.graphReady.Visibility = "Visible"
        $wpf.graphGrey.Visibility = "Hidden"
    } Else {
        $wpf.btnRun.IsEnabled = $false
        $wpf.btnChkFormats.IsEnabled = $false
        $wpf.graphBusy.Visibility = "Hidden"
        $wpf.graphReady.Visibility = "Hidden"
        $wpf.graphGrey.Visibility = "Visible"
    }
}

Function CmdYoutubeVideoFormatsList{
    $strCommand = ($wpf.txtExecLocation.text) + ('\youtube-dl.exe -F ') + ('"') + ($wpf.txtURL.text) + ('"')
    return $strCommand    
 }

Function Check-Exec {
    $FileExists = Test-Path $(($wpf.txtExecLocation.text) + ("\youtube-dl.exe"))
    If ($FileExists){
        $global:ExecExist = $true
        $wpf.lblExecStatus.Content = "Executable is there !"
        $wpf.lblExecStatus.Foreground = "Green"
    } Else {
        $global:ExecExist = $false
        $wpf.lblExecStatus.Content = "Executable is missing ... try another path and click the [Check] button "
        $wpf.lblExecStatus.Foreground = "Red"
    }

    if (($global:CommandLineValid) -and ($global:ExecExist)){
        $wpf.btnRun.IsEnabled = $true
        $wpf.graphBusy.Visibility = "Hidden"
        $wpf.graphReady.Visibility = "Visible"
        $wpf.graphGrey.Visibility = "Hidden"
    } Else {
        $wpf.btnRun.IsEnabled = $false
        $wpf.graphBusy.Visibility = "Hidden"
        $wpf.graphReady.Visibility = "Hidden"
        $wpf.graphGrey.Visibility = "Visible"
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
        Title="Youtube-DL PowerShell Front-End" Height="511.335" Width="1238.109">
    <Grid Background="Teal">
        <TextBox x:Name="txtURL" HorizontalAlignment="Left" Height="64" Margin="10,94,0,0" TextWrapping="Wrap" Text="https://www.youtube.com/watch?v=Kbr8aLbycss" VerticalAlignment="Top" Width="590"/>
        <Label Content="URL:" HorizontalAlignment="Left" Margin="10,63,0,0" VerticalAlignment="Top"/>
        <Button x:Name="btnRun" Content="Download" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="10,273,0,0"/>
        <TextBox x:Name="txtCmd" HorizontalAlignment="Left" Height="56" Margin="10,212,0,0" TextWrapping="Wrap" Text="TextBox" VerticalAlignment="Top" Width="590" Background="Black" Foreground="Yellow"/>
        <TextBox x:Name="txtExecLocation" HorizontalAlignment="Left" Height="49" Margin="306,299,0,0" TextWrapping="Wrap" Text="C:\Users\Administrator\OneDrive\Utils\Youtube-dl" VerticalAlignment="Top" Width="294"/>
        <Label Content="Location of Youtube-dl.exe:" HorizontalAlignment="Left" Margin="306,273,0,0" VerticalAlignment="Top"/>
        <Button x:Name="btnCheckExec" Content="Check" HorizontalAlignment="Left" Margin="306,360,0,0" VerticalAlignment="Top" Width="75"/>
        <Label x:Name="lblExecStatus" Content="Label" HorizontalAlignment="Left" Margin="306,385,0,0" VerticalAlignment="Top"/>
        <Ellipse x:Name="graphReady" Fill="Green" HorizontalAlignment="Left" Height="100" Margin="438,361,0,0" Stroke="Black" VerticalAlignment="Top" Width="100"/>
        <Ellipse x:Name="graphGrey" Fill="Gray" HorizontalAlignment="Left" Height="100" Margin="438,360,0,0" Stroke="Black" VerticalAlignment="Top" Width="100"/>
        <Rectangle x:Name="graphBusy" Fill="Red" HorizontalAlignment="Left" Height="100" Margin="438,360,0,0" Stroke="Black" VerticalAlignment="Top" Width="100"/>
        <TextBox x:Name="txtDownloadFolder" HorizontalAlignment="Left" Height="23" Margin="10,35,0,0" TextWrapping="Wrap" Text="C:\temp" VerticalAlignment="Top" Width="259" IsReadOnly="True"/>
        <Label Content="Current download location:" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" Width="231"/>
        <CheckBox x:Name="chkDownloadVideo" Content="Download video instead of converting to MP3" HorizontalAlignment="Left" Margin="10,301,0,0" VerticalAlignment="Top" Height="18" Width="276"/>
        <Button x:Name="btnChkFormats" Content="Check formats" HorizontalAlignment="Left" VerticalAlignment="Top" Width="91" Margin="10,163,0,0"/>
        <Label Content="Formats results" HorizontalAlignment="Left" Margin="619,17,0,0" VerticalAlignment="Top"/>
        <Label Content="Youtube-dl command line" HorizontalAlignment="Left" Margin="10,188,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="txtboxFormatsResults" HorizontalAlignment="Left" Height="407" Margin="619,48,0,0" Text="Formats results will be displayed here" VerticalAlignment="Top" Width="584" Background="DarkBlue" Foreground="Yellow" FontFamily="Courier New" HorizontalScrollBarVisibility="Visible" VerticalScrollBarVisibility="Visible"/>
        <TextBox x:Name="txtVideo" HorizontalAlignment="Left" Height="22" Margin="10,347,0,0" Text="Paste Video stream" VerticalAlignment="Top" Width="120" RenderTransformOrigin="0.517,0" Background="Pink" MaxLines="1"/>
        <TextBox x:Name="txtAudio" HorizontalAlignment="Left" Height="22" Margin="10,374,0,0" Text="Paste Audio stream" VerticalAlignment="Top" Width="120" Background="Purple" MaxLines="1"/>
        <CheckBox x:Name="chkCustomVideoAudio" Content="Custom Video and Audio formats" HorizontalAlignment="Left" Margin="10,324,0,0" VerticalAlignment="Top"/>
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
    $DownloadDirectory = "$($env:userprofile)\Downloads\"
    $wpf.txtDownloadFolder.Text = $DownloadDirectory
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
    Check-Exec #check if Youtube exe has not been modified last minute
    If ($global:ExecExist) {
        Update-CommandLine #normally not necessary here because each time you change the txtURL, the cmdline is updated anyways through the txtURL.add_Changed event handler ... but well just in case !
        #[string]$CommandWithFullPath = ("cmd.exe /C ") + ('"') + ($wpf.txtExecLocation.text) + ('\') + ($wpf.txtCmd.Text) + ('"')
        [string]$CommandWithFullPath = ($wpf.txtExecLocation.text) + ('\') + ($wpf.txtCmd.Text)
        Write-Host $CommandWithFullPath
        $wpf.graphBusy.Visibility = "Visible"
        $wpf.graphReady.Visibility = "Hidden"
        $wpf.graphGrey.Visibility = "Hidden"
        $wpf.$FormName.IsEnabled = $false
        $wpf.$FormName.Dispatcher.Invoke("Render",[action][scriptblock]{})
        Invoke-Expression $CommandWithFullPath | out-host
        $wpf.$FormName.IsEnabled = $true
        $wpf.graphBusy.Visibility = "Hidden"
        $wpf.graphReady.Visibility = "Visible"
        $wpf.graphGrey.Visibility = "Hidden"
        $wpf.$FormName.Dispatcher.Invoke("Render",[action][scriptblock]{})
    }
})

$wpf.txtURL.add_TextChanged({
    Update-CommandLine
})

$wpf.btnCheckExec.add_Click({
    Check-Exec
})
#endregion text box events
#End of text box events

$wpf.chkDownloadVideo.add_Click({
    Update-CommandLine
})

$wpf.btnChkFormats.add_Click({
    $wpf.graphBusy.Visibility = "Visible"
    $wpf.graphReady.Visibility = "Hidden"
    $wpf.graphGrey.Visibility = "Hidden"
    $wpf.$FormName.IsEnabled = $false
    $wpf.$FormName.Dispatcher.Invoke("Render",[action][scriptblock]{})

    $command = CmdYoutubeVideoFormatsList
    write-host $command
    $Results = invoke-expression $command | Out-String
    $Results | Out-Host
    $wpf.txtboxFormatsResults.Text = $Results

    $wpf.$FormName.IsEnabled = $true
    $wpf.graphBusy.Visibility = "Hidden"
    $wpf.graphReady.Visibility = "Visible"
    $wpf.graphGrey.Visibility = "Hidden"
    $wpf.$FormName.Dispatcher.Invoke("Render",[action][scriptblock]{})
})

#HINT: to update progress bar and/or label during WPF Form treatment, add the following:
# ... to re-draw the form and then show updated controls in realtime ...
#$wpf.$FormName.Dispatcher.Invoke("Render",[action][scriptblock]{})


# Load the form:
# Older way >>>>> $wpf.MyFormName.ShowDialog() | Out-Null >>>>> generates crash if run multiple times
# Newer way >>>>> avoiding crashes after a couple of launches in PowerShell...
# USing method from https://gist.github.com/altrive/6227237 to avoid crashing Powershell after we re-run the script after some inactivity time or if we run it several times consecutively...
$async = $wpf.$FormName.Dispatcher.InvokeAsync({
    $wpf.$FormName.ShowDialog() | Out-Null
})
$async.Wait() | Out-Null