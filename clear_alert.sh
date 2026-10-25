#!/bin/bash

# Requires ADMIN_API_KEY in the environment (the same value the backend uses).
: "${ADMIN_API_KEY:?Set ADMIN_API_KEY to the backend admin API key}"
API_URL="${API_URL:-http://localhost:5000}"

# Clear the alert
curl -sS -X POST "$API_URL/api/notification" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_API_KEY" \
  -d '{
    "active": false
  }'

echo -e "\n\nAlert cleared!"
