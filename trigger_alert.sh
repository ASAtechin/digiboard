#!/bin/bash

# Trigger an emergency alert
curl -X POST http://localhost:5000/api/notification \
  -H "Content-Type: application/json" \
  -d '{
    "active": true,
    "message": "🚨 FIRE DRILL IN PROGRESS - PLEASE EVACUATE 🚨",
    "type": "emergency"
  }'

echo -e "\n\nAlert triggered! Check the dashboard."
