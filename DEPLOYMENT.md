# Pomodoro Timer App - Deployment Guide

## Prerequisites
- Docker and Docker Compose installed
- Git (to clone the repository)

## Quick Start

### 1. Clone and Navigate
```bash
git clone <your-repo-url>
cd pomodoro-timer-app
```

### 2. Build and Run
```bash
# Build and start all services
docker-compose up --build

# Or run in detached mode
docker-compose up -d --build
```

### 3. Access the Application
- **Frontend**: http://localhost
- **Backend API**: http://localhost:5000
- **MongoDB**: localhost:27017

## Environment Variables

### For Production
Create a `.env` file in the root directory:
```env
# MongoDB
MONGO_INITDB_ROOT_USERNAME=your_admin_username
MONGO_INITDB_ROOT_PASSWORD=your_secure_password

# Backend
JWT_SECRET=your_super_secret_jwt_key_here
NODE_ENV=production

# Frontend
REACT_APP_API_URL=https://your-domain.com/api
```

## Docker Commands

### Development
```bash
# Start all services
docker-compose up

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

### Production
```bash
# Build and start in production mode
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Scale services
docker-compose up -d --scale backend=3

# Update services
docker-compose pull
docker-compose up -d
```

### Maintenance
```bash
# View running containers
docker-compose ps

# Access container shell
docker-compose exec backend sh
docker-compose exec mongodb mongosh

# Backup database
docker-compose exec mongodb mongodump --out /backup

# Restore database
docker-compose exec mongodb mongorestore /backup
```

## Deployment Platforms

### AWS ECS
1. Push images to Amazon ECR
2. Create ECS cluster and services
3. Use Application Load Balancer

### Google Cloud Run
1. Build and push to Google Container Registry
2. Deploy using Cloud Run
3. Set up Cloud SQL for MongoDB

### DigitalOcean App Platform
1. Connect GitHub repository
2. Configure build settings
3. Set environment variables

### Heroku
1. Add Heroku container registry
2. Push images to Heroku
3. Use Heroku Postgres or MongoDB Atlas

## Monitoring and Logs

### View Logs
```bash
# All services
docker-compose logs

# Specific service
docker-compose logs backend

# Follow logs
docker-compose logs -f frontend
```

### Health Checks
- Backend: http://localhost:5000/health
- Frontend: http://localhost
- MongoDB: Check container status

## Security Considerations

1. **Change default passwords** in production
2. **Use HTTPS** in production
3. **Set up proper firewall rules**
4. **Regular security updates**
5. **Backup strategy** for database

## Troubleshooting

### Common Issues
1. **Port conflicts**: Change ports in docker-compose.yml
2. **Memory issues**: Increase Docker memory allocation
3. **Database connection**: Check MongoDB credentials
4. **Build failures**: Clear Docker cache with `docker system prune`

### Debug Commands
```bash
# Check container status
docker-compose ps

# View container logs
docker-compose logs [service-name]

# Access container
docker-compose exec [service-name] sh

# Check network connectivity
docker-compose exec backend ping mongodb
``` 