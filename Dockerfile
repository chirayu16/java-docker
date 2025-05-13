# Stage 1: Build the application
FROM eclipse-temurin:17-jdk-alpine as builder
WORKDIR /app

# Copy the Maven wrapper and pom.xml first to cache dependencies
# Assuming you have the Maven wrapper (mvnw, .mvn directory)
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Download dependencies
RUN ./mvnw dependency:go-offline -B

# Copy the rest of the source code
COPY src ./src

# Build the project
# This will run tests by default. If you want to skip tests during Docker build, add -DskipTests
RUN ./mvnw clean package

# Stage 2: Run the application
FROM eclipse-temurin:17-jre-alpine
 # Use a smaller JRE image
WORKDIR /app

# Copy the built JAR from the builder stage
# Assuming the executable JAR is in target/ and its name follows standard Maven conventions
# You might need to adjust the JAR name pattern if it's different
COPY --from=builder /app/target/*.jar /app/app.jar

# Command to run the application
# The JAR should be executable and contain your main class
ENTRYPOINT ["java", "-jar", "app.jar"]
# If your app just has a main method in a class, you might use:
# CMD ["java", "-cp", "/app/app.jar", "com.yourcompany.YourMainClass"] # Replace with your package and class
