#!/bin/bash

echo "🗄️  Quick Database Viewer"
echo "========================"

echo -e "\n📋 Collections:"
docker compose exec mongodb mongosh --authenticationDatabase admin -u mongo_admin -p mangomongobangobongo --quiet --eval "use mongo-pomodoro-app; db.getCollectionNames();"

echo -e "\n👥 Users count:"
docker compose exec mongodb mongosh --authenticationDatabase admin -u mongo_admin -p mangomongobangobongo --quiet --eval "use mongo-pomodoro-app; db.users.countDocuments();"

echo -e "\n⏱️  Sessions count:"
docker compose exec mongodb mongosh --authenticationDatabase admin -u mongo_admin -p mangomongobangobongo --quiet --eval "use mongo-pomodoro-app; db.pomodorosessions.countDocuments();"

echo -e "\n📊 Stats count:"
docker compose exec mongodb mongosh --authenticationDatabase admin -u mongo_admin -p mangomongobangobongo --quiet --eval "use mongo-pomodoro-app; db.userstats.countDocuments();"

echo -e "\n🔍 To see detailed content, run:"
echo "docker compose exec mongodb mongosh --authenticationDatabase admin -u mongo_admin -p mangomongobangobongo"
echo ""
echo "Then use these commands:"
echo "  use mongo-pomodoro-app"
echo "  db.users.find().pretty()"
echo "  db.pomodorosessions.find().pretty()"
echo "  db.userstats.find().pretty()"
echo ""
echo "🧪 To add test data, run:"
echo "  ./test-api.sh" 