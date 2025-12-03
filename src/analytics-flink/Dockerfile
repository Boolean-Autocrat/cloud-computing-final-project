FROM maven:3.8.4-openjdk-11

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn clean package

CMD ["java", "-jar", "target/analytics-flink-1.0-SNAPSHOT.jar"]
