#!/bin/bash

# Trigger a general info notification (Global)
curl -X POST http://localhost:5000/api/notification \
  -H "Content-Type: application/json" \
  -d '{
    "active": true,
    "message": "Don'\''t forget to submit your project reports by Friday!",
    "type": "info"
  }'

echo -e "\n\nInfo Notification triggered! Check the dashboard."
