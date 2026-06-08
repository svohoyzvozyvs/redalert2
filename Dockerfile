# ========== 阶段一：构建阶段 ==========
# 使用 bun 官方镜像作为构建环境
FROM oven/bun:latest AS builder

# 设置工作目录
WORKDIR /app

# 复制依赖定义文件
COPY package.json bun.lock ./

# 安装依赖
RUN bun install

# 复制项目所有代码
COPY . .

# 执行构建命令 (Vite 默认构建输出目录为 dist)
RUN bun run build


# ========== 阶段二：运行阶段 ==========
# 使用轻量级的 Nginx 镜像来提供 Web 服务
FROM nginx:alpine

# 将构建产物从 builder 阶段复制到 nginx 的默认静态资源目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 【新增】将根目录的 full-pack.7z 直接复制到 nginx 容器的静态目录中
COPY full-pack.7z /usr/share/nginx/html/

# (可选) 如果你使用了 React Router 且为 history 模式，可以取消注释下面这行来应用自定义的 Nginx 路由配置
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露 80 端口
EXPOSE 80

# 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]