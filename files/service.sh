#!/usr/bin/env bash
set -e

echo "Starting Consul..."
sudo systemctl enable consul.service
sudo systemctl start consul
