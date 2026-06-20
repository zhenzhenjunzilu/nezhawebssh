# Nezha Agent Security Check & Hardening

一个用于检查和加固哪吒监控 Agent 的安全脚本。

主要用于排查：

- 多个 nezha-agent 同时运行
- 旧 Agent 残留
- 多个 systemd 服务
- WebSSH / 命令执行权限未关闭
- 修改错误配置文件导致安全设置未生效


## 功能

### 检查

自动检测：

- 当前运行中的 nezha-agent 数量
- 每个 Agent 使用的配置文件
- UUID
- Dashboard 地址
- disable_command_execute 状态
- systemd 中存在的 Agent 服务


### 加固

可自动：

- 设置：

```yaml
disable_command_execute: true
