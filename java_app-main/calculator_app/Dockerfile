FROM maven AS build
WORKDIR /app
COPY . /app
RUN mvn clean package
FROM tomcat
COPY --from=build /app/target/calculator.war /usr/local/tomcat/webapps/calculator.war

#RUN rm -rf $CATALINA_HOME/webapps/ROOT
#COPY target/calculator.war $CATALINA_HOME/webapps/ROOT.war
