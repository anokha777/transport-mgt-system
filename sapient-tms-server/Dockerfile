FROM node:11.3

RUN mkdir /usr/lib/app -p
WORKDIR /usr/lib/app

COPY package.json .
COPY package-lock.json .
RUN npm install --production
COPY . .

EXPOSE 5000
# CMD ["npm", "start", "--production"]
CMD ["npm", "run", "dev"]
