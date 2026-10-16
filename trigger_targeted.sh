#!/bin/bash

# Trigger a targeted notification for a specific classroom
# Note: You need to know the classroom name (e.g., "Class 10A", "Lab 1")
# This example targets "Class 10A"

curl -X POST http://localhost:5000/api/notification \
  -H "Content-Type: application/json" \
  -d '{
    "active": true,
    "message": "Lab coats are required for the next session.",
    "type": "info",
    "targets": ["Class 10A", "Lab 1"]
  }'

echo -e "\n\nTargeted Notification triggered for Class 10A/Lab 1!"
