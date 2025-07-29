#!/bin/bash

# Simple Database Viewer Script for Pomodoro Timer App

echo "🗄️  Pomodoro Timer Database Viewer"
echo "=================================="

echo -e "\n📋 Checking collections..."
docker compose exec mongodb mongosh --authenticationDatabase admin -u mongo_admin -p mangomongobangobongo --quiet --eval "
use mongo-pomodoro-app;
print('Collections:');
db.getCollectionNames().forEach(function(c) { print('  - ' + c); });
"

echo -e "\n👥 Users:"
docker compose exec mongodb mongosh --authenticationDatabase admin -u mongo_admin -p mangomongobangobongo --quiet --eval "
use mongo-pomodoro-app;
print('Total users: ' + db.users.countDocuments());
if (db.users.countDocuments() > 0) {
    db.users.find().forEach(function(u) {
        print('  User: ' + u.username + ' (ID: ' + u._id + ')');
    });
}
"

echo -e "\n⏱️  Sessions:"
docker compose exec mongodb mongosh --authenticationDatabase admin -u mongo_admin -p mangomongobangobongo --quiet --eval "
use mongo-pomodoro-app;
print('Total sessions: ' + db.pomodorosessions.countDocuments());
if (db.pomodorosessions.countDocuments() > 0) {
    db.pomodorosessions.find().forEach(function(s) {
        print('  Session: ' + s.mode + ' - ' + s.duration + 's - Completed: ' + s.completed);
    });
}
"

echo -e "\n📊 User Stats:"
docker compose exec mongodb mongosh --authenticationDatabase admin -u mongo_admin -p mangomongobangobongo --quiet --eval "
use mongo-pomodoro-app;
print('Total user stats: ' + db.userstats.countDocuments());
if (db.userstats.countDocuments() > 0) {
    db.userstats.find().forEach(function(s) {
        print('  User: ' + s.userId + ' - Work sessions: ' + s.totalWorkSessions + ' - Total time: ' + s.totalWorkTime + 's');
    });
}
"

echo -e "\n✅ Database content displayed!" 