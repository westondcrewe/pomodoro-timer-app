// MongoDB initialization script
// This script runs when the MongoDB container starts for the first time

db = db.getSiblingDB('mongo-pomodoro-app');

// Create collections with validation
db.createCollection('users', {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["username", "password"],
      properties: {
        username: {
          bsonType: "string",
          description: "must be a string and is required"
        },
        password: {
          bsonType: "string",
          description: "must be a string and is required"
        }
      }
    }
  }
});

db.createCollection('pomodorosessions', {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "startTime", "duration", "mode"],
      properties: {
        userId: {
          bsonType: "objectId",
          description: "must be an objectId and is required"
        },
        startTime: {
          bsonType: "date",
          description: "must be a date and is required"
        },
        duration: {
          bsonType: "int",
          minimum: 0,
          description: "must be a positive integer and is required"
        },
        mode: {
          enum: ["work", "break", "longBreak"],
          description: "must be one of the enum values and is required"
        }
      }
    }
  }
});

db.createCollection('userstats', {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId"],
      properties: {
        userId: {
          bsonType: "objectId",
          description: "must be an objectId and is required"
        }
      }
    }
  }
});

// Create indexes for better performance
db.users.createIndex({ "username": 1 }, { unique: true });
db.pomodorosessions.createIndex({ "userId": 1, "startTime": -1 });
db.pomodorosessions.createIndex({ "startTime": -1 });
db.userstats.createIndex({ "userId": 1 }, { unique: true });

print('MongoDB initialization completed successfully!'); 