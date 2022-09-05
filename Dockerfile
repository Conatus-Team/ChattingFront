# Base image
FROM node:16.17-alpine
 

# 실행 폴더
RUN mkdir /app
WORKDIR /app

# package.json/ package.lock.json 설치
COPY ./package*.json ./

# serve 다운
RUN npm install -g serve


COPY ./ ./
RUN npm install
RUN npm run build 


# 실행
ENTRYPOINT ["serve", "-s", "dist"]
# ENTRYPOINT ["npm", "run", "serve"]