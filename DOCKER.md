# JwSystemPublic Docker 使用说明

本仓库已提供根目录 `docker-compose.yml`，可用 Docker Compose 一键启动：

- MySQL（自动初始化导入数据）
- 后端 Spring Boot（端口 `8080`）
- 前端 Vue DevServer（端口 `8081`）

> 说明：当前 compose 以“开发/演示可运行”为目标：后端用 `mvn spring-boot:run`，前端用 `npm run dev`（支持热更新）。如需生产部署（构建 jar + 前端静态资源 + 反向代理），建议另做生产版 compose/nginx。

## 1. 前置条件

- 已安装 Docker Engine / Docker Desktop
- 已安装 Docker Compose v2（能运行 `docker compose version`）

## 2. 获取代码

```bash
git clone <your-repo-url>
cd JwSystemPublic
```

## 3. （可选）创建 `.env` 覆盖默认配置

`docker-compose.yml` 内所有关键参数都有默认值；如果你希望自定义（尤其是数据库密码），在仓库根目录新建一个 `.env`（不要提交到 Git）：

```bash
# MySQL（仅首次初始化卷时会写入）
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=jw_springboot
MYSQL_USER=jw_user
MYSQL_PASSWORD=jw_password

# 后端：是否跳过验证码校验（仅建议本地/CI）
# 注意：即便开启跳过，`/api/login` 仍要求 checkcode 非空（随便填一个即可）
JW_CAPTCHA_BYPASS=false
```

## 4. 一键启动

启动（后台运行，首次会拉镜像/下载依赖，可能需要几分钟）：

```bash
docker compose up -d --build
```

如果你的 Docker Compose 支持 `--wait`（推荐），可让命令等待服务健康检查通过后再返回：

```bash
docker compose up -d --build --wait
```

本地测试想跳过验证码（推荐仅本地/CI）：

```bash
JW_CAPTCHA_BYPASS=true docker compose up -d --build
```

### 4.1 首次启动会做什么

- MySQL 首次创建数据卷时会自动执行：
  - `Jwsystem/115jw-springboot.sql`
  - `scripts/seed_demo_data.sql`
- 后端首次启动会下载 Maven 依赖（缓存到 compose 卷 `m2`）
- 前端首次启动会在容器内自动执行 `npm ci`（依赖缓存到 compose 卷 `frontend_node_modules`）

## 5. 访问地址与默认账号

- 前端：`http://localhost:8081`
- 后端：`http://localhost:8080`（接口前缀通常为 `/api`，例如 `/api/login`）

默认账号/密码（来自项目 README 与初始化数据）：

- 学生：`20001 / 123456`
- 教师：`9 / 123456`
- 教务人员：`3 / 123456`
- 管理员：`1 / 123456`

## 6. 数据持久化说明

- MySQL 数据：Docker volume `jw_db_data`（`docker compose down` 不会删除；`docker compose down -v` 才会删）
- Maven 缓存：Docker volume `m2`
- 前端依赖：Docker volume `frontend_node_modules`
- 上传/生成的图片文件：`Jwsystem/images`（绑定到宿主机目录；已在 `.gitignore` 忽略）

## 7. 常用命令

```bash
# 查看服务状态
docker compose ps

# 查看日志
docker compose logs -f db
docker compose logs -f backend
docker compose logs -f frontend

# 重启某个服务
docker compose restart backend

# 停止（保留数据卷）
docker compose down

# 停止并删除数据卷（会清空 MySQL 数据 + 依赖缓存，重新初始化）
docker compose down -v
```

## 8. MySQL 如何连接/导出

### 8.1 默认方式（不暴露宿主端口）

compose 默认**不把 MySQL 的 3306 映射到宿主机**（避免你本机已有 MySQL 时冲突）。需要连库时，建议直接进容器执行：

```bash
# 使用 root 进入（若你没有自定义 .env，则 root 密码默认为 root）
docker compose exec db mysql -uroot -p
```

### 8.2 需要用 Navicat/Workbench 直连宿主机

在 `docker-compose.yml` 的 `db` 服务下加端口映射（示例用 `13306` 避免冲突）：

```yml
services:
  db:
    ports:
      - "13306:3306"
```

然后连接：`127.0.0.1:13306`，账号/库名按你的 `.env`。

## 9. 远程主机访问（可选）

如果 Docker 跑在远程服务器、你要从另一台电脑访问：

1) 确保服务器防火墙放行 `8081`（前端）与 `8080`（后端）。
2) 前端容器内需要把浏览器端 API 地址改成“浏览器能访问到的后端地址”，例如：

```bash
VUE_APP_BASE_API="http://<server-ip>:8080" \
DEV_SERVER_PUBLIC="<server-ip>:8081" \
docker compose up -d --build
```

## 10. 常见问题排查

- `8080/8081` 端口被占用：用环境变量改宿主端口映射（无需改文件）：
  ```bash
  FRONTEND_PORT=18081 BACKEND_PORT=18080 docker compose up -d --build
  ```
- `dependency failed to start: ... backend ... is unhealthy`：
  - 常见原因：首次启动后端会下载 Maven 依赖 + 编译（尤其项目放在 Windows 文件系统目录并 bind mount 时更慢），导致 8080 在健康检查窗口内未及时监听，compose 误判失败。
  - 排查/恢复：`docker compose logs -f backend` 等待后端完成启动；后端起来后再执行一次 `docker compose up -d`（或 `docker compose up -d frontend`）即可把前端拉起。
  - 建议：优先把代码放在 WSL 文件系统（如 `~/wsl_desktop/JwSystemPublic`）再运行；仓库的 `docker-compose.yml` 已为 backend/frontend healthcheck 增加 `start_period` 以容忍首次冷启动。
- 修改了 MySQL 密码但数据库连不上：如果 MySQL 卷已存在，初始化不会重跑；用 `docker compose down -v` 清空后重建（会丢数据）。
- 首次启动很慢：后端会下载 Maven 依赖、前端会 `npm ci`；看 `docker compose logs -f backend/frontend` 等待完成即可。
- 前端出现大量 `no such file or directory, open '/workspace/Jwsystem-front/node_modules/...'`：
  - 常见触发：容器运行时在宿主机手动删除/重建了 `Jwsystem-front/node_modules`（该目录是容器内 `node_modules` 卷挂载点的父目录的一部分）。
  - 直接修复：`docker compose restart frontend`
  - 仍不行：重置前端依赖卷（只会重装前端依赖，不影响数据库）：
    ```bash
    docker compose stop frontend
    docker compose rm -f frontend
    docker volume rm jwsystempublic_frontend_node_modules
    docker compose up -d --build frontend
    ```
