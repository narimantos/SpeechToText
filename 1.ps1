param (
  [string]$path,
  [string]$file
    )
write-output $path\$file

ffmpeg -i  $path\$file -acodec pcm_s16le -ar 16000 -ac 1 "$path\$file.wav"
$int = 0;
ffmpeg -i "$path\$file.wav" -f segment -segment_time 58 -c copy "$path\out%03d.wav"
$operation = "operation"
Get-ChildItem "$path" -Filter "out*.wav" |
Foreach-Object {
  $content = Get-ItemProperty $_.FullName
  #Write-Output($content.Name)
  $json = gcloud ml speech recognize-long-running $content.Name  --language-code "nl-NL"  --async --format="json";
  Write-Output( $json | ConvertFrom-Json | ForEach-Object {
    Start-Sleep -s 60
    $transcript = gcloud ml speech operations describe $_.name
    Write-Output( $transcript | ConvertFrom-Json | ForEach-Object {
      $transcript
    })
    $_.name})
  $int++
}