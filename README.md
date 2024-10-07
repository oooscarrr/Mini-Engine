[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/pLRyr-9g)

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
docker run -d -p 5001:5001 $DOCKER_USER_ID/se-server
```

### Pushing the container
```sh
docker push $DOCKER_USER_ID/se-server
```

# SE-Frontend

This template should help get you started developing with Vue 3 in Vite.

## Recommended IDE Setup

[VSCode](https://code.visualstudio.com/) + [Volar](https://marketplace.visualstudio.com/items?itemName=Vue.volar) (and disable Vetur).

## Customize configuration

See [Vite Configuration Reference](https://vitejs.dev/config/).

## Project Setup

```sh
npm install
```

### Compile and Hot-Reload for Development

```sh
npm run dev
```

### Compile and Minify for Production

```sh
npm run build
```

## Dockerize the Application

### Building the Container
```sh
docker buildx build --platform linux/amd64 -f Dockerfile -t $DOCKER_USER_ID/se-frontend .
```

### Running the Container
```sh
docker run -p 3000:3000 $DOCKER_USER_ID/se-frontend
```

### Pushing the container
```sh
docker push $DOCKER_USER_ID/se-frontend
```