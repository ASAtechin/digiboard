#!/bin/bash

# Requires ADMIN_API_KEY in the environment (the same value the backend uses).
: "${ADMIN_API_KEY:?Set ADMIN_API_KEY to the backend admin API key}"
API_URL="${API_URL:-http://localhost:5000}"

# Trigger a targeted notification for a specific classroom
# Note: You need to know the classroom name (e.g., "Class 10A", "Lab 1")
# This example targets "Class 10A"

curl -sS -X POST "$API_URL/api/notification" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_API_KEY" \
  -d '{
    "message": "Lab coats are required for the next session.",
    "type": "info",
    "targets": ["Class 10A", "Lab 1"]
  }'

echo -e "\n\nTargeted Notification triggered for Class 10A/Lab 1!"
