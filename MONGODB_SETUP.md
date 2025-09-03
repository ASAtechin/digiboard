# MongoDB Setup Instructions

Since MongoDB installation can vary by system, here are different options to set up MongoDB for the DigiBoard project:

## Option 1: Docker (Recommended)

```bash
# Pull and run MongoDB in Docker
docker run -d -p 27017:27017 --name digiboard-mongo mongo:5.0

# Stop the container when done
docker stop digiboard-mongo

# Start it again
docker start digiboard-mongo
```

## Option 2: MongoDB Atlas (Cloud)

1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create a free account and cluster
3. Get your connection string
4. Update the `MONGODB_URI` in the `.env` file:
   ```
   MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/digiboard
   ```

## Option 3: Ubuntu/Debian Installation

```bash
# Import MongoDB public GPG key
wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -

# Add MongoDB repository
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list

# Update package list and install
sudo apt update
sudo apt install -y mongodb-org

# Start MongoDB service
sudo systemctl start mongod
sudo systemctl enable mongod
```

## Option 4: macOS with Homebrew

```bash
# Install MongoDB Community Edition
brew tap mongodb/brew
brew install mongodb-community@5.0

# Start MongoDB service
brew services start mongodb/brew/mongodb-community@5.0
```

## Option 5: Windows

1. Download MongoDB Community Server from the [official website](https://www.mongodb.com/try/download/community)
2. Run the installer with default settings
3. MongoDB will start automatically as a Windows service

## Verification

After installation, verify MongoDB is running:

```bash
# Check if MongoDB is running
mongo --eval "db.runCommand({ connectionStatus: 1 })"

# Or try connecting with mongosh (newer versions)
mongosh --eval "db.runCommand({ connectionStatus: 1 })"
```

## Environment Configuration

Make sure your `.env` file in the backend directory contains:

```
MONGODB_URI=mongodb://localhost:27017/digiboard
PORT=5000
NODE_ENV=development
```

For cloud MongoDB (Atlas), use your connection string:
```
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/digiboard
```

## Troubleshooting

- **Connection refused**: Make sure MongoDB service is running
- **Authentication failed**: Check username/password in Atlas connection string
- **Port conflicts**: MongoDB default port is 27017, ensure it's not in use by other services

Once MongoDB is set up and running, you can seed the database with sample data:

```bash
npm run seed
```
