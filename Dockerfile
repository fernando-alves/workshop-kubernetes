FROM node:8-alpine

WORKDIR /app

RUN chown node:node /app

USER node

COPY . /app

RUN npm install

RUN npm run assets

CMD npm start