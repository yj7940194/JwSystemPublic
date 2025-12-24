# VS Code DevContainer 开发说明

本仓库提供了 `.devcontainer/` 配置，可在 VS Code 里直接使用 Docker 作为开发环境（Java 8 + Maven + Node 16 + npm 9）。

## 使用方式

1) VS Code 安装扩展：`Dev Containers`
2) 打开仓库根目录 → `Dev Containers: Reopen in Container`
3) 容器内开两个终端分别启动：

- 后端：`mvn -f /workspace/Jwsystem/pom.xml -DskipTests spring-boot:run`
- 前端：`bash -lc "cd /workspace/Jwsystem-front && bash ./scripts/docker-dev.sh"`

访问：

- 前端：`http://localhost:8081/`
- 后端：`http://localhost:8080/`

## Windows（重要）

如果你把仓库放在 Windows 文件系统路径（例如桌面 `C:\\Users\\<you>\\Desktop`）并在容器内运行 Maven，可能会遇到宿主机 bind mount 的权限/语义差异导致的写入报错（例如写 `Jwsystem/target` 失败）。

本 DevContainer 已将 `/workspace/Jwsystem/target` 挂载为 Docker named volume（`dev_backend_target`）以规避该问题；如果你仍遇到写入异常：

- 在 VS Code 执行 `Dev Containers: Rebuild Container`
- 或优先把仓库移动到 WSL 的 Linux 文件系统路径（例如 `~/code/JwSystemPublic`）再重新打开
