if (-not (Get-Command git -ErrorAction Ignore)) {
    choco install git.install --params "'/GitOnlyOnPath /WindowsTerminal /NoAutoCrlf'" -y --no-progress
    refreshenv
    $null = Get-Command git -ErrorAction Stop
}
git config --global safe.directory '*'
