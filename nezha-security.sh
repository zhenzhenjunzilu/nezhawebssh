
---

## nezha-security.sh

```bash
#!/bin/bash

set -e


VERSION="1.0.0"


if [ "$EUID" -ne 0 ]; then
    echo "请使用 root 运行"
    exit 1
fi


echo "
=================================
 Nezha Agent Security Tool
 Version $VERSION
=================================
"


echo "[+] 搜索运行中的 Agent"

agents=$(pgrep -af nezha-agent || true)


if [ -z "$agents" ]; then
    echo "未发现运行中的 Agent"
else
    echo "$agents"
fi


echo
echo "[+] 扫描配置文件"


configs=$(find /opt /etc /root \
-name "config*.yml" \
-o -name "config*.yaml" \
2>/dev/null | grep nezha || true)


if [ -z "$configs" ]; then

    echo "没有找到配置"

else


for file in $configs
do

echo "
--------------------------
$file
"

grep -E \
"server:|uuid:|disable_command_execute:" \
$file || true


done

fi


echo
echo "[+] systemd 服务"


services=$(systemctl list-units \
--type=service \
--all \
| grep -i nezha \
|| true)


echo "$services"



echo
read -p \
"是否开启所有 Agent 禁止命令执行? [y/N] " ans


if [[ "$ans" =~ ^[Yy]$ ]]
then

for file in $configs
do

if grep -q "disable_command_execute:" "$file"
then

sed -i \
's/disable_command_execute:.*/disable_command_execute: true/' \
"$file"

else

echo \
"disable_command_execute: true" >> "$file"

fi


echo "修改: $file"

done

fi



echo
read -p \
"是否停止多余 nezha-agent 服务? [y/N] " clean


if [[ "$clean" =~ ^[Yy]$ ]]
then


for service in $(systemctl list-units \
--type=service \
--all \
| grep -i nezha-agent \
| awk '{print $1}')
do

if [ "$service" != "nezha-agent.service" ]
then

echo "停止 $service"

systemctl stop "$service" || true

systemctl disable "$service" || true

fi

done


fi



echo
echo "[+] 清理残留进程"


main=$(systemctl show \
-p MainPID \
--value \
nezha-agent.service \
2>/dev/null || echo 0)


for pid in $(pgrep nezha-agent || true)
do

if [ "$pid" != "$main" ]
then

echo "停止旧 Agent PID=$pid"

kill "$pid" || true

fi

done



systemctl daemon-reload

systemctl restart nezha-agent || true



echo
echo "完成"

echo
echo "当前 Agent:"
pgrep -af nezha-agent || true
