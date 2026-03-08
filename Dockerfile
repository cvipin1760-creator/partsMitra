FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace
# Copy server sources
COPY backend/pom.xml /workspace/pom.xml
COPY backend/src /workspace/src
# Build (skip tests for faster CI)
RUN mvn -q -DskipTests -f /workspace/pom.xml package

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /workspace/target/inventory-system-0.0.1-SNAPSHOT.jar /app/app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
