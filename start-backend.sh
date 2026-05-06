#!/bin/bash
# Arranca os 3 serviços Pagali em background

ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "A iniciar backend Pagali..."

node "$ROOT/merchant-registry/src/index.js" &
MR_PID=$!
echo "  merchant-registry  → http://localhost:4002  (PID $MR_PID)"

node "$ROOT/qr-service/src/index.js" &
QR_PID=$!
echo "  qr-service         → http://localhost:8031  (PID $QR_PID)"

node "$ROOT/core-connector/src/index.js" &
CC_PID=$!
echo "  core-connector     → http://localhost:8030  (PID $CC_PID)"

echo ""
echo "Para parar: kill $MR_PID $QR_PID $CC_PID"
echo ""
echo "Health checks:"
echo "  curl http://localhost:8030/health"
echo "  curl http://localhost:4002/health"
echo "  curl http://localhost:8031/health"

wait
