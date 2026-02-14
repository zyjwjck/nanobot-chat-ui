# 设置Git用户信息
git config user.name "nanobot-chat-ui"
git config user.email "nanobot-chat-ui@example.com"

# 推送到底部
if (git remote -v) {
    Write-Host "Pushing to GitHub..."
    git push -u origin master
} else {
    Write-Host "Remote repository not set. Please set it first."
}
