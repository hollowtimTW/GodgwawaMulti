$ErrorActionPreference = 'Stop'
$repo = 'hollowtimTW/GodgwawaMulti'
$tag = 'v0.8.5'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$releaseZip = Join-Path (Split-Path -Parent $root) 'GodgwawaMulti-v0.8.5-portable.zip'
if (-not (Test-Path $releaseZip)) { throw "Missing release asset: $releaseZip" }
gh auth status --hostname github.com
if ($LASTEXITCODE -ne 0) { throw 'Run gh auth login -h github.com, then retry.' }
gh repo view $repo *> $null
if ($LASTEXITCODE -ne 0) {
  gh repo create $repo --public --source $root --remote origin --push
  if ($LASTEXITCODE -ne 0) { throw 'Could not create and push the public repository.' }
} else {
  $remote = git -C $root remote get-url origin 2>$null
  if (-not $remote) { git -C $root remote add origin "https://github.com/$repo.git" }
  git -C $root push -u origin main
  if ($LASTEXITCODE -ne 0) { throw 'Could not push the repository documentation.' }
}
gh release view $tag --repo $repo *> $null
if ($LASTEXITCODE -eq 0) { throw "Release $tag already exists; refusing to overwrite it." }
gh release create $tag $releaseZip --repo $repo --title 'Godgwawa Multi 0.8.5' --notes-file (Join-Path $root 'release-notes-v0.8.5.md')
if ($LASTEXITCODE -ne 0) { throw 'Could not create the GitHub Release.' }
