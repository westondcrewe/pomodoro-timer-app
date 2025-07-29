#!/bin/bash

# Database Viewer Script for Pomodoro Timer App
# Shows all collections and their content in a readable format

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo -e "${BLUE}🗄️  Pomodoro Timer Database Viewer${NC}"
echo "Connecting to MongoDB..."

# Create a temporary JavaScript file for MongoDB commands
cat > /tmp/view_db.js << 'EOF'
// Database viewer script
print("=== POMODORO TIMER DATABASE CONTENT ===\n");

// Switch to the pomodoro database
use mongo-pomodoro-app;

// Show all collections
print("📋 COLLECTIONS IN DATABASE:");
db.getCollectionNames().forEach(function(collection) {
    print("  - " + collection);
});

print("\n" + "=".repeat(50) + "\n");

// Show users collection
print("👥 USERS COLLECTION:");
print("Total users: " + db.users.countDocuments());
if (db.users.countDocuments() > 0) {
    print("\nUser documents:");
    db.users.find().forEach(function(user) {
        print("  User ID: " + user._id);
        print("  Username: " + user.username);
        print("  Created: " + user.createdAt);
        print("  Last Login: " + user.lastLogin);
        print("  ---");
    });
} else {
    print("  No users found");
}

print("\n" + "=".repeat(50) + "\n");

// Show pomodoro sessions collection
print("⏱️  POMODORO SESSIONS COLLECTION:");
print("Total sessions: " + db.pomodorosessions.countDocuments());
if (db.pomodorosessions.countDocuments() > 0) {
    print("\nSession documents:");
    db.pomodorosessions.find().forEach(function(session) {
        print("  Session ID: " + session._id);
        print("  User ID: " + session.userId);
        print("  Mode: " + session.mode);
        print("  Duration: " + session.duration + " seconds");
        print("  Start Time: " + session.startTime);
        print("  Completed: " + session.completed);
        print("  Rounds: " + session.rounds);
        if (session.notes) {
            print("  Notes: " + session.notes);
        }
        print("  ---");
    });
} else {
    print("  No sessions found");
}

print("\n" + "=".repeat(50) + "\n");

// Show user stats collection
print("📊 USER STATISTICS COLLECTION:");
print("Total user stats: " + db.userstats.countDocuments());
if (db.userstats.countDocuments() > 0) {
    print("\nUser statistics:");
    db.userstats.find().forEach(function(stats) {
        print("  User ID: " + stats.userId);
        print("  Total Work Sessions: " + stats.totalWorkSessions);
        print("  Total Work Time: " + stats.totalWorkTime + " seconds");
        print("  Total Break Time: " + stats.totalBreakTime + " seconds");
        print("  Total Long Break Time: " + stats.totalLongBreakTime + " seconds");
        print("  Total Rounds: " + stats.totalRounds);
        print("  Average Session Length: " + stats.averageSessionLength + " seconds");
        print("  Longest Streak: " + stats.longestStreak + " days");
        print("  Current Streak: " + stats.currentStreak + " days");
        print("  Last Active: " + stats.lastActiveDate);
        print("  ---");
    });
} else {
    print("  No user statistics found");
}

print("\n" + "=".repeat(50) + "\n");

// Show database stats
print("📈 DATABASE STATISTICS:");
print("Database: " + db.getName());
print("Total collections: " + db.getCollectionNames().length);

// Show collection sizes
db.getCollectionNames().forEach(function(collection) {
    var stats = db.getCollection(collection).stats();
    print("  " + collection + ": " + stats.count + " documents, " + 
          Math.round(stats.size / 1024) + " KB");
});

print("\n=== END OF DATABASE CONTENT ===");
EOF

# Execute the MongoDB script
docker compose exec mongodb mongosh --authenticationDatabase admin -u mongo_admin -p mangomongobangobongo --quiet < /tmp/view_db.js

# Clean up temporary file
rm /tmp/view_db.js

print_success "Database content displayed successfully!"
print_info "To view specific collections, you can run:"
print_info "  docker compose exec mongodb mongosh --authenticationDatabase admin -u mongo_admin -p mangomongobangobongo"
print_info "Then use commands like:"
print_info "  use mongo-pomodoro-app"
print_info "  db.users.find().pretty()"
print_info "  db.pomodorosessions.find().pretty()"
print_info "  db.userstats.find().pretty()" 