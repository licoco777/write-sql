<#
.SYNOPSIS
    把 .claude/skills/ 单源镜像到 .agents/skills/（及未来其他目标），保证多 agent 工具读到同一份技能资产。

.DESCRIPTION
    单源维护策略：所有 skill 修改只在 .claude/skills/ 下进行；执行本脚本会用 robocopy /MIR 把
    .claude/skills/ 完整镜像到目标目录（默认 .agents/skills/），并在目标目录顶层写入 .MIRROR
    标记文件和 _MIRROR_README.md 说明。

    脚本默认排除 *-workspace 目录（如 write-query-workspace/），它们是评测/迭代工作区，不属于
    skill 资产。

.PARAMETER Targets
    一个或多个镜像目标目录名（相对仓库根）。默认: .agents。可扩展为 ".agents,.codex"。

.PARAMETER DryRun
    仅打印 robocopy 将做什么，不实际修改文件。

.PARAMETER ExcludeDirs
    需要从镜像中排除的目录名（不含路径，按通配匹配）。默认: *-workspace。

.EXAMPLE
    pwsh scripts/sync_skills.ps1
    # 默认镜像到 .agents/skills/

.EXAMPLE
    pwsh scripts/sync_skills.ps1 -DryRun
    # 打印将做的事情，但不真改

.EXAMPLE
    pwsh scripts/sync_skills.ps1 -Targets ".agents",".codex"
    # 同时镜像到 .agents/skills 和 .codex/skills
#>
[CmdletBinding()]
param(
    [string[]]$Targets = @(".agents"),
    [switch]$DryRun,
    [string[]]$ExcludeDirs = @("*-workspace")
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Source = Join-Path $RepoRoot ".claude\skills"

if (-not (Test-Path $Source)) {
    Write-Error "源目录不存在: $Source"
    exit 1
}

Write-Host ("=== sync_skills 启动 ({0}) ===" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")) -ForegroundColor Cyan
Write-Host ("仓库根: {0}" -f $RepoRoot)
Write-Host ("源目录: {0}" -f $Source)
Write-Host ("目标: {0}" -f ($Targets -join ", "))
Write-Host ("排除子目录: {0}" -f ($ExcludeDirs -join ", "))
if ($DryRun) {
    Write-Host "*** DryRun 模式：不会修改任何文件 ***" -ForegroundColor Yellow
}

$exitCodeMax = 0

foreach ($targetName in $Targets) {
    $TargetSkills = Join-Path $RepoRoot ("{0}\skills" -f $targetName)
    Write-Host ""
    Write-Host ("--- 镜像 → {0} ---" -f $TargetSkills) -ForegroundColor Cyan

    if (-not (Test-Path $TargetSkills)) {
        if ($DryRun) {
            Write-Host "  (DryRun) 将创建目标目录: $TargetSkills"
        } else {
            New-Item -ItemType Directory -Path $TargetSkills -Force | Out-Null
            Write-Host "  已创建目标目录: $TargetSkills"
        }
    }

    $robocopyArgs = @($Source, $TargetSkills, "/MIR", "/NFL", "/NDL", "/NJH", "/NJS", "/NC", "/NS", "/NP")
    if ($ExcludeDirs.Count -gt 0) {
        $robocopyArgs += "/XD"
        $robocopyArgs += $ExcludeDirs
    }
    if ($DryRun) {
        $robocopyArgs += "/L"
    }

    Write-Host ("  robocopy {0}" -f ($robocopyArgs -join " "))
    & robocopy @robocopyArgs | Out-Null
    $rc = $LASTEXITCODE
    if ($rc -ge 8) {
        Write-Error ("robocopy 失败，退出码 {0}" -f $rc)
        exit $rc
    }
    if ($rc -gt $exitCodeMax) { $exitCodeMax = $rc }
    Write-Host ("  robocopy 完成，退出码 {0} (0=无变化, 1=有复制, 2=有额外, 3=复制+额外, <8 视为成功)" -f $rc)

    if (-not $DryRun) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
        $markerPath = Join-Path $TargetSkills ".MIRROR"
        $marker = "Generated from .claude/skills/ by scripts/sync_skills.ps1 at $timestamp.`r`nDO NOT EDIT.`r`n"
        Set-Content -Path $markerPath -Value $marker -Encoding UTF8 -NoNewline

        $writeQueryDir = Join-Path $TargetSkills "write-query"
        if (Test-Path $writeQueryDir) {
            $readmePath = Join-Path $writeQueryDir "_MIRROR_README.md"
            $readme = @"
# 镜像目录

本目录由 ``scripts/sync_skills.ps1`` 从 ``.claude/skills/write-query/`` 自动生成。

**请勿在此手改**。任何修改都应在 ``.claude/skills/write-query/`` 下进行，然后重新运行：

``````powershell
pwsh scripts/sync_skills.ps1
``````

最近一次同步：$timestamp
"@
            Set-Content -Path $readmePath -Value $readme -Encoding UTF8
        }

        $excelDir = Join-Path $TargetSkills "excel-to-table-md"
        if (Test-Path $excelDir) {
            $readmePath = Join-Path $excelDir "_MIRROR_README.md"
            $readme = @"
# 镜像目录

本目录由 ``scripts/sync_skills.ps1`` 从 ``.claude/skills/excel-to-table-md/`` 自动生成。

**请勿在此手改**。任何修改都应在 ``.claude/skills/excel-to-table-md/`` 下进行，然后重新运行：

``````powershell
pwsh scripts/sync_skills.ps1
``````

最近一次同步：$timestamp
"@
            Set-Content -Path $readmePath -Value $readme -Encoding UTF8
        }
    }
}

Write-Host ""
Write-Host ("=== sync_skills 完成（max robocopy rc = {0}）===" -f $exitCodeMax) -ForegroundColor Green
if ($DryRun) {
    Write-Host "DryRun 模式下未修改任何文件。" -ForegroundColor Yellow
}
exit 0
