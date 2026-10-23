#!/bin/bash
set -e
# 从运行包目录读取游戏资源。
cd "$(dirname "$0")"
exec ./demo
