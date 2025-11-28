
# build environment
FROM node:16-alpine as build
WORKDIR /app
COPY package.json ./
COPY server.js ./
COPY client/package.json ./client/
RUN npm install
COPY client/ ./client
RUN npm run build

# production environment
FROM node:16-alpine
WORKDIR /app
COPY --from=build /app/client/build ./client/build
COPY --from=build /app/server.js ./
COPY --from=build /app/package.json ./
RUN npm install --omit=dev
EXPOSE 3000
CMD ["npm", "start"]
