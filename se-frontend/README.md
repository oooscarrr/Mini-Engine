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
docker run -p 3000:3000 $DOCKER_USER_ID/se-frontend
```