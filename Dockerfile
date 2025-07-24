FROM node:20
WORKDIR /app
COPY package* .
RUN npm install
COPY . .
ENTRYPOINT npm start

# Comando: sudo docker built -t adopet-front:1.0 .
# docker images
# docker run -d -p 80:3000 adopet-front:1.0
# docker ps -a
