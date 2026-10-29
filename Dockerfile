# ---------- Compilation du  projet ----------
FROM eclipse-temurin:21-jdk AS build
WORKDIR /ndaje

COPY mvnw pom.xml ./
COPY .mvn ./.mvn
RUN chmod +x mvnw && ./mvnw dependency:go-offline

COPY src ./src
RUN ./mvnw package -DskipTests

# ---------- execution  ----------
FROM eclipse-temurin:21-jre AS runtime
WORKDIR /ndaje

# User sans droits d'administration
RUN groupadd --system ndaje && useradd --system --gid ndaje ndaje

COPY --from=build /ndaje/target/*.jar app.jar

USER ndaje
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]