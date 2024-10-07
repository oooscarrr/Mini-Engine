# SE-Server

## Project Setup
```sh
pip install -r requirements.txt
```

## Compile and Hot-Reload for Development
```sh
flask run --port=5001
```

## Dockerize the Application

### Building the Container
```sh
docker buildx build --platform linux/amd64 -f Dockerfile -t $DOCKER_USER_ID/se-server .
```

### Running the Container
```sh
docker run -p 3000:3000 $DOCKER_USER_ID/se-server
```

### Pushing the container
```sh
docker run -d -p 5001:5001 $DOCKER_USER_ID/se-server
```