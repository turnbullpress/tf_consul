#!/usr/bin/env bash
set -e

echo "Starting Consul..."
sudo systemctl enable consul.service

sleep 30

sudo systemctl start consul
