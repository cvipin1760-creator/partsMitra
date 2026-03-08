Build:
1. mvn -q -DskipTests package
2. Docker builds from target/spares-hub-server-0.0.1-SNAPSHOT.jar

Render:
- Create a new Web Service from repo root using render.yaml
- Set DATABASE_URL to postgres connection string

Railway:
- Create a new PostgreSQL plugin and note the connection string
- Create a New Service from Dockerfile
- Set DATABASE_URL env var to the postgres connection string

Env:
- DATABASE_URL or SPRING_DATASOURCE_URL/USERNAME/PASSWORD

Base URL:
- http(s)://<host>/api
