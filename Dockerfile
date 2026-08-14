# Stage 1: Build with Maven
FROM maven:3.9.6-openjdk-21 AS builder
WORKDIR /app
COPY ./src ./src
COPY ./pom.xml .
RUN mvn package -DskipTests

# Stage 2: Create the final image
FROM openjdk:21-jdk-alpine
ARG JAR_FILE=/app/target/app.jar
COPY --from=builder ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
