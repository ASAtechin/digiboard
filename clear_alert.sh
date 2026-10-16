#!/bin/bash

# Clear the alert
curl -X POST http://localhost:5000/api/notification \
  -H "Content-Type: application/json" \
  -d '{
    "active": false
  }'

echo -e "\n\nAlert cleared!"
