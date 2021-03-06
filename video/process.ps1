param([string] $prefix,
      [string] $path = ".",
      [string] $output = ".\output")

# Get video files.
$files = Get-ChildItem $path | Where-Object {$_.extension -like ".mp4"} | Sort-Object LastWriteTime

# Rename with prefix.
If($prefix){
    $x = 1
    ForEach ($file in $files) {
        Rename-Item -Path $file.FullName -NewName ($prefix + $x.ToString("D2") + ".mp4")
        $x++
    }
    $files = Get-ChildItem $path | Where-Object {$_.extension -like ".mp4"}
}

# Split into 1 minute segments.
New-Item -ItemType directory -Path $output
ForEach ($file in $files)
{
    New-Item -ItemType directory -Path "$($output)\$($file.basename)"
    & ".\ffmpeg.exe" -i $file.FullName -c copy -f segment -segment_time 60 -r 30 -reset_timestamps 1 "$($output)\$($file.basename)\$($file.basename)_%03d$($file.extension)"
} 

# Move into subfolders for ease of instagram posting.
$outputFiles = Get-ChildItem $output -Recurse | Where-Object {$_.extension -like ".mp4"}
ForEach ($file in $outputFiles)
{
    $source = $file.FullName
    $dest = "$($file.Directory.FullName)\$($file.basename)"
    New-Item -Path $dest -ItemType Directory
    Move-Item $source $dest
} 