FROM node:12 as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:1.17 as production-stage
COPY ./nginx-prod.conf /temp/prod.conf
RUN envsubst /app < /temp/prod.conf > /etc/nginx/conf.d/default.conf
COPY --from=build-stage /app/dist /usr/share/nginx/html
RUN chmod +x /usr/share/nginx/html/settings/create_settings.sh
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
EXPOSE 80
CMD ["sh", "-c", "/usr/share/nginx/html/settings/create_settings.sh; rm /usr/share/nginx/html/settings/create_settings.sh; nginx"]
# CMD ["nginx", "-g", "daemon off;"]